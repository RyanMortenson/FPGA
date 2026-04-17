/***************************************************************************
* 
* Filename: pong.sv
*
* Author: Ryan Mortenson
* Description: pong module
*
****************************************************************************/

module pong (
    input logic         clk,            // 100MHz Clock
    input logic         reset,          // Active high reset signal
    input logic         paddle_up_l,    // Move left paddle up
    input logic         paddle_down_l,  // Move left paddle down
    input logic         paddle_up_r,    // Move right paddle up
    input logic         paddle_down_r,  // Move right paddle down
    output logic [8:0]  vga_x,          // X-coordinate to draw
    output logic [7:0]  vga_y,          // Y-coordinate to draw
    output logic [2:0]  vga_color,      // RGB color to draw
    output logic        vga_wr_en,       // Write enable for VGA bitmap memory
    output logic [3:0] score_left,     // Left player's score (0-9)
    output logic [3:0] score_right     // Right player's score (0-9
);

localparam int SCREEN_W      = 320;
localparam int SCREEN_H      = 240;
localparam int PADDLE_HEIGHT = 40;
localparam int BALL_SIZE     = 4;
localparam int WAIT_COUNT    = 24'd750_000; // 2.5 ms at 100 MHz

// registers and logic for controlling the movement of the ball and paddles, detecting collisions, and updating the VGA outputs accordingly will go here.
logic [8:0] ball_x; 
logic [7:0] ball_y; 
logic ball_dir_x, ball_dir_y; // Direction of the ball (0 for left/up, 1 for right/down)
logic [7:0] paddle_left_y, paddle_right_y; // Y position of the top of the left and right paddles

logic draw_ball, draw_paddle_left, draw_paddle_right; // Control signals for drawing
logic done_drawing_ball, done_drawing_paddle_left, done_drawing_paddle_right; // Signals to indicate when drawing is done

logic start_ball, start_paddle_left, start_paddle_right;

// Separate drawer outputs so multiple modules do not drive vga_x/vga_y directly
logic [8:0] ball_draw_x, paddle_left_draw_x, paddle_right_draw_x;
logic [7:0] ball_draw_y, paddle_left_draw_y, paddle_right_draw_y;

// ball_drawer instance
ball_drawer ball_drawer_inst (
    .clk(clk),
    .reset(reset),
    .start(start_ball),
    .draw(draw_ball),
    .done(done_drawing_ball),
    .x_in(ball_x),
    .y_in(ball_y),
    .x_out(ball_draw_x),
    .y_out(ball_draw_y)
);

// v_line_drawer instance for left paddle
v_line_drawer #(
    .HEIGHT(PADDLE_HEIGHT)
) v_line_drawer_left (
    .clk(clk),
    .reset(reset),
    .start(start_paddle_left),
    .draw(draw_paddle_left),
    .done(done_drawing_paddle_left),
    .x_in(9'd0), // left paddle is on the left edge of the screen
    .y_in(paddle_left_y),
    .x_out(paddle_left_draw_x),
    .y_out(paddle_left_draw_y)
);

// v_line_drawer instance for right paddle
v_line_drawer #(
    .HEIGHT(PADDLE_HEIGHT)
) v_line_drawer_right (
    .clk(clk),
    .reset(reset),
    .start(start_paddle_right),
    .draw(draw_paddle_right),
    .done(done_drawing_paddle_right),
    .x_in(9'd319),
    .y_in(paddle_right_y),
    .x_out(paddle_right_draw_x),
    .y_out(paddle_right_draw_y)
);


// STATE MACHINE - game loop
typedef enum logic [3:0] {
    START_DRAW_PADDLE_LEFT,
    DRAW_PADDLE_LEFT,
    START_DRAW_PADDLE_RIGHT,
    DRAW_PADDLE_RIGHT,
    START_DRAW_BALL,
    DRAW_BALL,
    WAIT,
    START_ERASE_PADDLE_LEFT,
    ERASE_PADDLE_LEFT,
    START_ERASE_PADDLE_RIGHT,
    ERASE_PADDLE_RIGHT,
    START_ERASE_BALL,
    ERASE_BALL,
    UPDATE
} StateType;
StateType state, next_state;

// wait counter
logic [23:0] wait_counter;

// State register
always_ff @(posedge clk) begin
    if (reset) begin
        state <= START_DRAW_PADDLE_LEFT;
    end else begin
        state <= next_state;
    end
end

// Wait counter
always_ff @(posedge clk) begin
    if (reset) begin
        wait_counter <= 0;
    end else if (state == WAIT) begin
        if (wait_counter < WAIT_COUNT)
            wait_counter <= wait_counter + 1;
        else
            wait_counter <= 0;
    end else begin
        wait_counter <= 0;
    end
end

// Combinational FSM / VGA mux / drawer start control
always_comb begin
    // Default values for outputs and next state
    vga_x = 0;
    vga_y = 0;
    vga_color = 3'b000; // Default to black
    vga_wr_en = 0;
    next_state = state;

    start_ball = 0;
    start_paddle_left = 0;
    start_paddle_right = 0;

    case (state)
        START_DRAW_PADDLE_LEFT: begin
            start_paddle_left = 1;
            next_state = DRAW_PADDLE_LEFT;
        end

        DRAW_PADDLE_LEFT: begin
            vga_x = paddle_left_draw_x;
            vga_y = paddle_left_draw_y;
            vga_color = 3'b101; // purple color for left paddle
            vga_wr_en = draw_paddle_left;
            if (done_drawing_paddle_left)
                next_state = START_DRAW_PADDLE_RIGHT;
        end

        START_DRAW_PADDLE_RIGHT: begin
            start_paddle_right = 1;
            next_state = DRAW_PADDLE_RIGHT;
        end

        DRAW_PADDLE_RIGHT: begin
            vga_x = paddle_right_draw_x;
            vga_y = paddle_right_draw_y;
            vga_color = 3'b011; //  teal color for right paddle
            vga_wr_en = draw_paddle_right;
            if (done_drawing_paddle_right)
                next_state = START_DRAW_BALL;
        end

        START_DRAW_BALL: begin
            start_ball = 1;
            next_state = DRAW_BALL;
        end

        DRAW_BALL: begin
            vga_x = ball_draw_x;
            vga_y = ball_draw_y;
            vga_color = 3'b111; //  white color for ball
            vga_wr_en = draw_ball;
            if (done_drawing_ball)
                next_state = WAIT;
        end

        WAIT: begin
            if (wait_counter >= WAIT_COUNT)
                next_state = START_ERASE_PADDLE_LEFT;
        end

        START_ERASE_PADDLE_LEFT: begin
            start_paddle_left = 1;
            next_state = ERASE_PADDLE_LEFT;
        end

        ERASE_PADDLE_LEFT: begin
            vga_x = paddle_left_draw_x;
            vga_y = paddle_left_draw_y;
            vga_color = 3'b000; // Black color for erasing
            vga_wr_en = draw_paddle_left;
            if (done_drawing_paddle_left)
                next_state = START_ERASE_PADDLE_RIGHT;
        end

        START_ERASE_PADDLE_RIGHT: begin
            start_paddle_right = 1;
            next_state = ERASE_PADDLE_RIGHT;
        end

        ERASE_PADDLE_RIGHT: begin
            vga_x = paddle_right_draw_x;
            vga_y = paddle_right_draw_y;
            vga_color = 3'b000; // Black color for erasing
            vga_wr_en = draw_paddle_right;
            if (done_drawing_paddle_right)
                next_state = START_ERASE_BALL;
        end

        START_ERASE_BALL: begin
            start_ball = 1;
            next_state = ERASE_BALL;
        end

        ERASE_BALL: begin
            vga_x = ball_draw_x;
            vga_y = ball_draw_y;
            vga_color = 3'b000; // Black color for erasing
            vga_wr_en = draw_ball;
            if (done_drawing_ball)
                next_state = UPDATE;
        end

        UPDATE: begin
            next_state = START_DRAW_PADDLE_LEFT; // Go back to the first step of the loop
        end

        default: begin
            next_state = START_DRAW_PADDLE_LEFT;
        end
    endcase
end

// score left flag to stop it from updating the counting initial score when the game resets
logic initial_score_left_flag;

// Update the location of the ball and paddles based on the game logic
always_ff @(posedge clk) begin
    if (reset) begin
        // Initialize ball and paddle positions, directions, and scores here
        ball_x <= 9'd160; // Start in the middle of the screen
        ball_y <= 8'd120; // Start in the middle of the screen
        ball_dir_x <= 1;  // Start moving to the right
        ball_dir_y <= 1;  // Start moving down
        paddle_left_y <= 8'd100;  // Start left paddle somewhere in the middle
        paddle_right_y <= 8'd100; // Start right paddle somewhere in the middle
        score_left <= 0;
        score_right <= 0;
        initial_score_left_flag <= 1; // Set the flag to indicate initial score for left player and prevent it from updating on the first reset
    end else if (state == UPDATE) begin

        // Ball movement / collisions
        // Horizontal movement
        if (ball_dir_x) begin
            // moving right
            if ((ball_x + BALL_SIZE - 1) >= 9'd318) begin
                // check right paddle collision
                if ((ball_y + BALL_SIZE - 1 >= paddle_right_y) &&
                    (ball_y <= paddle_right_y + PADDLE_HEIGHT - 1)) begin
                    ball_dir_x <= 0;
                    ball_x <= ball_x - 1;
                end else if (initial_score_left_flag) begin
                    // If the left player has not scored yet, do not update the score on the first reset
                    ball_x <= 9'd160;
                    ball_y <= 8'd120;
                    ball_dir_x <= 1;
                    ball_dir_y <= ball_dir_y;
                    initial_score_left_flag <= 0; // Clear the flag after the first reset
                end else begin
                    // score for left player, reset ball
                    score_left <= score_left + 1;
                    ball_x <= 9'd160;
                    ball_y <= 8'd120;
                    ball_dir_x <= 0;
                    ball_dir_y <= ball_dir_y;
                end
            end else begin
                ball_x <= ball_x + 1;
            end
        end else begin
            // moving left
            if (ball_x <= 9'd1) begin
                // check left paddle collision
                if ((ball_y + BALL_SIZE - 1 >= paddle_left_y) &&
                    (ball_y <= paddle_left_y + PADDLE_HEIGHT - 1)) begin
                    ball_dir_x <= 1;
                    ball_x <= ball_x + 1;
                end else begin
                    // score for right player, reset ball
                    score_right <= score_right + 1;
                    ball_x <= 9'd160;
                    ball_y <= 8'd120;
                    ball_dir_x <= 1;
                    ball_dir_y <= ball_dir_y;
                end
            end else begin
                ball_x <= ball_x - 1;
            end
        end

        // Vertical movement
        if (ball_dir_y) begin
            // moving down
            if ((ball_y + BALL_SIZE - 1) >= SCREEN_H - 1) begin
                ball_dir_y <= 0;
                ball_y <= ball_y - 1;
            end else begin
                ball_y <= ball_y + 1;
            end
        end else begin
            // moving up
            if (ball_y <= 0) begin
                ball_dir_y <= 1;
                ball_y <= ball_y + 1;
            end else begin
                ball_y <= ball_y - 1;
            end
        end

        // Paddle movement with bounds checking
        if (paddle_up_l) begin
            if (paddle_left_y > 0)
                paddle_left_y <= paddle_left_y - 1;
            else
                paddle_left_y <= 0;
        end else if (paddle_down_l) begin
            if (paddle_left_y < SCREEN_H - PADDLE_HEIGHT)
                paddle_left_y <= paddle_left_y + 1;
            else
                paddle_left_y <= SCREEN_H - PADDLE_HEIGHT;
        end

        if (paddle_up_r) begin
            if (paddle_right_y > 0)
                paddle_right_y <= paddle_right_y - 1;
            else
                paddle_right_y <= 0;
        end else if (paddle_down_r) begin
            if (paddle_right_y < SCREEN_H - PADDLE_HEIGHT)
                paddle_right_y <= paddle_right_y + 1;
            else
                paddle_right_y <= SCREEN_H - PADDLE_HEIGHT;
        end
    end
end

endmodule