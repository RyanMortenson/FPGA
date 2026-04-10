/***************************************************************************
* 
* Filename: rx_top.sv
*
* Author: Ryan Mortenson
* Description: Top level module for the receiver lab. Instantiates the rx module and the seven_segment4 module.
*
****************************************************************************/

module rx_top #(
    parameter int CLK_FREQUENCY = 100_000_000,
    parameter int BAUD_RATE     = 19_200,
    parameter int REFRESH_RATE  = 19_200
)(
    input  logic        clk,
    input  logic        btnd,
    input  logic        rx_in,
    output logic        parityErr,
    output logic [7:0]  segment,
    output logic [3:0]  anode,
    output logic        rx_debug
);


    //intermediate signals
    logic rst_ff1, rst_sync, sin_ff1, sin_sync;
    logic rx_receive, ack, rx_parityErr, parity_reg;
    logic [7:0] rx_dout, data_reg, char_count;
    logic [15:0] disp;


    
    // Synchronize reset button
    always_ff @(posedge clk) begin
        rst_ff1  <= btnd;
    end

    // Synchronize reset signal
    always_ff @(posedge clk) begin
        rst_sync <= rst_ff1;
    end

    // Synchronize rx_in
    always_ff @(posedge clk) begin
        sin_ff1  <= rx_in;
    end

    // Synchronize rx_in
    always_ff @(posedge clk) begin
        sin_sync <= sin_ff1;
    end

    // rx_debug is inverted rx_in
    assign rx_debug = ~rx_in;


    assign ack = rx_receive;   // “ack signal assigned directly to Receive”
                               // and looped back into ReceiveAck below.

    // Instantiate the rx module
    rx #(
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .BAUD_RATE(BAUD_RATE)
    ) rx_u (
        .clk        (clk),
        .rst        (rst_sync),
        .Sin        (sin_sync),
        .ReceiveAck (ack),
        .Receive    (rx_receive),
        .Dout       (rx_dout),
        .parityErr  (rx_parityErr)
    );


    // Register the data output and parity error from the rx module
    always_ff @(posedge clk) begin
        if (rst_sync) begin
            data_reg   <= 8'h00;
        end else if (ack) begin
            data_reg   <= rx_dout;
        end
    end

    // Register the character count
    always_ff @(posedge clk) begin
        if (rst_sync) begin
            char_count <= 8'h00;
        end else if (ack) begin
            char_count <= char_count + 8'd1;
        end
    end

    // Register the parity error from the rx module
    always_ff @(posedge clk) begin
        if (rst_sync) begin
            parity_reg <= 1'b0;
        end else if (ack) begin
            parity_reg <= rx_parityErr;
        end
    end


    // Assign parityErr output to the registered parity error
    assign parityErr = parity_reg;

    
    // seven segment: upper byte = char_count, lower byte = data_reg
    assign disp = {char_count, data_reg};

    // Instantiate the seven_segment4 module
    seven_segment4 #(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .REFRESH_RATE(REFRESH_RATE)
    ) display_u (
        .clk     (clk),
        .rst     (rst_sync),
        .data_in (disp),
        .blank   (4'b0000),
        .dp_in   (4'b0100),
        .segment (segment),
        .anode   (anode)
    );

endmodule