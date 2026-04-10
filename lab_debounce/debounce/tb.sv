//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb_debounce.sv
//
//////////////////////////////////////////////////////////////////////////////////

module tb #(
    parameter CLK_FREQUENCY     = 100_000_000, 
    parameter WAIT_TIME_US      = 5000,
    parameter NUMBER_OF_PULSES  = 4
) ();

    localparam WAIT_CLOCKS = CLK_FREQUENCY / 1_000_000 * WAIT_TIME_US;
    localparam MAX_WAIT_CLOCKS = WAIT_CLOCKS + 1;
    localparam MIN_WAIT_CLOCKS = WAIT_CLOCKS - 1;
    localparam MIN_BOUNCE_CLOCKS = WAIT_CLOCKS / 50 + 1;
    localparam MAX_BOUNCE_CLOCKS = WAIT_CLOCKS / 2 + 2;
    localparam MIN_WAIT_NS = (WAIT_TIME_US - 1) * 1000;
    localparam MAX_WAIT_NS = (WAIT_TIME_US + 1) * 1000;

    logic clk, tb_noisy, tb_noisy_d, tb_debounced, tb_debounced_d, reset;

    integer i, j, errors, max_error, clk_count;
    time noisy_tt = 0; // noisy transition time
    time noisy_delay;

    // ---------------------------------------------------------------------
    //  NOISY PULSE TASK
    //  - produces short toggles (false pulses)
    //  - ends by holding tb_noisy stable for WAIT_CLOCKS cycles
    //  - false_pulses: the number of pulses to create
    //  - min_false_pulse_cycles: the minimum number of cycles for each phase of the noisy pulse
    //  - max_false_pulse_cycles: the maximum number of cycles for each phase of the noisy pulse
    // ---------------------------------------------------------------------
    task automatic noisy_pulse(input int false_pulses, input int min_false_pulse_cycles, input int max_false_pulse_cycles );
        integer pulse_cycles;
        //time p_time;
        @ (negedge clk);

        // Create short toggles
        // $display("[%0t] noisy start at %0b", $time, tb_noisy);
        for (i=0; i<false_pulses; i=i+1) begin
            // Toggle the noisy signal and wait
            tb_noisy = ~tb_noisy;
            pulse_cycles = $urandom_range(max_false_pulse_cycles, min_false_pulse_cycles);
            // $display("[%0t] noisy %b for %0d clocks", $time, tb_noisy, pulse_cycles);
            repeat (pulse_cycles) @ (negedge clk);

            // Toggle back to its original value and wait
            tb_noisy = ~tb_noisy;
            pulse_cycles = $urandom_range(max_false_pulse_cycles, min_false_pulse_cycles);
            // $display("[%0t] noisy %b for %0d clocks", $time, tb_noisy, pulse_cycles);
            repeat (pulse_cycles) @ (negedge clk);
        end

        // Toggle to its new value and hold it stable 
        tb_noisy = ~tb_noisy;
        // Wait long enough for the debouncer to detect
        pulse_cycles = WAIT_CLOCKS + $urandom%min_false_pulse_cycles;
        // $display("[%0t] noisy to stabelize at %0b for %0d clocks", $time, tb_noisy, pulse_cycles);
        repeat (pulse_cycles) @ (negedge clk);

        // We've held 'noisy' stable for about WAIT_CLOCKS cycles.
        // If the DUT is correct, 'debounced' MUST match tb_noisy now.
        if (tb_debounced !== tb_noisy) begin
            $display("[%0t] *** ERROR: after %0d stable cycles, debounced(%0b) != tb_noisy(%0b) ***", 
                     $time, pulse_cycles, tb_debounced, tb_noisy);
            errors++;
        end

        //$display("[%0t] noisy stabelized at %0b", $time, tb_noisy);
        @(negedge clk);
    endtask


    // Instance the debounce DUT
    debounce #(.CLK_FREQUENCY(CLK_FREQUENCY),.WAIT_TIME_US(WAIT_TIME_US))
    debounce (.clk(clk), .noisy(tb_noisy), .debounced(tb_debounced), .rst(reset));

    // Oscilating clock
    initial begin
        #105; // wait 105 ns before starting clock (after inputs have settled)
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

// Things to do in testbench:
// - Make sure that a pulse is properly passed (if long enough)
// - Make sure that a pulse is properly filtered (if not long enough)
// - Make sure there are no extraneous pulses

    initial begin

        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);
        $display("** Start of Simulation: simulate %0d transitions, debouncer requires %0d clocks",
            NUMBER_OF_PULSES, WAIT_CLOCKS);

        tb_noisy = 0;
        errors = 0;
        max_error = 0;
        reset = 0;

        // Reset Sequence
        repeat(3) @(negedge clk);
        reset = 1;
        repeat(3) @(negedge clk);
        reset = 0;
        @(negedge clk);
        repeat(100) @(negedge clk);

        // Generate pulses
        // Each iteration will create a zero to one transition and then a one to zero transition
        // of a noisy button.

        for (int j=0; j<NUMBER_OF_PULSES; j=j+1) begin
            noisy_pulse($urandom_range(5,2), MIN_BOUNCE_CLOCKS, MAX_BOUNCE_CLOCKS);
        end

        $display("*** Simulation done, WAIT_TIME_US=%0d with %0d errors at time %0t ***", WAIT_TIME_US, errors, $time);
        $finish;

    end  // end initial begin

    // "Too early"/"Too late" checks
    // Identify the last time that the noisy has transitioned
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tb_noisy_d <= tb_noisy;
            tb_debounced_d <= tb_debounced;
            clk_count <= 0;
        end else begin
            tb_noisy_d <= tb_noisy;
            tb_debounced_d <= tb_debounced;

            if (tb_noisy_d != tb_noisy) begin
                // First positive edge in which noisy and noisy_d are different (start of first clock)
                clk_count <= 0;
                noisy_tt = $time;
                $display("[%0t] Noisy input changes to %0b", $time, tb_noisy);
            end else begin
                clk_count <= clk_count + 1;
            end

            if (tb_debounced_d != tb_debounced) begin
                $display("[%0t] Debounce change to %0b after %0d clocks", $time, tb_debounced, clk_count);
                if (clk_count < MIN_WAIT_CLOCKS) begin
                    $display("[%0t] *** Error: Debounce signal changed too soon after %0d clocks ***", $time, clk_count);
                    errors = errors + 1;
                end
                if (clk_count > MAX_WAIT_CLOCKS) begin
                    $display("[%0t] *** Error: Debounce signal changed too late after %0d clocks ***", $time, clk_count);
                    errors = errors + 1;
                end
            end
        end
    end

endmodule
