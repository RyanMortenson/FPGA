/***************************************************************************
* 
* Filename: arithmetic_top.sv
*
* Author: Ryan Mortenson
* Description: top level module for arithmetic
*
****************************************************************************/

module arithmetic_top (
        input logic [15:0]   sw, // ‘input switches
        input logic          btnc, // center button
        output logic [8:0]    led // led output
    );

    // intermediate signals
    logic [7:0] a, b;
    logic a7, b7, s7, a7_not, b7_not, s7_not;
    logic g, f;

    // mux: inverts switches [15:8] if btnc is pressed
    xor(b[0], sw[8], btnc);
    xor(b[1], sw[9], btnc);
    xor(b[2], sw[10], btnc);
    xor(b[3], sw[11], btnc);
    xor(b[4], sw[12], btnc);
    xor(b[5], sw[13], btnc);
    xor(b[6], sw[14], btnc);
    xor(b[7], sw[15], btnc);

    //overflow detector 1
    not(a7_not, sw[7]);
    not(b7_not, b[7]);
    not(s7_not, led[7]);
    and(g, a7_not, b7_not, led[7]);
    and(f, sw[7], b[7], s7_not);
    or(led[8], g, f);




    add_8 Add8(
        .a      (sw[7:0]),
        .b      (b[7:0]),
        .cin    (btnc),
        .s      (led[7:0]),
        .co     (co)
    );


endmodule