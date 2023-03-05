`timescale 1ns / 1ps

module zerodetect #(parameter WIDTH = 8) (
    input [WIDTH-1 : 0] a,
    output y
    );
    assign y = (a==0);
endmodule
