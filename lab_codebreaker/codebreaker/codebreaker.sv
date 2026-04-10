/***************************************************************************
* 
* Filename: codebreaker.sv
*
* Author: Ryan Mortenson
* Description: code breaker module
*
****************************************************************************/

module codebreaker #(
    parameter MAX_KEY = 24'hffffff	// Maximum key value to check
)(
    input logic         clk,        // 100MHz Clock
    input logic         reset,      // Active high reset signal
    input logic         start,      // Set high to start running the codebreaker
    output logic        done,       // High when the key search completes (on success or error). Stays high until reset or starting a new search
    output logic        error,      // Indicates the previous codebreak resulted in no match. Stays high until reset or starting a new search
    output logic [23:0] key,         // Encryption key
    input logic [127:0] bytes_in,     // input bytes (cipher text)
    output logic [127:0] bytes_out     // output bytes (plain text)
);

// Intermediate signals
logic [127:0] original_ciphertext;
logic decrypt_enable, decrypt_done;

// Instantiate the decrypt_rc4 module
decrypt_rc4 
decrypt_inst (
    .clk(clk),
    .reset(reset),
    .enable(decrypt_enable),
    .key(key),
    .bytes_in(original_ciphertext),
    .bytes_out(bytes_out),
    .done(decrypt_done)
);



// Determines whether the input byte is an ASCII character
function logic isAscii(input logic [7:0] byte_in);
    isAscii = ((byte_in >= "A" && byte_in <= "Z") || 
            (byte_in >= "0" && byte_in <= "9") ||
            (byte_in == " "));
endfunction

// Check simultaneously if all output bytes are ASCII characters
assign is_ascii = isAscii(bytes_out[127:120]) && isAscii(bytes_out[119:112]) &&
                  isAscii(bytes_out[111:104]) && isAscii(bytes_out[103:96]) &&
                  isAscii(bytes_out[95:88]) && isAscii(bytes_out[87:80]) &&
                  isAscii(bytes_out[79:72]) && isAscii(bytes_out[71:64]) &&
                  isAscii(bytes_out[63:56]) && isAscii(bytes_out[55:48]) &&
                  isAscii(bytes_out[47:40]) && isAscii(bytes_out[39:32]) &&
                  isAscii(bytes_out[31:24]) && isAscii(bytes_out[23:16]) &&
                  isAscii(bytes_out[15:8]) && isAscii(bytes_out[7:0]);  


// State machine to iterate through keys and check for a match
typedef enum {IDLE, CHECK_KEY, INCREMENT_KEY, DONE} StateType;
StateType cs;

// Sequential logic for state transitions and output control
always_ff @(posedge clk) begin
    if (reset) begin
        cs <= IDLE;
        key <= 24'h0;
        done <= 0;
        error <= 0;
        decrypt_enable <= 1'b0; // Disable decryption by default, will enable in CHECK_KEY state
        original_ciphertext <= 128'h0; // Clear original ciphertext on reset
    end else begin
        decrypt_enable <= 1'b0; // Default to not enabling decryption, will enable in CHECK_KEY state
        
        case (cs)
            IDLE: begin
                done <= 0;
                error <= 0;
                if (start) begin
                    cs <= CHECK_KEY;
                    original_ciphertext <= bytes_in; // Store the original ciphertext for comparison
                end
            end
            CHECK_KEY: begin
                decrypt_enable <= 1; // Enable decryption with the current key
                if (decrypt_done) begin // Wait for decryption to complete
                    if (is_ascii) begin // Check if output is valid ASCII
                        done <= 1; // Found a valid key, signal done
                        cs <= DONE;
                    end else begin
                        cs <= INCREMENT_KEY; // Not a match, try the next key
                    end
                end
            end
            INCREMENT_KEY: begin
                decrypt_enable <= 0; // Disable decryption while incrementing key
                if (key < MAX_KEY) begin
                    key <= key + 1; // Increment the key and check again
                    cs <= CHECK_KEY;
                end else begin
                    error <= 1; // Reached max key without finding a match, signal error
                    done <= 1;
                    cs <= DONE;
                end
            end
            DONE: begin
                // Stay in this state until reset or a new search is started
                if (start) begin
                    cs <= CHECK_KEY; // Start a new search immediately if start is asserted again
                    key <= 24'h0; // Reset key to 0 for new search
                    done <= 0;
                    error <= 0;
                    original_ciphertext <= bytes_in; // Update the original ciphertext for the new search
                end
            end
        endcase
    end
end









endmodule