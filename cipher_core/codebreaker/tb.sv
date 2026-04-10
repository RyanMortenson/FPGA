// Testbench for codebreaker

module tb #(
    parameter logic [127:0] CYPHERTEXT=128'hca7d05cd7e096d91acaf6fd347ef4994,
    parameter logic [127:0] ERROR_CYPHERTEXT=128'hb8935bbf5f819bcfec46da11d5393d4f,
    parameter logic [23:0] EXPECTED_KEY = 24'h0005,
    parameter logic [127:0] EXPECTED_PLAINTEXT=128'h52205520484156494e472046554e2020) ();

    // Estimate the maximum amount of time to complete the testbench
    localparam time MAX_TIMER_PER_DECRYPT = 12us;
    localparam logic [23:0] TEST_MAX_KEY = 24'h02FF;
    localparam int NUM_DECRYPT_RUNS = 3;
    localparam int MAX_ATTEMPTS_PER_RUN = TEST_MAX_KEY + 1;
    localparam time MAX_SIMULATION_TIME = MAX_TIMER_PER_DECRYPT * MAX_ATTEMPTS_PER_RUN * NUM_DECRYPT_RUNS;

    logic clk, reset, start, done;
    logic [23:0] key;
    logic [127:0] bytes_in, bytes_out;
    int errors = 0;
    int i;
    logic saw_done_deassert;
    logic error;

    codebreaker #(
        .MAX_KEY(TEST_MAX_KEY)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .bytes_in(bytes_in),
        .key(key),
        .bytes_out(bytes_out),
        .done(done),
        .error(error)
    );

    // Clock
    initial begin
        #100ns; // wait 100 ns before starting clock (after inputs have settled)
        clk = 0;
        forever
            #5ns  clk = ~clk;
    end

    // Main test block
    initial begin

        // errors = 0;
        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);
        $display("*** Start of Simulation ***");
        $display("INFO: Test configured for %0d decrypt runs, timeout budget %0t", NUM_DECRYPT_RUNS, MAX_SIMULATION_TIME);
        $display("INFO: DUT MAX_KEY=%h", TEST_MAX_KEY);
        $display("INFO: Expected outcomes: 1) done+no error 2) done+error 3) done+no error");

        reset = 0;
        start = 0;
        bytes_in = 0;
        $display("INFO: Holding reset low for 10 cycles");
        repeat (10) @(negedge clk);
        reset = 1;
        $display("INFO: Asserting reset high for 10 cycles");
        repeat (10) @(negedge clk);
        reset = 0;
        $display("INFO: Reset complete at %0t", $time);

        // RUN1: known-good decrypt should succeed
        $display("====== Run 1. Correct Key = 0x%h (Expect: done + no error) ======", EXPECTED_KEY);
        bytes_in = CYPHERTEXT;
        $display("INFO: RUN1 start: bytes_in=%h", bytes_in);
        start = 1;
        @(negedge clk);
        bytes_in = 128'hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        $display("INFO: RUN1 changed bytes_in after start high to Xs: %h", bytes_in);
        repeat (9) @(negedge clk);
        start = 0;
        $display("INFO: RUN1 start pulse complete, waiting for done...");

        wait(done);
        $display("INFO: RUN1 done observed at %0t, key=%h bytes_out=%h error=%b", $time, key, bytes_out, error);
        if (error) begin
            $display("ERROR: RUN1 expected error=0, got error=1");
            errors = errors + 1;
        end
        if (key != EXPECTED_KEY) begin
            $display("ERROR: Expected key %h, got %h", EXPECTED_KEY, key);
            errors = errors + 1;
        end
        if (bytes_out != EXPECTED_PLAINTEXT) begin
            $display("ERROR: Expected plaintext %h, got %h", EXPECTED_PLAINTEXT, bytes_out);
            errors = errors + 1;
        end

        // done should remain asserted until a new decrypt is started
        $display("INFO: Checking done remains high before RUN2");
        repeat (10) begin
            @(negedge clk);
            if (!done) begin
                $display("ERROR: done deasserted before a new start");
                errors = errors + 1;
                break;
            end
        end
        $display("INFO: done hold-high check complete (done=%b)", done);

        // RUN2: this ciphertext should fail under MAX_KEY=0x02FF
    $display("====== Run 2. Max Key = 0x%h (Expect: done + error) ======", TEST_MAX_KEY);
        bytes_in = ERROR_CYPHERTEXT;
        $display("INFO: RUN2 start: bytes_in=%h", bytes_in);
        start = 1;
        @(negedge clk);
        bytes_in = 128'hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        $display("INFO: RUN2 changed bytes_in after start high to Xs: %h", bytes_in);
        repeat (9) @(negedge clk);
        start = 0;
        $display("INFO: RUN2 start pulse complete, waiting for done to clear then reassert...");

        // done should clear once the new operation has started
        saw_done_deassert = 0;
        for (i = 0; i < 20; i = i + 1) begin
            @(negedge clk);
            if (!done)
                saw_done_deassert = 1;
        end
        if (!saw_done_deassert) begin
            $display("ERROR: done never deasserted after second start");
            errors = errors + 1;
        end else begin
            $display("INFO: RUN2 saw done deassert as expected");
        end

        wait(done);
        $display("INFO: RUN2 done observed at %0t, key=%h bytes_out=%h error=%b", $time, key, bytes_out, error);
        if (!error) begin
            $display("ERROR: RUN2 expected error=1, got error=0");
            errors = errors + 1;
        end

        // done should remain asserted until a new decrypt is started
        $display("INFO: Checking done remains high before RUN3");
        repeat (10) begin
            @(negedge clk);
            if (!done) begin
                $display("ERROR: done deasserted before RUN3 start");
                errors = errors + 1;
                break;
            end
        end

        // RUN3: repeat known-good decrypt and expect success
    $display("====== Run 3. Correct Key = 0x%h (Expect: done + no error) ======", EXPECTED_KEY);
        bytes_in = CYPHERTEXT;
        $display("INFO: RUN3 start: bytes_in=%h", bytes_in);
        start = 1;
        @(negedge clk);
        bytes_in = 128'hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        $display("INFO: RUN3 changed bytes_in after start high to Xs: %h", bytes_in);
        repeat (9) @(negedge clk);
        start = 0;

        saw_done_deassert = 0;
        for (i = 0; i < 20; i = i + 1) begin
            @(negedge clk);
            if (!done)
                saw_done_deassert = 1;
        end
        if (!saw_done_deassert) begin
            $display("ERROR: done never deasserted after RUN3 start");
            errors = errors + 1;
        end

        wait(done);
        $display("INFO: RUN3 done observed at %0t, key=%h bytes_out=%h error=%b", $time, key, bytes_out, error);
        if (error) begin
            $display("ERROR: RUN3 expected error=0, got error=1");
            errors = errors + 1;
        end
        if (key != EXPECTED_KEY) begin
            $display("ERROR: RUN3 expected key %h, got %h", EXPECTED_KEY, key);
            errors = errors + 1;
        end
        if (bytes_out != EXPECTED_PLAINTEXT) begin
            $display("ERROR: RUN3 expected plaintext %h, got %h", EXPECTED_PLAINTEXT, bytes_out);
            errors = errors + 1;
        end

        if (errors == 0) begin
            $display("SUCCESS: All three runs passed at time %0t ***", $time);
        end else begin
            $display("INFO: Test completed with %0d error(s)", errors);
        end
        $finish;

   end  // end initial begin

    // Timeout
    initial begin
        wait(start);
        #MAX_SIMULATION_TIME;
        $display("ERROR: Timeout after %0t (limit %0t)", $time, MAX_SIMULATION_TIME);
        $display("ERROR: Timeout state snapshot done=%b key=%h bytes_out=%h error=%b", done, key, bytes_out, error);
        $finish;
    end

endmodule // tb
