`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2024 11:51:50 AM
// Design Name: 
// Module Name: gray_binary
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


module full #(parameter WIDTH = 3)(
        input logic [WIDTH:0] grptr_next,
        input logic [WIDTH:0] wptr,
        output logic wfull
    );

    genvar i;
    logic [WIDTH:0] rptr_next;
    generate 
        for(i = 0; i < (WIDTH + 1); i++) begin
            assign rptr_next[i] = ^(grptr_next >>i);
        end
    endgenerate

    assign wfull = (rptr_next[WIDTH] == !(wptr[WIDTH])) && (rptr_next[(WIDTH-1):0] == wptr[(WIDTH-1):0]);
endmodule
