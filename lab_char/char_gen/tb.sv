// Testbench for charGen

module tb #(parameter FILENAME="", parameter VERBOSE = 0)();
   logic clk, char_we;
   logic [6:0] char_value;
   logic [11:0] char_addr;
   logic [9:0] pixel_x, pixel_x_d, pixel_x_dd = 0;
   logic [8:0] pixel_y, pixel_y_d, pixel_y_dd = 0;
   logic pixel_out, expected_pixel;
   logic [10:0] font_addr = 0;
   logic [7:0] font_data;
   logic start_checking = 0;
   int errors = 0;

   // Specifies what character should be at the given character location
   function int char_at_address(input int char_column, input int char_row);
      char_at_address = (char_column+char_row) % 128;
   endfunction

   // Determines the addres of a column/row in the character memory
   function int char_address(input int char_column, input int char_row);
      char_address = char_row*128+char_column;
   endfunction

   // Determines character column from pixel column
   function int pixel_col2char_col(input int pixel_col);
      pixel_col2char_col = pixel_col >> 3;
   endfunction

   // Determines character row from pixel row
   function int pixel_row2char_row(input int pixel_row);
      pixel_row2char_row = pixel_row >> 4;
   endfunction

   // Write a character to the character memory
   task write_char(input int character_value, input int character_address);
      @(negedge clk);
      char_we = 1;
      char_value = character_value;
      char_addr = character_address;
      @(posedge clk);
      if (VERBOSE)
         $display("[%0t] Write character 0x%0x to address %0x, char loc (%0d,%0d)", 
            $time, character_value, character_address,
            character_address & 7'h7f, (character_address & 12'hf80) >> 7);
      @(negedge clk);
      char_we = 0;
      @(negedge clk);
   endtask

/*
      if (pixel_out != expected_pixel) begin
         $display("[%0t] Error: Pixel at %0d,%0d is %0d but expected %0d. Char: 0x%0x, font data: 0x%0x", 
         $time, pixel_col, pixel_row, pixel_out, expected_pixel, char_to_display, font_data);
         errors++;
      end
      else if (VERBOSE) begin
         $display("[%0t] Ok: Pixel at %0d,%0d is %0d, expected %0d", $time, pixel_col, pixel_row, pixel_out, expected_pixel);
      end
*/
   // Behavioral pixel_out generation
   logic [6:0] tb_char_to_display;
   always_ff @(posedge clk) begin
      pixel_y_d <= pixel_y;
      pixel_y_dd <= pixel_y_d;
      pixel_x_d <= pixel_x; // Only keep the bottom three bits
      pixel_x_dd <= pixel_x_d;
      tb_char_to_display <= char_at_address(
         pixel_col2char_col(pixel_x),
         pixel_row2char_row(pixel_y));
   end
   always_comb begin
      font_addr = {tb_char_to_display, pixel_y_d[3:0]};
      expected_pixel = font_data[7-pixel_x_dd[2:0]];
   end

   always_ff @(negedge clk) begin
      if (start_checking) begin
         if (pixel_out !== expected_pixel) begin
            $display("[%0t] Error: Pixel at %0d,%0d is %0d (exp %0d). Char: 0x%0x (%0d,%0d), font line: 0x%0x (%0d,%0d)", 
            $time, pixel_x_dd, pixel_y_dd, pixel_out, expected_pixel, 
            tb_char_to_display, (pixel_x_dd>>3), (pixel_y_dd>>4), font_data, (pixel_x_dd&3'b111), (pixel_y_dd&4'b1111));
            errors++;
            $finish;
         end
         else if (VERBOSE) begin
            $display("[%0t] Ok: Pixel at %0d,%0d is %0d, expected %0d", $time, pixel_x, pixel_y, pixel_out, expected_pixel);
         end
      end
   end

   // Instance design under test
   char_gen #(.FILENAME(FILENAME))
   DUT (
        .clk(clk),
        .char_we(char_we),
        .char_addr(char_addr),
        .char_value(char_value),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_out(pixel_out)
    );

   // Instance font rom
   font_rom font_rom(
        .clk(clk),
        .addr(font_addr),
        .data(font_data)
    );

   // Clock
   initial begin
      #100ns; // wait 100 ns before starting clock (after inputs have settled)
      clk = 0;
      forever begin
         #5ns  clk = ~clk;
      end
   end

   // Main test block
   initial begin

      // errors = 0;
      //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
      $timeformat(-9, 0, " ns", 20);
      $display("*** Start of Simulation ***");

      char_we = 0;
      char_value = 0;
      pixel_x = 0;
      pixel_y = 0;
      repeat (10) @(negedge clk); // wait 10 clocks

      // Write values into character memory
      $display("[%0t] Write characters to character memory", $time);
      for (int i=0; i<30; i++) begin // rows
         for (int j=0; j<80; j++) begin // columns
            // $display("[%0t] %0d,%0d: %0x-0x%0x", $time, j, i, char_at_address(j,i), char_address(j,i));
            write_char( char_at_address(j,i), char_address(j,i) );
         end
      end
      char_value = 0;

      // Loop through all the pixels
      @(posedge clk); // start at positive edge
      start_checking = 1;
      $display("[%0t] Checking all pixel values", $time);
      for (int i=0; i<480; i++) begin // rows
         #1ns;
         pixel_y = i;
         for (int j=0; j<640; j++) begin // columns
            #1ns;
            pixel_x = j;
            repeat (4) @(posedge clk); // four clocks for each pixel_x,pixel_y pair
         end
      end

      $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
      $finish;

   end  // end initial begin

endmodule // tb
