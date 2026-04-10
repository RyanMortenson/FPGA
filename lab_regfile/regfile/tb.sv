//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb_regfile.sv
//
//////////////////////////////////////////////////////////////////////////////////

module tb();

    logic clk, load, clr;
    logic [2:0] addr;
    logic [3:0] din, q;
    integer i,errors;
    logic [3:0] regfile_array [7:0];

    task automatic write_reg( input [3:0] data, input [2:0] address );
        // set address and data
        @(negedge clk);
        din = data;
        addr = address;
        load = 1;
        $display("[%0t] Writing 0x%h to address %h", $time, data, address);
        regfile_array[address] = data;
        @(negedge clk);
        load = 0;
        // Check output
        if (q !== data) begin
            $display("*** Error: q should be 0x%h but is 0x%h at time %0t", data, q, $time);
            errors = errors + 1;
        end
    endtask

    task automatic write_sequential( input [3:0] data);
        // set address and data
        @(negedge clk);
        for(i=0; i < 8; i=i+1) begin
            write_reg( data + i, i );
        end
    endtask

    task automatic rand_write();
        addr = $urandom_range(0,7);
        din = $urandom_range(0,15);
        write_reg(din, addr);
    endtask

    task automatic rand_read();
        addr = $urandom_range(0,7);
        @(negedge clk);
        // Check output
        if (q !== regfile_array[addr]) begin
            $display("*** Error: q should be 0x%h but is 0x%h at time %0t", regfile_array[addr], q, $time);
            errors = errors + 1;
        end
    endtask

    task automatic check_clear();
        // Check to make sure all registers are cleared
        $display("[%0t] Checking for empty register file", $time);
        for(i=0; i < 8; i=i+1) begin
            addr = i;
            @(negedge clk);
            if (q !== 0) begin
                $display("*** Error: q should be 0 for address %0d but is 0x%h at time %0t", i, q,  $time);
                errors = errors + 1;
            end
        end
    endtask

    task automatic set_clear();
        // Check to make sure all registers are cleared
        $display("[%0t] Set Clear", $time);
        clr = 1;
        @(negedge clk);
        for(i=0; i < 8; i=i+1)
            regfile_array[i] = 0;
        clr = 0;
        @(negedge clk);
    endtask

    // Instance the Seven-Segment display
    regfile dut(.clk(clk), .load(load), .clr(clr), .addr(addr), .din(din), .q(q));

    //////////////////////////////////////////////////////////////////////////////////
    // Clock Generator
    //////////////////////////////////////////////////////////////////////////////////
    always
    begin
        clk <=1; #5ns;
        clk <=0; #5ns;
    end

    initial begin

        errors = 0;
        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);
        $display("*** Start of Simulation ***");

        // Run a few clocks with no input sets
        repeat(5) @(negedge clk)
        // set defaults
        load = 0;
        clr = 0;
        addr = 0;
        din = 0;
        // Run a few clocks to get past GSR
        repeat(5) @(negedge clk);

        // Check initial clear
        check_clear();
        write_sequential(4'b0001);
        write_sequential(4'b1000);
        // Clear register file
        repeat(3) @(negedge clk);
        set_clear();
        repeat(3) @(negedge clk);
        check_clear();
        for (i=0; i < 32; i=i+1) begin
            rand_write();
            rand_read();
        end
        #20

        $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
        $finish;

    end  // end begin

endmodule