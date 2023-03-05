`timescale 1ns / 1ps

module mmu(
    input clk,
    input reset,
    input read,
    input write,
    input [5:0] adr, //We never actually use the address, so any address in the range will have the same effect
    output reg [7:0] read_data,
    input [7:0] write_data
    );
    
    reg [3:0] avail;
    
    always @(*) begin
        if(avail[0]) begin
            read_data <= 8'h4; //The read data will always be the next open page
        end else if(avail[1]) begin
            read_data <= 8'h5;
        end else if(avail[2]) begin
            read_data <= 8'h6;
        end else if(avail[3]) begin
            read_data <= 8'h7;
        end else begin
            read_data <= 8'h0;
        end
    end
                
    always @(posedge clk) begin
        if(reset) avail<= 4'b1111;
        else begin
            if(read) begin
                if(avail[0]) begin
                    avail[0] <= 0; //mark the page as unavailable after it is returned
                end else if(avail[1]) begin
                    avail[1] <= 0;
                end else if(avail[2]) begin
                    avail[2] <= 0;
                end else if(avail[3]) begin
                    avail[3] <= 0;
                end
            end
            if(write) begin
                avail[write_data] <= 1; //Pages can be freed by writing
            end
        end
    end
    
endmodule
