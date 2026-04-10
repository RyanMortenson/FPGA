module LUT4(output O, input I0, I1, I2, I3);
  parameter [15:0] INIT = 0;
  wire [ 7: 0] s3 = I3 ? INIT[15: 8] : INIT[ 7: 0];
  wire [ 3: 0] s2 = I2 ?   s3[ 7: 4] :   s3[ 3: 0];
  wire [ 1: 0] s1 = I1 ?   s2[ 3: 2] :   s2[ 1: 0];
  assign O = I0 ? s1[1] : s1[0];
endmodule

module FDCE #(
  parameter [0:0] INIT = 1'b0)(
  output Q,
  
  input C,
  input CE,
  input CLR,
  input D
);
    reg Q_out = INIT;
    always @(posedge C or posedge CLR)
        if (CLR || (CLR === 1'bx && Q_out == 1'b0))
            Q_out <= 1'b0;
        else if (CE || (CE === 1'bz) || ((CE === 1'bx) && (Q_out == D)))
            Q_out <= D;
    assign Q = Q_out;

endmodule
