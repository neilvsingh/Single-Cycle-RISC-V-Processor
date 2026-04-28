`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2026 01:41:04 PM
// Design Name: 
// Module Name: instruction_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

        
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2026 01:41:04 PM
// Design Name: 
// Module Name: instruction_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decoder(
    input  logic signed [6:0] immediate,
    input  logic signed [5:0] nzimm,
    input  logic signed [8:0] offset,
    input  logic [3:0] opcode,

    output logic RegWrite, RegDst, ALUSrc1, ALUSrc2, MemWrite, MemToReg, RegSrc,
    output logic signed [15:0] instr_i,
    output logic [3:0] ALUOp,
    logic [15:0] imm_ext,
    logic [15:0] nzimm_ext,
    logic [15:0] offset_ext
);
   
    assign imm_ext    = {{9{immediate[6]}}, immediate};
    assign nzimm_ext  = {{10{nzimm[5]}}, nzimm};
    assign offset_ext = {{7{offset[8]}}, offset};
    

    always_comb begin

    // default values
    RegWrite = 0;
    RegDst   = 0;
    ALUSrc1  = 0;
    ALUSrc2  = 0;
    MemWrite = 0;
    MemToReg = 0;
    RegSrc   = 0;
    ALUOp    = 4'b0000;
    instr_i = 16'b0;

        case(opcode)
        4'b0000: begin // LW
            RegWrite = 1;
            RegDst   = 1;
            ALUSrc2  = 1;
            MemToReg = 1;
            instr_i = imm_ext;
            RegSrc = 0;
            ALUOp    = 4'b0000;
        end

        4'b0001: begin // SW
            RegWrite = 0;
            ALUSrc2  = 1;
            RegDst   = 0;
            ALUOp    = 4'b0000;
            MemWrite = 1;
            RegSrc = 0;
            instr_i  = imm_ext;
        end

        4'b0010: begin // ADD
            RegWrite = 1;
            MemToReg = 0;
            ALUSrc1 = 0;
            ALUSrc2  = 0;
            RegDst   = 1;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
            ALUOp    = 4'b0000; // use ADD for address calculation
        end

        4'b0011: begin // ADDI
            MemWrite = 0;
            RegWrite = 1;
            RegDst   = 1;
            ALUOp    = 4'b0000; // use ADD for address calculation
            instr_i  = nzimm_ext;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b0100: begin // AND
            RegWrite = 1;
            RegDst   = 1;
            ALUOp    = 4'b0001;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegSrc = 1;
        end

        4'b0101: begin // ANDI
            RegWrite = 1;
            RegDst   = 1;
            ALUSrc2  = 1;
            ALUOp    = 4'b0001;
            instr_i  = imm_ext;
            ALUSrc1 = 0;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b0110: begin // OR
            RegWrite = 1;
            RegDst   = 1;
            ALUOp    = 4'b0010;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b0111: begin // XOR
            RegWrite = 1;
            RegDst   = 1;
            ALUOp    = 4'b1000;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b1000: begin // SRAI
            RegWrite = 1;
            RegDst   = 1;
            ALUSrc2  = 1;
            ALUOp    = 4'b0100;
            instr_i  = nzimm_ext;
            ALUSrc1 = 0;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b1001: begin // SLLI
            RegWrite = 1;
            RegDst   = 1;
            ALUSrc2  = 1;
            ALUOp    = 4'b0101;
            instr_i  = nzimm_ext;
            ALUSrc1 = 0;
            MemWrite = 0;
            MemToReg = 0;
            RegSrc = 1;
        end

        4'b1010: begin // BEQZ
            instr_i  = offset_ext;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            MemWrite = 0;
            RegSrc = 0;
            ALUOp = 4'b0110;
        end

        4'b1011: begin // BNEZ
            ALUOp    = 4'b0111; // subtract to check non-zero
            instr_i  = offset_ext;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            MemWrite = 0;
            RegSrc = 0;
        end

        default: begin
            // keep defaults
        end
        
    endcase

end
 
endmodule