`timescale 1ns / 1ps

module alucontrol(
    input [1:0] aluop,
    input [5:0] funct,
    output reg [3:0] alucont //Had to make alucont wider to accomodate extra arithmetic options
    );
    
    always @(*) begin
        case(aluop)
            2'b00: alucont <= 4'b0010;
            2'b01: alucont <= 4'b1010;
            default: case(funct)
                6'b100000: alucont <= 4'b0010;
                6'b100010: alucont <= 4'b1010;
                6'b100100: alucont <= 4'b0000;
                6'b100101: alucont <= 4'b0001;
                6'b101010: alucont <= 4'b1011;
                6'b110000: alucont <= 4'b0100;
                6'b110001: alucont <= 4'b0101;
                default: alucont <= 4'b1001;
            endcase
        endcase
    end
endmodule
