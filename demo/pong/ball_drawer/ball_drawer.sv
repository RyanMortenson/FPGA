/***************************************************************************
* 
* Filename: ball_drawer.sv
*
* Author: Ryan Mortenson
* Description: ball drawer module
*
****************************************************************************/

module ball_drawer (
    input logic         clk,        // 100MHz Clock
    input logic         reset,      // Active high reset signal
    input logic         start,      // High to start drawing a ball, must go back low before drawing another ball
    output logic        draw,       // High when the module is outputting a valid pixel location to draw
    output logic        done,       // High on cycle that last pixel location is output
    input logic [8:0]   x_in,       // Leftmost x-Coordinate of ball to be drawn
    input logic [7:0]   y_in,       // Topmost y-Coordinate of ball to be drawn
    output logic [8:0]  x_out,      // x-Coordinate to be drawn
    output logic [7:0]  y_out       // y-Coordinate to be drawn
);

// State machine to iterate through pixel locations for the ball
/* The state machine should wait for the start signal before starting to draw a ball.
For each pixel that needs to be drawn, 
the state machine should output an (x,y) coordinate using the x_out and y_out outputs, and 
assert the draw signal to indicate that a valid pixel is being output.
The done signal should be asserted for exactly 1 cycle after the ball is done being drawn (or during the last pixel).
The state machine should wait for the start signal to go low before allowing another ball to be drawn. */

logic [3:0] ball_counter;
logic [8:0] x_base;
logic [7:0] y_base;

typedef enum logic [1:0] {IDLE, DRAWING, DONE} StateType;
StateType state, next_state;

// Sequential logic
always_ff @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        ball_counter <= 0;
        x_base <= 0;
        y_base <= 0;
    end else begin
        state <= next_state;

        case (state)
            IDLE: begin
                ball_counter <= 0;
                if (start) begin
                    x_base <= x_in;
                    y_base <= y_in;
                end
            end

            DRAWING: begin
                if (ball_counter < 7)
                    ball_counter <= ball_counter + 1;
                else
                    ball_counter <= 0;
            end

            DONE: begin
                ball_counter <= 0;
            end
        endcase
    end
end

// Combinational logic
always_comb begin
    draw = 0;
    done = 0;
    x_out = x_base;
    y_out = y_base;
    next_state = state;

    case (state)
        IDLE: begin
            if (start)
                next_state = DRAWING;
        end

        DRAWING: begin
            draw = 1;

            case (ball_counter)
                0: begin x_out = x_base + 1; y_out = y_base;     end 
                1: begin x_out = x_base + 2; y_out = y_base;     end 
                2: begin x_out = x_base;     y_out = y_base + 1; end 
                3: begin x_out = x_base;     y_out = y_base + 2; end
                4: begin x_out = x_base + 3; y_out = y_base + 1; end
                5: begin x_out = x_base + 3; y_out = y_base + 2; end
                6: begin x_out = x_base + 1; y_out = y_base + 3; end
                7: begin x_out = x_base + 2; y_out = y_base + 3; end
                default: begin x_out = x_base; y_out = y_base; end
            endcase

            if (ball_counter == 7)
                next_state = DONE;
        end

        DONE: begin
            done = 1;
            if (!start)
                next_state = IDLE;
        end
    endcase
end



endmodule