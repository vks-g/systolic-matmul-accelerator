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
go to `build/synth/` (gitignored). Results are deterministic for a fixed
OSS CAD Suite version because placement uses a fixed seed.

Nothing here is required for Phase 1.
