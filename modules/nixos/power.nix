{ ... }:
{
  # TuneD - Tuning Profile Delivery Mechanism for Linux
  # A modern replacement for PPD(power-profiles-daemon)
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;

    # Hosts pin their profile with `services.tuned.recommend` (an empty rule
    # matches any host): TuneD reads /etc/tuned/recommend.conf in its automatic
    # profile mode on every boot. `ppdSettings.main.default` looks like it does
    # the same, but never wins -- tuned-ppd restores the base profile it saved in
    # /etc/tuned/ppd_base_profile, or TuneD's own recommendation, first. Nothing
    # here uses the PPD D-Bus API, so tuned-ppd stays off instead of overwriting
    # the pinned profile at startup.
    ppdSupport = false;
  };

  # Battery/AC state, used by the desktops; tuned-ppd was the other consumer.
  services.upower.enable = true;

  services.power-profiles-daemon.enable = false; # conflicts with tuned
  services.tlp.enable = false; # conflicts with tuned
}
