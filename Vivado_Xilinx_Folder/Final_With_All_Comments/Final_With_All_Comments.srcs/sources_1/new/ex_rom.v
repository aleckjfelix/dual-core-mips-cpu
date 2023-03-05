`timescale 1ns / 1ps

module ex_rom(
    input clk,
    input [5:0] adr,
    input read,
    output reg [7:0] data
    );
    
    reg [31:0] ROM [15:0];
    wire [31:0] word;
    assign word = ROM[adr >> 2];
    
    always @(*) begin //This is just the RAM but without the ability to write
        case(adr[1:0])
            2'b00: data <= word[7:0];
            2'b01: data <= word[15:8];
            2'b10: data <= word[23:16];
            2'b11: data <= word[31:24];
        endcase
    end
    
    initial begin
        //ROM[0] <= 32'b001000_00000_00001_0000000000000100;
        ROM[0] <= 32'b100000_00000_00001_0000000010000000;
        ROM[1] <= 32'b000001_00001_00000_00000_00000000000;
        ROM[2] <= 32'b000010_00000_00000_00000010_00000000;
    end
endmodule
