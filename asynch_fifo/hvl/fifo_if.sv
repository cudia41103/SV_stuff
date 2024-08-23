`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2024 06:32:49 PM
// Design Name: 
// Module Name: interface
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

interface fifo_if;
    logic clk1;
    logic clk2;
    logic rst1;
    logic rst2;
    logic wr;
    logic rd;
    logic [7:0] din;
    logic [7:0] dout;
    logic empty;
    logic full;
endinterface
