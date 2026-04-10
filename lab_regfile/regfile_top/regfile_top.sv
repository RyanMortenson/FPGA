/***************************************************************************
* 
* Filename: regfile_top.sv
*
* Author: Ryan Mortenson
* Description: uses regfile
*
****************************************************************************/

module regfile_top (
        input logic         clk,
        input logic [3:0]   data_in,
        input logic [2:0]   addr,
        input logic         btnc,
        input logic         btnd,
        input logic         btnr,
        output logic [7:0]   segment,
        output logic [3:0]  anode
    );

    //intermediate
    logic [3:0] rf_output;
    assign segment[7] = 1;
    assign anode = btnr ? 4'b1111 : 4'b1110;

    regfile regfile_u (.clk(clk), 
                       .din(data_in), 
                       .addr(addr), 
                       .load(btnc), 
                       .clr(btnd), 
                       .q(rf_output));

    seven_segment ss_u (.data(rf_output),
                        .segment(segment[6:0]));



endmodule