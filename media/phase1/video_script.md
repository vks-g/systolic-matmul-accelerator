# Phase 1 video: face-cam script

Each of us records **only our face**, reading our lines straight to the camera. You don't record your screen. Gokul (@vks-g) edits the video and adds the diagrams, code, waveforms and test runs around you, timed to your words. The finished video runs under 5:00 (#12, #22).

**Deadline:** send your recording to Gokul by **Sun 15 Nov, 22:00 IST**.

## Before you record

**Camera**
- Record landscape (horizontal), 1080p, 30 fps. On a phone the front camera is fine.
- Put the camera at eye level, about an arm's length away. Stack books under the phone or laptop if you need to.
- Frame yourself from the chest up, centred, with some space on both sides. The editor crops in for split-screen shots, so don't sit near the edge of the frame.

**Light and sound**
- Face a window or a lamp. Never sit with a bright window behind you.
- Use a quiet room: fan off, door closed, no music. Earphones with a mic sound better than a laptop mic.
- Use a plain, tidy background and plain clothes; thin stripes flicker on camera.

**Reading to camera**
- Look into the lens, not at yourself on the screen.
- Put this script in a narrow window right under the camera. With a phone, stand the phone in front of your laptop and keep the script at the top of the laptop screen, just below the lens.
- Speak a little slower than normal and pause briefly at each paragraph break. The editor cuts on those pauses.
- Read your lines as written. If a phrase feels unnatural, change the wording, but keep every number exactly as written. The numbers come from `docs/spec.md` and the logs in `results/phase1/`.
- Don't point at the screen or say "as you can see in the figure". The editor puts the right visual on screen as you speak.
- Practise once with a timer. If you run over your time, speak a little faster rather than dropping lines.

**Recording**
- Start recording, stay silent for 2 seconds, then smile and start with your name.
- If you stumble, don't stop the recording. Pause for 2 seconds and say the whole sentence again. The editor keeps the clean take.
- At the end, stay silent and still for 2 seconds before you stop.
- Two full takes are ideal. Send the better one, or both.

## Sending your recording

- Name the file `segment_<github-handle>.mp4`, for example `segment_MilindDevX.mp4`.
- Send it as a file: a Google Drive link, or WhatsApp as a **Document**. A WhatsApp video gets compressed and looks blurry in the edit.
- The video file is never committed. The unlisted link goes in `media/phase1/README.md` and the README (#12).

## Running order

| Time | Who | Topic | Speaking time |
|---|---|---|---|
| 0:00–0:55 | Gokul VKS (@vks-g) | The idea, the team, the architecture | about 55 s |
| 0:55–1:42 | Yashi Agrawal (@11yashiagrawal) | Literature and the golden model | about 47 s |
| 1:42–2:29 | Milind Bansal (@MilindDevX) | Processing element and controller | about 47 s |
| 2:29–3:14 | Isha Tomar (@Bytebard089) | Dataflow, buffers and the end-to-end test | about 45 s |
| 3:14–3:58 | Mohammad Affan Anas (@affan80) | Tools, CI and diagrams | about 44 s |
| 3:58–4:43 | Gokul VKS (@vks-g) | Results and Phase 2 | about 45 s |
| 4:43–4:49 | End card | Repository link | – |

Times assume about 130 words a minute. The editor adjusts them to the real takes. Gokul records two parts: `segment_vks-g_1.mp4` and `segment_vks-g_2.mp4`.

---

## 1. Gokul: the idea, the team, the architecture

**Say:**

> Hi, I'm Gokul VKS, the team lead.\
> Neural networks spend most of their time multiplying matrices.\
> Our project is a hardware accelerator for that: a systolic array, written in Verilog.\
> I'm here with Milind Bansal, Isha Tomar, Yashi Agrawal and Mohammad Affan Anas.
>
> Here's how it works.\
> The host writes two signed 8-bit matrices, A and B, and sends a start pulse.\
> Then a four-by-four grid of processing elements works on them in parallel: up to sixteen multiply-accumulates per clock cycle.\
> A controller runs each step, and an output buffer holds the result for the host to read.
>
> I wrote the specification first, so all five of us could build in parallel.\
> Then I built the processing-element grid and the top level.

**Viewers see** (the editor adds these; you don't need to do anything):
1. Gokul full-frame. The title card with all five names appears as the team is named.
2. The system diagram (`docs/architecture/svg/system.svg`), lighting up host → buffers → array → output buffer, then the 4×4 grid (`dataflow.svg`).
3. `docs/spec.md`, then `rtl/array/systolic_array.v` and `rtl/top/systolic_top.v`.

## 2. Yashi: literature and the golden model

**Say:**

> Hi, I'm Yashi Agrawal. I did the literature review and the golden model.\
> Systolic arrays were introduced by H. T. Kung and Charles Leiserson in 1979.\
> Each number is read from memory once, then reused as it moves from cell to cell.\
> That matters, because reading off-chip memory costs over a thousand times more energy than an 8-bit multiply.\
> Google's Tensor Processing Unit is built on the same idea.
>
> To check our hardware, I wrote a golden model in Python.\
> It generates 106 test cases: six hand-picked edge cases and 100 random ones.\
> The hardware has to match every single one.

**Viewers see:**
1. Yashi full-frame, then a "Kung & Leiserson, 1979" card and an energy comparison card.
2. Split screen: the literature review section of the report.
3. `model/golden_model.py`, a terminal running `make vectors`, and the table of test cases.

## 3. Milind: processing element and controller

**Say:**

> Hi, I'm Milind Bansal. I built the processing element and the controller.\
> Each processing element multiplies two signed 8-bit numbers, and adds the product to a 32-bit accumulator, every cycle.\
> One cycle later, it passes A to the right and B downward.\
> The accumulator can't overflow: the largest possible sum needs only 18 of its 32 bits.\
> Here's one processing element in simulation: one times five, plus two times six, plus three times seven, plus four times eight, gives 70.
>
> The controller is a five-state machine: idle, clear, compute, capture and done.\
> For a four-by-four array, compute lasts exactly ten cycles.

**Viewers see:**
1. Milind full-frame, then the PE diagram (`pe.svg`) and `rtl/pe/mac.v`.
2. An "18 of 32 bits" card.
3. The PE waveform (`results/phase1/waveforms/pe.png`) with the accumulator reaching 70.
4. The controller diagram (`controller.svg`), each state lighting up as it is named.

## 4. Isha: dataflow, buffers and the end-to-end test

**Say:**

> Hi, I'm Isha Tomar. I built the input and output buffers, and the end-to-end test.\
> The key to a systolic array is timing.\
> A moves right and B moves down, but row i of A starts i cycles late, and column j of B starts j cycles late.\
> So the two numbers that belong together always meet at the right processing element, in the same cycle.\
> My skew buffers create those delays, and the output buffer holds the result for reading.
>
> Then I tested the whole accelerator on all 106 golden cases.\
> Every element of every result matches.

**Viewers see:**
1. Isha full-frame, then the skewed wavefront (`dataflow.svg`) animated step by step.
2. `rtl/buffers/input_skew_buffer.v`.
3. A terminal running `make sim-systolic_top`, ending on `PASS tb_systolic_top 2195/2195`.
4. The top-level waveform (`results/phase1/waveforms/systolic_top.png`).

## 5. Affan: tools, CI and diagrams

**Say:**

> Hi, I'm Mohammad Affan Anas. I set up our tools and drew the architecture diagrams.\
> Everything we use is free and open source: Icarus Verilog to simulate, Verilator to lint, GTKWave for waveforms, and Python for the golden model.\
> My setup guide installs it all on macOS, Linux or Windows.
>
> One command, make lint test, checks every hardware module and runs all seven testbenches.\
> GitHub runs the same command on every pull request, so a broken change is caught before it's merged.\
> I also drew the block diagrams in this video, from editable source files.

**Viewers see:**
1. Affan full-frame, then the tool names as cards.
2. `docs/setup.md`.
3. A terminal running `make lint test`, then a green CI run on a pull request.
4. All four diagrams side by side with their Mermaid sources (`docs/architecture/src/`).

## 6. Gokul: results and Phase 2

**Say:**

> So, does it work? Yes.\
> All seven testbenches pass: more than ten thousand checks, and zero failures.\
> The specification predicted 12 cycles from start to done: one to clear, ten to compute and one to capture.\
> The hardware takes exactly 12, in every run.
>
> A four-by-four product needs 64 multiply-accumulates.\
> One multiplier on its own would need 64 cycles. Our array needs 10.\
> That's 6.4 times faster, or 5.3 times counting all 12 cycles.
>
> In Phase 2, we'll synthesize the design, build that one-multiplier baseline in hardware, and widen the input and output ports.\
> Thanks for watching.

**Viewers see:**
1. Gokul full-frame, then a "7 testbenches · 10,349 checks · 0 failures" card.
2. `results/phase1/cycle_counts.csv`, and a bar split into clear 1, compute 10 and capture 1.
3. A "64 cycles vs 10 cycles" comparison card (spec section 11).
4. A Phase 2 checklist card, then the end card: `github.com/vks-g/systolic-matmul-accelerator`.

## Where the numbers come from

| Number | Source |
|---|---|
| 106 cases (6 directed, 100 random, seed 1) | `docs/spec.md` §9, `model/gen_vectors.py` |
| 18 of 32 bits | `docs/spec.md` §4, report §III (PE and MAC unit) |
| 1·5 + 2·6 + 3·7 + 4·8 = 70 | `results/phase1/waveforms/captions.md` |
| 10 compute cycles, 12 busy cycles | `docs/spec.md` §§7.3, 11; `results/phase1/cycle_counts.csv` |
| 7 testbenches, 10,349 checks, 0 failures | `make test` on `dev` (20 + 15 + 56 + 496 + 96 + 7,471 + 2,195) |
| 2195/2195 for the end-to-end test | `results/phase1/logs/tb_systolic_top.log` |
| 64 MACs, 6.4× and 5.3× | `docs/spec.md` §11 |
| Over a thousand times the energy of an 8-bit multiply | Report §II, from Horowitz (2014) |
