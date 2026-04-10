/***************************************************************************
* 
* Filename: full_add.sv
*
* Author: Ryan Mortenson
* Description: implements a full adder function
*
****************************************************************************/

module full_add (
        input logic     a, // ‘a’ operand input
        input logic     b, // ‘b’ operand input
        input logic     cin, // Carry in
        output wire    s, //Sum output
        output wire    co // Carry out output
    );

    xor(s, a, b, cin); // Full adder gives s

    // Intermediate signals
    logic a_and_b, b_and_cin, a_and_cin;

    and(a_and_b, a, b);
    and(b_and_cin, b, cin);
    and(a_and_cin, a, cin);
    or(co, a_and_b, b_and_cin, a_and_cin); // or's the anded signals to give carry out
   

endmodule