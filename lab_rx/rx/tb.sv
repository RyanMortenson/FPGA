// Testbench for UART Receiver Lab

module tb #(parameter CLK_FREQUENCY=100_000_000, parameter BAUD_RATE = 19_200);
   logic clk, Receive, ReceiveAck, Sin, rst, parityErr;
   logic [7:0] Dout;
   int         errors;
   int bitTime = CLK_FREQUENCY / BAUD_RATE;
   int halfBitTime = bitTime/2;
   int bitTime98 = (bitTime * 98) / 100;
   int bitTime102 = (bitTime * 102) / 100;
   // int         bitTime = 5208;
   // int         halfBitTime = bitTime/2;

   // Instance the DUT
   rx student_rx(.clk(clk), .rst(rst), .Receive(Receive), .Dout(Dout), .ReceiveAck(ReceiveAck), .Sin(Sin), .parityErr(parityErr));

   // Clock
   initial begin
      #100ns; // wait 100 ns before starting clock (after inputs have settled)
      clk = 0;
      forever begin
         #5ns  clk = ~clk;
      end
   end

   task dla(int cycles = 1);
      repeat (cycles)
        @(negedge clk);
   endtask

   task sdla(int cycles = 1);
      dla(cycles);
      #1ns;  // To ensure driving is after monitoring
   endtask

   function void pmsg(input string msg);
      $display("%s at time %0t", msg, $time);
   endfunction // msg

   function void incErr(input string msg);
      pmsg(msg);
      errors += 1;
      if (errors > 10) begin
         pmsg("*** MAX ERROR COUNT of 10 exceeded: exiting");
         endSimulation();
      end
   endfunction // incErr

   function void sampleHint();
      pmsg("*** HINT: This may indicate the receiver is not sampling near the middle of the bit period");
   endfunction

   task sendDataWithBitTime(input logic [7:0] mdin, input int txBitTime);
      pmsg($sformatf("Testbench is getting ready to send 0x%0x", mdin));

      // Wait for a few negative edges of clock and then start sending
      sdla(4);

      // Start bit
      Sin = 0;
      sdla(txBitTime);

      // Send bits
      for (int i=0;i<8;i++) begin
         Sin = mdin[i];
         sdla(txBitTime);
      end

      // Send parity
      Sin = ~^mdin;
      sdla(txBitTime);

      // Send stop bit
      Sin = 1;
      sdla(txBitTime);
      pmsg($sformatf("   Testbench is done serially transmitting byte 0x%h", mdin));
   endtask

   task sendData(input logic [7:0] mdin);
      sendDataWithBitTime(mdin, bitTime);
   endtask

   task chkTransfer(input logic [7:0] mdout);

      // Wait for 'receive' signal
      @(posedge Receive);
      sdla();

         if (mdout != Dout) begin
        incErr($sformatf("*** ERROR: expecting to have received byte 0x%0x but received 0x%0x instead", mdout, Dout));
             sampleHint();
         end else
        pmsg($sformatf("   Serially received data byte 0x%0x", Dout));
         if (parityErr == 1) begin
        incErr($sformatf("*** ERROR: parity error on received byte"));
             sampleHint();
         end

      ReceiveAck = 1;
      @(negedge Receive);
      sdla();

      ReceiveAck = 0;
      sdla();
   endtask

   // Fire up parallel tasks to drive and monitor at same time
   task doTransfer(input logic [7:0] Din);
      fork
         sendData(Din);
         chkTransfer(Din);
      join
//      pmsg("Done with doTransfer");
   endtask

   task doTransferWithBitTime(input logic [7:0] Din, input int txBitTime);
      fork
         sendDataWithBitTime(Din, txBitTime);
         chkTransfer(Din);
      join
   endtask

   function void endSimulation();
      $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
   endfunction // endSimulation

   // Main test block
   initial begin

      errors = 0;
      //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
      $timeformat(-9, 0, " ns", 20);
      $display("*** Start of Simulation ***");

      // Initial values
      ReceiveAck = 0;
      rst = 0;
      Sin = 1;

      // Do rst
      sdla(1);
      rst = 1;
      sdla(2);
      rst = 0;
      sdla(1);

      // Check that Receive initially idles low
      if (Receive != 0)
        incErr($sformatf("*** ERROR: 'Receive' should start out as a '0' but it is a %0d", Receive));

      // test some transfers
      dla(10);
      doTransfer(8'hff);

      dla(100);
      doTransfer(8'h00);

      dla(100);
      doTransfer(8'h0f);

      dla(100);
      doTransfer(8'hf0);

      // test odd number of bits
      dla(100);
      doTransfer(8'h37);

      dla(100);
      doTransfer(8'h73);

      dla(100);
      doTransfer(8'haa);

      dla(100);
      doTransfer(8'h55);

      $display();
      pmsg("Doing test with 98% period");
      dla(100);
      doTransferWithBitTime(8'h37, bitTime98);

      dla(100);
      doTransferWithBitTime(8'h73, bitTime98);

      $display();
      pmsg("Doing test with 102% period");
      dla(100);
      doTransferWithBitTime(8'h37, bitTime102);

      dla(100);
      doTransferWithBitTime(8'h73, bitTime102);

      endSimulation();
      $finish;

   end  // end initial begin

endmodule // tb
