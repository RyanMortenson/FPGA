/***************************************************************************
* 
* Filename: v_line_drawer.sv
*
* Author: Ryan Mortenson
* Description: vertical line drawer module
*
****************************************************************************/

module v_line_drawer #(
    parameter HEIGHT = 40
)(
    input logic         clk,
    input logic         reset,
    input logic         start,
    output logic        draw,
    output logic        done,
    input logic [8:0]   x_in,
    input logic [7:0]   y_in,
    output logic [8:0]  x_out,
    output logic [7:0]  y_out
);

localparam int HEIGHT_BITS = (HEIGHT <= 1) ? 1 : $clog2(HEIGHT);

logic [HEIGHT_BITS-1:0] line_counter;
logic [8:0] x_base;
logic [7:0] y_base;

typedef enum logic [1:0] {IDLE, DRAWING, DONE} StateType;
StateType state, next_state;

// Sequential logic
always_ff @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        line_counter <= 0;
        x_base <= 0;
        y_base <= 0;
    end else begin
        state <= next_state;

        case (state)
            IDLE: begin
                line_counter <= 0;
                if (start) begin
                    x_base <= x_in;
                    y_base <= y_in;
                end
            end

            DRAWING: begin
                if (line_counter < HEIGHT - 1)
                    line_counter <= line_counter + 1;
                else
                    line_counter <= 0;
            end

            DONE: begin
                line_counter <= 0;
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
            x_out = x_base;
            y_out = y_base + line_counter;

            if (line_counter == HEIGHT - 1)
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