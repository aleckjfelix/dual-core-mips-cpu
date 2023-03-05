`timescale 1ns / 1ps

module single_core_test(
    );
    reg clk;
    reg reset;
    wire [7:0] memdata, writedata, adr;
    wire memread, memwrite;
    
    mips #(.WIDTH(8), .REGBITS(3)) my_core(
        .clk(clk),
        .reset(reset),
        .memdata(memdata),
        .memread(memread),
        .memwrite(memwrite),
        .adr(adr),
        .writedata(writedata),
        .bus_grant(1)
    );
    
    exmemory #(.WIDTH(8), .ADDR_WIDTH(8)) my_mem(
        .clk(clk),
        .memdata(memdata),
        .memwrite(memwrite),
        .adr(adr),
        .writedata(writedata)
    );
    
    initial begin
        clk <= 0;
        reset <= 1;
        #1;
        clk <= 1;
        #1;
        clk <= 0;
        #1;
        clk <= 1;
        #1;
        clk <= 0;
        reset <= 0;
        #1;
        for(integer i=0; i<200; i=i+1) begin
            clk <= 1;
            #1;
            clk <= 0;
            #1;
        end
    end
endmodule
