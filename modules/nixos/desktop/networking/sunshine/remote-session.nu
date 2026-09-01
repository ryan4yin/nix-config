#!/usr/bin/env nu

def main [
  --user (-u): string = 'ryan'
  --tty (-t): string = '/dev/tty1'
  --command (-c): string = ''
  --force (-f)
] {
  let session_user = ($env.SUDO_USER? | default $user)
  let user_machine = $'($session_user)@.host'
  let old_niri = (^systemctl --machine $user_machine --user is-active niri.service | complete).stdout | str trim
  let old_niri_process = ((^pgrep -u $session_user -x niri | complete).exit_code) == 0
  if ($old_niri == 'active' or $old_niri_process) and not $force {
    let answer = (input 'Niri is already running. Terminate it and start a remote session? [y/N] ')
    if ($answer | str downcase) != 'y' {
      print 'Aborted.'
      return
    }
  }
  if $old_niri == 'active' {
    ^systemctl --machine $user_machine --user stop niri.service
  }
  if $old_niri_process {
    ^pkill -TERM -u $session_user -x niri
  }
  let home = (getent passwd $session_user | split row ':' | get 5)
  # niri-session starts niri.service through the user manager. Run the
  # compositor directly so greetd owns this temporary session.
  let command = if $command == '' { '/run/current-system/sw/bin/niri --session' } else { $command }
  let command_binary = ($command | split row ' ' | first)
  if not ($command_binary | path exists) {
    error make { msg: $'Wayland session command not found: ($command_binary)' }
  }

  let config = (mktemp --tmpdir-path /run greetd-sunshine.XXXXXX.toml)
  let tuigreet = (which tuigreet | get path | first)
  let greetd_config = {
    general: { runfile: $'($config).run' }
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
  job spawn {
    # Sunshine waits for the Wayland socket in its pre-start hook.
    ^systemctl --machine $user_machine --user start sunshine.service
  }
  (^systemd-run
    --unit greetd-sunshine
    --collect
    --property $'TTYPath=($tty)'
    --property StandardInput=tty
    --property StandardOutput=tty
    --property StandardError=journal
    --
    $greetd
    --config $config)

  mut ready = false
  for _ in 1..30 {
    let greetd_active = ((^systemctl is-active greetd-sunshine.service | complete).stdout | str trim) == 'active'
    let niri_active = ((^pgrep -u $session_user -x niri | complete).exit_code) == 0
    let sunshine_active = ((^systemctl --machine $user_machine --user is-active sunshine.service | complete).stdout | str trim) == 'active'
    if $greetd_active and $niri_active and $sunshine_active {
      $ready = true
      break
    }
    sleep 1sec
  }
  if not $ready {
    error make { msg: 'Remote session did not become ready within 30 seconds; inspect journalctl -u greetd-sunshine.service' }
  }
  print 'Remote Niri and Sunshine session is ready.'
}
