module ALU #(parameter n=32) (out, zero, inA, inB, op);
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

module RegFile #(parameter n=32)(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
input clock, reset, wen;
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

    else if (wen) begin
        registers[wa] = wd;
    end
end
endmodule