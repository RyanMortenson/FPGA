/***************************************************************************
* 
* Filename: reg4.sv
*
* Author: Ryan Mortenson
* Description: Creates a 4 bit register that can store 4-bit values
*
****************************************************************************/

module reg4 (
        input logic         clk,
        input logic [3:0]   din,
        input logic         load,
        input logic         clr,
        output logic [3:0]  q
    );

    
    FDCE my_ff_0 (.Q(q[0]), .C(clk), .CE(load), .CLR(clr), .D(din[0]));
    FDCE my_ff_1 (.Q(q[1]), .C(clk), .CE(load), .CLR(clr), .D(din[1]));
    FDCE my_ff_2 (.Q(q[2]), .C(clk), .CE(load), .CLR(clr), .D(din[2]));
    FDCE my_ff_3 (.Q(q[3]), .C(clk), .CE(load), .CLR(clr), .D(din[3]));

endmodule