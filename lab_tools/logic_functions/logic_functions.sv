/***************************************************************************
* 
* Filename: logic_functions.sv
*
* Author: Ryan Mortenson
* Description: Implements the following logic functions: O1 = AC+A'B, O2 = (A+C')(BC)
*
****************************************************************************/

module logic_functions (
        input logic     A,
        input logic     B,
        input logic     C,
        output logic    O1,
        output logic    O2
    );

    // O1 = AC+A'B
    logic not_A, A_and_C, notA_and_B;
    not(not_A, A);
    and(A_and_C, A, C);
    and(notA_and_B, not_A, B);
    or(O1, A_and_C, notA_and_B);

    // O2 = (A+C')(BC)
    logic not_C, A_or_not_C, B_and_C;
    not(not_C, C);
    or(A_or_not_C, A, not_C);
    and(B_and_C, B, C);
    and(O2, A_or_not_C, B_and_C);

endmodule