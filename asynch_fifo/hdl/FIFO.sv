`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2024 09:49:12 PM
// Design Name: 
// Module Name: FIFO
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

module FIFO #(parameter WIDTH = 8, PTR_WIDTH = 4)(
    input logic clk1, clk2, rst1, rst2, wr, rd,
    input logic [WIDTH-1:0] din, 
    output logic [WIDTH-1:0] dout,
    output empty, full);
    
    reg [WIDTH-1:0] fifo [8];
    //binary pointers
    logic [PTR_WIDTH-1:0] rptr;
    logic [PTR_WIDTH-1:0] wptr;
    logic [PTR_WIDTH-1:0] rptr_next;
    logic [PTR_WIDTH-1:0] wptr_next;
    //graycode pointers
    logic [PTR_WIDTH-1:0] grptr;
    logic [PTR_WIDTH-1:0] gwptr;
    logic [PTR_WIDTH-1:0] grptr_next;
    logic [PTR_WIDTH-1:0] gwptr_next;
    logic [PTR_WIDTH-1:0] grptr_next_sync;
    logic [PTR_WIDTH-1:0] gwptr_next_sync;


    // logic wfull;
    // logic rempty;

    //fifo memory
    
    always_ff @(posedge clk1) begin//clk1 and rst1 are wr
        if(wr && !full) begin
            fifo[wptr[PTR_WIDTH-1:0]] <= din;
        end
    end
    assign dout = !empty ? fifo[rptr[PTR_WIDTH-1:0]] : 'x;
    // add logic on reciever end to only sample when not empty 
            
            
    //write pointer logic
    assign wptr_next = (wr && !full) ? (wptr + 1'b1) : wptr;
    assign gwptr_next = (wptr_next >> 1) ^ wptr_next;


    always_ff @(posedge clk1) begin
        if(rst1 || rst2) begin
            wptr <= '0;
            gwptr <= '0;
        end else begin
            wptr <= wptr_next;
            gwptr <= gwptr_next;
        end
    end        
    
    synch read_sync(
        .clk(clk2),
        .rst(rst2),
        .data_in(grptr_next),
        .data_out(grptr_next_sync)
    );
    full full_module(
        .grptr_next(grptr_next_sync),
        .wptr(wptr),
        .wfull(full)
    );

    //read pointer logic
    assign rptr_next = (!empty && rd) ? (rptr + 1'b1) : rptr;
    assign grptr_next = (rptr_next >> 1) ^rptr_next;

    always_ff @(posedge clk2) begin
        if (rst2) begin
            rptr <= 0;
            grptr <= 0;
        end else begin
            rptr <= rptr_next;
            grptr <= grptr_next;
        end
    end
    synch write_sync(
        .clk(clk1),
        .rst(rst1),
        .data_in(gwptr_next),
        .data_out(gwptr_next_sync)
    );
    empty empty_module (
        .gwptr_next(gwptr_next_sync),
        .rptr(rptr),
        .rempty(empty)
    );
            
endmodule
