module tb();
    logic [5:0] char_code;
    logic       use_custom;
    logic [6:0] custom_segments;
    logic [6:0] segment;

    int errors = 0;

    seven_segment_custom dut (
        .char_code(char_code),
        .use_custom(use_custom),
        .custom_segments(custom_segments),
        .segment(segment)
    );

    task automatic expect(input logic [6:0] expected, input string msg);
        #1;
        if (segment !== expected) begin
            $display("ERROR %s: got %b expected %b", msg, segment, expected);
            errors++;
        end
    endtask

    initial begin
        // Built-in map checks
        use_custom = 1'b0;
        custom_segments = 7'b1111111;

        char_code = 6'h00; expect(7'b1000000, "hex 0");
        char_code = 6'h0A; expect(7'b0001000, "hex A");
        char_code = 6'h0F; expect(7'b0001110, "hex F");
        char_code = 6'h10; expect(7'b1000111, "L");
        char_code = 6'h12; expect(7'b0001100, "P");
        char_code = 6'h18; expect(7'b1111111, "blank");

        // Unknown code should blank
        char_code = 6'h3F; expect(7'b1111111, "unknown");

        // Custom pattern override checks
        use_custom = 1'b1;
        char_code = 6'h00;

        custom_segments = 7'b1010101; expect(7'b1010101, "custom 1");
        custom_segments = 7'b0101010; expect(7'b0101010, "custom 2");

        if (errors == 0) begin
            $display("PASS: seven_segment_custom testbench completed without errors.");
        end else begin
            $display("FAIL: seven_segment_custom had %0d error(s).", errors);
        end

        $finish;
    end
endmodule
