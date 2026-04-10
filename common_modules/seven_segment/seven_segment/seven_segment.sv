/***************************************************************************
* 
* Filename: seven_segment.sv
*
* Author: Ryan Mortenson
* Description: powers seven segment display
*
****************************************************************************/

module seven_segment (
        input logic [3:0] data,
        output logic [6:0] segment
    );

    /////////////////
    // Segment A
    /////////////////

    //intermediate signals
    logic m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;

    assign m1 = (!data[3] & !data[2] & !data[1] & data[0]);
    assign m4 = (!data[3] & data[2] & !data[1] & !data[0]);
    assign m11 = (data[3] & !data[2] & data[1] & data[0]);
    assign m13 = (data[3] & data[2] & !data[1] & data[0]);

    assign segment[0] = (m1 | m4 | m11 | m13);


    /////////////////
    // Segment B
    /////////////////
    logic M0, M1, M2, M3, M4, M7, M8, M9, M10, M13;
    assign M0 =  (data[3] | data[2] | data[1] | data[0]);
    assign M1 =  (data[3] | data[2] | data[1] | !data[0]);
    assign M2 =  (data[3] | data[2] | !data[1] | data[0]);
    assign M3 =  (data[3] | data[2] | !data[1] | !data[0]);
    assign M4 =  (data[3] | !data[2] | data[1] | data[0]);
    assign M7 =  (data[3] | !data[2] | !data[1] | !data[0]);
    assign M8 =  (!data[3] | data[2] | data[1] | data[0]);
    assign M9 =  (!data[3] | data[2] | data[1] | !data[0]);
    assign M10 = (!data[3] | data[2] | !data[1] | data[0]);
    assign M13 = (!data[3] | !data[2] | data[1] | !data[0]);

    assign segment[1] = (M0 & M1 & M2 & M3 & M4 & M7 & M8 & M9 & M10 & M13);


    /////////////////
    // Segment C
    /////////////////
    logic m2g, m12g, m14g, m15g;
    and(m2g, !data[3], !data[2], data[1], !data[0]);
    and(m12g, data[3], data[2], !data[1], !data[0]);
    and(m14g, data[3], data[2], data[1], !data[0]);
    and(m15g, data[3], data[2], data[1], data[0]);
    or(segment[2], m2g, m12g, m14g, m15g);


    /////////////////
    // Segment D
    /////////////////
    LUT4 #(.INIT(16'b1000010010010010)
    ) seg_LUT (
        .O(segment[3]),
        .I0(data[0]),
        .I1(data[1]),
        .I2(data[2]),
        .I3(data[3])
        );


    /////////////////
    // Segment E
    /////////////////
    logic M0g, M2g, M6g, M8g, M10g, M11g, M12g, M13g, M14g, M15g;
    or(M0g, data[3], data[2], data[1], data[0]);
    or(M2g, data[3], data[2], !data[1], data[0]);
    or(M6g, data[3], !data[2], !data[1], data[0]);
    or(M8g, !data[3], data[2], data[1], data[0]);
    or(M10g, !data[3], data[2], !data[1], data[0]);
    or(M11g, !data[3], data[2], !data[1], !data[0]);
    or(M12g, !data[3], !data[2], data[1], data[0]);
    or(M13g, !data[3], !data[2], data[1], !data[0]);
    or(M14g, !data[3], !data[2], !data[1], data[0]);
    or(M15g, !data[3], !data[2], !data[1], !data[0]);
    and(segment[4], M0g, M2g, M6g, M8g, M10g, M11g, M12g, M13g, M14g, M15g);
    

    /////////////////
    // Segment F
    /////////////////
    assign segment[5] = (data == 4'b0001 ? 1 : 
                         data == 4'b0010 ? 1 : 
                         data == 4'b0011 ? 1 : 
                         data == 4'b0111 ? 1 : 
                         data == 4'b1101 ? 1 : 0
                        );

    /////////////////
    // Segment G
    /////////////////
    logic m0n, m1n, m7n, m12n, and0, and1, and7, and12;
    nand(and0, !data[3], !data[2], !data[1], !data[0]);
    nand(and1, !data[3], !data[2], !data[1], data[0]);
    nand(and7, !data[3], data[2], data[1], data[0]);
    nand(and12, data[3], data[2], !data[1], !data[0]);
    nand(m0n, and0, and0);
    nand(m1n, and1, and1);
    nand(m7n, and7, and7);
    nand(m12n, and12, and12);

    nand(segment[6], and0, and1, and7, and12); //or gate




endmodule