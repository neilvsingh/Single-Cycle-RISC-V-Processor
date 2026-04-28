`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2026 05:27:34 PM
// Design Name: 
// Module Name: program_counter
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


module program_counter(
    input logic clk,
    input logic reset,
    input logic take_branch, 
    input logic signed [8:0] offset,
    output logic signed [8:0] pc
);



assign offset_ext = {{7{offset[8]}}, offset};

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 9'b000000000;      // reset PC to 0
    else if (take_branch)
        pc <= pc + offset;
    else
        pc <= pc + 1;           // increment PC each clock press
end

endmodule