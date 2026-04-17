/***************************************************************************
*
* Filename: goertzel_spectrum.sv
*
* Description: Real-time Goertzel-based spectral analyzer suitable for
* Basys3 resources. Uses one shared multiplier pipeline and updates bins
* sequentially at 100 MHz between audio samples.
*
****************************************************************************/

module goertzel_spectrum #(
    parameter int SAMPLE_W      = 24,
    parameter int INTERNAL_W    = 32,
    parameter int COEF_W        = 16,
    parameter int COEF_SHIFT    = 14,
    parameter int N_BINS        = 32,
    parameter int WINDOW_SIZE   = 256,
    parameter int BAR_HEIGHT_W  = 8
) (
    input  logic                                 clk,
    input  logic                                 rst,
    input  logic                                 sample_strobe,
    input  logic signed [SAMPLE_W-1:0]           sample_in,
    input  logic [3:0]                           noise_floor_ctrl,
    input  logic [1:0]                           sensitivity_ctrl,

    output logic [N_BINS-1:0][BAR_HEIGHT_W-1:0]  bar_heights,
    output logic                                 bars_valid
);

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_UPDATE,
        ST_MAG
    } state_t;

    state_t state;

    logic signed [COEF_W-1:0] coef_rom [0:N_BINS-1];
    initial begin
        coef_rom[0]  = 16'sd32758;
        coef_rom[1]  = 16'sd32729;
        coef_rom[2]  = 16'sd32679;
        coef_rom[3]  = 16'sd32610;
        coef_rom[4]  = 16'sd32522;
        coef_rom[5]  = 16'sd32413;
        coef_rom[6]  = 16'sd32286;
        coef_rom[7]  = 16'sd32138;
        coef_rom[8]  = 16'sd31972;
        coef_rom[9]  = 16'sd31786;
        coef_rom[10] = 16'sd31357;
        coef_rom[11] = 16'sd30853;
        coef_rom[12] = 16'sd30274;
        coef_rom[13] = 16'sd29622;
        coef_rom[14] = 16'sd28899;
        coef_rom[15] = 16'sd27684;
        coef_rom[16] = 16'sd26320;
        coef_rom[17] = 16'sd24812;
        coef_rom[18] = 16'sd22595;
        coef_rom[19] = 16'sd20160;
        coef_rom[20] = 16'sd17531;
        coef_rom[21] = 16'sd14010;
        coef_rom[22] = 16'sd9512;
        coef_rom[23] = 16'sd4808;
        coef_rom[24] = -16'sd804;
        coef_rom[25] = -16'sd7180;
        coef_rom[26] = -16'sd14010;
        coef_rom[27] = -16'sd20788;
        coef_rom[28] = -16'sd26791;
        coef_rom[29] = -16'sd31114;
        coef_rom[30] = -16'sd32413;
        coef_rom[31] = -16'sd32758;
    end

    logic signed [INTERNAL_W-1:0] q1 [0:N_BINS-1];
    logic signed [INTERNAL_W-1:0] q2 [0:N_BINS-1];

    logic [$clog2(N_BINS)-1:0]  bin_idx;
    logic [$clog2(WINDOW_SIZE):0] sample_count;

    logic signed [INTERNAL_W-1:0] sample_scaled;
    logic signed [INTERNAL_W+COEF_W-1:0] mult_term;
    logic signed [INTERNAL_W-1:0] q0_next;

    logic signed [2*INTERNAL_W-1:0] q1_sq;
    logic signed [2*INTERNAL_W-1:0] q2_sq;
    logic signed [2*INTERNAL_W-1:0] q1q2;
    logic signed [2*INTERNAL_W+COEF_W-1:0] cross_term_mult;
    logic signed [2*INTERNAL_W:0] mag_sq;

    logic [7:0] log_mag;
    logic [8:0] floor_subtracted;
    logic [7:0] floor_db;
    logic [9:0] scaled_mag;
    logic [7:0] mapped_height;
    logic [7:0] prev_height;
    logic [10:0] smooth_acc;
    logic [BAR_HEIGHT_W-1:0] next_height;

    function automatic [7:0] log2_like_u65(input logic [2*INTERNAL_W:0] value);
        int msb;
        logic [2*INTERNAL_W:0] shifted;
        logic [3:0] frac;
        logic [8:0] tmp;
        begin
            msb = -1;
            for (int j = 2*INTERNAL_W; j >= 0; j--) begin
                if ((msb == -1) && value[j]) begin
                    msb = j;
                end
            end

            if (msb < 0) begin
                log2_like_u65 = 8'd0;
            end else begin
                shifted = value << ((2*INTERNAL_W) - msb);
                frac = shifted[2*INTERNAL_W-1 -: 4];
                tmp = (msb << 2) + frac;
                if (tmp > 9'd255) begin
                    log2_like_u65 = 8'hFF;
                end else begin
                    log2_like_u65 = tmp[7:0];
                end
            end
        end
    endfunction

    // Keep internal dynamic range reasonable.
    assign sample_scaled = {{(INTERNAL_W-SAMPLE_W){sample_in[SAMPLE_W-1]}}, sample_in} >>> 7;

    always_comb begin
        mult_term = q1[bin_idx] * coef_rom[bin_idx];
        q0_next   = sample_scaled + (mult_term >>> COEF_SHIFT) - q2[bin_idx];

        q1_sq           = q1[bin_idx] * q1[bin_idx];
        q2_sq           = q2[bin_idx] * q2[bin_idx];
        q1q2            = q1[bin_idx] * q2[bin_idx];
        cross_term_mult = q1q2 * coef_rom[bin_idx];
        mag_sq          = q1_sq + q2_sq - (cross_term_mult >>> COEF_SHIFT);

        if (mag_sq[2*INTERNAL_W]) begin
            log_mag = 8'd0;
        end else begin
            log_mag = log2_like_u65(mag_sq);
        end

        // User-adjustable floor: 0..120 (about 8 units/step).
        floor_db = {noise_floor_ctrl, 3'b000};

        if (log_mag > floor_db) begin
            floor_subtracted = {1'b0, log_mag} - {1'b0, floor_db};
        end else begin
            floor_subtracted = 9'd0;
        end

        // Base attenuation + user sensitivity trim keeps default from saturating.
        scaled_mag = ({2'b00, floor_subtracted} * 10'd3) >> (2 + sensitivity_ctrl);

        if (scaled_mag > 10'd239) begin
            mapped_height = 8'd239;
        end else begin
            mapped_height = scaled_mag[7:0];
        end

        prev_height = bar_heights[bin_idx];

        // Fast attack, slow decay smoothing to stabilize the display.
        if (mapped_height >= prev_height) begin
            smooth_acc = {2'b00, mapped_height} + {2'b00, prev_height};
            next_height = smooth_acc[8:1];
        end else begin
            smooth_acc = ({2'b00, prev_height, 1'b0} + {3'b000, prev_height} + {3'b000, mapped_height});
            next_height = smooth_acc[9:2];
        end
    end

    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            state        <= ST_IDLE;
            bin_idx      <= '0;
            sample_count <= '0;
            bars_valid   <= 1'b0;
            for (i = 0; i < N_BINS; i++) begin
                q1[i]          <= '0;
                q2[i]          <= '0;
                bar_heights[i] <= '0;
            end
        end else begin
            bars_valid <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (sample_strobe) begin
                        bin_idx <= '0;
                        state   <= ST_UPDATE;
                    end
                end

                ST_UPDATE: begin
                    q2[bin_idx] <= q1[bin_idx];
                    q1[bin_idx] <= q0_next;

                    if (bin_idx == N_BINS-1) begin
                        bin_idx <= '0;
                        if (sample_count == WINDOW_SIZE-1) begin
                            sample_count <= '0;
                            state <= ST_MAG;
                        end else begin
                            sample_count <= sample_count + 1'b1;
                            state <= ST_IDLE;
                        end
                    end else begin
                        bin_idx <= bin_idx + 1'b1;
                    end
                end

                ST_MAG: begin
                    bar_heights[bin_idx] <= next_height;
                    q1[bin_idx] <= '0;
                    q2[bin_idx] <= '0;

                    if (bin_idx == N_BINS-1) begin
                        bin_idx    <= '0;
                        bars_valid <= 1'b1;
                        state      <= ST_IDLE;
                    end else begin
                        bin_idx <= bin_idx + 1'b1;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
