#!/usr/bin/env nu

def user-machine [user: string] {
  $'($user)@.host'
}

def niri-source [user: string] {
  let process = (^pgrep -o -u $user -x niri | complete)
  if $process.exit_code != 0 { return 'none' }

  let pid = ($process.stdout | str trim)
  let cgroup = (open --raw $'/proc/($pid)/cgroup')
  if ($cgroup | str contains '/greetd-sunshine.service/') { return 'remote session' }
  if ($cgroup | str contains '/niri.service') { return 'user niri.service' }
  'standalone process'
}

def stop-niri [user: string, machine: string, source: string] {
  match $source {
    'remote session' => { stop-transient-session }
    'user niri.service' => { ^systemctl --machine $machine --user stop niri.service }
    'standalone process' => { ^pkill -TERM -u $user -x niri }
  }
}

def stop-transient-session [] {
  let loaded = ((^systemctl show greetd-sunshine.service -p LoadState --value | complete).stdout | str trim)
  if $loaded == 'not-found' or $loaded == '' { return }

  ^systemctl stop greetd-sunshine.service
  let _ = (^systemctl reset-failed greetd-sunshine.service | complete)
  for _ in 1..50 {
    let state = ((^systemctl show greetd-sunshine.service -p LoadState --value | complete).stdout | str trim)
    if $state == 'not-found' or $state == '' { return }
    sleep 100ms
  }
  error make { msg: 'Previous greetd-sunshine.service was stopped but not unloaded' }
}

def confirm-replacement [source: string] {
  (input $'Niri is already running via ($source). Terminate it and start a remote session? [y/N] '
    | str lowercase) == 'y'
}

def preflight [tty: string, command: string] {
  let command_binary = ($command | split row ' ' | first)
  if not ($command_binary | path exists) {
    error make { msg: $'Wayland session command not found: ($command_binary)' }
  }
  if not ($tty | path exists) {
    error make { msg: $'TTY not found: ($tty)' }
  }

  let exec_start = (^systemctl show greetd.service -p ExecStart --value)
  let greetd = ($exec_start
    | parse --regex 'path=(?<path>[^ ;]+)'
    | get path
    | first)
  let system_config = ($exec_start
    | parse --regex '--config (?<path>[^ ;]+)'
    | get path
    | first)
  let default_session = (open $system_config | get default_session)
  { greetd: $greetd, default_session: $default_session }
}

def write-greetd-config [path: string, user: string, tty: string, command: string, default_session: record] {
  {
    general: { runfile: $'($path).run' }
    initial_session: { command: $command, user: $user }
    default_session: $default_session
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

def niri-socket [machine: string] {
  let environment = (^systemctl --machine $machine --user show-environment | complete)
  if $environment.exit_code != 0 { return '' }

  ($environment.stdout
    | lines
    | where { |line| $line starts-with 'NIRI_SOCKET=' }
    | get 0?
    | default ''
    | str replace 'NIRI_SOCKET=' '')
}

def wait-niri [user: string, machine: string] {
  for _ in 1..30 {
    let greetd = ((^systemctl is-active greetd-sunshine.service | complete).stdout | str trim) == 'active'
    let niri = ((^pgrep -u $user -x niri | complete).exit_code) == 0
    let socket = (niri-socket $machine)
    let ipc = if $socket == '' or not ($socket | path exists) {
      false
    } else {
      with-env { NIRI_SOCKET: $socket } {
        ((^niri msg outputs | complete).exit_code) == 0
      }
    }
    if $greetd and $niri and $ipc { return }
    sleep 1sec
  }
  error make { msg: 'Niri IPC did not become ready within 30 seconds; inspect journalctl -u greetd-sunshine.service' }
}

def start-sunshine [machine: string] {
  let _ = (^systemctl --machine $machine --user reset-failed sunshine.service | complete)
  ^systemctl --machine $machine --user start sunshine.service
}

def main [
  --user (-u): string = 'ryan'
  --tty (-t): string = '/dev/tty1'
  --command (-c): string = ''
  --force (-f)
  --check
] {
  let session_user = ($env.SUDO_USER? | default $user)
  let user_machine = (user-machine $session_user)
  # niri-session starts niri.service through the user manager. Run the
  # compositor directly so greetd owns this temporary session. This
  # intentionally skips xdg-desktop-autostart.target, keeping XDG autostart
  # apps such as browsers out of the remote session.
  let command = if $command == '' { '/run/current-system/sw/bin/niri --session' } else { $command }
  let runtime = (preflight $tty $command)
  if $check {
    print 'Remote session prerequisites are valid.'
    return
  }

  let source = (niri-source $session_user)
  if $source != 'none' {
    if not $force and not (confirm-replacement $source) {
      print 'Aborted.'
      return
    }
    ^systemctl --machine $user_machine --user stop sunshine.service
    stop-niri $session_user $user_machine $source
  }
  # A previous helper may have exited after Niri but left its greeter running.
  stop-transient-session

  let config = (mktemp --tmpdir-path /run greetd-sunshine.XXXXXX.toml)
  write-greetd-config $config $session_user $tty $command $runtime.default_session
  systemctl stop greetd.service
  (^systemd-run
    --unit greetd-sunshine
    --collect
    --property $'TTYPath=($tty)'
    --property StandardInput=tty
    --property StandardOutput=tty
    --property StandardError=journal
    --
    $runtime.greetd
    --config $config)

  wait-niri $session_user $user_machine
  start-sunshine $user_machine
  wait-ready $session_user $user_machine
  print 'Remote Niri and Sunshine session is ready.'
}
