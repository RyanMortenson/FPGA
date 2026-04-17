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

    logic [BAR_HEIGHT_W-1:0] next_height;

    // Keep internal dynamic range reasonable.
    assign sample_scaled = {{(INTERNAL_W-SAMPLE_W){sample_in[SAMPLE_W-1]}}, sample_in} >>> 6;

    always_comb begin
        mult_term = q1[bin_idx] * coef_rom[bin_idx];
        q0_next   = sample_scaled + (mult_term >>> COEF_SHIFT) - q2[bin_idx];

        q1_sq          = q1[bin_idx] * q1[bin_idx];
        q2_sq          = q2[bin_idx] * q2[bin_idx];
        q1q2           = q1[bin_idx] * q2[bin_idx];
        cross_term_mult = q1q2 * coef_rom[bin_idx];
        mag_sq         = q1_sq + q2_sq - (cross_term_mult >>> COEF_SHIFT);

        if (mag_sq[2*INTERNAL_W]) begin
            next_height = '0;
        end else if (|mag_sq[2*INTERNAL_W-1:34]) begin
            next_height = {BAR_HEIGHT_W{1'b1}};
        end else begin
            // log-ish compression by taking upper bits.
            next_height = mag_sq[26 +: BAR_HEIGHT_W];
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
