module audio_echo #(
    parameter int IN_BITS     = 24,
    parameter int EFFECT_BITS = 16,
    parameter int DELAY_LOG2  = 12
) (
    input  logic                        clk,
    input  logic                        rst,
    input  logic                        sample_strobe,
    input  logic                        effect_en,
    input  logic signed [IN_BITS-1:0]   left_in,
    input  logic signed [IN_BITS-1:0]   right_in,
    output logic signed [IN_BITS-1:0]   left_out,
    output logic signed [IN_BITS-1:0]   right_out
);
    localparam int DEPTH = (1 << DELAY_LOG2);

    // ------------------------------------------------------------------------
    // Intentionally small echo architecture for Basys3 resource fit:
    //   * ONE mono circular delay buffer (shared by L/R)
    //   * EFFECT_BITS reduced precision in the effect path
    //   * synchronous RAM-style coding to infer FPGA memory (BRAM/LUTRAM),
    //     not a giant FF shift-register structure
    // ------------------------------------------------------------------------
    logic [DELAY_LOG2-1:0] wr_ptr;
    logic signed [EFFECT_BITS-1:0] delay_mem [0:DEPTH-1];
    logic signed [EFFECT_BITS-1:0] delayed_q;

    logic signed [IN_BITS-1:0] dry_mono_24;
    logic signed [EFFECT_BITS-1:0] dry_mono_fx;
    logic signed [EFFECT_BITS+1:0] wet_fx;
    logic signed [EFFECT_BITS+1:0] fb_fx;

    logic signed [IN_BITS-1:0] wet_24;
    logic signed [IN_BITS-1:0] sat_left;
    logic signed [IN_BITS-1:0] sat_right;

    function automatic logic signed [IN_BITS-1:0] sat_in_bits(
        input logic signed [IN_BITS:0] v
    );
        logic signed [IN_BITS-1:0] max_pos;
        logic signed [IN_BITS-1:0] min_neg;
        begin
            max_pos = {1'b0, {(IN_BITS-1){1'b1}}};
            min_neg = {1'b1, {(IN_BITS-1){1'b0}}};
            if (v > $signed(max_pos)) sat_in_bits = max_pos;
            else if (v < $signed(min_neg)) sat_in_bits = min_neg;
            else sat_in_bits = v[IN_BITS-1:0];
        end
    endfunction

    function automatic logic signed [EFFECT_BITS-1:0] sat_fx_bits(
        input logic signed [EFFECT_BITS+1:0] v
    );
        logic signed [EFFECT_BITS-1:0] max_pos;
        logic signed [EFFECT_BITS-1:0] min_neg;
        begin
            max_pos = {1'b0, {(EFFECT_BITS-1){1'b1}}};
            min_neg = {1'b1, {(EFFECT_BITS-1){1'b0}}};
            if (v > $signed(max_pos)) sat_fx_bits = max_pos;
            else if (v < $signed(min_neg)) sat_fx_bits = min_neg;
            else sat_fx_bits = v[EFFECT_BITS-1:0];
        end
    endfunction

    always_comb begin
        // Mono dry path for the delay write path (smallest practical storage).
        dry_mono_24 = ($signed(left_in) + $signed(right_in)) >>> 1;
        // Truncate to EFFECT_BITS for effect processing/storage.
        dry_mono_fx = dry_mono_24[IN_BITS-1 -: EFFECT_BITS];

        // Very small single-comb style echo:
        // wet = dry + 1/2 delayed, feedback write = dry + 1/4 delayed.
        wet_fx = $signed(dry_mono_fx) + ($signed(delayed_q) >>> 1);
        fb_fx  = $signed(dry_mono_fx) + ($signed(delayed_q) >>> 2);

        // Convert reduced-width effect result back to IN_BITS domain.
        wet_24 = $signed({{(IN_BITS-EFFECT_BITS){wet_fx[EFFECT_BITS+1]}},
                          wet_fx[EFFECT_BITS+1 -: EFFECT_BITS]})
                 <<< (IN_BITS - EFFECT_BITS);

        sat_left  = sat_in_bits($signed(left_in) + ($signed(wet_24 - dry_mono_24) >>> 1));
        sat_right = sat_in_bits($signed(right_in) + ($signed(wet_24 - dry_mono_24) >>> 1));
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr    <= '0;
            delayed_q <= '0;
            left_out  <= '0;
            right_out <= '0;
        end else if (sample_strobe) begin
            // Synchronous RAM-style access pattern:
            // read current tap, then write feedback into same circular location.
            delayed_q <= delay_mem[wr_ptr];
            delay_mem[wr_ptr] <= sat_fx_bits(fb_fx);
            wr_ptr <= wr_ptr + 1'b1;

            if (effect_en) begin
                left_out  <= sat_left;
                right_out <= sat_right;
            end else begin
                left_out  <= left_in;
                right_out <= right_in;
            end
        end
    end
endmodule
