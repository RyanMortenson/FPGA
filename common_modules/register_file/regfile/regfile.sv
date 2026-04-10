/***************************************************************************
* 
* Filename: regfile.sv
*
* Author: Ryan Mortenson
* Description: uses reg4 to crate a register file with 8 entries
*
****************************************************************************/

module regfile (
        input logic         clk,
        input logic [3:0]   din,
        input logic [2:0]   addr,
        input logic         load,
        input logic         clr,
        output logic [3:0]  q
    );

    //intermediate boi
    logic [3:0] q0, q1, q2, q3, q4, q5, q6, q7;

    logic a0n, a1n, a2n, a0, a1, a2;
    logic l0, l1, l2, l3, l4, l5, l6, l7;

    

    assign q = (addr == 3'b000) ? q0 :
               (addr == 3'b001) ? q1 :
               (addr == 3'b010) ? q2 :
               (addr == 3'b011) ? q3 :
               (addr == 3'b100) ? q4 :
               (addr == 3'b101) ? q5 :
               (addr == 3'b110) ? q6 : q7;

    assign a0n = ~addr[0];
    assign a1n = ~addr[1];
    assign a2n = ~addr[2];
    assign a0 = addr[0];
    assign a1 = addr[1];
    assign a2 = addr[2];

    assign l0 = load & a2n & a1n & a0n;
    assign l1 = load & a2n & a1n & a0;
    assign l2 = load & a2n & a1 & a0n;
    assign l3 = load & a2n & a1 & a0;
    assign l4 = load & a2 & a1n & a0n;
    assign l5 = load & a2 & a1n & a0;
    assign l6 = load & a2 & a1 & a0n;
    assign l7 = load & a2 & a1 & a0;



    reg4 reg4_0 (.clk(clk), .din(din), .load(l0), .clr(clr), .q(q0));
    reg4 reg4_1 (.clk(clk), .din(din), .load(l1), .clr(clr), .q(q1));
    reg4 reg4_2 (.clk(clk), .din(din), .load(l2), .clr(clr), .q(q2));
    reg4 reg4_3 (.clk(clk), .din(din), .load(l3), .clr(clr), .q(q3));
    reg4 reg4_4 (.clk(clk), .din(din), .load(l4), .clr(clr), .q(q4));
    reg4 reg4_5 (.clk(clk), .din(din), .load(l5), .clr(clr), .q(q5));
    reg4 reg4_6 (.clk(clk), .din(din), .load(l6), .clr(clr), .q(q6));
    reg4 reg4_7 (.clk(clk), .din(din), .load(l7), .clr(clr), .q(q7));

endmodule