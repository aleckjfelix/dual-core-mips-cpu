`timescale 1ns / 1ps

module io_regs(
    input clk,
    input reset,
    input [5:0] adr,
    input read,
    input write,
    output [7:0] read_data,
    input [7:0] write_data,
    
    input [7:0] switches,
    output reg [15:0] seven_seg,
    output reg [7:0] leds
    );
    assign read_data = switches; //no matter what address you read from, you always get the switches
    always @(posedge clk) begin
        if(reset) begin
            seven_seg <= 0; //be sure to reset the output to 0
        end else if(write) begin
            case(adr[1:0]) //check the address and use that to determine which output to write
                2'b00: seven_seg[7:0] <= write_data;
                2'b01: seven_seg[15:8] <= write_data;
                2'b10: leds <= write_data;
                2'b11: leds <= write_data;
            endcase
        end
    end
endmodule
