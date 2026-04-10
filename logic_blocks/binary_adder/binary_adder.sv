// binary_adder.sv
//
// Perform binary addition on two 2-bit signals to produce a 3-bit output.
//


module binary_adder (
        input logic [1:0] A,
        input logic [1:0] B,
        output logic [2:0] O
    );
    // Carry intermediate signals
    logic [1:0] carry;
    // Intermediate signals
    logic a1_and_b1, a1_and_c0, b1_and_c0;

    // Bit 0
    xor(O[0], A[0], B[0]);                         // sum[0]
    and(carry[0], A[0], B[0]);                     // carry[0]
    // Bit 1
    xor(O[1], A[1], B[1], carry[0]);               // sum[1]
    and(a1_and_b1 ,A[1], B[1]);
    and(a1_and_c0, A[1], carry[0]);
    and(b1_and_c0, B[1], carry[0]);
    or(carry[1], a1_and_b1, a1_and_c0, b1_and_c0); // carry[1]
    // Bit 2
    buf(O[2], carry[1]);

endmodule
