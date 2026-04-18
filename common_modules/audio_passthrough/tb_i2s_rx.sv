module tb_i2s_rx;

localparam int SAMPLE_WIDTH = 16;

logic clk;
logic rst;
logic sclk_rise;
logic lrck;
logic lrck_edge;
logic sdata;
logic signed [SAMPLE_WIDTH-1:0] left_sample;
logic signed [SAMPLE_WIDTH-1:0] right_sample;
logic sample_valid;
int errors;

i2s_rx #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) dut (
    .clk(clk),
    .rst(rst),
    .sclk_rise(sclk_rise),
    .lrck(lrck),
    .lrck_edge(lrck_edge),
    .sdata(sdata),
    .left_sample(left_sample),
    .right_sample(right_sample),
    .sample_valid(sample_valid)
);

initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
end

task automatic pulse_sclk_rise(input logic bit_value);
begin
    @(negedge clk);
    sdata = bit_value;
    sclk_rise = 1'b1;
    @(negedge clk);
    sclk_rise = 1'b0;
end
endtask

task automatic drive_channel(input logic next_lrck, input logic signed [SAMPLE_WIDTH-1:0] sample);
begin
    @(negedge clk);
    lrck = next_lrck;
    lrck_edge = 1'b1;
    @(negedge clk);
    lrck_edge = 1'b0;

    // I2S inserts one bit-clock delay after the LRCK transition.
    pulse_sclk_rise(1'b0);
    for (int bit_idx = SAMPLE_WIDTH - 1; bit_idx >= 0; bit_idx--) begin
        pulse_sclk_rise(sample[bit_idx]);
    end
end
endtask

task automatic expect_samples(
    input logic signed [SAMPLE_WIDTH-1:0] expected_left,
    input logic signed [SAMPLE_WIDTH-1:0] expected_right
);
begin
    @(posedge sample_valid);
    if (left_sample !== expected_left) begin
        $display("*** ERROR: left sample mismatch. expected=%0d actual=%0d", expected_left, left_sample);
        errors += 1;
    end
    if (right_sample !== expected_right) begin
        $display("*** ERROR: right sample mismatch. expected=%0d actual=%0d", expected_right, right_sample);
        errors += 1;
    end
end
endtask

initial begin
    errors = 0;
    rst = 1'b1;
    sclk_rise = 1'b0;
    lrck = 1'b0;
    lrck_edge = 1'b0;
    sdata = 1'b0;

    repeat (4) @(negedge clk);
    rst = 1'b0;
    repeat (2) @(negedge clk);

    drive_channel(1'b0, 16'sh1234);
    if (sample_valid) begin
        $display("*** ERROR: sample_valid should stay low after left channel only");
        errors += 1;
    end
    drive_channel(1'b1, -16'sh2345);
    expect_samples(16'sh1234, -16'sh2345);

    drive_channel(1'b0, -16'sh4000);
    drive_channel(1'b1, 16'sh07f0);
    expect_samples(-16'sh4000, 16'sh07f0);

    drive_channel(1'b0, 16'sh7fff);
    drive_channel(1'b1, -16'sh8000);
    expect_samples(16'sh7fff, -16'sh8000);

    if (errors == 0) begin
        $display("*** tb_i2s_rx PASSED ***");
    end else begin
        $display("*** tb_i2s_rx FAILED with %0d errors ***", errors);
    end
    $finish;
end

endmodule
