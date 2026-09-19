#!/usr/bin/env bash

set -uo pipefail

# Default services to check when no arguments are provided.
DEFAULT_SERVICES=(
    nginx
    httpd
    sshd
    mariadb
    redis
)

# Return a status for one systemd service.
check_service() {
    local service="$1"

    # Validate the service name before passing it to systemctl.
    # This avoids accepting arbitrary command-line fragments.
    if [[ ! "$service" =~ ^[a-zA-Z0-9_.@:-]+$ ]]; then
        printf '%s|%s|%s\n' "$service" "INVALID" "3"
        return
    fi

    # Check whether the service exists.
    if ! systemctl cat "$service" >/dev/null 2>&1; then
        printf '%s|%s|%s\n' "$service" "NOT_FOUND" "2"
        return
    fi

    local state
    state="$(systemctl is-active "$service" 2>/dev/null || true)"

    case "$state" in
        active)
            printf '%s|%s|%s\n' "$service" "RUNNING" "0"
            ;;
        inactive)
            printf '%s|%s|%s\n' "$service" "STOPPED" "1"
            ;;
        failed)
            printf '%s|%s|%s\n' "$service" "FAILED" "1"
            ;;
        *)
            printf '%s|%s|%s\n' "$service" "${state:-UNKNOWN}" "1"
            ;;
    esac
}

# Use supplied service names or the default list.
if [[ "$#" -gt 0 ]]; then
    SERVICES=("$@")
else
    SERVICES=("${DEFAULT_SERVICES[@]}")
fi

printf 'SERVICE|STATUS|EXIT_CODE\n'

overall_exit=0

for service in "${SERVICES[@]}"; do
    result="$(check_service "$service")"
    printf '%s\n' "$result"

    code="${result##*|}"

    # Preserve the most significant failure status.
    if [[ "$code" -eq 3 ]]; then
        overall_exit=3
    elif [[ "$code" -eq 1 && "$overall_exit" -ne 3 ]]; then
        overall_exit=1
    elif [[ "$code" -eq 2 && "$overall_exit" -eq 0 ]]; then
        overall_exit=2
    fi
done

exit "$overall_exit"
