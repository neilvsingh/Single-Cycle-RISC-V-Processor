`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2022 09:58:38 AM
// Design Name: 
// Module Name: alu_datamem_top
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


module alu_instrmem_top(input clk,	// clock for vio and regfile
        input top_pb_clk,
        input reset,
		output logic ovf_ctrl,
		output logic take_branch,
		output [3:0] disp_en,		// 7-Segment display enable
		output [6:0] seg7_output    // LD3
    );
    
    logic [7:0] pc;
    logic [15:0] alu_input1, alu_input2,alu_input2_instr_src;
    logic [15:0] alu_output;
    logic [3:0] ALUOp;
    logic RegWrite;
    logic alu_ovf_flag, alu_take_branch;
    

    logic [2:0] regfile_ReadAddress1;	//source register1 address
    logic [2:0] regfile_ReadAddress2;	//source register2 address
    logic [2:0] regfile_WriteAddress;	//destination register address
    logic [15:0] regfile_WriteData;		//result data
    logic [15:0] regfile_ReadData1;		//source register1 data
    logic [15:0] regfile_ReadData2;		//source register2 data
    logic ALUSrc1, ALUSrc2;
    logic [15:0] DataMemOut;
    logic [15:0] zero_register = 0;
    logic MemWrite;
    
    logic Regdst,Regsrc,instr_i;
    logic pb_clk_debounced;
    
    logic [2:0] rs1,rs2,rd;
    logic [6:0] immediate;
    logic [8:0] offset;
    logic [3:0] opcode;
    logic [5:0] nzimm;
    logic [15:0] instruction;
	assign ovf_ctrl = alu_ovf_flag;
	assign take_branch = alu_take_branch;
	
	//initial debounce
	debounce d1(.clk_in(clk),.rst_in(right_pb_rst_general),.sig_in(top_pb_clk),.sig_debounced_out(pb_clk_debounced));
	 //instruction_memory
    instr_mem inst_mem(.a(pc),.spo(instruction));
	//instantiate program counter
	program_counter prog_count(.clk(pb_clk_debounced),.reset(reset),.pc(pc),.take_branch(alu_take_branch),.offset(offset));
	// mapper instantiation
	mapper m(.instruction(instruction), .rs1(rs1),.rs2(rs2),.rd(rd),.immediate(immediate),.nzimm(nzimm),.offset(offset),.opcode(opcode));
	//instantiate instruction decoder
	instruction_decoder inst (.nzimm(nzimm),
    .opcode(opcode),.immediate(immediate),.offset(offset),.RegWrite(RegWrite),.RegDst(Regdst),
    .ALUSrc1(ALUSrc1),.ALUSrc2(ALUSrc2),.MemWrite(MemWrite),.MemToReg(MemToReg),.RegSrc(Regsrc),
    .instr_i(alu_input2_instr_src),.ALUOp(ALUOp));
    // Instantiate RegFile module here
    reg_file reg1(.rst(reset),.clk(pb_clk_debounced),.wr_en(RegWrite),.rd0_addr(regfile_ReadAddress1),
    .rd1_addr(regfile_ReadAddress2),.wr_addr(regfile_WriteAddress),
    .wr_data(regfile_WriteData),.rd0_data(regfile_ReadData1),.rd1_data(regfile_ReadData2)
    );
    //Instantiate muxes here
    mux2to1_16bit mux1(.in0(regfile_ReadData1),.in1(zero_register),.sel(ALUSrc1),.out(alu_input1));
    mux2to1_16bit mux2(.in0(regfile_ReadData2),.in1(alu_input2_instr_src),.sel(ALUSrc2),.out(alu_input2));

   //Instantiate the sixteenbit_alu module here	
    alu sixteenbit_alu(
        .s(ALUOp),
        .a(alu_input1),
        .b(alu_input2),
        .f(alu_output),
        .ovf(alu_ovf_flag),
        .take_branch(alu_take_branch)
        );
   
    //data memory    
    data_mem data(.clk(pb_clk_debounced),
                  .we(MemWrite),
                  .a(alu_output),
                  .d(regfile_ReadData2),
                  .spo(DataMemOut));
                  
    mux2to1_16bit mux3(.in0(alu_output),.in1(DataMemOut),.sel(MemToReg),.out(regfile_WriteData));
    mux2to1_16bit mux4(.in0(rs1),.in1(rd),.sel(Regsrc),.out(regfile_ReadAddress1));
    mux2to1_16bit mux5(.in0(rs2),.in1(rd),.sel(Regdst),.out(regfile_WriteAddress));

    assign regfile_ReadAddress2 = rs2;
    Adaptor_display display(
		.clk(clk), 					// system clock
		.input_value(alu_output),	// 16-bit input [15:0] value to display
		.disp_en(disp_en),			// output [3:0] 7 segment display enable
		.seg7_output(seg7_output)	// output [6:0] 7 segment signals
	);

    //Instantiate the VIO core here
    //Find the instantiate template from Sources Pane, IP sources -> Instantiation Template -> vio_0.veo (double click to open the file)        
    vio_0 vio (
          .clk(clk),                // input wire clk
          .probe_in0(regfile_WriteData),    // input wire [15 : 0] probe_in0
          .probe_in1(regfile_ReadData1),    // input wire [0 : 0] probe_in1
          .probe_in2(regfile_ReadData2),    // input wire [0 : 0] probe_in2
          .probe_in3(alu_input1),
          .probe_in4(alu_input2),
          .probe_in5(alu_take_branch),
          .probe_in6(alu_ovf_flag),
          .probe_in7(alu_output),
          .probe_in8(DataMemOut),
          .probe_in9(alu_input2_instr_src),
          .probe_in10(rs1),  // output wire [15 : 0] probe_out0
          .probe_in11(rs2),  // output wire [15 : 0] probe_out1
          .probe_in12(rd),
          .probe_in13(immediate),
          .probe_in14(nzimm),
          .probe_in15(offset),
          .probe_in16(opcode),
          .probe_in17(instruction),
          .probe_in18(pc)
        );
endmodule
