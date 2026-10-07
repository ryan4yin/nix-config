#!/usr/bin/env nu
#
# Route desktop audio to the WiVRn headset, and back again.
#
# WiVRn creates its speaker (wivrn.sink) and microphone (wivrn.source) only
# while a headset is connected, so this script waits (bounded) for those nodes
# before it switches the default devices and moves the streams that are already
# playing. The previous defaults are saved under $XDG_RUNTIME_DIR, so they last
# for the login session only; WirePlumber's persisted defaults stay untouched.
#
#   just vr        start the service, then route audio to the headset
#   just vr-audio  route audio after a headset connected later
#   just vr-stop   restore the previous devices, then stop the service
#
# See hosts/idols-ai/VR.md.

# WiVRn's PipeWire node names (server/driver/wivrn_session.cpp).
const SINK = "wivrn.sink"
const SOURCE = "wivrn.source"

# 'pactl list' output for a target ("sinks", "sources", "sink-inputs", ...).
def list-devices [target: string] {
  (^pactl --format=json list $target | complete | get stdout | from json)
}

# The device called $name, or null.
def find-device [target: string, name: string] {
  let matches = (list-devices $target | where name == $name)
  if ($matches | is-empty) { null } else { $matches | get 0 }
}

# Wait for $name to appear, up to $seconds; returns null on timeout.
def wait-for-device [target: string, name: string, seconds: int] {
  let deadline = (date now) + ($seconds * 1sec)
  mut waited = 0
  loop {
    let device = (find-device $target $name)
    if $device != null { return $device }
    if (date now) > $deadline { return null }
    sleep 2sec
    $waited += 2
    if ($waited mod 30) == 0 { print $"audio: still waiting for the headset (($waited)s)" }
  }
}

# Where the previous defaults are remembered (per login session).
def state-path [] {
  let runtime = ($env.XDG_RUNTIME_DIR? | default $"/run/user/(^id -u | str trim)")
  $runtime | path join "wivrn-audio.json"
}

# The current default sink or source name.
def default-device [kind: string] {
  (^pactl $"get-default-($kind)" | complete | get stdout | str trim)
}

# Point the default sink or source at $name.
def set-default-device [kind: string, name: string] {
  ^pactl $"set-default-($kind)" $name | complete | ignore
}

# Move every playback stream to $sink.
def move-sink-inputs [sink: string] {
  for input in (list-devices "sink-inputs") {
    ^pactl move-sink-input ($input.index | into string) $sink | complete | ignore
  }
}

# Move every recording stream to $source.
def move-source-outputs [source: string] {
  for output in (list-devices "source-outputs") {
    ^pactl move-source-output ($output.index | into string) $source | complete | ignore
  }
}

# Point the default devices at the headset and follow with current streams.
def switch [seconds: int] {
  print $"audio: waiting up to ($seconds)s for the headset to connect"
  let sink = (wait-for-device "sinks" $SINK $seconds)
  if $sink == null {
    print $"audio: the headset did not connect within ($seconds)s; run 'just vr-audio' once it does"
    return
  }

  let state = (state-path)
  if (default-device "sink") != $SINK {
    { sink: (default-device "sink"), source: (default-device "source") } | to json | save -f $state
  }

  set-default-device "sink" $SINK
  move-sink-inputs $SINK
  print $"audio: playback -> ($SINK), previous default saved in ($state)"

  let source = (find-device "sources" $SOURCE)
  if $source != null {
    set-default-device "source" $SOURCE
    move-source-outputs $SOURCE
    print $"audio: microphone -> ($SOURCE)"
  } else {
    print $"audio: no ($SOURCE) yet, microphone left alone"
  }
}

# Put the remembered default devices back.
def restore [] {
  let state = (state-path)
  if not ($state | path exists) {
    print "audio: no saved defaults, nothing to restore"
    return
  }

  let previous = (open --raw $state | from json)
  rm $state

  if (find-device "sinks" $previous.sink) == null {
    print $"audio: ($previous.sink) is gone, leaving the default to WirePlumber"
  } else {
    set-default-device "sink" $previous.sink
    move-sink-inputs $previous.sink
    print $"audio: playback -> ($previous.sink)"
  }

  if (find-device "sources" $previous.source) == null {
    print $"audio: ($previous.source) is gone, leaving the default to WirePlumber"
  } else {
    set-default-device "source" $previous.source
    move-source-outputs $previous.source
    print $"audio: microphone -> ($previous.source)"
  }
}

# Entry point: 'nu wivrn-audio.nu switch' / '... restore'.
def main [
  action: string = "switch" # switch to the headset, or restore the previous devices
  --timeout: int = 120 # seconds to wait for the headset audio devices
] {
  match $action {
    "switch" => { switch $timeout }
    "restore" => { restore }
    _ => { error make { msg: $"unknown action '($action)'; expected switch or restore" } }
  }
}
