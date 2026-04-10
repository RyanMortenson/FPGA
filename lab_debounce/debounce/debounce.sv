/***************************************************************************
* 
* Filename: debounce.sv
*
* Author: Ryan Mortenson
* Description: Debounce State Machine
*
****************************************************************************/

module debounce #(
    parameter WAIT_TIME_US = 5000, // Determines the wait time, in micro seconds, for the debounce circuit
    parameter CLK_FREQUENCY = 100_000_000	//Specifies the frequency of the clock in Hz
)(
    input logic     clk,        //Clock
    input logic     rst,        //Active high synchronous reset
    input logic     noisy,      //Noisy debounce input
    output logic    debounced   //Debounced output
);

logic clrTimer, timer_done;

//number of clock cycles used for the timer in state machine
localparam TIMER_CLOCK_COUNT = (CLK_FREQUENCY / 1_000_000) * WAIT_TIME_US;

// Determine the number of bits needed to represent the maximum count value
localparam TIMER_CLOCK_COUNT_WIDTH = $clog2(TIMER_CLOCK_COUNT);

// Declare a signal used for this counter signal
logic [TIMER_CLOCK_COUNT_WIDTH-1:0] timer_clock_count;


//Counter that rolls over every n=TIMER_CLOCK_COUNT cycles
always_ff @(posedge clk) begin
    if (rst || clrTimer) timer_clock_count <= 0;
    else if (timer_clock_count == TIMER_CLOCK_COUNT-1) timer_clock_count <= 0;
    else timer_clock_count <= timer_clock_count + 1;
end

//Counter that rolls over every n=DIGIT_DISPLAY_CLOCKS cycles (timer done edition)
always_ff @(posedge clk) begin
    if (rst || clrTimer) timer_done <= 0;
    else if (timer_clock_count == TIMER_CLOCK_COUNT-1) timer_done <= 1;
    else timer_done <= 0;
end



typedef enum {S0, S1, S2, S3} StateType;
StateType cs;

always_ff @(posedge clk) begin
    if (rst) cs <= S0;
    else case (cs)
        S0: if (noisy) cs <= S1;
            else cs <= S0;
        S1: if (!noisy) cs <= S0;
            else if (noisy && timer_done) cs <= S2;
            else cs <= S1;
        S2: if (!noisy) cs <= S3;
            else cs <= S2;
        S3: if (noisy) cs <= S2;
            else if (timer_done) cs <= S0;
            else cs <= S3;
    endcase
end

assign debounced = (cs == S2) || (cs == S3);
assign clrTimer = (cs == S0) || (cs == S2);




endmodule