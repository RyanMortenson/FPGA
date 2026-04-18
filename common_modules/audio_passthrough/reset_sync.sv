/***************************************************************************
*
* Filename: reset_sync.sv
*
* Author: OpenAI Codex
* Description: Synchronously deasserts an active-high reset.
*
****************************************************************************/

module reset_sync #(
    parameter STAGES = 2
)(
    input  logic clk,
    input  logic rst_in,
    output logic rst_out
);

logic [STAGES-1:0] sync_ff;

always_ff @(posedge clk or posedge rst_in) begin
    if (rst_in) begin
        sync_ff <= '1;
    end else begin
        if (STAGES == 1) begin
            sync_ff <= 1'b0;
        end else begin
            sync_ff <= {sync_ff[STAGES-2:0], 1'b0};
        end
    end
end

assign rst_out = sync_ff[STAGES-1];

endmodule
