/***************************************************************************
*
* Filename: bringup_top.sv
*
* Author: OpenAI Codex
* Description: Minimal Basys3 bring-up design for verifying programming,
*              clocking, LEDs, and button input without any audio logic.
*
****************************************************************************/

module bringup_top (
    input  logic       clk,
    input  logic       btnc,
    output logic [2:0] led
);

logic [25:0] blink_counter;

always_ff @(posedge clk) begin
    blink_counter <= blink_counter + 1'b1;
end

assign led[0] = 1'b1;
assign led[1] = blink_counter[25];
assign led[2] = btnc;

endmodule
