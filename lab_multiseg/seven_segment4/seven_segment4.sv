/***************************************************************************
* 
* Filename: seven_segment4.sv
*
* Author: Ryan Mortenson
* Description: drives four-digit seven segment display on the Basys3 board
*
****************************************************************************/

module seven_segment4 #(
    parameter CLK_FREQUENCY = 100_000_000, //Specifies the frequency of the input clock
    parameter REFRESH_RATE  = 200 // Specifies the display refresh rate in Hz
) (
    input logic          clk,   //Clock input
    input logic          rst,   //Reset input
    input logic [15:0]   data_in,   //Indicates the 16-bit value to display on the 4 digits
    input logic [3:0]    blank,     //Indicates which digits to blank
    input logic [3:0]    dp_in,     //Indicates which digit points to display
    output logic [7:0]   segment,   //Cathode signals for seven-segment display (including digit point). segment[0] corresponds to CA and segment[6] corresponds to CG, and segment[7] corresponds to DP.
    output logic [3:0]   anode    //Anode signals for each of the four digits.
);


// Determine the number of clock cycles to display each digit
localparam DIGIT_DISPLAY_CLOCKS = CLK_FREQUENCY / REFRESH_RATE / 4;

// Determine the number of bits needed to represent the maximum count value
localparam DIGIT_COUNTER_WIDTH = $clog2(DIGIT_DISPLAY_CLOCKS);

// Declare a signal used for this counter signal
logic [DIGIT_COUNTER_WIDTH-1:0] digit_display_counter;

//Intermediate signals
logic [1:0] digit_select;
logic [3:0] display_data;

//Counter that rolls over every n=DIGIT_DISPLAY_CLOCKS cycles
always_ff @(posedge clk) begin
    if (rst) digit_display_counter <= 0;
    else if (digit_display_counter == DIGIT_DISPLAY_CLOCKS-1) digit_display_counter <= 0;
    else digit_display_counter <= digit_display_counter + 1;
end

//Counter that rolls over every n=DIGIT_DISPLAY_CLOCKS cycles
always_ff @(posedge clk) begin
    if (rst) digit_select <= 0;
    else if (digit_display_counter == DIGIT_DISPLAY_CLOCKS-1) digit_select <= digit_select + 1;
    else digit_select <= digit_select;
end

//Mux who's output will be used as the input to the seven segment decoder
always_comb begin
    case (digit_select)
        2'b00: display_data = data_in[3:0];
        2'b01: display_data = data_in[7:4];
        2'b10: display_data = data_in[11:8];
        default: display_data = data_in[15:12];
    endcase
end

seven_segment ssg(.data(display_data), .segment(segment[6:0]));

//Choose which segment gets the dp
always_comb begin
    case (digit_select)
        2'b00: segment[7] = ~dp_in[0];
        2'b01: segment[7] = ~dp_in[1];
        2'b10: segment[7] = ~dp_in[2];
        default: segment[7] = ~dp_in[3];
    endcase
end


//Anode signal multiplexer
always_comb begin
    case (digit_select)
        2'b00: anode = (blank[0]) ? 4'b1111 : 4'b1110;
        2'b01: anode = (blank[1]) ? 4'b1111 : 4'b1101;
        2'b10: anode = (blank[2]) ? 4'b1111 : 4'b1011;
        default: anode = (blank[3]) ? 4'b1111 : 4'b0111;
    endcase
end



endmodule