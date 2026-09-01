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
  $'[initial_session]\ncommand = "($command)"\nuser = "($session_user)"\n\n[terminal]\nvt = (($tty | path basename | str replace \'tty\' \'\'))\n' | save --force $config
  chmod 600 $config
  systemctl stop greetd.service
  ^/run/current-system/sw/bin/greetd --config $config
}
