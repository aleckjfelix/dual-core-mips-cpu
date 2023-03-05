`timescale 1ns / 1ps

module alu #(parameter WIDTH = 8) (
    input [WIDTH-1 : 0] a,
    input [WIDTH-1 : 0] b,
    input [3:0] alucont,
    output reg [WIDTH-1 : 0] result
    );
    wire [WIDTH-1 : 0] b2, sum, slt;
    assign b2 = alucont[3] ? ~b : b;
    assign sum = a + b2 + alucont[3];
    assign slt = sum[WIDTH-1];
    
    always @(*) begin
        case(alucont[2:0])
            3'b000: result <= a&b;
            3'b001: result <= a|b;
            3'b010: result <= sum;
            3'b011: result <= slt;
            3'b100: result <= a << 8; //new arithmetic option to allow for accessing high bits in registers, needed to store more than 1 byte numbers to the output registers
            3'b101: result <= a >> 8;
            default: result <= 0;
        endcase
    end
endmodule
