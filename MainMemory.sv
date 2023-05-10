`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2023 10:26:06
// Design Name: 
// Module Name: MainMemory
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


module MainMemory(reset);

input logic reset;

parameter MM_BLOCK_COUNT = 1024;   // 2^10 blocks => 10 bit address
parameter DATA_WIDTH = 32;      // 32 bit data

logic [DATA_WIDTH-1:0] mem [MM_BLOCK_COUNT];

always @ (negedge reset)
begin
    if(~reset) begin
    for( int i = 0; i < MM_BLOCK_COUNT; i++)
        mem[i] = i;
    end
end

endmodule
