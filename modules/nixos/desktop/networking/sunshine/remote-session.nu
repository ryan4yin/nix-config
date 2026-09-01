#!/usr/bin/env nu

def user-machine [user: string] {
  $'($user)@.host'
}

def niri-running [user: string, machine: string] {
  let service = ((^systemctl --machine $machine --user is-active niri.service | complete).stdout | str trim) == 'active'
  let process = ((^pgrep -u $user -x niri | complete).exit_code) == 0
  $service or $process
}

def stop-niri [user: string, machine: string] {
  ^systemctl --machine $machine --user stop niri.service
  ^pkill -TERM -u $user -x niri
}

def confirm-replacement [] {
  (input 'Niri is already running. Terminate it and start a remote session? [y/N] '
    | str downcase) == 'y'
}

def write-greetd-config [path: string, user: string, tty: string, command: string, tuigreet: string] {
  {
    general: { runfile: $'($path).run' }
    initial_session: { command: $command, user: $user }
    default_session: { command: $'($tuigreet) --time --cmd ($command)', user: $user }
    terminal: { vt: ($tty | path basename | str replace 'tty' '') }
  } | to toml | save --force $path
  chmod 600 $path
}

def wait-ready [user: string, machine: string] {
  for _ in 1..30 {
    let greetd = ((^systemctl is-active greetd-sunshine.service | complete).stdout | str trim) == 'active'
    let niri = ((^pgrep -u $user -x niri | complete).exit_code) == 0
    let sunshine = ((^systemctl --machine $machine --user is-active sunshine.service | complete).stdout | str trim) == 'active'
    if $greetd and $niri and $sunshine { return }
    sleep 1sec
  }
  error make { msg: 'Remote session did not become ready within 30 seconds; inspect journalctl -u greetd-sunshine.service' }
}

def main [
  --user (-u): string = 'ryan'
  --tty (-t): string = '/dev/tty1'
  --command (-c): string = ''
  --force (-f)
] {
  let session_user = ($env.SUDO_USER? | default $user)
  let user_machine = (user-machine $session_user)
  if (niri-running $session_user $user_machine) {
    if not $force and not (confirm-replacement) {
      print 'Aborted.'
      return
    }
    stop-niri $session_user $user_machine
  }
  # niri-session starts niri.service through the user manager. Run the
  # compositor directly so greetd owns this temporary session.
  let command = if $command == '' { '/run/current-system/sw/bin/niri --session' } else { $command }
  let command_binary = ($command | split row ' ' | first)
  if not ($command_binary | path exists) {
    error make { msg: $'Wayland session command not found: ($command_binary)' }
  }

  let config = (mktemp --tmpdir-path /run greetd-sunshine.XXXXXX.toml)
  let tuigreet = (which tuigreet | get path | first)
  write-greetd-config $config $session_user $tty $command $tuigreet
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

  wait-ready $session_user $user_machine
  print 'Remote Niri and Sunshine session is ready.'
}
