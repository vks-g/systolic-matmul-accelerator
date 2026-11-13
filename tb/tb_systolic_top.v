`timescale 1ns / 1ps
`default_nettype none
`include "sa_params.vh"

// End-to-end self-checking testbench for systolic_top (issue #11).
//
// Reads A, B and the expected C from the golden vectors of #14 (docs/spec.md
// section 9) in sim/vectors/, which `make vectors` creates. Run with
// `make sim-systolic_top`. Expected values come only from the vector files.
//
// Last line of output: "PASS tb_systolic_top <passed>/<total>", or
// "FAIL tb_systolic_top <failed> of <total> checks failed" followed by $fatal.
module tb_systolic_top;

    localparam N         = `SA_N;
    localparam DATA_W    = `SA_DATA_W;
    localparam ACC_W     = `SA_ACC_W;
    localparam CYC_W     = `SA_CYC_W;
    localparam K         = N;
    localparam NN        = N * N;
    localparam ADDR_W    = $clog2(NN);
    localparam BUSY      = K + 2*N;         // busy cycles per run, spec 7.4 (12 for N = 4)
    localparam MAX_CASES = 1024;
    localparam MAX_REPORTED = 10;

    reg                     clk     = 1'b0;
    reg                     rst_n   = 1'b0;
    reg                     a_we    = 1'b0;
    reg  [ADDR_W-1:0]       a_addr  = 0;
    reg  signed [DATA_W-1:0] a_wdata = 0;
    reg                     b_we    = 1'b0;
    reg  [ADDR_W-1:0]       b_addr  = 0;
    reg  signed [DATA_W-1:0] b_wdata = 0;
    reg                     start   = 1'b0;
    reg  [ADDR_W-1:0]       c_addr  = 0;
    wire                    busy;
    wire                    done;
    wire signed [ACC_W-1:0] c_rdata;
    wire [CYC_W-1:0]        cycle_count;

    systolic_top #(
        .N(N), .DATA_W(DATA_W), .ACC_W(ACC_W), .CYC_W(CYC_W)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .a_we(a_we), .a_addr(a_addr), .a_wdata(a_wdata),
        .b_we(b_we), .b_addr(b_addr), .b_wdata(b_wdata),
        .start(start), .busy(busy), .done(done),
        .c_addr(c_addr), .c_rdata(c_rdata), .cycle_count(cycle_count)
    );

    always #5 clk = ~clk;

    // Golden vectors (spec section 9).
    reg [31:0]       cfg   [0:1];
    reg [DATA_W-1:0] a_mem [0:MAX_CASES*NN-1];
    reg [DATA_W-1:0] b_mem [0:MAX_CASES*NN-1];
    reg [ACC_W-1:0]  c_mem [0:MAX_CASES*NN-1];
    integer          n_cases;

    integer n_checks = 0;
    integer n_fail   = 0;

    // ---- helpers -----------------------------------------------------------

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check(input integer ok, input [8*24-1:0] what, input integer got, input integer expected);
        begin
            n_checks = n_checks + 1;
            if (!ok) begin
                if (n_fail < MAX_REPORTED)
                    $display("  FAIL %0s: got %0d, expected %0d", what, got, expected);
                n_fail = n_fail + 1;
            end
        end
    endtask

    // Every address of C reads zero (after reset).
    task check_c_zero(input [8*24-1:0] what);
        integer addr;
        begin
            for (addr = 0; addr < NN; addr = addr + 1) begin
                c_addr = addr;
                #0.1;
                check(c_rdata === 0, what, c_rdata, 0);
            end
        end
    endtask

    // Print the seed line of manifest.txt, so the log records the vector seed.
    task print_vector_seed;
        integer fd, seed_val, r;
        reg [8*128-1:0] line;
        begin
            fd = $fopen("sim/vectors/manifest.txt", "r");
            if (fd == 0) begin
                $display("FAIL tb_systolic_top: cannot open sim/vectors/manifest.txt (run make vectors)");
                $fatal(1, "missing vectors");
            end
            while (!$feof(fd)) begin
                r = $fgets(line, fd);
                if (r > 0 && $sscanf(line, "seed = %d", seed_val) == 1)
                    $display("vectors: seed = %0d", seed_val);
            end
            $fclose(fd);
        end
    endtask

    // ---- the test sequence -------------------------------------------------

    initial begin
        $dumpfile("build/tb_systolic_top.vcd");
        $dumpvars(0, tb_systolic_top);

        // Load the vectors and check they were made for this N.
        $readmemh("sim/vectors/config.hex", cfg);
        n_cases = cfg[1];
        $display("vectors: N = %0d, cases = %0d", cfg[0], n_cases);
        print_vector_seed;
        if (cfg[0] !== N || n_cases < 1 || n_cases > MAX_CASES) begin
            $display("FAIL tb_systolic_top: config.hex says N = %0d with %0d cases; this testbench has N = %0d",
                     cfg[0], n_cases, N);
            $fatal(1, "vectors do not match this testbench");
        end
        $readmemh("sim/vectors/a.hex", a_mem, 0, n_cases*NN - 1);
        $readmemh("sim/vectors/b.hex", b_mem, 0, n_cases*NN - 1);
        $readmemh("sim/vectors/c.hex", c_mem, 0, n_cases*NN - 1);

        // Reset: every address of C reads 0 and cycle_count is 0 (spec 7.5).
        repeat (2) @(posedge clk);
        #1;
        check(cycle_count === 0, "reset cycle_count", cycle_count, 0);
        check(busy === 1'b0 && done === 1'b0, "reset busy/done", {busy, done}, 0);
        check_c_zero("reset C");
        rst_n = 1'b1;
        tick;

        if (n_fail == 0) begin
            $display("PASS tb_systolic_top %0d/%0d", n_checks, n_checks);
            $finish;
        end else begin
            $display("FAIL tb_systolic_top %0d of %0d checks failed", n_fail, n_checks);
            $fatal(1, "systolic_top does not match the golden vectors");
        end
    end

endmodule

`default_nettype wire
