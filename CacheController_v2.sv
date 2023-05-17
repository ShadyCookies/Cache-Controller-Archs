`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2023 17:50:12
// Design Name: 
// Module Name: CacheController_v2
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


module CacheController_v2(clk,reset,addr,rw,rdata,wdata);   

// Cache Controller for L1 direct mapped cache, with write-back policy.

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

logic writeToMem;
logic [DATA_WIDTH-1:0] dataBuffer;
logic [MM_BLOCK_COUNT_BITS-1:0] addrBuffer;
logic [L1_TAG_BITS-1:0] tagval;
logic [L1_INDEX_BITS-1:0] indexval;

typedef enum logic [2:0] {CACHE_IDLE, CACHE_COMPARE, CACHE_READ, CACHE_WRITE, CACHE_MISS} CACHE_STATE;
enum logic {READ,WRITE} INSTR;

CACHE_STATE currentState,nextState;

always @ (posedge clk, posedge reset)
    if(reset)
        currentState <= CACHE_IDLE;
    else
        currentState <= nextState;
        
always @ (currentState)
begin   
    if(writeToMem == 1) begin   // data eviction check
        M1.mem[addrBuffer] = dataBuffer;  // write back evicted data
        writeToMem = 0;
    end
    case(currentState) 
        CACHE_IDLE: begin         
                        nextState = CACHE_COMPARE;
                    end             
        CACHE_COMPARE: begin            // tag matching and valid checking
        
                         indexval = addr % L1_BLOCK_COUNT;
                         tagval = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS];
                         
                         if(L1.valid[indexval] == 1 && tagval == L1.tag[indexval]) begin  // cache hit condition
                            case(rw)
                                READ: begin             // Read is done in 1 cc
                                        rdata = L1.mem[indexval];
                                        nextState = CACHE_IDLE;
                                      end  
                                WRITE: begin             // write is done in 1 cc
                                        L1.mem[indexval] = wdata;
                                        L1.valid[indexval] = 1;
                                        L1.dirty[indexval] = 1;
                                        nextState = CACHE_IDLE;
                                       end
                            endcase
                         end
                         else 
                             nextState = CACHE_MISS;    
                       end                       
        CACHE_READ: begin               // read from cache
                        rdata = L1.mem[indexval];
                        nextState = CACHE_COMPARE;
                    end  
        CACHE_WRITE: begin              // write to cache
                        L1.mem[indexval] = wdata;
                        L1.tag[indexval] = tagval;
                        L1.valid[indexval] = 1;
                        L1.dirty[indexval] = 1;
                        nextState = CACHE_COMPARE;
                     end
        CACHE_MISS: begin               // on cache miss, always read a block from mem     
                      dataBuffer =  L1.mem[indexval];  // data to be written back
                      addrBuffer = {L1.tag[indexval],indexval}; // main mem addr to write back to
                      L1.mem[indexval] = M1.mem[{tagval,indexval}];
                      L1.tag[indexval] = tagval;
                      L1.valid[indexval] = 1;
                      if(L1.dirty[indexval] == 1) writeToMem = 1;   // if dirty, then writeback
                      if(rw == WRITE) nextState = CACHE_WRITE; 
                      else nextState = CACHE_READ;      
                    end                  
    endcase
end              
                                      
endmodule
