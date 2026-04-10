/***************************************************************************
* 
* Filename: add_8.sv
*
* Author: Ryan Mortenson
* Description: implements a full adder function
*
****************************************************************************/

module add_8 (
        input logic  [7:0]   a, // ‘a’ operand input
        input logic  [7:0]   b, // ‘b’ operand input
        input logic         cin, // Carry in
        output wire [7:0]   s, //Sum output
        output wire         co // Carry out output
    );

    //intermediate signals
    logic [6:0] carry;

    //full_adder 0
    full_add full_adder0(
        .a      (a[0]),
        .b      (b[0]),
        .cin    (cin),
        .s      (s[0]),
        .co     (carry[0])
    );

    //full_adder 1
    full_add full_adder1(
        .a      (a[1]),
        .b      (b[1]),
        .cin    (carry[0]),
        .s      (s[1]),
        .co     (carry[1])
    );

    //full_adder 2
    full_add full_adder2(
        .a      (a[2]),
        .b      (b[2]),
        .cin    (carry[1]),
        .s      (s[2]),
        .co     (carry[2])
    );

    //full_adder 3
    full_add full_adder3(
        .a      (a[3]),
        .b      (b[3]),
        .cin    (carry[2]),
        .s      (s[3]),
        .co     (carry[3])
    );

    //full_adder 4
    full_add full_adder4(
        .a      (a[4]),
        .b      (b[4]),
        .cin    (carry[3]),
        .s      (s[4]),
        .co     (carry[4])
    );

    //full_adder 5
    full_add full_adder5(
        .a      (a[5]),
        .b      (b[5]),
        .cin    (carry[4]),
        .s      (s[5]),
        .co     (carry[5])
    );

    //full_adder 6
    full_add full_adder6(
        .a      (a[6]),
        .b      (b[6]),
        .cin    (carry[5]),
        .s      (s[6]),
        .co     (carry[6])
    );

    //full_adder 7
    full_add full_adder7(
        .a      (a[7]),
        .b      (b[7]),
        .cin    (carry[6]),
        .s      (s[7]),
        .co     (co)
    );

endmodule