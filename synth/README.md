# Synthesis (Phase 2)

Open-source synthesis of the accelerator and the sequential baseline for the
Lattice ECP5 LFE5U-25F, giving the resource counts (LUT4, flip-flops,
MULT18X18D) and maximum clock frequency the Phase 2 report cites (issue #75).

## Layout

- `yosys/ecp5.lpf`: the clock constraint. The flow measures resources and
  Fmax without a board, so only `clk` is constrained (100 MHz target); no pin
  locations. A missed target is a result, not a failure: the CSV records the
  achieved Fmax next to the constraint.
- `yosys/run_synth.sh`: synthesizes one design (`systolic_top` or
  `seq_matmul`) at one array size with Yosys `synth_ecp5`, then places and
  routes it with `nextpnr-ecp5` (LFE5U-25F, CABGA256, speed grade 6, fixed
  seed). Exits nonzero when the design does not fit the device.
- `yosys/summarize.py`: collects the logs into `synth_summary.csv` and the
  top critical path of each configuration into `critical_paths.md`.
- `vivado/` and `constraints/` are reserved for a Xilinx flow if a board or
  Vivado licence becomes available; nothing there yet.

## Running it

Install the OSS CAD Suite (`yosys` and `nextpnr-ecp5`) following
[`docs/setup.md`](../docs/setup.md), then from the repository root:

```sh
make synth                # systolic_top at N=2,3,4,8 (8 if it fits) + seq_matmul at N=4
make synth SYNTH_N="2 4"  # choose the array sizes
```

Logs, the timing reports, `synth_summary.csv` and `critical_paths.md` land in
`results/phase2/synth/` and are committed as evidence; intermediate netlists
go to `build/synth/` (gitignored). The committed results were generated with
OSS CAD Suite release `2026-11-22` (`linux-x64`), Yosys `0.71+77` and
nextpnr-ecp5 `0.11.1-121`. The workflow pins that release and fails if the
regenerated `synth_summary.csv` differs from the committed one.

Placement uses a fixed seed, so results repeat exactly on the same platform
build. Other platform builds of the same release can place differently: on
macOS (`darwin-arm64`) every resource count and the N = 2, 3 and baseline Fmax
match, but N = 4 reaches 56.11 MHz instead of 56.83 MHz. The committed numbers
are the Linux ones; don't commit results regenerated on another platform.

Nothing here is required for Phase 1.
