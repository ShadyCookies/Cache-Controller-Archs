`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2023 10:51:46
// Design Name: 
// Module Name: Cache_Controller
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


module Cache_Controller(clk,reset,addr,rw,rdata,wdata);

// Cache Controller for L1 direct mapped cache with write-back, implemented using some jugaad method. Not recommended to use as a baseline controller.    
    
parameter DATA_WIDTH = 32;
parameter L1_BLOCK_COUNT = 64;
parameter MM_BLOCK_COUNT = 1024;
parameter MM_BLOCK_COUNT_BITS = $clog2(MM_BLOCK_COUNT);
parameter L1_INDEX_BITS = $clog2(L1_BLOCK_COUNT);
parameter L1_TAG_BITS = MM_BLOCK_COUNT_BITS - L1_INDEX_BITS;

input logic clk,reset;
input logic rw;
input logic [MM_BLOCK_COUNT_BITS-1:0] addr;
input logic [DATA_WIDTH-1:0] wdata;
output logic [DATA_WIDTH-1:0] rdata;

MainMemory M1(reset);
L1_Cache L1(reset);

logic [L1_TAG_BITS-1:0] tagval;
logic [L1_INDEX_BITS-1:0] indexval;

logic readUpdateCache,writeUpdateMem;
logic [DATA_WIDTH-1:0] writeBackData;
logic [L1_TAG_BITS-1:0] writeBackTag;

    
always @ (posedge clk)
begin
    if(readUpdateCache == 1) begin  // update cache 1 cc after read miss
        L1.tag[indexval] = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS];
        L1.mem[indexval] = M1.mem[addr];
        L1.valid[indexval] = 1;
    end
    
    if(writeUpdateMem == 1) begin   // update main mem 1 cc later for write back
        M1.mem[{writeBackTag,indexval}] = writeBackData;
    end
    
    indexval = addr % L1_BLOCK_COUNT ;
    tagval = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS] ;
    
    readUpdateCache = 0;    
    writeUpdateMem = 0;
    writeBackData = L1.mem[indexval];
    writeBackTag = L1.tag[indexval];
    
    case (L1.valid[indexval])
        1'b0: begin                  // valid bit = 0  => Compulsory miss      
                if(rw == 0) begin    // read  
                    rdata = 32'bx;
                    readUpdateCache = 1;
                end
                else begin          // write 
                    L1.tag[indexval] = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS];
                    L1.mem[indexval] = wdata;
                    L1.valid[indexval] = 1;
                    L1.dirty[indexval] = 1;
                end
              end               
        1'b1: begin                 // valid bit = 1  
                if(rw == 0) begin   // read
                    if(tagval == L1.tag[indexval]) begin    // read hit
                        rdata = L1.mem[indexval];
                    end
                    else begin      // read miss          
                        rdata = 32'bx;
                        readUpdateCache = 1;
                        writeUpdateMem = 1;
                    end
                end
                else begin          // write
                    rdata = 32'bx;
                    if(tagval == L1.tag[indexval]) begin    // write hit
                        L1.mem[indexval] = wdata;
                        L1.dirty[indexval] = 1;                        
                    end
                    else begin      // write miss
                        L1.tag[indexval] = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS];
                        L1.mem[indexval] = wdata;
                        L1.dirty[indexval] = 1; 
                        writeUpdateMem = 1;
                    end
                end
              end
    endcase
end

endmodule
