/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC;
 reg [31:0] IFID_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_shamtExtend;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd;
 reg        ren, wen;                         
 reg        IDEX_RegDst, IDEX_ALUSrc;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite;
 reg        IDEX_MemToReg, IDEX_RegWrite;               
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd;
 reg [31:0] EXMEM_ALUOut;
 reg        EXMEM_Zero;
 reg [31:0] EXMEM_MemWriteData;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd;
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;
 reg [31:0] DMemIn;
 reg [31:0] ALUInA , ALUInB, RegBVal;   
 reg [5:0] IDEX_FUNC, IDEX_OPCODE;          
 wire [31:0] instr, ALUOut, rdA, rdB, shamtExtend, signExtend, DMemOut, wRegData, PCIncr ;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch, PC_Write, IFID_Write, nop_sel;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr, shamt;
 wire [3:0] ALUOp;
 wire       shamtSel;
 wire [1:0] ALUcntrl;
 wire [1:0] ForwardA, ForwardB;
 wire       ForwardC;
 wire [15:0] imm;
 

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)     
       PC <= -1;     
    else if (PC == -1)
       PC <= 0;
    else if (PC_Write == 1)
       PC <= PC + 4;
  end
 
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)     
      begin
       IFID_PCplus4 <= 32'b0;   
       IFID_instr <= 32'b0;
    end
    else if (IFID_Write == 1)
      begin
       IFID_PCplus4 <= PC + 32'd4;
       IFID_instr <= instr;
    end
  end
 
// TO FILL IN: Instantiate the Instruction Memory here
Memory cpu_IMem (clock, reset, ren, wen, PC/4, 32'bx, instr);


/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign imm = IFID_instr[15:0];
assign shamt = IFID_instr[10:6];
assign signExtend = {{16{imm[15]}}, imm};
assign shamtExtend = {{27{shamt[4]}}, shamt};

// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)
      begin
       IDEX_rdA <= 32'b0;   
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_shamtExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                 
       IDEX_RegWrite <= 1'b0;
       IDEX_FUNC <= 6'b0;
       IDEX_OPCODE <= 6'b0;
    end
    else
      begin
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_signExtend <= signExtend;
       IDEX_shamtExtend <= shamtExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
       IDEX_RegDst <= RegDst;
       IDEX_ALUcntrl <= ALUcntrl;
       IDEX_ALUSrc <= ALUSrc;
       IDEX_Branch <= Branch;
       IDEX_MemRead <= MemRead;
       IDEX_MemWrite <= MemWrite;
       IDEX_MemToReg <= MemToReg;                 
       IDEX_RegWrite <= RegWrite;
       IDEX_FUNC <= func;
       IDEX_OPCODE <= opcode;
    end
    if (nop_sel == 0)
      begin
       IDEX_RegDst <= 0;
       IDEX_ALUcntrl <= 0;
       IDEX_ALUSrc <= 0;
       IDEX_Branch <= 0;
       IDEX_MemRead <= 0;
       IDEX_MemWrite <= 0;
       IDEX_MemToReg <= 0;                 
       IDEX_RegWrite <= 0;
      end
  end

// Main Control Unit
control_main main_control(
    RegDst,
    Branch,
    MemRead,
    MemWrite,
    MemToReg,
    ALUSrc,
    RegWrite,
    ALUcntrl,
    opcode
);
                 
// TO FILL IN: Instantiation of Control Unit that generates stalls
  hazard_detection_unit hazard_detection_unit(
    PC_Write,
    IFID_Write,
    nop_sel,
    IDEX_MemRead,
    IDEX_instr_rt,
    IFID_instr
  );


                           
/***************** Execution Unit (EX)  ****************/

always @(IDEX_rdA or IDEX_rdB or wRegData or EXMEM_ALUOut or ForwardA or ForwardB)
  begin
    case (ForwardA)
      0: ALUInA = IDEX_rdA;
      1: ALUInA = wRegData;
      2: ALUInA = EXMEM_ALUOut;
    endcase

    case (ForwardB)
      0: DMemIn = IDEX_rdB;
      1: DMemIn = wRegData;
      2: DMemIn = EXMEM_ALUOut;
    endcase
  
  RegBVal = (IDEX_ALUSrc == 1'b0) ? DMemIn : IDEX_signExtend;
  
  if (shamtSel)
    begin 
      ALUInB = IDEX_shamtExtend;
      ALUInA = RegBVal;
    end
  else if (IDEX_OPCODE == 0 && (IDEX_FUNC == 6'b000100 || IDEX_FUNC == 6'b000110)) //SLLV or SRLV
    begin 
      ALUInB = ALUInA;
      ALUInA = RegBVal;
    end
  else 
    begin
      ALUInB = RegBVal;
    end
  end
                 
//  ALU
ALU  #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)     
      begin
       EXMEM_ALUOut <= 32'b0;   
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                 
       EXMEM_RegWrite <= 1'b0;
      end
    else
      begin
       EXMEM_ALUOut <= ALUOut;   
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= DMemIn;
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;                 
       EXMEM_RegWrite <= IDEX_RegWrite;
      end
  end
 
  // ALU control
  control_alu control_alu(ALUOp, shamtSel, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
 
   // TO FILL IN: Instantiation of control logic for Forwarding goes here

  forwarding_unit forwarding_unit(
    ForwardA,
    ForwardB,
    ForwardC,
    EXMEM_RegWrite,
    EXMEM_RegWriteAddr,
    MEMWB_RegWrite,
    MEMWB_RegWriteAddr,
    IDEX_instr_rs,
    IDEX_instr_rt
  );

/***************** Memory Unit (MEM)  ****************/ 

// Data memory 1KB
// Instantiate the Data Memory here
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);


// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;   
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                 
       MEMWB_RegWrite <= 1'b0;
      end
    else
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;                 
       MEMWB_RegWrite <= EXMEM_RegWrite;
      end
  end


/***************** WriteBack Unit (WB)  ****************/ 
// TO FILL IN: Write Back logic
assign wRegData = (MEMWB_MemToReg == 1'b0) ? MEMWB_ALUOut : MEMWB_DMemOut;


endmodule