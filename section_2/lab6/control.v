`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch, 
                output reg MemRead,
                output reg MemWrite, 
                output reg MemToReg, 
                output reg ALUSrc, 
                output reg RegWrite, 
                output reg [1:0] ALUcntrl, 
                input [5:0] opcode);

  always @(*)
   begin
     case (opcode)
      `R_FORMAT:
      /* TO FILL IN: The control signal values in each and every case */
          begin
            RegDst   = 1'b1;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc   = 1'b0;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUcntrl = 2'b10;             
          end
       `LW :   
           begin
            RegDst   = 1'b0;
            MemRead  = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUcntrl = 2'b00;
           end
        `SW :   
           begin
            RegDst   = 1'bx;
            MemRead  = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'bx;
            ALUSrc   = 1'b1;
            RegWrite = 1'b0;
            Branch   = 1'b0;
            ALUcntrl = 2'b00;
           end
       `BEQ: 
           begin
            RegDst   = 1'bx;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'bx;
            ALUSrc   = 1'b0;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            ALUcntrl = 2'b01;
           end
       `ADDI:
           begin
            RegDst   = 1'b0;
            MemRead  = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUcntrl = 2'b00;
           end
       default:
           begin
            RegDst   = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc   = 1'b0;
            RegWrite = 1'b0;
            Branch   = 1'b0;
            ALUcntrl = 2'b00;
           end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
// TO FILL IN: Module details
module forwarding_unit (
                output reg [1:0] ForwardA,  // Forwarding control for ALU input A
                output reg [1:0] ForwardB,  // Forwarding control for ALU input B
                output reg       ForwardC,
                input EXMEM_RegWrite,
                input [4:0] EXMEM_RegWriteAddr,
                input MEMWB_RegWrite,
                input [4:0] MEMWB_RegWriteAddr,
                input [4:0] IDEX_instr_rs,
                input [4:0] IDEX_instr_rt
            );

  always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        ForwardC = 1'b0;
        if (MEMWB_RegWrite == 1 && MEMWB_RegWriteAddr != 0 && MEMWB_RegWriteAddr == IDEX_instr_rs
          && (EXMEM_RegWriteAddr != IDEX_instr_rs || EXMEM_RegWrite == 0)) begin
           ForwardA = 2'b01;
        end
        if (MEMWB_RegWrite == 1 && MEMWB_RegWriteAddr != 0 && MEMWB_RegWriteAddr == IDEX_instr_rt
          && (EXMEM_RegWriteAddr != IDEX_instr_rt || EXMEM_RegWrite == 0)) begin
           ForwardB= 2'b01;
        end

        if (EXMEM_RegWrite == 1 && EXMEM_RegWriteAddr != 0 && EXMEM_RegWriteAddr == IDEX_instr_rs) begin
          ForwardA =  2'b10;
        end
        if (EXMEM_RegWrite == 1 && EXMEM_RegWriteAddr != 0 && EXMEM_RegWriteAddr == IDEX_instr_rt) begin
          ForwardB =  2'b10;
        end

        if (MEMWB_RegWrite == 1 && MEMWB_RegWriteAddr != 0 && MEMWB_RegWriteAddr == EXMEM_RegWriteAddr)  begin
          ForwardC = 1'b1;
        end
  end

endmodule         
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
// TO FILL IN: Module details
module hazard_detection_unit(
                output reg PC_Write,
                output reg IFID_Write,
                output reg nop_sel,
                input IDEX_MemRead,
                input [4:0] IDEX_instr_rt,
                input [31:0] IFID_instr
              );

  always @(*) begin
    nop_sel = 1'b1;
    PC_Write = 1'b1;
    IFID_Write = 1'b1;
   
    if (IDEX_MemRead && ((IDEX_instr_rt == IFID_instr[25:21]) || (IDEX_instr_rt == IFID_instr[20:16]))) begin
      nop_sel = 1'b0;
      PC_Write = 1'b0;
      IFID_Write = 1'b0;
    end
  end

endmodule
                   
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,
               output reg shamtSel,                 
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func) 
    begin
      shamtSel = 1'b0;
      case (ALUcntrl)
          2'b10:
           begin
             case (func)
              `ADD:  ALUOp = 4'b0010;

              `SUB:  ALUOp = 4'b0110;

              `AND:  ALUOp = 4'b0000;

              `OR:   ALUOp = 4'b0001;

              `NOR:  ALUOp = 4'b1100;

              `SLT:  ALUOp = 4'b0111;

              `SLL:
                  begin 
                    ALUOp = 4'b1000;
                    shamtSel = 1'b1;
                  end

              `SRL:
                  begin 
                    ALUOp = 4'b1001;
                    shamtSel = 1'b1;
                  end

              `SLLV: ALUOp = 4'b1000;

              `SRLV: ALUOp = 4'b1001;
                     
              default: ALUOp = 4'b0000;       
             endcase
          end   
        2'b00:
              ALUOp  = 4'b0010; // add
        2'b01:
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule