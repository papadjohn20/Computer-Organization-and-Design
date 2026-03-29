`timescale 1ns / 1ps
`define clock_period 20
`include "constants.h"


module cpu_tb;

reg clock,reset;
integer i, counter;

cpu cpu0(.clock(clock), .reset(reset));

always
   #(`clock_period / 2) clock = ~clock; 

initial begin
    clock = 0;
    reset = 0; 
    cpu0.ren = 1;
    $readmemh("program.hex", cpu0.instruction_memory.data, 0, 1023);
    #(2*`clock_period / 3) reset = 1;

    for (i = 0; i < 32; i = i+1)
      cpu0.regs.registers[i] = i;   // Note that always R0 = 0 in MIPS
    // for (i = 0; i < 32; i = i+1)
    //   #1 $display("Time=%0d , register=%0d, counter=%0d", $time , cpu0.regs.registers[i], i);
    

    $monitor("Time=%0d | PC: %h |Instruction: %h |inA: %0d and inB: %0d |ALUOut: %0d | RegWrite: %0d | ren: %0d | AluOp %0d |" /*sing_extend = %b*/
    , $time, cpu0.PC, cpu0.instruction, cpu0.inA, cpu0.inB, cpu0.aluOut, cpu0.RegWrite, cpu0.ren, cpu0.AluOp, /*cpu0.sign_extend*/);


    #1000
     for (i = 0; i < 32; i = i+1)
          #1 $display("Time=%0d , register=%0d, counter=%0d", $time , cpu0.regs.registers[i], i);
           $finish;
end

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, cpu_tb);

    for (counter = 0; counter < 32; counter = counter+1)
      $dumpvars(1, cpu0.regs.registers[counter]);
    for (counter = 0; counter < 1024; counter = counter+1)
      $dumpvars(1, cpu0.instruction_memory.data[counter]);
      // $dumpvars(1, cpu0.data_memory.data[counter]);
end


endmodule