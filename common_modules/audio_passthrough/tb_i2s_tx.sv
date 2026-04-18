module tb_i2s_tx;

localparam int SAMPLE_WIDTH = 16;

logic clk;
logic rst;
logic sclk_fall;
logic lrck;
logic lrck_edge;
logic signed [SAMPLE_WIDTH-1:0] left_sample;
logic signed [SAMPLE_WIDTH-1:0] right_sample;
logic sample_valid;
logic sample_ready;
logic sdata;
int errors;

i2s_tx #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) dut (
    .clk(clk),
    .rst(rst),
    .sclk_fall(sclk_fall),
    .lrck(lrck),
    .lrck_edge(lrck_edge),
    .left_sample(left_sample),
    .right_sample(right_sample),
    .sample_valid(sample_valid),
    .sample_ready(sample_ready),
    .sdata(sdata)
);

initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
end

task automatic pulse_sclk_fall(output logic sampled_bit);
begin
    @(negedge clk);
    sclk_fall = 1'b1;
    @(posedge clk);
    sampled_bit = sdata;
    @(negedge clk);
    sclk_fall = 1'b0;
end
endtask

task automatic start_channel(input logic next_lrck);
begin
    @(negedge clk);
    lrck = next_lrck;
    lrck_edge = 1'b1;
    @(negedge clk);
    lrck_edge = 1'b0;
end
endtask

task automatic check_channel_bits(input logic next_lrck, input logic signed [SAMPLE_WIDTH-1:0] sample);
    logic observed_bit;
begin
    start_channel(next_lrck);
    pulse_sclk_fall(observed_bit);
    if (observed_bit !== sample[SAMPLE_WIDTH-1]) begin
        $display("*** ERROR: MSB mismatch for channel %0d", next_lrck);
        errors += 1;
    end

    for (int bit_idx = SAMPLE_WIDTH - 2; bit_idx >= 0; bit_idx--) begin
        pulse_sclk_fall(observed_bit);
        if (observed_bit !== sample[bit_idx]) begin
            $display("*** ERROR: bit %0d mismatch for channel %0d", bit_idx, next_lrck);
            errors += 1;
        end
    end
end
endtask

initial begin
    errors = 0;
    rst = 1'b1;
    sclk_fall = 1'b0;
    lrck = 1'b0;
    lrck_edge = 1'b0;
    left_sample = '0;
    right_sample = '0;
    sample_valid = 1'b0;

    repeat (4) @(negedge clk);
    rst = 1'b0;
    repeat (2) @(negedge clk);

    if (!sample_ready) begin
        $display("*** ERROR: transmitter should be ready after reset");
        errors += 1;
    end

    left_sample = -16'sh1234;
    right_sample = 16'sh5678;
    sample_valid = 1'b1;
    @(negedge clk);
    sample_valid = 1'b0;

    check_channel_bits(1'b0, -16'sh1234);
    check_channel_bits(1'b1, 16'sh5678);

    if (!sample_ready) begin
        $display("*** ERROR: transmitter should be ready for another stereo sample");
        errors += 1;
    end

    left_sample = 16'sh7fff;
    right_sample = -16'sh8000;
    sample_valid = 1'b1;
    @(negedge clk);
    sample_valid = 1'b0;

    check_channel_bits(1'b0, 16'sh7fff);
    check_channel_bits(1'b1, -16'sh8000);

    if (errors == 0) begin
        $display("*** tb_i2s_tx PASSED ***");
    end else begin
        $display("*** tb_i2s_tx FAILED with %0d errors ***", errors);
    end
    $finish;
end

endmodule
