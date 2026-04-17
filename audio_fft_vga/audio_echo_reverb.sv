/***************************************************************************
*
* Filename: audio_echo_reverb.sv
*
* Description: Lightweight switch-controlled echo/reverb approximation.
* Processes one stereo sample per sample_strobe using a feedback delay line.
*
****************************************************************************/

module audio_echo_reverb #(
    parameter int SAMPLE_BITS = 24,
    parameter int DELAY_LOG2  = 11 // 2^11 = 2048 samples (~131 ms @ 15.625 kHz)
) (
    input  logic                           clk,
    input  logic                           rst,
    input  logic                           sample_strobe,
    input  logic                           reverb_en,
    input  logic signed [SAMPLE_BITS-1:0]  left_in,
    input  logic signed [SAMPLE_BITS-1:0]  right_in,

    output logic signed [SAMPLE_BITS-1:0]  left_out,
    output logic signed [SAMPLE_BITS-1:0]  right_out
);

    localparam int DELAY_DEPTH = (1 << DELAY_LOG2);

    logic [DELAY_LOG2-1:0] wr_ptr;

    logic signed [SAMPLE_BITS-1:0] delay_mem_l [0:DELAY_DEPTH-1];
    logic signed [SAMPLE_BITS-1:0] delay_mem_r [0:DELAY_DEPTH-1];

    logic signed [SAMPLE_BITS-1:0] delayed_l;
    logic signed [SAMPLE_BITS-1:0] delayed_r;

    logic signed [SAMPLE_BITS+2:0] wet_sum_l;
    logic signed [SAMPLE_BITS+2:0] wet_sum_r;
    logic signed [SAMPLE_BITS+2:0] fb_sum_l;
    logic signed [SAMPLE_BITS+2:0] fb_sum_r;

    function automatic logic signed [SAMPLE_BITS-1:0] sat_sample(input logic signed [SAMPLE_BITS+2:0] value);
        logic signed [SAMPLE_BITS-1:0] max_pos;
        logic signed [SAMPLE_BITS-1:0] min_neg;
        begin
            max_pos = {1'b0, {(SAMPLE_BITS-1){1'b1}}};
            min_neg = {1'b1, {(SAMPLE_BITS-1){1'b0}}};

            if (value > $signed(max_pos)) begin
                sat_sample = max_pos;
            end else if (value < $signed(min_neg)) begin
                sat_sample = min_neg;
            end else begin
                sat_sample = value[SAMPLE_BITS-1:0];
            end
        end
    endfunction

    always_comb begin
        wet_sum_l = $signed(left_in) + ($signed(delayed_l) >>> 2); // x + 0.25*delay
        wet_sum_r = $signed(right_in) + ($signed(delayed_r) >>> 2);

        fb_sum_l = $signed(left_in) + ($signed(delayed_l) >>> 1); // x + 0.5*delay
        fb_sum_r = $signed(right_in) + ($signed(delayed_r) >>> 1);
    end

    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr    <= '0;
            delayed_l <= '0;
            delayed_r <= '0;
            left_out  <= '0;
            right_out <= '0;
            for (i = 0; i < DELAY_DEPTH; i++) begin
                delay_mem_l[i] <= '0;
                delay_mem_r[i] <= '0;
            end
        end else if (sample_strobe) begin
            delayed_l <= delay_mem_l[wr_ptr];
            delayed_r <= delay_mem_r[wr_ptr];

            if (reverb_en) begin
                left_out  <= sat_sample(wet_sum_l);
                right_out <= sat_sample(wet_sum_r);
                delay_mem_l[wr_ptr] <= sat_sample(fb_sum_l);
                delay_mem_r[wr_ptr] <= sat_sample(fb_sum_r);
            end else begin
                // Dry passthrough default path.
                left_out  <= left_in;
                right_out <= right_in;
                delay_mem_l[wr_ptr] <= left_in;
                delay_mem_r[wr_ptr] <= right_in;
            end

            wr_ptr <= wr_ptr + 1'b1;
        end
    end

endmodule
