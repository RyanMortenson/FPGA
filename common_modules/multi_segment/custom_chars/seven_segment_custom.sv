/***************************************************************************
*
* Filename: seven_segment_custom.sv
*
* Description: Seven-segment decoder with support for built-in alphanumeric
*              characters and fully custom user-defined segment bitmaps.
*
****************************************************************************/

module seven_segment_custom (
    input  logic [5:0] char_code,
    input  logic       use_custom,
    input  logic [6:0] custom_segments,
    output logic [6:0] segment
);

    logic [6:0] builtin_segment;

    always_comb begin
        case (char_code)
            // Hex digits
            6'h00: builtin_segment = 7'b1000000; // 0
            6'h01: builtin_segment = 7'b1111001; // 1
            6'h02: builtin_segment = 7'b0100100; // 2
            6'h03: builtin_segment = 7'b0110000; // 3
            6'h04: builtin_segment = 7'b0011001; // 4
            6'h05: builtin_segment = 7'b0010010; // 5
            6'h06: builtin_segment = 7'b0000010; // 6
            6'h07: builtin_segment = 7'b1111000; // 7
            6'h08: builtin_segment = 7'b0000000; // 8
            6'h09: builtin_segment = 7'b0010000; // 9
            6'h0A: builtin_segment = 7'b0001000; // A
            6'h0B: builtin_segment = 7'b0000011; // b
            6'h0C: builtin_segment = 7'b1000110; // C
            6'h0D: builtin_segment = 7'b0100001; // d
            6'h0E: builtin_segment = 7'b0000110; // E
            6'h0F: builtin_segment = 7'b0001110; // F

            // Extra useful characters
            6'h10: builtin_segment = 7'b1000111; // L
            6'h11: builtin_segment = 7'b0101011; // n
            6'h12: builtin_segment = 7'b0001100; // P
            6'h13: builtin_segment = 7'b1000001; // U
            6'h14: builtin_segment = 7'b0101111; // r
            6'h15: builtin_segment = 7'b0001001; // H
            6'h16: builtin_segment = 7'b0000111; // t
            6'h17: builtin_segment = 7'b0000001; // O
            6'h18: builtin_segment = 7'b1111111; // blank
            6'h19: builtin_segment = 7'b0111111; // '-'

            default: builtin_segment = 7'b1111111; // blank
        endcase
    end

    always_comb begin
        if (use_custom) segment = custom_segments;
        else segment = builtin_segment;
    end

endmodule
