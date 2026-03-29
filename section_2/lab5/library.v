`include "constants.h"
`timescale 1ns/1ps
`define clock_period 20

module pc_module(clock, reset, PC, PC_new);
input clock, reset;
input [31:0] PC_new;
output reg[31:0] PC;

// reg [31:0] PC_new;

always @(posedge clock or negedge reset) begin
    if (!reset)
        PC <= 0;
    else
        PC <= PC_new; 
        // if (PC_new != 32'bx)  begin $display("Updating PC: %h -> %h", PC, PC_new); end  
    end

// always @(PC) begin
//     PC_new = PC + 4;
// end

endmodule

// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU #(parameter n=32)(out, zero, inA, inB, op);
input [n-1:0] inA, inB;
input [3:0] op;
output reg [n-1: 0] out;
output reg zero;

always @(inA, inB, op) begin
    case (op)
        0: out = inA & inB;
        1: out = inA | inB;
        2: out = inA + inB;
        6: out = inA - inB;     
        7: out = (inA < inB) ? 1:0;   
        12: out = ~(inA | inB);
        default: out = {n{1'bx}};
    endcase

    zero = (out == 0) ? 1 : 0;
end
endmodule


// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, addr, din, dout);
input ren;
input  [31:0] addr, din;
output  [31:0] dout;

reg [31:0] data[1023:0];
wire [31:0] dout;

always @(posedge ren  or addr) begin // It does not correspond to hardware. Just for error detection
if (addr[31:10] != 0)
    $display("Memory WARNING (time %0d): address msbs are not zero\n addr = %h", $time, addr);
end  

assign dout = (ren==1'b1) ? data[addr[9:0]] : 32'bx;  /*(==1'b0) &&*/ 

always @(din or ren or addr)
begin
// $display("(time %0d)    dout = %h", $time,dout);
if (ren==1'b0) 
    data[addr[9:0]] = din;
// else dout = data[addr[9:0]];
end
endmodule


// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile#(parameter n=32) (clock, reset, raA, raB, wa, RegWrite, wd, rdA, rdB);
input clock, reset, RegWrite;
input[4:0] raA, raB, wa;
input[n-1:0] wd;
output [n-1:0] rdA, rdB;
integer i;
input [3:0] op;

reg [n-1:0] registers [31:0];

assign rdA = registers[raA];
assign rdB = registers[raB];

always @(negedge clock or negedge reset) begin
    if (reset == 0) begin
        for(i = 0; i < 32; i = i + 1) 
            registers[i] = 32'b0;            
    end
    
    else if (RegWrite && wa != 0) begin
        // $display("(time %0d)    RegWrite was %0d", $time,RegWrite);
        registers[wa] = wd;
        // $display("(time %0d)   register changed to -> %0d | wa = %0d", $time, wd, wa);
    end
end

endmodule

// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
// Write the FSM code here
module Control_Unit(opcode, func, AluOp, RegWrite, RegDst, AluSrc, Branch_BEQ, Branch_BNE, MemRead, MemToReg);           
	input [5:0] opcode;
    input [5:0] func;
    output reg [3:0] AluOp;
    output reg RegWrite, RegDst, AluSrc, Branch_BEQ, Branch_BNE, MemToReg, MemRead;

    //PAGE 28 LEC9_SINGLECYCLE
    always @(opcode, func) begin

        if (opcode == `R_FORMAT) begin
           RegWrite = 1; RegDst = 1; AluSrc = 0; Branch_BEQ = 0; Branch_BNE = 0; MemRead = 1; MemToReg = 0;
            
          case (func) 
            6'b100100: AluOp = 0; //and
            6'b100101: AluOp = 1; //or
            6'b100000: AluOp = 2; //add
            6'b100010: AluOp = 6; //sub
            6'b101010: AluOp = 7; //slt
            6'b100111: AluOp = 12;//nor
            default: AluOp = 4'bxxxx;
          endcase           
        end 

        else if (opcode == `LW) begin 
            RegWrite = 1; RegDst = 0; AluSrc = 1; Branch_BEQ = 0; Branch_BNE = 0; MemRead = 1; MemToReg = 1; AluOp = 2;
        end

        else if (opcode == `SW) begin 
            RegWrite = 0; RegDst = 1'bx; AluSrc = 1; Branch_BEQ = 0; Branch_BNE = 0; MemRead = 0; MemToReg = 1'bx; AluOp = 2;
        end

        else if (opcode == `BEQ)begin 
            RegWrite = 0; RegDst = 1'bx; AluSrc = 0; Branch_BEQ = 1; Branch_BNE = 0; MemRead = 1; MemToReg = 1'bx; AluOp = 6;
        end
        
        else if (opcode == `BNE)begin 
            RegWrite = 0; RegDst = 1'bx; AluSrc = 0; Branch_BEQ = 0; Branch_BNE = 1; MemRead = 1; MemToReg = 1'bx; AluOp = 6;
        end

        else if (opcode == `ADDI)begin 
            RegWrite = 1; RegDst = 0; AluSrc = 1; Branch_BEQ = 0; Branch_BNE = 0; MemRead = 1; MemToReg = 0; AluOp = 2;
        end
    end 
endmodule

module mux#(parameter n = 32) (a, b, sel, mux_out);
    input  sel;              
    input  [n-1:0] a, b;
    output  [n-1:0] mux_out;   

    assign mux_out = sel ? b : a;     
endmodule

module SignExtender(instruction, extended);
input [15:0] instruction;
output reg [31:0] extended;

always @(instruction) begin 
    extended[15:0] = instruction[15:0];
    extended[31:16] = {31{instruction[15]}};
end
endmodule

module Check_Branch(aluZero, Branch_BEQ, Branch_BNE, Branch);
input aluZero, Branch_BEQ, Branch_BNE;
output reg Branch; //tha to ftiaxw wste an to branch vgei 1 na prepei na ginei jump

always @(*)begin
    if (Branch_BEQ & aluZero) begin
        Branch = 1; //tha exw branch taken se beq 
    end 
    else if (Branch_BNE & ~aluZero) begin 
        Branch = 1; //tha exw branch taken se bne
    end
    else Branch = 0;
end 
endmodule

module cpu(clock, reset);
input clock, reset;
integer i;
wire [31:0] PC, PC_new, instruction, aluOut, inA, inB, mux_inB, sign_extend, shifted_sign_extend, Read_data, Write_data;
wire [3:0] AluOp;
wire [4:0] RegDst_out;
wire RegWrite, RegDst, aluZero, AluSrc, Branch, Branch_BEQ, Branch_BNE, MemRead, MemToReg; //control signals
reg ren;

pc_module pc_inst(.clock(clock), .reset(reset), .PC(PC), .PC_new(PC_new));

Memory instruction_memory(.ren(ren), .addr(PC/4), .din(32'bx), .dout(instruction));

Control_Unit FSM(.opcode(instruction[31:26]), .func(instruction[5:0]), .AluOp(AluOp), .RegWrite(RegWrite), .RegDst(RegDst), .AluSrc(AluSrc), .Branch_BEQ(Branch_BEQ), .Branch_BNE(Branch_BNE), .MemRead(MemRead), .MemToReg(MemToReg));

mux #(5) mux_RegDst(.a(instruction[20:16]), .b(instruction[15:11]), .sel(RegDst), .mux_out(RegDst_out));
RegFile #(32) regs(.clock(clock), .reset(reset), .raA(instruction[25:21]), .raB(instruction[20:16]), .wa(RegDst_out), .RegWrite(RegWrite), .wd(Write_data), .rdA(inA), .rdB(inB));

SignExtender sign_extended(.instruction(instruction[15:0]), .extended(sign_extend));
mux #(32) mux_AluSrc( .a(inB), .b(sign_extend), .sel(AluSrc), .mux_out(mux_inB));
ALU #(32) alu_reg(.out(aluOut), .zero(aluZero), .inA(inA), .inB(mux_inB), .op(AluOp));

Memory data_memory(.ren(MemRead), .addr(aluOut), .din(inB), .dout(Read_data));
mux #(32) mux_MemToReg(.a(aluOut), .b(Read_data), .sel(MemToReg), .mux_out(Write_data));

assign shifted_sign_extend = sign_extend << 2;

Check_Branch check_branch(.aluZero(aluZero), .Branch_BEQ(Branch_BEQ), .Branch_BNE(Branch_BNE), .Branch(Branch));
mux #(32) mux_Branch( .a(PC+4), .b(shifted_sign_extend + PC), .sel(Branch), .mux_out(PC_new));

endmodule