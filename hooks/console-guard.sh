#!/usr/bin/env bash
# Claude Code PreToolUse(Bash) hook: SIEM/EDR consoles may only be reached through the
# read-only `roq` gate (audited). Blocks any command that names a console host together
# with something that can make a network request.
# Set ROQ_PROTECTED_HOSTS to a regex of your console hostnames.
cmd=$(jq -r '.tool_input.command // ""')
hosts="${ROQ_PROTECTED_HOSTS:-example\.com|example-edr\.net}"
net='(^|[^a-z])(curl|wget|http|https|python[0-9.]*|perl|ruby|node|nc|ncat|socat|openssl|telnet|xh|httpie|aria2c|lynx|bws)([^a-z]|$)'
if grep -qiE "$hosts" <<<"$cmd" && grep -qiE "$net" <<<"$cmd"; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",
    permissionDecisionReason:"Consoles may only be queried through the read-only gate: roq <target> GET|POST <path>. Use a roq target name instead of the hostname."}}'
fi
exit 0
