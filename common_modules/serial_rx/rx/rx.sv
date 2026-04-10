/***************************************************************************
* 
* Filename: rx.sv
*
* Author: Ryan Mortenson
* Description: receiver module
*
****************************************************************************/

module rx #(
    parameter CLK_FREQUENCY = 100_000_000,	// Specifies the frequency of the clock in Hz
    parameter BAUD_RATE     = 19_200 // Determine the baud rate of the transmitter
)(
    input logic         clk,        // Clock
    input logic         rst,        // System reset active high
    input logic         Sin,        // Receiver serial input signal
    input logic         ReceiveAck, // Indicates that the byte on the Dout pins has been received.
    output logic        Receive,    // Indicates that a byte has been received over the serial RX line (Sin), and is ready to be retrieved from the Dout pins.
    output logic [7:0]  Dout,       // 8-bit data received by the module. Valid when Receive is high.
    output logic        parityErr   // Indicates that there was a parity error. Valid when Receive is high.
);

//intermediate signals
logic baud_half_done, baud_full_done, baud_half_done_flag, baud_full_done_flag, timer_en;
logic [12:0] tick_counter;
logic [3:0] phase;
localparam BAUD_TICKS = CLK_FREQUENCY / BAUD_RATE; // Number of clock ticks per baud

// Baud done / half-done conditions
assign baud_half_done = timer_en && (tick_counter == BAUD_TICKS/2 - 1);
assign baud_full_done = timer_en && (tick_counter == BAUD_TICKS - 1);

// Baud counter
always_ff @(posedge clk) begin
    if (rst) begin
        tick_counter <= 0;
    end else if (!timer_en) begin
        tick_counter <= 0;
    end else if (baud_full_done) begin
        tick_counter <= 0;
    end else begin
        tick_counter <= tick_counter + 1;
    end
end

// Baud half done flags
always_ff @(posedge clk) begin
    if (rst) begin
        baud_half_done_flag <= 0;
    end else if (baud_half_done) begin
        baud_half_done_flag <= 1;
    end else begin
        baud_half_done_flag <= 0;
    end
end

// Baud full done flags
always_ff @(posedge clk) begin
    if (rst) begin
        baud_full_done_flag <= 0;
    end else if (baud_full_done) begin
        baud_full_done_flag <= 1;
    end else begin
        baud_full_done_flag <= 0;
    end
end


//shift register (8 data bits, 1 parity bit, 1 stop bit)
logic [9:0] shift_reg;

//parity error logic
assign parityErr = (Receive) ? (shift_reg[8] != ~(^shift_reg[7:0])) : 1'b0;


//state machine states
typedef enum logic [1:0] { POWER_UP, IDLE, RECV, WAIT_HANDOFF } state_t;
state_t state;
always @(posedge clk) begin
    if (rst) begin
        state <= POWER_UP;
        Dout <= 0;
        Receive <= 0;
        shift_reg <= 0;
        phase <= 0;
        timer_en <= 0;
    end else begin
        // Default assignments
        case (state)
            POWER_UP: begin
                Receive <= 0;
                timer_en <= 0;
                phase <= 0;
                if (Sin) state <= IDLE;
            end

            // IDLE state waits for the start bit (Sin goes low)
            IDLE: begin
                Receive <= 0;
                timer_en <= 0;
                phase <= 0;

                if (!Sin) begin
                    shift_reg <= 0;
                    phase <= 0;
                    timer_en <= 1;
                    state <= RECV;
                end
            end

            // RECV state samples the Sin line and shifts in the bits into the shift register
            RECV: begin
                if (baud_half_done_flag) begin
                    if (phase == 0) begin
                        // sample middle of start bit
                        if (!Sin) begin
                            phase <= 1;
                        end else begin
                            timer_en <= 0;
                            state <= IDLE;
                        end
                    end else begin
                        // shift in data/parity/stop
                        shift_reg <= {Sin, shift_reg[9:1]};

                        if (phase == 10) begin
                            timer_en <= 0;
                            state <= WAIT_HANDOFF;
                        end else begin
                            phase <= phase + 1;
                        end
                    end
                end
            end

            // WAIT_HANDOFF state waits for the ReceiveAck signal 
            // to go high before returning to IDLE
            WAIT_HANDOFF: begin
                Receive <= 1;
                Dout <= shift_reg[7:0];

                if(ReceiveAck) begin
                    Receive <= 0;
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule