/***************************************************************************
* 
* Filename: debounce_top.sv
*
* Author: Ryan Mortenson
* Description: Debounce top, interfaces with seven segment
*
****************************************************************************/

module debounce_top #(
    parameter WAIT_TIME_US = 5000,          // Determines the wait time, in micro seconds, for the debounce circuit
    parameter CLK_FREQUENCY = 100_000_000,	//Specifies the frequency of the clock in Hz
    parameter REFRESH_RATE = 200            // Refresh rate for seven segment controller
)(
    input logic         clk,        //Clock
    input logic         btnd,       //Active high synchronous reset
    input logic         btnc,       //Counter button input
    output logic [3:0]  anode,      //Seven-Segment Display anode outputs
    output logic [7:0]  segment     //Seven-Segment Display cathode segment outputs
);

logic btnd_sync, btnd_sync_r, btnc_sync, btnc_sync_r, enable, debounce, debounce_r, debounce_rr;


//first ff for btnd for synchronizer
always_ff @(posedge clk) begin
    if (btnd) btnd_sync <= 1;
    else btnd_sync <= 0;
end

//second ff for btnd for synchronizer
always_ff @(posedge clk) begin
    if (btnd_sync) btnd_sync_r <= 1;
    else btnd_sync_r <= 0;
end

//first ff for btnc for synchronizer
always_ff @(posedge clk) begin
    if (btnc) btnc_sync <= 1;
    else btnc_sync <= 0;
end

//second ff for btnc for synchronizer
always_ff @(posedge clk) begin
    if (btnc_sync) btnc_sync_r <= 1;
    else btnc_sync_r <= 0;
end



//debounced part of sev seg
debounce #(
    .WAIT_TIME_US(WAIT_TIME_US),
    .CLK_FREQUENCY(CLK_FREQUENCY)
) debounce_u (
    .clk(clk),
    .rst(btnd_sync),
    .noisy(btnc_sync_r),
    .debounced(debounce)
);


always_ff @(posedge clk) begin
    debounce_r <= debounce;
end

always_ff @(posedge clk) begin
    debounce_rr <= debounce_r;
end

//positive edge detector on btnc
assign enable = ~debounce_rr & debounce_r;


//8-bit counter that counts debounced
logic [7:0] db_counter;


//db_counter
always_ff @(posedge clk) begin
    if (btnd_sync) db_counter <= 0;
    else if (enable) db_counter <= db_counter + 1;
    else db_counter <= db_counter;
end


//8-bit counter that counts undebounced
logic [7:0] undb_counter;


//positive edge detector on btnc - undebounced
assign undebounced_enable = ~btnc_sync_r & btnc_sync;

//undb_counter
always_ff @(posedge clk) begin
    if (btnd_sync) undb_counter <= 0;
    else if (undebounced_enable) undb_counter <= undb_counter + 1;
    else undb_counter <= undb_counter;
end


//seven-segment display

seven_segment4 #(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .REFRESH_RATE(REFRESH_RATE)
) ss4_u (
    .clk(clk),
    .rst(btnd_sync),
    .data_in({undb_counter, db_counter}),
    .blank(4'b0000),
    .dp_in(4'b0001),
    .segment(segment),
    .anode(anode)
);




endmodule