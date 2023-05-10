`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2023 11:27:08
// Design Name: 
// Module Name: CacheController_tb
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


module CacheController_tb();

logic clk,reset,rw;
logic [9:0] addr;
logic [31:0] rdata,wdata;

Cache_Controller C1(clk,reset,addr,rw,rdata,wdata);

initial begin
reset = 1'b1;
#1 reset = 1'b0;
end

initial begin
clk = 1'b0;
repeat(50)
#5 clk = ~clk;
end

initial begin
rw = 0; addr = 10'd0;                           // read miss
#25 rw = 0; addr = 10'd1;                       // read miss
#25 rw = 1; wdata = 10'd69; addr = 10'd128;     // write miss 
#25 rw = 1; wdata = 10'd420; addr = 10'd567;    // write miss
#25 rw = 1; wdata = 10'd333; addr = 10'd128;    // write hit
#25 rw = 1; wdata = 10'd666; addr = 10'd128;    // write hit
#25 rw = 1; wdata = 10'd666; addr = 10'd0;      // write miss -> write back
end

endmodule
