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

// Cache Controller for L1 direct mapped cache with write through, but implemented using states.

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
    case(currentState)                  // State on cold start, or when writing to main mem
        CACHE_IDLE: begin           
                        if(writeToMem == 1) begin       // write to main mem when idle               
                            M1.mem[{tagval,indexval}] = dataBuffer;  
                            writeToMem = 0;
                        end  
                        nextState = CACHE_COMPARE;
                    end             
        CACHE_COMPARE: begin            // tag matching and valid checking
                         indexval = addr % L1_BLOCK_COUNT;
                         tagval = addr[MM_BLOCK_COUNT_BITS-1:L1_INDEX_BITS];
                         dataBuffer = wdata;            // store write data for future states
                         
                         if(L1.valid[indexval] == 1 && tagval == L1.tag[indexval]) begin  
                            case(rw)
                                READ: nextState = CACHE_READ;
                                WRITE: nextState = CACHE_WRITE;
                            endcase
                         end
                         else begin
                             nextState = CACHE_MISS;
                         end 
                       end                       
        CACHE_READ: begin               // read from cache
                        rdata = L1.mem[indexval];
                        nextState = CACHE_COMPARE;
                    end  
        CACHE_WRITE: begin              // write to cache & to mem (in idle state)
                        L1.mem[indexval] = dataBuffer;
                        L1.tag[indexval] = tagval;
                        L1.valid[indexval] = 1;
                        writeToMem = 1;
                        nextState = CACHE_IDLE;
                     end
        CACHE_MISS: begin               // on cache miss, always read a block from mem
                      rdata = 32'bx;        
                      L1.mem[indexval] = M1.mem[{tagval,indexval}];
                      L1.tag[indexval] = tagval;
                      L1.valid[indexval] = 1;
                      if(rw == WRITE) nextState = CACHE_WRITE; 
                      else nextState = CACHE_READ;      
                    end                  
    endcase
end              
                                      
endmodule
