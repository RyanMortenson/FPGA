/***************************************************************************
* 
* Filename: ssd_top.sv
*
* Author: Ryan Mortenson
* Description: top module for seven_segment4
*
****************************************************************************/

module ssd_top #(
    parameter CLK_FREQUENCY = 100_000_000, //Specifies the frequency of the input clock
    parameter REFRESH_RATE  = 200 // Specifies the display refresh rate in Hz
) (
    input logic          clk,        // Clock input
    input logic [15:0]   sw,         // Indicates the 16-bit value to display on the 4 digits
    input logic          btnc,       // Invert (i.e., NOT) the value to display
    input logic          btnd,       // Reset signal
    input logic          btnu,        // Shut off display of digits
    input logic          btnl,       // Turn on all digit points
    input logic          btnr,       // Turn off left two digits
    output logic [7:0]   segment,    // Cathode signals for seven-segment display (including digit point). segment[0] corresponds to CA and segment[6] corresponds to CG, and segment[7] corresponds to DP.
    output logic [3:0]   anode       // Anode signals for each of the four digits.
);

seven_segment4 #(
    .CLK_FREQUENCY(100_000_000),
    .REFRESH_RATE(200)
) ss4_u (
    .clk     (clk),
    .rst     (btnd),
    .data_in (btnc?~sw:sw),
    .blank   (btnu   ? 4'b1111 :
               (btnr ?   4'b1100 :
                         4'b0000)),
    .dp_in   (btnl ? 4'b1111 : 4'b0000),
    .segment (segment),
    .anode   (anode)
);



endmodule