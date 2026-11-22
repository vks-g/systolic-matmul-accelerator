#!/bin/sh
# Synthesize one design at one array size for the Lattice ECP5 LFE5U-25F,
# then place and route it under the clock constraint in ecp5.lpf (issue #75).
#
# Usage: sh synth/yosys/run_synth.sh <top> <N> <outdir>   (from the repo root)
#
# Writes, under <outdir>:
#   <top>_n<N>.yosys.log     synthesis log; the last stat block has the cells
#   <top>_n<N>.nextpnr.log   place-and-route log with the timing summary
#   <top>_n<N>.timing.json   nextpnr timing report (Fmax and critical paths)
# Netlists and bitstream-level outputs go to build/synth/ (gitignored).
#
# Exits nonzero when the design does not fit the device; `make synth` reads
# that as "this N does not fit" and skips the configuration. A missed clock
# constraint is a result, not a failure: the design routed, and the CSV
# records the achieved Fmax next to the constraint.

set -eu

TOP=$1
N=$2
OUT=$3

YOSYS=${YOSYS:-yosys}
NEXTPNR=${NEXTPNR:-nextpnr-ecp5}
LPF=$(dirname "$0")/ecp5.lpf
NETLIST=build/synth/${TOP}_n${N}.json
TIMING_JSON=$OUT/${TOP}_n${N}.timing.json
PNR_LOG=$OUT/${TOP}_n${N}.nextpnr.log

mkdir -p "$OUT" build/synth

# chparam sets the default of N before synth_ecp5 elaborates the top, so one
# RTL tree serves every array size. The file list must stay on one line:
# yosys treats each newline in -p as a new command.
RTL_FILES=$(find rtl -type f -name '*.v' | sort | tr '\n' ' ')
# shellcheck disable=SC2086
"$YOSYS" -l "$OUT/${TOP}_n${N}.yosys.log" -p "
read_verilog -I rtl/include $RTL_FILES
chparam -set N $N $TOP
synth_ecp5 -top $TOP -json $NETLIST
stat
"

# LFE5U-25F, CABGA256 package, commercial -6 speed grade (the common
# LFE5U-25F-6BG256C variant). --seed 1 pins placement so a fresh clone
# reproduces the same numbers. nextpnr exits nonzero when the constraint is
# missed even though routing succeeded, so a written timing report means the
# design fitted and only timing failed.
if ! "$NEXTPNR" --25k --package CABGA256 --speed 6 --seed 1 \
    --lpf-allow-unconstrained --lpf "$LPF" \
    --json "$NETLIST" \
    --textcfg "build/synth/${TOP}_n${N}.config" \
    --report "$TIMING_JSON" \
    -l "$PNR_LOG"; then
    if test -s "$TIMING_JSON"; then
        echo "NOTE $TOP N=$N: routed, but the clock constraint was not met"
    else
        rm -f "$PNR_LOG" "$TIMING_JSON" "$OUT/${TOP}_n${N}.yosys.log"
        echo "FAIL $TOP N=$N: does not fit or route on the LFE5U-25F"
        exit 1
    fi
fi
