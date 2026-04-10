/***************************************************************************
* 
* Filename: char_gen.sv
*
* Author: Ryan Mortenson
* Description: character generator module
*
****************************************************************************/

module char_gen #(
    parameter FILENAME = ""	// Specifies the filename of the initial contents of the memory
)(
    input logic         clk,        // 100MHz Clock
    input logic         char_we,        // Character write enable
    input logic [11:0]  char_addr,  // The write address of the character memory
    input logic  [6:0]  char_value, // The 7-bit value to pad and write into the character memory
    input logic  [9:0]  pixel_x,    // The column address of the current pixel
    input logic  [8:0]  pixel_y,    // The row address of the current pixel
    output logic        pixel_out   // The value of the character output pixel
);


logic [7:0] mem_data[0:4095];
logic [7:0] char_read_value, rom_data;
logic [11:0] char_read_addr;
logic [8:0] pixel_y_r;
logic [9:0] pixel_x_r, pixel_x_r2;

// Initialize memory from file
always_ff @(posedge clk) begin
    if (char_we) begin
        mem_data[char_addr] <= {1'b0, char_value}; // Pad the 7-bit value with a leading 0 to make it 8 bits
    end
    
end


// Calculate the character memory address based on the pixel coordinates
assign char_read_addr = {pixel_y[8:4], pixel_x[9:3]}; 


// Read the character data from memory
always_ff @(posedge clk) begin
    char_read_value <= mem_data[char_read_addr];
end

//pixel_y_r is used to hold the value of pixel_y for the next clock cycle, which is needed for the font ROM address calculation. This is because the font ROM needs to know which row of the character to output, and that depends on the current pixel's y-coordinate.
always_ff @(posedge clk) begin
    pixel_y_r <= pixel_y;
end

//pixel_x_r and pixel_x_r2 are used to hold the value of pixel_x for the next two clock cycles, which is needed for the font ROM data selection. This is because the font ROM outputs an 8-bit value representing a row of the character, and we need to select the appropriate bit from that value based on the current pixel's x-coordinate.
always_ff @(posedge clk) begin
    pixel_x_r <= pixel_x;
end

//pixel_x_r2 is used to hold the value of pixel_x for the next clock cycle, which is needed for the font ROM data selection. This is because the font ROM outputs an 8-bit value representing a row of the character, and we need to select the appropriate bit from that value based on the current pixel's x-coordinate.
always_ff @(posedge clk) begin
    pixel_x_r2 <= pixel_x_r;
end

// The initial block is used to initialize the character memory from a file. If the FILENAME parameter is not an empty string, it will read the contents of the file into the mem_data array. The $readmemh system task is used to read hexadecimal values from the file and store them in the mem_data array, starting at index 0.
initial begin
     if (FILENAME != "")
         $readmemh(FILENAME, mem_data, 0);
 end

// Instantiate the font ROM module. The address input to the font ROM is formed by concatenating the 7-bit character value read from the character memory (char_read_value[6:0]) with the 3-bit row index of the character (pixel_y_r[2:0]). This allows the font ROM to output the correct row of pixel data for the current character being displayed.
font_rom font_rom_inst (
    .clk(clk),
    .addr({char_read_value[6:0], pixel_y_r[3:0]}),
    .data(rom_data)
);

// multiplex the appropriate bit from the ROM data based on the x-coordinate of the pixel. The x-coordinate is used to determine which bit of the 8-bit ROM data to output as the pixel value. Since each character is 8 pixels wide, we use the lower 3 bits of the x-coordinate (pixel_x[2:0]) to select the appropriate bit from the ROM data.
assign pixel_out = rom_data[7 - pixel_x_r2[2:0]]; // Select the appropriate bit from the ROM data based on the x-coordinate of the pixel

endmodule