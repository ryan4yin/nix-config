# ROCm on aquamarine

`aquamarine` runs Radeon AI PRO R9700 cards (Navi 48, RDNA4, PCI ID `1002:7551`, ROCm target
`gfx1201`) as headless compute devices; the Intel iGPU drives the console. This note records which
versions support the card, why amdgpu runtime power management leaves it unusable, and which
decisions that produced. Claims are marked **verified** (primary source), **community-reported**,
**measured here** (taken on this machine), or **inference** (read from kernel source, not confirmed
by a maintainer).

## Versions

- **ROCm**: AMD's compatibility matrix has no RDNA4 content and no `gfx1201` in the 6.4.0 column;
  `gfx1201` and the RDNA4 row appear from 7.0.0 on. The R9700 first appears in AMD's _Radeon_ matrix
  for **6.4.4** (Ubuntu 24.04.2/22.04.5, RHEL 9.6/9.4), so it arrived inside 6.4.x, not at 6.4.0.
  **verified**
  ([matrix](https://github.com/ROCm/legacy-rocm-build/blob/develop/docs/compatibility/compatibility-matrix.rst),
  [6.4.4 Radeon matrix](https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-6.4.4/docs/compatibility/compatibilityrad/native_linux/native_linux_compatibility.html))
- **ROCm today**: system requirements list `AMD Radeon AI PRO R9700 | RDNA4 | gfx1201 | ✅`.
  **verified**
  ([requirements](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html))
- **This repository**: the primary nixpkgs input `f71476e8` provides `rocmPackages.clr` 7.2.3.
  Aquamarine selects `linuxPackages_latest` for newer amdgpu/KFD fixes; this does not establish
  compatibility with ROCm 10.1 containers. On 2026-10-20, before activating this change, the host
  reported kernel/driver 6.18.54, host CLR 7.2.3 and inference-container ROCm 7.2.4. The first
  bring-up also used `linuxPackages_latest` (7.2.8).
- **Mesa**: "initial GFX12 (RDNA4) support on RADV" landed in 25.0.0. **verified**
  ([notes](https://gitlab.freedesktop.org/mesa/mesa/-/blob/main/docs/relnotes/25.0.0.rst))
- **Kernel**: amdgpu has no static `1002:7551` entry; its ID table ends with
  `PCI_DEVICE(0x1002, PCI_ANY_ID)` wildcards carrying `CHIP_IP_DISCOVERY`, so binding depends on the
  `soc24`/`gfx_v12_0` IP blocks and firmware, not a PCI ID. AMD validates Ubuntu 24.04.3 HWE kernel
  6.14 for R9700 with ROCm 6.4.4; no primary source states a minimum kernel for Navi 48.
  **verified**
  ([amdgpu_drv.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c?h=v7.2.8))
- **linux-firmware**: Navi 4x uses `gc_12_0_1_*`, `psp_14_0_3_*`, `smu_14_0_3.bin`,
  `sdma_7_0_1.bin`, `dcn_4_0_1_dmcub.bin`; an Ubuntu SRU "Fix power state transition on navi4x"
  updates exactly those files and states they fix bad D3cold→D0 transitions. **verified**
  ([LP #2122659](https://bugs.launchpad.net/ubuntu/+source/linux-firmware/+bug/2122659))

## The runtime-PM failure

The chain is readable from kernel source: a defect in this board's ACPI firmware that the driver
walks into and then hides. The R9700 and the ROCm userspace are fine.

The defect is in Colorful's DSDT. It advertises the ATPX dGPU power-control method while the method
body calls `\_SB.PC00.PEG0.PEGP._OFF`/`_ON`, symbols this DSDT never defines, so the firmware
promises power control it cannot deliver. amdgpu then hides the failure instead of surfacing it: it
routes runtime PM through ATPX and discards the ACPI error (step 4), which turns "this firmware
cannot power-gate the card" into "the card is dead until reboot".

Hitting it took exactly two display-class devices (the iGPU kept for the console fallback plus one
R9700) for `amdgpu_atpx_detect()` to accept ATPX, this DSDT, and an idle dGPU with no display
attached. With **two** R9700s installed there are three display-class devices, so that condition no
longer holds and `amdgpu.runpm=0` may be belt-and-braces rather than a live fix; it stays because
disabling runtime PM on an always-on host costs nothing and the failure needs a reboot to clear. The
field comparison below predates the second card.

1. `amdgpu_atpx_detect()` accepts an ACPI `ATPX` method only when two VGA/display-class devices
   exist, which the iGPU plus one R9700 satisfies; this DSDT does expose `\_SB.PC00.GFX0.ATPX`, as
   the log names it. **verified**
   ([atpx handler](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_atpx_handler.c?h=v7.2.8))
2. When ATPX advertises dGPU power control, amdgpu sets `AMD_IS_PX` on the R9700 and, with the
   default `runpm=-1`, selects `AMDGPU_RUNPM_PX` ("Using ATPX for runtime pm"). **verified**
   ([amdgpu_device.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_device.c?h=v7.2.8))
3. `vga_switcheroo_init_domain_pm_ops()` routes runtime suspend/resume through the ATPX handler,
   which evaluates `\_SB.PC00.PEG0.PEGP._OFF`/`_ON`. Those symbols are absent here, so ACPI aborts
   the method with `AE_NOT_FOUND`. **verified**
   ([vga_switcheroo.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/vga/vga_switcheroo.c?h=v7.2.8))
4. The failure is discarded twice over: `amdgpu_atpx_power_state()` calls
   `amdgpu_atpx_set_discrete_state()` and then returns 0 unconditionally, and
   `vga_switcheroo_power_switch()` never looks at the handler's return value either. So the failed
   switch is silent; the driver resumes as if the card had been power-cycled, re-initializes SMU,
   gets no answer (`SMU: No response msg_reg: 6 resp_reg: 0`) and reports
   `resume of IP block <smu> failed -62` with `runtime_status = error`. **verified** for the two
   discarded returns, **inference** for the SMU sequence that follows
   ([amdgpu_atpx_handler.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_atpx_handler.c?h=v6.18.54),
   [vga_switcheroo.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/vga/vga_switcheroo.c?h=v6.18.54)).
5. With `runtime_status` not `active`, rocm-smi prints its low-power-state warning;
   `check_runtime_status()` reads `…/device/power/runtime_status`. **verified**
   ([rocm_smi.py](https://github.com/ROCm/rocm-systems/blob/rocm-7.2.3/projects/rocm-smi-lib/python_smi_tools/rocm_smi.py))

**No upstream report of this exact chain was found.** Searches of the freedesktop drm/amd tracker,
kernel Bugzilla and distro trackers found no bug matching `PEGP._OFF` + `AE_NOT_FOUND` +
`Aborting method … ATPX` on RDNA4 desktop hardware. The nearest documents are the amd-gfx patch
"drm/amdgpu/soc24: reset dGPU if suspend got aborted", which handles the same `SMU … -62` tail but
only when `adev->in_s3` is set (present in 7.2.8; it does **not** cover runtime PM), and the navi4x
firmware SRU. **verified**
([patch](https://lists.freedesktop.org/archives/amd-gfx/2026-June/146878.html),
[soc24.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/soc24.c?h=v7.2.8))

Nor is a fix in flight on the code itself: `amdgpu_atpx_handler.c`'s most recent change is a 2026-05
buffer-length hardening, and its dGPU power-control semantics have not been touched since 2019,
while the 2025-2026 `vga_switcheroo.c` changes are cosmetic (`pci_is_display()`, fbcon wrappers,
`kmalloc_obj` conversions). **verified** (mainline commit history of both files)

## What actually fixes it

- `amdgpu.runpm=0` is the documented "disable" value (default `-1`, auto). With mode `NONE`,
  `amdgpu_pmops_runtime_checks()` calls `pm_runtime_forbid()` and returns `-EBUSY`, the
  vga_switcheroo domain is not installed, and no runtime suspend can run. **verified**
  ([amdgpu_drv.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c?h=v7.2.8))
- `echo on > /sys/bus/pci/devices/…/power/control` is the PM-core equivalent — the device never
  runtime-suspends — but it leaves the driver registered as a PX client, which is why this host sets
  `amdgpu.runpm=0` instead (below) rather than persisting that write with a udev rule. **verified**
  for the ABI, **community-reported** as a fix.
- AMD's own notes carry the workaround ("users can run amdgpu.runpm=0, which temporarily disables
  the runtime power management feature from the driver"), and the Arch Wiki gives the same advice
  for a dGPU that "becomes disabled during use", citing drm/amd issue 1820. **verified**
  ([ROCm 5.0.0 highlights](https://github.com/ROCm/legacy-rocm-build/blob/develop/tools/autotag/templates/highlights/5.0.0.md),
  [Arch Wiki](https://wiki.archlinux.org/title/AMDGPU#Issues_with_power_management_/_dynamic_re-activation_of_a_discrete_amdgpu_graphics_card))

The workaround is field-verified on this host: the pre-fix boot logged
`amdgpu: Using ATPX for runtime pm` and left the card in `runtime_status = error`, while the 6.18.54
boot with `amdgpu.runpm=0` logs `amdgpu: runtime pm is manually disabled` and
`amdgpu: Runtime PM not available`, keeps `power/control = on` and `runtime_status = active`, and
`rocm-smi` reads the card normally after minutes of idling. **verified** (`journalctl -k -b 0` vs
`-b -2` on this host)

One adjacent problem gets conflated with this one: Navi 48 s2idle breaks when
`hardware.amdgpu.overdrive`'s default `ppfeaturemask = "0xfffd7fff"` disables GFXOFF (upstream
default `0xfff7bfff`; `0xfff7ffff` works). **verified**
([nixpkgs#564601](https://github.com/NixOS/nixpkgs/issues/564601))

`amdgpu.ppfeaturemask=0xffffffff` does not address the ATPX/SMU path; it comes from a community
tuning repository and no primary source ties it to it. **community-reported**
([r9700-setup](https://github.com/stew675/r9700-setup/blob/HEAD/README.md)). The host's own
`pcie_aspm=off` and `processor.max_cstate=2` are unrelated to this path too — they are set for PCIe
link retraining and C-state exit latency, with their reasons in
[hardware-amd-gpu.nix](./hardware-amd-gpu.nix).

## Kernel parameters and module options

- `iommu=pt` — keep. AMD: "Systems with multiple GPUs may require iommu=pt … to prevent application
  hangs". **verified**
  ([requirements](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html))
- `iommu=off` — claimed by `stew675/r9700-setup` to "allow for P2P between multiple R9700's"; no AMD
  statement supports that. **community-reported**
- `amdgpu.gpu_recovery=1` — enables GPU recovery; default is `-1`, "auto, disabled except SRIOV".
  **verified**
  ([amdgpu_drv.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c?h=v7.2.8))
- `amdgpu.ppfeaturemask` — exposed as `hardware.amdgpu.overdrive.ppfeaturemask`; see the s2idle
  caveat above. **verified**
  ([module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/hardware/amdgpu.nix))
- `amdgpu.ras_enable` — the real parameter name (`module_param_named(ras_enable, …)`), default `-1`;
  the driver's GECC message calls it `amdgpu_ras_enable`. **verified**
  ([amdgpu_psp.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_psp.c?h=v7.2.8))

The Arch Wiki documents the same knobs plus `power_dpm_force_performance_level` and the COMPUTE
profile, but has no R9700/gfx1201 entry; its ROCm section only says the official list is short and
equivalent-generation consumer cards are "known to work", and never mentions
`HSA_OVERRIDE_GFX_VERSION`. **verified** ([AMDGPU](https://wiki.archlinux.org/title/AMDGPU),
[GPGPU § ROCm](https://wiki.archlinux.org/title/General-purpose_computing_on_graphics_processing_units#ROCm))

## ROCm userland in nixpkgs

- `hardware.amdgpu.opencl.enable = true` adds both `rocmPackages.clr` and `rocmPackages.clr.icd` —
  the module's own shape — rather than `.icd` alone. **verified**
  ([amdgpu.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/hardware/amdgpu.nix))
- **`rocm-smi` works on a healthy card.** The `Fail to open libdrm_amdgpu.so.1` message upstream
  logs (and AMD's amdsmi PR tolerates, closed unmerged) appeared here only while the R9700 sat in
  `runtime_status = error`, so it is a symptom of the wedged card rather than a packaging bug. With
  `amdgpu.runpm=0` the tool reads temperatures, clocks, power and VRAM, and `--showproductname`
  answers `Card Model: 0x7551`, `Card Vendor: 0x1002`, `GFX Version: gfx1201`; only `Card Series`
  stays `N/A` because the userspace name table has no R9700 entry. **verified** (observed on this
  host) ([amdsmi PR](https://github.com/ROCm/rocm-systems/pull/2987))
- nixpkgs' Ollama and Open WebUI modules use `SupplementaryGroups = [ "render" ]`, matching this
  host. **verified**
  ([ollama.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/ollama.nix))
- A real NixOS RDNA4 host pins `linuxPackages_latest` and sets `amdgpu.runpm=0` ("Disable runtime
  power management for stability") plus `amdgpu.gpu_recovery=1` and `amdgpu.dc=1`.
  **community-reported**
  ([config](https://github.com/dustinlyons/nixos-config/blob/main/hosts/nixos/default.nix))
- GitHub code search found **no** public Nix configuration targeting `gfx1201` or the R9700.

## Two R9700s

- R9700 cards have no Infinity Fabric/xGMI link. A dual-R9700 report documents an **RCCL deadlock
  with vLLM TP=2** on ROCm 7.2.1 (RCCL 2.27.7): both GPUs spin at 100%, `NCCL_P2P_DISABLE=1` changes
  nothing, and the same stack worked with RCCL 2.27.3. **verified** (open upstream)
  ([rocm-systems#5480](https://github.com/ROCm/rocm-systems/issues/5480))
- llama.cpp gates peer copies behind `GGML_CUDA_NO_PEER_COPY`; without it cross-device copies use
  `cudaMemcpyPeerAsync` and the backend advertises P2P events. The tuning repo recommends
  `-DGGML_CUDA_NO_PEER_COPY=1` "if P2P is unstable in your topology". **verified** (flag),
  **community-reported** (recommendation)
  ([ggml-cuda.cu](https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-cuda/ggml-cuda.cu))
- `HIP_VISIBLE_DEVICES` (documented by llama.cpp) and `ROCR_VISIBLE_DEVICES` (used as
  `ROCR_VISIBLE_DEVICES=0` in the R9700 report) both hide the iGPU. **verified**
  ([build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md),
  [legacy-rocm-build#6630](https://github.com/ROCm/legacy-rocm-build/issues/6630))
- Split by layer/pipeline, not tensor parallel: `-sm/--split-mode` offers `none`, `layer` (default,
  "split layers and KV across GPUs (pipelined)"), `row` and `tensor` (parallelised, EXPERIMENTAL);
  `--device` and `--main-gpu` choose devices. **verified**
  ([arg.cpp](https://github.com/ggml-org/llama.cpp/blob/master/common/arg.cpp))
- Both installed R9700s (`0000:04:00.0` behind the card's own switch at `02:00.0`/`03:00.0`, and
  `0000:83:00.0` behind `82:00.0`) negotiate `current_link_width = 16` at `32.0 GT/s` (PCIe 5.0 x16,
  their maximum) — that is the card-side link, not the slot. The slot links differ: the CPU root
  port `0000:00:06.0` is x16 at 32 GT/s, while the chipset root port `0000:80:1c.0` is **x4 at 16
  GT/s (PCIe 4.0)**. The board manual's x4 claim is therefore measured, and because `lspci` on the
  card reports x16 either way, read the root port or the engine's `PCIe probe` line (./README.md).

## Inference software

- **llama.cpp**: `-DGGML_HIP=ON -DGPU_TARGETS=gfx1201` (`GPU_TARGETS` is optional; omitting it
  builds for all GPUs present). `HSA_OVERRIDE_GFX_VERSION` is documented only for GPUs that are not
  officially supported, so it is not needed. ROCm's matrix validates llama.cpp `b6356` with 7.0.x.
  **verified** ([build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md),
  [matrix](https://github.com/ROCm/legacy-rocm-build/blob/develop/docs/compatibility/compatibility-matrix.rst))
- **llama.cpp on gfx1201 is not clean**: an upstream report on one R9700 shows Vulkan passing while
  ROCm 7.14 hangs in generation and later resets MES/PSP (`resume of IP block <psp> failed -62`),
  still open. **verified** ([#6630](https://github.com/ROCm/legacy-rocm-build/issues/6630))
- The tuning repo also passes `-DGGML_HIP_ROCWMMA_FATTN=ON` and `-DGGML_HIP_RCCL=ON`; only
  `GGML_HIP_RCCL` exists in `ggml/CMakeLists.txt`, so the ROCWMMA flash-attention flag is stale and
  CMake ignores it. **community-reported**
  ([CMakeLists.txt](https://github.com/ggml-org/llama.cpp/blob/master/ggml/CMakeLists.txt))
- **Ollama**: the PR "Add native support for AMD RDNA 4 (gfx1201 / Radeon AI Pro R9700)" whitelists
  the architecture and adds ROCm targets but is **closed and not merged**; it states RDNA4 discovery
  timed out in the HIP handshake before whitelisting and links reports of
  `TensileLibrary_lazy_gfx1201.dat` missing. A later report shows Ollama 0.20.2-rocm detecting
  `compute=gfx1201` while still logging the rocBLASLt `.dat` error. **verified**
  ([#14021](https://github.com/ollama/ollama/pull/14021),
  [#15338](https://github.com/ollama/ollama/issues/15338))
- **vLLM**: the current ROCm GPU installation page does not mention gfx1201, RDNA4, R9700 or 9070;
  working dual-R9700 setups are community forks. **verified** (docs' silence)
  ([vLLM docs](https://docs.vllm.ai/en/latest/getting_started/installation/gpu.html));
  **community-reported** ([toolboxes](https://github.com/kyuz0/amd-r9700-vllm-toolboxes))

## Power, thermals, ECC

- **GECC** is a PSP boot-config bit: the driver prints `GECC is enabled`, or
  `GECC will be enabled in next boot cycle` after setting it; enabling needs UMC RAS support and
  `ras_default_ecc_enabled`/`amdgpu.ras_enable=1`. It takes effect next boot and costs VRAM
  capacity/bandwidth, so decide before filling the cards. **verified**
  ([amdgpu_psp.c](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_psp.c?h=v7.2.8))
- **Monitoring/control**: `power_dpm_force_performance_level`, `pp_dpm_*` clocks,
  `gpu_busy_percent`, `mem_busy_percent` and the `fan_*` files are documented. **verified**
  ([kernel thermal docs](https://docs.kernel.org/gpu/amdgpu/thermal.html)); the Arch Wiki adds
  `pp_od_clk_voltage`, `pp_power_profile_mode` (COMPUTE is profile 5) and warns that PowerPlay-table
  tools are "bugged on kernel side" for Navi 3x/4x. **verified**
  ([Arch Wiki](https://wiki.archlinux.org/title/AMDGPU#Overclocking))
- **Undervolt/power cap**: the tuning repo forces `manual`, writes `vo -85` + `c` to
  `pp_od_clk_voltage`, and writes watts to hwmon `power1_cap` from a systemd oneshot. No NixOS
  module exists. **community-reported**
  ([tune_r9700.sh](https://github.com/stew675/r9700-setup/blob/HEAD/tune_r9700.sh))
- **What a power cap costs here**: against the 300 W default, a 250 W cap costs roughly 4% of
  prefill and decode throughput and a 230 W cap roughly 7%, the same order in both phases — measured
  with a 27B model on the second card. **measured here**

## What this repository does, and what is still open

1. `hardware-amd-gpu.nix` sets `"amdgpu.runpm=0"` next to `iommu=pt`, over a `power/control=on` udev
   rule, which would leave the driver registered as a PX client. Revisit if a BIOS update defines
   the `_OFF`/`_ON` methods — or now that two cards may keep ATPX out of the picture (above).
2. `iommu=pt` stays; `iommu=off` for P2P is a community claim with no AMD statement.
3. `hardware.amdgpu.opencl.enable = true` is the shape the host uses — the module adds both `clr`
   and `clr.icd` — instead of a hand-written `hardware.graphics.extraPackages`.
4. `rocmPackages.rocm-smi` is not wrapped for libdrm. It reads a healthy card completely; the
   `Fail to open libdrm_amdgpu.so` message only appeared while the card was wedged (see "ROCm
   userland in nixpkgs"). Expect `Card Series: N/A` until upstream names the R9700.
5. `hardware.amdgpu.overdrive` stays off unless undervolting is wanted; if it is turned on, set
   `ppfeaturemask = "0xfff7ffff"` (nixpkgs#564601). A oneshot unit in `hardware-amd-gpu.nix` caps
   both cards at 250 W through hwmon `power1_cap` to keep their fans quiet, and exits non-zero when
   a card does not take the value; the cap needs no overdrive. `amdgpu.gpu_recovery=1` is set,
   because the driver default is auto/off except SRIOV.
6. **Open:** set `HIP_VISIBLE_DEVICES` (and `ROCR_VISIBLE_DEVICES` where honoured) so the iGPU is
   never selected; for llama.cpp prefer `--split-mode layer` or an RPC/pipeline split over tensor
   parallelism, and build with `-DGGML_HIP=ON -DGPU_TARGETS=gfx1201`, no `HSA_OVERRIDE_GFX_VERSION`.
7. Keep the x4 claim in [README.md](./README.md) and `hardware-amd-gpu.nix`: the chipset root port
   `80:1c.0` measures 16 GT/s x4 while both cards' own links are x16, which is why the engine's
   probe matters. Keep "split by layer, not tensor parallel" either way — it now rests on the RCCL
   TP=2 issue, not slot width.
8. **Open:** make the ECC decision explicit: for GECC add `amdgpu.ras_enable=1` and confirm the boot
   log's `GECC is enabled` line; otherwise say so, because the kernel warns about it every boot.

## Not settled from primary sources

- The `PEG0.PEGP._OFF` → ATPX abort → SMU `-62` sequence is read from kernel source; no maintainer
  has confirmed the "ignored ATPX return value" step, and no upstream report of the chain was found.
- No primary source states a minimum kernel for Navi 48, and none states that PCIe P2P between R9700
  cards is available — only the two-card report and llama.cpp's opt-out flag.
- vLLM's official ROCm support for gfx1201 is undocumented; working configurations are community
  forks whose correctness is not independently verified.
