# Chapter 27 Homework

For this homework assignment you will need to create a testbench to verify the operation of a 4-bit counter.
The counter has the following top-level ports:
```
module cnt(input logic clk, rst, en, up, load, 
    input logic [3:0] count_in,
    output logic [3:0] count);
```
The proper operation of this counter is as follows:
* This counter has a synchronous reset signal 'rst' that resets the counter to 0 when asserted.
* The counter should only change when the 'en' signal is asserted (except of course with the reset)
* If the 'load' signal is asserted, perform a parallel load of the counter.
* If the 'load' signal is not asserted, perform an up or down count depending on the 'up' input signal (count up if up=1, otherwise count down). 

Create a testbench file named `tb_cnt.sv` that does the following:
* Waits 100 ns before setting any input signals
* Generate a free running clock of 100 MHz after 100 ns
* Run the simulation for 100 ns before setting any other inputs
* Set default values for all inputs (including a rst = 0)
* Run the simulation for several clock cycles
* Issue a reset for a few clock cycles and release the reset
* Assert 'en' and 'up' and make sure the counter counts up from 0 to 15 and rolls over to 0.
* Test the ability to count down.
* Create a test to make sure the 'load' works and has priority over the 'up' signal.
* Test the reset signal after other tests to make sure you can reset the counter again.
* Print an error message if the counter does not behave as expected. Print a success message if the counter operates as expected.

This directory contains several counter files to test that all have the same interface and module name.
Create a `Makfefile` that has a rule for each of the counter files to run the simulation.
These rules should be named 'test_cnt1', 'test_cnt2', and and so on.
Add a `clean` rule to remove all the simulation files.

Submit your files by committing your testbench and makefile to this directory of your respository.

