
module write_vga #(
    parameter CIPHER_TEXT_ROW = 10,
    parameter CIPHER_TEXT_COLUMN = 15,
    parameter PLAIN_TEXT_ROW = 11,
    parameter PLAIN_TEXT_COLUMN = 15,
    parameter KEY_ROW = 12,
    parameter KEY_COLUMN = 15
) 
(
    input logic clk,
    input logic rst,
    input logic write_display,
    input logic [127:0] ciphertext,
    input logic [127:0] plaintext,
    input logic [23:0] key,
    output logic [11:0] char_addr,
    output logic [7:0] char_data,
    output logic write_char
);

    localparam CIPHER_TEXT_COLUMNS = $bits(ciphertext) / 8;
    localparam PLAIN_TEXT_COLUMNS = $bits(plaintext) / 8;
    localparam KEY_COLUMNS = $bits(key) / 4; // There are 3 bytes for the key but 6 nibbles

    // Converts a 4-bit nibble to its corresponding ASCII character
    function logic [7:0] nibble_to_char(input logic [3:0] nibble_to_display);
        if (nibble_to_display < 10)
            nibble_to_char = nibble_to_display + 8'h30; // 0-9
        else if (nibble_to_display < 16) // A-F   
            nibble_to_char = nibble_to_display + 8'd55; // 'A' = ASCII 65 or 0x41
        else
            nibble_to_char = 8'h3F; // '?' = ASCII 63 or 0x3F
    endfunction

    typedef enum logic [2:0] {IDLE, WRITE_CIPHERTEXT, WRITE_PLAINTEXT, WRITE_KEY, DONE, ERR='X} StateType;
    StateType ns, cs;
    logic [4:0] cur_text_row, next_text_row;
    logic [6:0] cur_text_col, next_text_col;
    logic [127:0] current_data, data_to_load;
    logic load_data, shift_data;

    // Current data register
    always_ff @(posedge clk) begin
        if (rst) begin
            current_data <= 128'h0;
        end
        else if (load_data) begin
            current_data <= data_to_load;
        end
        else if (shift_data) begin
            current_data <= {current_data[119:0], 8'h0};
        end
    end 
    assign char_data = current_data[127:120];

    always_ff @(posedge clk) begin
        if (rst) begin
            cs <= IDLE;
            cur_text_row <= 0;
            cur_text_col <= 0;
        end
        else begin
            cs <= ns;
            cur_text_row <= next_text_row;
            cur_text_col <= next_text_col;
        end
    end 

    logic [47:0] key_ascii; // 6 ascii characters
    assign key_ascii = {nibble_to_char(key[23:20]), nibble_to_char(key[19:16]), nibble_to_char(key[15:12]), 
        nibble_to_char(key[11:8]), nibble_to_char(key[7:4]), nibble_to_char(key[3:0])};

    // Next state logic
    always_comb begin
        ns = cs;
        next_text_row = cur_text_row;
        next_text_col = cur_text_col;
        write_char = 0;
        data_to_load = 0;
        shift_data = 0;
        load_data = 0;
        case (cs)
            IDLE: begin
                if (write_display) begin
                    ns = WRITE_CIPHERTEXT;
                    next_text_row = CIPHER_TEXT_ROW;
                    next_text_col = CIPHER_TEXT_COLUMN;
                    data_to_load = ciphertext;
                    load_data = 1;
                end
            end
            WRITE_CIPHERTEXT: begin  // Wait a half baud period for the start bit
                write_char = 1;
                if (cur_text_col == CIPHER_TEXT_COLUMN + CIPHER_TEXT_COLUMNS - 1) begin
                    ns = WRITE_PLAINTEXT;
                    next_text_col = PLAIN_TEXT_COLUMN;
                    next_text_row = PLAIN_TEXT_ROW;
                    data_to_load = plaintext;
                    load_data = 1;
                end
                else begin
                    shift_data = 1;
                    next_text_col = cur_text_col + 1;
                end
            end
            WRITE_PLAINTEXT: begin  // Wait a half baud period for the start bit
                write_char = 1;
                if (cur_text_col == PLAIN_TEXT_COLUMN + PLAIN_TEXT_COLUMNS - 1) begin
                    ns = WRITE_KEY;
                    next_text_col = KEY_COLUMN;
                    next_text_row = KEY_ROW;
                    data_to_load = {key_ascii, 80'h0};
                    load_data = 1;
                end
                else begin
                    shift_data = 1;
                    next_text_col = cur_text_col + 1;
                end
            end
            WRITE_KEY: begin  // Wait until the end of the frame
                write_char = 1;
                if (cur_text_col == KEY_COLUMN + KEY_COLUMNS - 1) begin
                    ns = DONE;
                end
                else begin
                    next_text_col = cur_text_col + 1;
                    shift_data = 1;
                end
            end
            DONE: begin  // Wait until the end of the frame
                if (~write_display) begin
                    ns = IDLE;
                end
            end
            default: ns = IDLE;
        endcase
    end

    assign char_addr = {cur_text_row, cur_text_col};


endmodule

