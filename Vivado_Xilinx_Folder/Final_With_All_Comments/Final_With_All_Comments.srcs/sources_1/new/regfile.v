`timescale 1ns / 1ps

module regfile #(parameter WIDTH = 8, REGBITS = 3) (
    input clk,
    input regwrite,
    input [REGBITS-1 : 0] ra1,
    input [REGBITS-1 : 0] ra2,
    input [REGBITS-1 : 0] wa,
    input [WIDTH-1 : 0] wd,
    output [WIDTH-1 : 0] rd1,
    output [WIDTH-1 : 0] rd2
    );
    reg [WIDTH-1:1] RAM [(1<<REGBITS)-1:0]; // There is no register 0
    always @(posedge clk) begin
        if (regwrite && wa) RAM[wa] <= wd; // Don't try to write to register 0
    end
    assign rd1 = ra1 ? RAM[ra1] : 0;
    assign rd2 = ra2 ? RAM[ra2] : 0;
    
endmodule
