# Phase 1 video: script and timing

Hard limit: **5:00**. The plan below runs 4:55. Every member says their own name on camera or over their screen.

Record your segment as a screen capture with your voice, keep to your slot, and send the file to Isha (@Bytebard089) by **Sun 15 Nov, 22:00** (#22). The video file is never committed; the unlisted link goes in `media/phase1/README.md` and the README (#12).

## Timing

| Time | Length | Who | Content |
|---|---|---|---|
| 0:00–0:10 | 0:10 | Title card | Project title and all five names |
| 0:10–0:55 | 0:45 | Gokul (@vks-g) | Introduction, project idea, architecture |
| 0:55–1:40 | 0:45 | Yashi (@11yashiagrawal) | Literature context, golden model |
| 1:40–2:30 | 0:50 | Milind (@MilindDevX) | PE and MAC unit, controller, PE waveform |
| 2:30–3:20 | 0:50 | Isha (@Bytebard089) | Dataflow, skew buffers, end-to-end test passing |
| 3:20–4:05 | 0:45 | Affan (@affan80) | Toolchain, Makefile, CI, block diagrams |
| 4:05–4:45 | 0:40 | Gokul (@vks-g) | Results, latency, Phase 2 roadmap |
| 4:45–4:55 | 0:10 | End card | Repository link |

## Storyboard

Each segment lists what is on screen and the points to say. Put them in your own words; the numbers must stay as written, since they come from `docs/spec.md` and the logs in `results/phase1/`.

### Gokul: introduction and architecture (0:10–0:55)

- **On screen:** the architecture block diagram (#18), then `docs/spec.md` section 2.
- "I'm Gokul." Introduce the team and the project idea: a 4×4 output-stationary systolic array in Verilog that multiplies signed 8-bit matrices into 32-bit results.
- The blocks: two input skew buffers, the N×N PE array, the controller and the output buffer, behind one host interface.

### Yashi: literature and golden model (0:55–1:40)

- **On screen:** the literature review section of the report, then `model/gen_vectors.py` and `make vectors`.
- "I'm Yashi." Systolic arrays go back to Kung (1982); output-stationary versus weight-stationary dataflows.
- The Python golden model writes 106 test cases (6 directed, 100 random, seed 1) that the hardware is checked against.

### Milind: PE, MAC and controller (1:40–2:30)

- **On screen:** `rtl/pe/mac.v`, `rtl/pe/pe.v`, the controller state diagram (Fig. 1 in the report), then the PE waveform (#8).
- "I'm Milind." Each PE does one signed 8×8 multiply per cycle into a 32-bit accumulator and passes its operands right and down one cycle later.
- The controller runs IDLE, CLEAR, COMPUTE, CAPTURE, DONE; COMPUTE takes K + 2N − 2 = 10 cycles for N = 4.

### Isha: dataflow, skew buffers and the end-to-end test (2:30–3:20)

- **On screen:** spec table 7.2, `rtl/buffers/input_skew_buffer.v`, then a terminal running `make test` with `tb_systolic_top` passing (#11).
- "I'm Isha." A moves right and B moves down; row i and column j start i and j cycles late, so A[i][k] and B[k][j] meet at PE (i, j).
- The end-to-end test runs every golden case through the whole accelerator and checks each run takes 12 cycles from `start` to `done`.

### Affan: toolchain and block diagrams (3:20–4:05)

- **On screen:** `docs/setup.md`, the `Makefile` targets, a green CI run on a PR, then the block diagrams.
- "I'm Affan." Icarus Verilog simulates, Verilator lints, and `make lint test` runs everything; CI runs the same command on every PR.

### Gokul: results and Phase 2 (4:05–4:45)

- **On screen:** `results/phase1/cycle_counts.csv` and the performance table (spec section 11).
- Measured latency: 12 cycles from `start` to `done`, 10 of them compute, as the spec predicts.
- 64 multiply-accumulates in 10 compute cycles, against 64 cycles for one sequential MAC: 6.4× on compute, 5.3× counting all 12 busy cycles.
- Phase 2: synthesis, an RTL sequential baseline for a measured speed-up, and wider I/O ports.
