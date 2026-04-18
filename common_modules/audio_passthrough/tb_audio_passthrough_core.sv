module tb_audio_passthrough_core;

localparam int SAMPLE_WIDTH = 16;

logic clk;
logic rst;
logic signed [SAMPLE_WIDTH-1:0] rx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] rx_right_sample;
logic rx_sample_valid;
logic signed [SAMPLE_WIDTH-1:0] tx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] tx_right_sample;
logic tx_sample_valid;
logic tx_sample_ready;
int errors;

audio_passthrough_core #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) dut (
    .clk(clk),
    .rst(rst),
    .rx_left_sample(rx_left_sample),
    .rx_right_sample(rx_right_sample),
    .rx_sample_valid(rx_sample_valid),
    .tx_left_sample(tx_left_sample),
    .tx_right_sample(tx_right_sample),
    .tx_sample_valid(tx_sample_valid),
    .tx_sample_ready(tx_sample_ready)
);

initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
end

task automatic push_sample(
    input logic signed [SAMPLE_WIDTH-1:0] in_left,
    input logic signed [SAMPLE_WIDTH-1:0] in_right
);
begin
    @(negedge clk);
    rx_left_sample = in_left;
    rx_right_sample = in_right;
    rx_sample_valid = 1'b1;
    @(negedge clk);
    rx_sample_valid = 1'b0;
end
endtask

task automatic expect_buffered(
    input logic signed [SAMPLE_WIDTH-1:0] expected_left,
    input logic signed [SAMPLE_WIDTH-1:0] expected_right
);
begin
    @(posedge clk);
    if (!tx_sample_valid) begin
        $display("*** ERROR: expected tx_sample_valid");
        errors += 1;
    end
    if (tx_left_sample !== expected_left || tx_right_sample !== expected_right) begin
        $display("*** ERROR: passthrough mismatch expected=(%0d,%0d) actual=(%0d,%0d)",
            expected_left, expected_right, tx_left_sample, tx_right_sample);
        errors += 1;
    end
end
endtask

initial begin
    errors = 0;
    rst = 1'b1;
    rx_left_sample = '0;
    rx_right_sample = '0;
    rx_sample_valid = 1'b0;
    tx_sample_ready = 1'b0;

    repeat (4) @(negedge clk);
    rst = 1'b0;

    push_sample(16'sh1111, -16'sh2222);
    expect_buffered(16'sh1111, -16'sh2222);

    @(negedge clk);
    tx_sample_ready = 1'b1;
    @(posedge clk);
    if (!tx_sample_valid) begin
        $display("*** ERROR: buffer should remain valid until a newer sample arrives");
        errors += 1;
    end
    tx_sample_ready = 1'b0;

    push_sample(-16'sh4000, 16'sh1234);
    expect_buffered(-16'sh4000, 16'sh1234);

    if (errors == 0) begin
        $display("*** tb_audio_passthrough_core PASSED ***");
    end else begin
        $display("*** tb_audio_passthrough_core FAILED with %0d errors ***", errors);
    end
    $finish;
end

endmodule
