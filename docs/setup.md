# Toolchain setup

Run commands from the repository root unless a section says otherwise. Use
GNU Make 3.81 or newer, Icarus Verilog (`iverilog` and `vvp`), Verilator,
Python 3.10 or newer with NumPy, and either GTKWave or Surfer. Tectonic builds
the report; it and a waveform viewer are not needed for `make lint test`.

## macOS

Install [Homebrew](https://brew.sh/) if needed, then in Terminal:

```sh
brew install git make icarus-verilog verilator python tectonic
```

macOS's `/usr/bin/make` is sufficient; Homebrew's newer GNU Make is also
available as `gmake`. For waveforms, download the macOS ARM binary from
[Surfer's official site](https://surfer-project.org/) and put the `surfer`
executable on your `PATH`. On other Macs, follow its source-build instructions
or use a compatible [GTKWave release](https://gtkwave.sourceforge.net/).
Check that `surfer --help` or `gtkwave --help` works before `make waves`.
Make selects GTKWave when it is on `PATH`, otherwise Surfer. An explicit
`VIEWER=...` overrides this selection.

## Linux (Ubuntu / Debian)

On Ubuntu 24.04 or a recent Debian release:

```sh
sudo apt update
sudo apt install git make iverilog verilator gtkwave python3 python3-venv python3-pip
```

Other distributions can install the same tools through their package manager;
check that Python is at least 3.10. For Tectonic, download and extract the
binary matching your CPU and OS from the
[official releases](https://github.com/tectonic-typesetting/tectonic/releases),
then install it into your user executable directory:

```sh
# Run in the directory containing the extracted tectonic binary.
mkdir -p "$HOME/.local/bin"
install -m 755 tectonic "$HOME/.local/bin/tectonic"
export PATH="$HOME/.local/bin:$PATH"
tectonic --version
```

Add that `PATH` setting to your shell startup file to keep it across sessions.
If you already use Conda, `conda install -c conda-forge tectonic` is another
[supported installation method](https://tectonic-typesetting.github.io/en-US/install.html).

## Windows (WSL2)

Use Ubuntu under WSL2 for the complete Make/Verilator workflow, as recommended
by the [Verilator Windows FAQ](https://verilator.org/guide/latest/faq.html#does-verilator-run-under-windows).
In an administrator PowerShell window:

```powershell
wsl --install -d Ubuntu
```

Restart if prompted, open Ubuntu, and finish creating your Linux user. Follow
the Linux installation commands above **inside Ubuntu**, including Tectonic.
Clone into your Linux home directory rather than `/mnt/c`:

```sh
mkdir -p ~/src
cd ~/src
git clone https://github.com/vks-g/systolic-matmul-accelerator.git
cd systolic-matmul-accelerator
git switch dev
```

All remaining shell commands in this guide run in Ubuntu, not PowerShell.
GTKWave needs WSL GUI support (WSLg). If a GUI is unavailable, open the VCD
with a Windows viewer downloaded from
[Surfer](https://surfer-project.org/), or its browser version. From Windows
Explorer, `\\wsl.localhost\Ubuntu\home\<linux-user>\src\systolic-matmul-accelerator\build`
contains the generated waveforms. See Microsoft's
[WSL installation guide](https://learn.microsoft.com/en-us/windows/wsl/install)
for system requirements and troubleshooting.

## Python and NumPy (all platforms)

Clone the repository and switch to `dev` if you have not done so already.
For contributions, create your task branch from the updated `dev` using
the naming rules in [CONTRIBUTING.md](../CONTRIBUTING.md).

```sh
python3 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
if [ -f model/requirements.txt ]; then
    python -m pip install -r model/requirements.txt
else
    python -m pip install numpy
fi
```

The requirements file and golden model are delivered by issue #14. Until
then, installing NumPy is enough to prepare the environment. Once that issue
lands, run `python -m pip install -r model/requirements.txt` again. Activate
`.venv` in each new terminal. To select another Python interpreter, use
`make test PYTHON=/path/to/python`.

## Check the installation

```sh
make --version
iverilog -V
vvp -V
verilator --version
python --version
python -c "import numpy; print(numpy.__version__)"
tectonic --version
```

Icarus sometimes prints additional component-version information with `-V`;
the compile/run commands below are the functional check.

## Lint, vectors, simulation and waveforms

```sh
make lint test
make vectors                         # N=4, RANDOM_CASES=100, SEED=1
make sim-pe                          # tb/tb_pe.v, once the PE lands
make waves                           # tb_systolic_top and an installed viewer
make waves VIEWER=surfer              # use Surfer instead
make waves WAVE_MODULE=pe VIEWER=surfer
make clean
```

| Target | Behaviour |
|---|---|
| `lint` | Discovers every `rtl/**/*.v`; runs Verilator `--lint-only -Wall` in Verilog-2005 mode, once per module as a top. Warnings fail lint. |
| `vectors` | Runs `model/gen_vectors.py --n 4 --random 100 --seed 1 --out build/vectors`. Override `N`, `RANDOM_CASES` or `SEED` on the command line. |
| `sim-<module>` | Generates vectors, compiles all available RTL and `tb/tb_<module>.v` with Icarus `-g2005`, selects `tb_<module>` as the simulation top, then runs `vvp`. |
| `test` | Generates vectors and runs every discovered `tb/tb_*.v`; a compilation error, nonzero simulator exit, `FAIL` line or missing `PASS` summary fails Make. |
| `waves` | Runs `sim-systolic_top` then opens `build/tb_systolic_top.vcd` in GTKWave if installed, otherwise Surfer. Override `WAVE_MODULE`, `WAVE_FILE` and `VIEWER` as needed. |
| `clean` | Deletes `build/` and the Make-created `sim/vectors` link. Leaves source, committed evidence, layouts and `.venv` alone. |

Simulation executables, logs and waveforms belong in `build/` (gitignored).
Vectors also live in `build/vectors/`; Make creates the ignored relative
symlink `sim/vectors -> ../build/vectors` so `$readmemh("sim/vectors/...")`
continues to follow [the spec](spec.md#9-golden-test-vectors). If you previously
generated a real `sim/vectors` directory, move it aside before using
`make vectors`; Make will refuse to replace it. Run simulations from the
repository root so relative paths resolve correctly.

Testbench owners must dump waveforms to `build/tb_<module>.vcd` (or supply
`WAVE_FILE` when opening another path). No VCD is invented by the build.
Testbenches must print the summary from [spec section 10](spec.md#10-verification-plan),
for example `PASS tb_pe 8/8`, and call `$fatal(1, ...)` on a mismatch.
Compile and simulation logs are `build/compile_tb_<module>.log` and
`build/tb_<module>.log`; lint logs are `build/lint_<module>.log`.

At the scaffold stage, `SKIP` messages are expected: absent RTL, testbenches
and the vector generator are skipped. A testbench whose matching RTL file
has not landed is also skipped; `systolic_top` additionally waits for #14.
Existing files with syntax errors, unresolved instantiated dependencies or
failing checks **fail** the build. A successful scaffold run therefore does
not mean accelerator verification has passed. Once files land, they are
discovered on the next invocation without editing the Makefile.

`make -j test` generates vectors once before simulations start. Simulations
rerun on each invocation, so a cached executable cannot hide a failing test.
Changing `N` for vectors also requires a testbench configured for the same N,
as required by the spec; Make does not override RTL or testbench parameters.
Tool commands can be overridden with `PYTHON`, `IVERILOG`, `VVP` and
`VERILATOR`. Installed tools are required when their inputs exist.

## Synthesis (Phase 2)

`make synth` (#75) needs Yosys and nextpnr-ecp5. Install them with the
[YosysHQ OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build), a
single archive that bundles both (plus Icarus, Verilator and GTKWave, so it
can replace the earlier installs). Download the newest `oss-cad-suite-*`
archive for your platform from its
[releases page](https://github.com/YosysHQ/oss-cad-suite-build/releases).

### macOS

Pick `darwin-arm64` (Apple silicon) or `darwin-x64` (Intel). In Terminal:

```sh
mkdir -p "$HOME/opt"
tar -xzf ~/Downloads/oss-cad-suite-darwin-*.tgz -C "$HOME/opt"
source "$HOME/opt/oss-cad-suite/environment"
```

The `source` line puts the tools on `PATH` for the current shell only; add it
to your `~/.zshrc` to keep it. The first run of each tool may need approval
under System Settings > Privacy & Security because the archive is not
notarized.

### Linux (Ubuntu / Debian)

```sh
sudo mkdir -p /opt
sudo tar -xzf ~/Downloads/oss-cad-suite-linux-x64-*.tgz -C /opt
source /opt/oss-cad-suite/environment
```

Add the `source` line to your `~/.bashrc` to keep the tools on `PATH`.

### Windows (WSL2)

Follow the YosysHQ recommendation and use the Linux build inside the WSL2
Ubuntu set up above: download the `linux-x64` archive in Ubuntu and run the
Linux commands. A native `windows-x64` archive also exists; after extracting
it, `start.bat` in the `oss-cad-suite` folder opens a shell with the tools on
`PATH`.

### Check the synthesis tools

```sh
yosys -V
nextpnr-ecp5 --version
make synth
```

`make synth` synthesizes `systolic_top` at N = 2, 3, 4 and 8 (8 only if it
fits the device) plus the `seq_matmul` baseline at N = 4 for the Lattice ECP5
LFE5U-25F, then writes logs, `synth_summary.csv` and `critical_paths.md` to
`results/phase2/synth/`. See [`synth/README.md`](../synth/README.md) for the
constraint, device variant and skip behaviour.

`make synth` overwrites the committed files in `results/phase2/synth/`. On macOS
the N = 4 Fmax can differ slightly from the committed Linux result (see
[`synth/README.md`](../synth/README.md)); undo the run with
`git checkout -- results/phase2/synth` and don't commit the difference.

## CI

[`.github/workflows/sim.yml`](../.github/workflows/sim.yml) runs on every PR
(including PRs targeting `dev`) and pushes to `dev`. Ubuntu installs Icarus,
Verilator and NumPy, then runs the same `make lint test` command. Failed jobs
upload available `build/*.log` files as the `simulation-logs` artifact.
CI also runs `python -m unittest discover -s tests -v` to check viewer
selection with command-recording fixtures; it does not open GUI viewers
or build the report.

[`.github/workflows/synth.yml`](../.github/workflows/synth.yml) runs the same
`make synth` sweep on PRs and pushes to `dev`: it downloads the OSS CAD
Suite, synthesizes every configuration and prints the summary CSV.

## Build the reports

The final report (Phase 2) and the submitted Phase 1 report build the same
way, from the repository root:

```sh
tectonic reports/phase2/main.tex     # final report -> reports/phase2/main.pdf
tectonic reports/phase1/main.tex     # Phase 1 report -> reports/phase1/main.pdf
```

The first build needs internet access to download TeX resources. The Phase 2
report reads its figures from `results/` and `docs/architecture/png/`, so build
it inside a full checkout. Follow the report instructions
([Phase 2](../reports/phase2/README.md), [Phase 1](../reports/phase1/README.md))
when changing report sections or committing the PDF; only the lead commits
`main.pdf`. Report output is separate from simulation build output, and
`make clean` does not remove it.

## Common problems

- **Command not found:** reopen the terminal after installation, check
  `PATH`, and reactivate `.venv` for Python packages.
- **Missing PASS summary:** read `build/tb_<module>.log`. A test that only
  calls `$finish` without the spec's summary is not self-checking enough
  for CI.
- **No waveform:** confirm the selected testbench calls `$dumpfile` and
  `$dumpvars`, then use its actual dump path as `WAVE_FILE`.
- **Verilator warnings:** fix the source or add a narrowly scoped waiver
  with a reason as described in the contribution rules; do not disable
  warnings globally.
