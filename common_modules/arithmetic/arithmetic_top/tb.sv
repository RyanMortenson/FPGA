//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb.sv
//
//  Author: Brent Nelson
//
//  Description: Provides a basic testbench for the arithmetic lab.  Is modified
//               version of tb_arithmetic v.
//
//  Version 3.2
//
//  Change Log:
//    v3.2: Add btnc to select between addition and substation. 
//    v3.1: Replace sign extension with overflow detection. Add only 8 bits.
//    v2.1: Removed btnl and btnr to streamline lab for on-line semesters.
//          Converted to SystemVerilog
//    v1.1: Modified the arithmetic_top to use "port mapping by name" rather than
//          port mapping by order.
//
//////////////////////////////////////////////////////////////////////////////////

module tb();
	logic btnc;
	logic [15:0] sw;
	logic [8:0] led;

	integer i,errors;
	logic [31:0] rnd;
	logic signed [7:0] A,B;
	logic signed [7:0] result;
	logic overflow;

	// Instance the unit under test
	arithmetic_top dut(.sw(sw), .btnc(btnc), .led(led));

	initial begin

		// print time in ns (-9) with the " ns" string
		$timeformat(-9, 0, " ns", 0);
		errors = 0;
		#20
		$display("*** Starting simulation at time %t ***", $time);
		#20

		// Test random cases
		for(i=1; i < 256; i=i+1) begin
			#10
			btnc = i%2;  // switch between addition and subtraction every iteration
			rnd = $random;
			sw[15:0] = rnd[15:0];
			B = sw[15:8];
			A = sw[7:0];
			#10
			if (!btnc) begin     // addition when sub = 0, subtraction when sub = 1
			     result = A+B;
			     overflow = (A[7] & B[7] & ~result[7]) | (~A[7] & ~B[7] & result[7]); // overflow for addition
			  end
			else begin
			     result = A-B;
			     overflow = (A[7] & ~B[7] & ~result[7]) | (~A[7] & B[7] & result[7]); // overflow for subtraction must use the sign of flipped B
              end

			if (result !== led[7:0] || led[8] !== overflow) begin
			    if (!btnc)
				    $display("Error: A=%b,B=%b and A+B=%b overflow=%b but expecting %b overflow=%b at time %t", A,B,led[7:0],led[8],result,overflow, $time);
				else
					$display("Error: A=%b,B=%b and A-B=%b overflow=%b but expecting %b overflow=%b at time %t", A,B,led[7:0],led[8],result,overflow, $time);
				errors = errors + 1;
			end
			else begin
			    if (!btnc)
					$display("Success: A=%b,B=%b and A+B=%b overflow=%b at time %t", A,B,led[7:0],led[8], $time);
				else
					$display("Success: A=%b,B=%b and A-B=%b overflow=%b at time %t", A,B,led[7:0],led[8], $time);
			end
		end

		#20
		$display("*** Simulation done with %0d errors at time %t ***", errors, $time);
		$finish;

	end // initial

endmodule