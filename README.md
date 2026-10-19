# Agent Console Guardrails

Guardrails for letting an AI coding agent (Claude Code, or any agent with a shell tool) work against **live SIEM and EDR consoles** without being able to change anything, leak credentials, or be steered by poisoned instructions.

I built these to use an AI agent for threat hunting on real security data. The question behind them: *what has to be true before an agent can safely touch production security tooling?*

## The three layers

```
 agent wants data ──► roq (read-only gate) ──► Elasticsearch / Kibana / SentinelOne
        │                 ▲ refuses writes, credential endpoints, bad queries; audit-logs everything
        │
        ├── console-guard.sh (PreToolUse hook): blocks curl/python/etc. aimed at a console host,
        │                                       so the agent can't go around roq
        │
        └── skills (method library): lint step quarantines skills with injected instructions
                                     before the agent can ever load them
```

### 1. `roq`: a read-only query gate
A single-file Python CLI (standard library only) that is the agent's **only** route to the consoles.

- **Read-only by construction:** allows GET, plus POST only to search endpoints (ES `_search`, `_count`, `_eql/search`, `_query`, `_sql`, Kibana signals search, SentinelOne PowerQuery). Everything else is refused.
- **Credentials never enter the model's context:** keys come from Bitwarden Secrets Manager via `bws run` at request time. They're never printed, and error messages are suppressed where an HTTP library might echo headers. The gate also refuses endpoints that return credential material.
- **Catches queries that fail silently:** a time window ending in the future, PowerQuery `NOT expr` (silently returns 0 rows), unsupported operators, `contains '10.'` matching public IPs, unpinned multi-tenant queries, oversized pages.
- **Full audit log:** every request, allowed or refused, goes to `~/.local/state/roq/audit.jsonl` (the key is never logged).

```bash
cp targets.example.json targets.json      # your hosts, secret names, kinds
./roq targets
./roq siem-es POST /logs-*/_search --data query.json --dry-run
./roq siem-es DELETE /logs-*              # roq: REFUSED: method DELETE is never allowed
```

### 2. `hooks/console-guard.sh`: no going around the gate
A Claude Code `PreToolUse` hook for the Bash tool. If a command names a protected console host **and** a network-capable tool (curl, wget, python, node, nc, openssl…), it's denied with a message pointing back to `roq`. Set `ROQ_PROTECTED_HOSTS` to a regex of your console hostnames.

### 3. `skill-library/`: method skills with a quarantine
Installing many agent skills costs context on every turn, so only a tiny "router" skill is installed. It tells the agent to **search** this library and load just the one skill it needs.

Skills are instructions to the model, which makes them a prompt-injection surface (especially ones borrowed from other repos). `skills lint` scans every skill for:
- injection phrasing ("ignore previous instructions")
- download-and-run (`curl | sh`, `IEX`)
- touching secrets or keys
- requests to disable a safeguard
- "don't tell the user"
- sending data to URLs, links outside an allowlist

A skill with a hit is **quarantined**: search won't return it and `show` refuses it. Only a human can clear it, and the agent can't write the override flag.

```bash
cd skill-library
python3 bin/skills new security detecting-kerberoasting
python3 bin/skills lint
python3 bin/skills search kerberoasting elastic
python3 bin/skills --root tests/fixtures test      # router test cases (22)
```

## Status and limits

- Built for and used in a real SOC workflow. The examples here are generalised and contain no client data.
- The host-matching hook is a tripwire, not a sandbox: a determined agent could still obfuscate a hostname. The real boundary is that the agent never holds a key and `roq` is the only thing that does.
- The hygiene patterns are heuristics, so expect some false positives on offensive-security skills.

## License

MIT
