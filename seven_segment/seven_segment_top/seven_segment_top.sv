/***************************************************************************
* 
* Filename: seven_segment_top.sv
*
* Author: Ryan Mortenson
* Description: top level module seven_segment
*
****************************************************************************/

module seven_segment_top (
        input logic [3:0]   sw, // ‘input switches
        input logic         btnc, // center button
        input logic         btnl, // left button
        input logic         btnr, // right button
        output logic [6:0]  seg,  // seven segment display
        output logic        dp,
        output logic [3:0]  an //anode signals for each digit (4 total)
    );

   seven_segment sseg (
    .data(sw),
    .segment(seg[6:0])
   );

   //digit point
   assign dp = !btnc;

   assign an = btnr ? 4'b1111 :
                  btnl ? 4'b0000 :
                  (btnl & btnr) ? 4'b0000 : 4'b1110;




endmodule