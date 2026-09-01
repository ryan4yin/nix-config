#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 && ${1:-} != -h ]]; then
  exec sudo "$0" "$@"
fi

session_user=${SUDO_USER:-ryan}
session_home=$(getent passwd "$session_user" | cut -d: -f6)
tty_path=/dev/tty1
session_command="$session_home/.wayland-session"

usage() {
  printf 'Usage: %s [-u user] [-t tty] [-c command]\n' "$0"
}

while getopts ':u:t:c:h' option; do
  case "$option" in
    u) session_user=$OPTARG; session_home=$(getent passwd "$session_user" | cut -d: -f6); session_command="$session_home/.wayland-session" ;;
    t) tty_path=$OPTARG ;;
    c) session_command=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

if [[ -z ${session_home:-} || ! -x $session_command ]]; then
  printf 'Wayland session command does not exist or is not executable: %s\n' "$session_command" >&2
  exit 1
fi

config_file=$(mktemp /run/greetd-sunshine.XXXXXX.toml)
trap 'rm -f "$config_file"' EXIT
chmod 600 "$config_file"
cat >"$config_file" <<EOF
[initial_session]
command = "$session_command"
user = "$session_user"

[terminal]
vt = ${tty_path#/dev/tty}
EOF

systemctl stop greetd.service
exec /run/current-system/sw/bin/greetd --config "$config_file"
