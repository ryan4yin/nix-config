{
  # Enable in-memory compressed devices and swap space provided by the zram kernel module.
  # By enable this, we can store more data in memory instead of fallback to disk-based swap devices directly,
  # and thus improve I/O performance when we have a lot of memory.
  #
  #   https://www.kernel.org/doc/Documentation/blockdev/zram.txt
  zramSwap = {
    enable = true;
    # one of "lzo", "lz4", "zstd"
    algorithm = "zstd";
    # Priority of the zram swap devices.
    # It should be a number higher than the priority of your disk-based swap devices
    # (so that the system will fill the zram swap devices before falling back to disk swap).
    priority = 100;
    # Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).
    # Defaults to 1/2 of your total RAM. Run zramctl to check how good memory is compressed.
    # This doesn’t define how much memory will be used by the zram swap devices.
    memoryPercent = 50;
  };

  # Optimizing swap on zram
  boot.kernel.sysctl = {
    # vm.swappiness - Controls kernel preference for swapping (range: 0-200, default: 60)
    # For in-memory swap devices like zram/zswap, values above 100 are recommended.
    "vm.swappiness" = 180;

    # vm.watermark_boost_factor - Controls aggressiveness of memory reclaim (default: 15000)
    # Setting to 0 disables watermark boost, preventing premature memory reclamation.
    # This allows fuller memory utilization before the kernel starts reclaiming pages.
    "vm.watermark_boost_factor" = 0;

    # vm.watermark_scale_factor - Controls kswapd wakeup frequency (range: 1-1000, default: 10)
    # A higher value triggers background memory reclamation earlier (at 12.5% memory pressure).
    # Value 125 means kswapd becomes active when free memory drops below 1/125 of total memory,
    # balancing memory more proactively to prevent sudden swap storms at high swappiness values.
    "vm.watermark_scale_factor" = 125;

    # vm.page-cluster - Controls swap readahead (range: 0-6, default: 3)
    # 0 means read only 1 page (2^0) at a time, disabling readahead.
    # For low-latency devices like zram, readahead hurts performance by fetching unnecessary data.
    "vm.page-cluster" = 0;
  };
}
