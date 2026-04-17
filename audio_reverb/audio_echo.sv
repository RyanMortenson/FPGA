module audio_echo #(
    parameter int SAMPLE_BITS = 24,
    parameter int DELAY_LOG2  = 10
) (
    input  logic                           clk,
    input  logic                           rst,
    input  logic                           sample_strobe,
    input  logic                           effect_en,
    input  logic signed [SAMPLE_BITS-1:0]  left_in,
    input  logic signed [SAMPLE_BITS-1:0]  right_in,
    output logic signed [SAMPLE_BITS-1:0]  left_out,
    output logic signed [SAMPLE_BITS-1:0]  right_out
);
    localparam int DEPTH = (1 << DELAY_LOG2);

    logic [DELAY_LOG2-1:0] wr_ptr;
    logic signed [SAMPLE_BITS-1:0] delay_l [0:DEPTH-1];
    logic signed [SAMPLE_BITS-1:0] delay_r [0:DEPTH-1];

    logic signed [SAMPLE_BITS-1:0] tap_l;
    logic signed [SAMPLE_BITS-1:0] tap_r;

    logic signed [SAMPLE_BITS+2:0] wet_l;
    logic signed [SAMPLE_BITS+2:0] wet_r;
    logic signed [SAMPLE_BITS+2:0] fb_l;
    logic signed [SAMPLE_BITS+2:0] fb_r;

    function automatic logic signed [SAMPLE_BITS-1:0] sat24(input logic signed [SAMPLE_BITS+2:0] v);
        logic signed [SAMPLE_BITS-1:0] max_pos;
        logic signed [SAMPLE_BITS-1:0] min_neg;
        begin
            max_pos = {1'b0, {(SAMPLE_BITS-1){1'b1}}};
            min_neg = {1'b1, {(SAMPLE_BITS-1){1'b0}}};
            if (v > $signed(max_pos)) sat24 = max_pos;
            else if (v < $signed(min_neg)) sat24 = min_neg;
            else sat24 = v[SAMPLE_BITS-1:0];
        end
    endfunction

    always_comb begin
        wet_l = $signed(left_in) + ($signed(tap_l) >>> 2);
        wet_r = $signed(right_in) + ($signed(tap_r) >>> 2);
        fb_l = $signed(left_in) + ($signed(tap_l) >>> 1);
        fb_r = $signed(right_in) + ($signed(tap_r) >>> 1);
    end

    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            tap_l <= '0;
            tap_r <= '0;
            left_out <= '0;
            right_out <= '0;
            for (i = 0; i < DEPTH; i++) begin
                delay_l[i] <= '0;
                delay_r[i] <= '0;
            end
        end else if (sample_strobe) begin
            tap_l <= delay_l[wr_ptr];
            tap_r <= delay_r[wr_ptr];

            if (effect_en) begin
                left_out <= sat24(wet_l);
                right_out <= sat24(wet_r);
                delay_l[wr_ptr] <= sat24(fb_l);
                delay_r[wr_ptr] <= sat24(fb_r);
            end else begin
                left_out <= left_in;
                right_out <= right_in;
                delay_l[wr_ptr] <= left_in;
                delay_r[wr_ptr] <= right_in;
            end
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
endmodule
