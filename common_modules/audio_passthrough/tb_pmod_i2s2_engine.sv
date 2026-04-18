module tb_pmod_i2s2_engine;

localparam int SAMPLE_WIDTH = 24;
localparam int FRAMES_TO_CHECK = 2;

logic audio_clk;
logic rst;
logic signed [SAMPLE_WIDTH-1:0] tx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] tx_right_sample;
logic signed [SAMPLE_WIDTH-1:0] rx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] rx_right_sample;
logic rx_sample_valid;
logic tx_mclk;
logic tx_lrck;
logic tx_sclk;
logic tx_sdout;
logic rx_mclk;
logic rx_lrck;
logic rx_sclk;
logic rx_sdin;
int errors;

logic signed [SAMPLE_WIDTH-1:0] in_left [0:FRAMES_TO_CHECK-1];
logic signed [SAMPLE_WIDTH-1:0] in_right [0:FRAMES_TO_CHECK-1];
logic signed [SAMPLE_WIDTH-1:0] out_left [0:FRAMES_TO_CHECK-1];
logic signed [SAMPLE_WIDTH-1:0] out_right [0:FRAMES_TO_CHECK-1];
int rx_frames_seen;

pmod_i2s2_engine #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) dut (
    .audio_clk(audio_clk),
    .rst(rst),
    .tx_left_sample(tx_left_sample),
    .tx_right_sample(tx_right_sample),
    .rx_left_sample(rx_left_sample),
    .rx_right_sample(rx_right_sample),
    .rx_sample_valid(rx_sample_valid),
    .tx_mclk(tx_mclk),
    .tx_lrck(tx_lrck),
    .tx_sclk(tx_sclk),
    .tx_sdout(tx_sdout),
    .rx_mclk(rx_mclk),
    .rx_lrck(rx_lrck),
    .rx_sclk(rx_sclk),
    .rx_sdin(rx_sdin)
);

initial begin
    audio_clk = 1'b0;
    forever #22.13ns audio_clk = ~audio_clk;
end

task automatic wait_for_engine_slot(
    input logic desired_lrck,
    input int bit_number,
    input logic [2:0] phase
);
    int slot_number;
begin
    slot_number = SAMPLE_WIDTH - bit_number;
    forever begin
        @(posedge audio_clk);
        if ((dut.count[8] == desired_lrck) &&
            (dut.count[7:3] == slot_number[4:0]) &&
            (dut.count[2:0] == phase)) begin
            break;
        end
    end
end
endtask

task automatic drive_rx_channel(input logic desired_lrck, input logic signed [SAMPLE_WIDTH-1:0] sample);
begin
    rx_sdin = 1'b0;
    for (int bit_idx = SAMPLE_WIDTH - 1; bit_idx >= 0; bit_idx--) begin
        // The engine samples din_sync when count[2:0] == 3. Because the RX
        // input passes through a three-deep synchronizer, the bench drives the
        // bit three audio_clk cycles earlier at phase 0 of the same slot.
        wait_for_engine_slot(desired_lrck, bit_idx, 3'b000);
        rx_sdin = sample[bit_idx];
    end
end
endtask

task automatic capture_tx_channel(
    input logic desired_lrck,
    output logic signed [SAMPLE_WIDTH-1:0] sample
);
    logic [SAMPLE_WIDTH-1:0] temp;
begin
    temp = '0;
    for (int bit_idx = SAMPLE_WIDTH - 1; bit_idx >= 0; bit_idx--) begin
        wait_for_engine_slot(desired_lrck, bit_idx, 3'b000);
        temp[bit_idx] = tx_sdout;
    end
    sample = temp;
end
endtask

initial begin
    in_left[0] = 24'sh123456;
    in_right[0] = -24'sh12345;
    in_left[1] = -24'sh234567;
    in_right[1] = 24'sh045678;
end

initial begin : drive_rx
    rx_sdin = 1'b0;
    wait(!rst);
    while (dut.count != 9'd0) @(posedge audio_clk);
    for (int frame_idx = 0; frame_idx < FRAMES_TO_CHECK; frame_idx++) begin
        drive_rx_channel(1'b0, in_left[frame_idx]);
        drive_rx_channel(1'b1, in_right[frame_idx]);
    end
end

initial begin : monitor_rx
    rx_frames_seen = 0;
    wait(!rst);
    forever begin
        @(posedge audio_clk);
        if (rx_sample_valid) begin
            if (rx_left_sample !== in_left[rx_frames_seen]) begin
                $display("*** ERROR: RX left frame %0d mismatch expected=%0h actual=%0h",
                    rx_frames_seen, in_left[rx_frames_seen], rx_left_sample);
                errors += 1;
            end
            if (rx_right_sample !== in_right[rx_frames_seen]) begin
                $display("*** ERROR: RX right frame %0d mismatch expected=%0h actual=%0h",
                    rx_frames_seen, in_right[rx_frames_seen], rx_right_sample);
                errors += 1;
            end
            rx_frames_seen += 1;
            if (rx_frames_seen == FRAMES_TO_CHECK) begin
                disable monitor_rx;
            end
        end
    end
end

initial begin : drive_tx
    tx_left_sample = '0;
    tx_right_sample = '0;
    wait(!rst);
    while (dut.count != 9'd0) @(posedge audio_clk);
    tx_left_sample = 24'sh654321;
    tx_right_sample = -24'sh23456;
    wait(rx_sample_valid);
    tx_left_sample = -24'sh345678;
    tx_right_sample = 24'sh055555;
end

initial begin : capture_tx
    logic signed [SAMPLE_WIDTH-1:0] captured_left;
    logic signed [SAMPLE_WIDTH-1:0] captured_right;
    wait(!rst);
    while (dut.count != 9'd0) @(posedge audio_clk);

    capture_tx_channel(1'b0, captured_left);
    capture_tx_channel(1'b1, captured_right);
    if (captured_left !== 24'sh654321 || captured_right !== -24'sh23456) begin
        $display("*** ERROR: TX frame 0 mismatch expected=(654321,%0h) actual=(%0h,%0h)",
            -24'sh23456, captured_left, captured_right);
        errors += 1;
    end

    capture_tx_channel(1'b0, captured_left);
    capture_tx_channel(1'b1, captured_right);
    if (captured_left !== -24'sh345678 || captured_right !== 24'sh055555) begin
        $display("*** ERROR: TX frame 1 mismatch expected=(%0h,055555) actual=(%0h,%0h)",
            -24'sh345678, captured_left, captured_right);
        errors += 1;
    end
end

initial begin
    errors = 0;
    rst = 1'b1;
    repeat (10) @(posedge audio_clk);
    rst = 1'b0;

    wait(rx_frames_seen == FRAMES_TO_CHECK);
    repeat (600) @(posedge audio_clk);

    if (errors == 0) begin
        $display("*** tb_pmod_i2s2_engine PASSED ***");
    end else begin
        $display("*** tb_pmod_i2s2_engine FAILED with %0d errors ***", errors);
    end
    $finish;
end

endmodule
