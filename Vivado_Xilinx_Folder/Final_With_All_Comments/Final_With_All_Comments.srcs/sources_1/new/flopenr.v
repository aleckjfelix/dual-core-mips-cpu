`timescale 1ns / 1ps

module flopenr #(parameter WIDTH = 8) (
    input clk,
    input en,
    input reset,
    input [WIDTH-1 : 0] d,
    output reg [WIDTH-1 : 0] q
    );
    always @(posedge clk) begin
        if(reset) q<= 0;
        else if(en) q <= d;
    end
endmodule
