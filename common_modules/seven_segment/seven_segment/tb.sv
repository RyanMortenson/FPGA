//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb.sv
//
//  Description: Testbench for the seven_segment module
//
//////////////////////////////////////////////////////////////////////////////////

module tb();

    reg [3:0] tb_data;
    wire [6:0] tb_segment;
    integer i,j,errors;

    reg [6:0] segment_const [15:0];

    // Instance the Seven-Segment display
    seven_segment ss(.data(tb_data), .segment(tb_segment));

    initial begin

        errors = 0;
        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);
        $display("*** Start of Simulation ***");

        // Intialize constants
        segment_const[ 0] = 7'b1000000;
        segment_const[ 1] = 7'b1111001;
        segment_const[ 2] = 7'b0100100;
        segment_const[ 3] = 7'b0110000;
        segment_const[ 4] = 7'b0011001;
        segment_const[ 5] = 7'b0010010;
        segment_const[ 6] = 7'b0000010;
        segment_const[ 7] = 7'b1111000;
        segment_const[ 8] = 7'b0000000;
        segment_const[ 9] = 7'b0010000;
        segment_const[10] = 7'b0001000;
        segment_const[11] = 7'b0000011;
        segment_const[12] = 7'b1000110;
        segment_const[13] = 7'b0100001;
        segment_const[14] = 7'b0000110;
        segment_const[15] = 7'b0001110;

        errors = 0;

        // Don't care at this point (emphasize unknowns)
        #20

        // Initialize
        tb_data = 4'b0000;
        #20

        // Test the segments
        for(i=0; i < 16; i=i+1) begin
            #20
            tb_data = i;
            #20
            tb_data = i;
            if (tb_segment == segment_const[i]) begin
                $display("Correct: with data input 0x%1h segments[6:0]=%b at time %0t",
                i, tb_segment, $time);
            end
            //if (tb_segment !== segment_const[i]) begin
            //	$display("*** Error: with data input 0x%1h segment should be '%h' but is '%h' at time %0t",
            //	i, segment_const[i],tb_segment, $time);
            //end
            for (j=0; j < 16; j=j+1) begin
                if (tb_segment[j] !== segment_const[i][j]) begin
                    $display("*** Error: with data input 0x%1h segment[%1d] should be '%1d' but is '%1d' at time %0t",
                    i, j, segment_const[i][j],tb_segment[j], $time);
                    errors = errors + 1;
                end
            end
        end

        #20

        $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);

    end  // end begin

endmodule