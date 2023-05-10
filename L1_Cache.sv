`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2023 10:38:36
// Design Name: 
// Module Name: L1_Cache
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


module L1_Cache(reset);

input logic reset;

parameter MM_BLOCK_COUNT = 1024; // 2^10 blocks => 10 bit address
parameter L1_BLOCK_COUNT = 64; // 2^6 - 64 => 6 bit index
parameter TAG_BITS = $clog2(MM_BLOCK_COUNT)- $clog2(L1_BLOCK_COUNT);  // 10 - 6 => 4 bit tag
parameter DATA_WIDTH = 32;  // 32 bit data

logic [DATA_WIDTH-1:0] mem [L1_BLOCK_COUNT];
logic [TAG_BITS-1:0] tag [L1_BLOCK_COUNT];
logic valid [L1_BLOCK_COUNT];
logic dirty [L1_BLOCK_COUNT];

always @ (negedge reset)
begin
    if(~reset) begin
        for( int i = 0; i < L1_BLOCK_COUNT; i++) 
        begin
            mem[i] = 0;
            tag[i] = 0;
            valid[i] = 0;
            dirty[i] = 0;
        end
    end
end

endmodule
