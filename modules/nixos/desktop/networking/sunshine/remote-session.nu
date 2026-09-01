#!/usr/bin/env nu

def main [
  --user (-u): string = 'ryan'
  --tty (-t): string = '/dev/tty1'
  --command (-c): string = ''
] {
  let session_user = ($env.SUDO_USER? | default $user)
  let home = (getent passwd $session_user | split row ':' | get 5)
  let command = if $command == '' { $'($home)/.wayland-session' } else { $command }
  if not ($command | path exists) {
    error make { msg: $'Wayland session command not found: ($command)' }
  }

  let config = (mktemp --tmpdir-path /run greetd-sunshine.XXXXXX.toml)
  let tuigreet = (which tuigreet | get path | first)
  let greetd_config = {
    initial_session: { command: $command, user: $session_user }
    default_session: { command: $'($tuigreet) --time --cmd ($command)', user: $session_user }
    terminal: { vt: ($tty | path basename | str replace 'tty' '') }
  }
  $greetd_config | to toml | save --force $config
  chmod 600 $config
  systemctl stop greetd.service
  let greetd = (systemctl show greetd.service -p ExecStart --value
    | parse --regex 'path=(?<path>[^ ;]+)'
    | get path
    | first)
  ^systemd-run --unit greetd-sunshine --collect --wait --property $'TTYPath=($tty)' --property StandardInput=tty --property StandardOutput=tty --property StandardError=journal -- $greetd --config $config
}
