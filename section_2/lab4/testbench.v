// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`timescale 1ns/1ps
`define clock_period 4

module cpu_tb;

parameter n = 8;
reg clock, reset;    // Clock and reset signals
reg [4:0] raA, raB, wa;
reg wen;
reg [n-1:0] wd;
wire [n-1:0] rdA, rdB;
integer i;
// reg [31:0] inA, inB;
reg [3:0] op;
wire [n-1:0] out;
wire zero;
// Instantiate regfile module
RegFile #(n) regs(clock, reset, raA, raB, wa, wen, out, rdA, rdB);
// YOU ALSO NEED TO INSTATIATE THE ALU HERE
ALU #(n) alu(out, zero, rdA, rdB, op);

initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka
   $monitor("Time=%0d, op=%d, rdA=%b, rdB=%b, out=%b, zero=%b, reset = %b", $time, op, rdA, rdB, out, zero, reset);
  // Initialize the module
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   
   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
      regs.registers[i] = i;   // Note that always R0 = 0 in MIPS
   
  // Now apply some inputs.
  // You SHOULD EXTEND this part of the code with extra inputs

// reset = 0;
// #1
// #(2*`clock_period)

   raA = 1; raB = 2; op = 0;  wa = 3; wen=1; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

   raA = 1; raB = 2; op = 1;  wa = 4; wen=1; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

   raA = 1; raB = 2; op = 2;  wa = 5; wen=1; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

   raA = 1; raB = 2; op = 6;  wa = 6; wen=0; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

   raA = 1; raB = 2; op = 7;  wa = 7; wen=1; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

   raA = 1; raB = 2; op = 12;  wa = 3; wen=1; reset = 1;
   #10  $display("Time=%0d , wd=%b, wa=%d", $time ,regs.registers[wa], wa);
#(2*`clock_period)

$finish;
end

// Generate clock by inverting the signal every half of clock period
always
   #(`clock_period / 2) clock = ~clock; 

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, cpu_tb);
end

endmodule
