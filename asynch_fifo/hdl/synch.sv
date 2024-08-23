`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2024 02:18:12 PM
// Design Name: 
// Module Name: synch
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


module synch #(parameter WIDTH = 4)(
    input   logic clk,
    input   logic rst,
    input   logic [WIDTH-1:0] data_in, 
    output  logic [WIDTH-1:0] data_out
    );
    logic [WIDTH-1:0] temp;

    always_ff @(posedge clk) begin
        if(rst) begin
            temp<= 0;
            data_out<= 0;
        end else begin
            temp <= data_in;
            data_out <= temp;
        end
    end
endmodule
