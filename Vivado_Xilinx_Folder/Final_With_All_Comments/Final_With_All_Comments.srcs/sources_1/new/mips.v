`timescale 1ns / 1ps

module mips #(parameter WIDTH = 8, REGBITS = 3) ( //Single core design
    input clk,
    input reset,
    input [8-1 : 0] memdata,
    output memread,
    output memwrite,
    output [11 : 0] adr,
    output [8-1 : 0] writedata,
    output bus_req,
    input bus_grant
    );
    assign bus_req = memread | memwrite;
    
    wire [31:0] instr;
    wire zero, alusrca, memtoreg, iord, pcen, regwrite, regdst, mem_offset_en;
    wire [1:0] aluop, pcsource, alusrcb;
    wire [3:0] alucont;
    wire [3:0] irwrite;
    wire aluout_hold;
    
    controller cont(
        .clk(clk),
        .reset(reset),
        .op(instr[31:26]),
        .zero(zero),
        .memread(memread),
        .memwrite(memwrite),
        .alusrca(alusrca),
        .alusrcb(alusrcb),
        .memtoreg(memtoreg),
        .iord(iord),
        .pcen(pcen),
        .regwrite(regwrite),
        .regdst(regdst),
        .pcsource(pcsource),
        .aluop(aluop),
        .irwrite(irwrite),
        .bus_grant(bus_grant),
        .aluout_hold(aluout_hold),
        .mem_offset_en(mem_offset_en)
    );
    alucontrol ac(
        .aluop(aluop),
        .funct(instr[5:0]),
        .alucont(alucont)
    );
    datapath #(.WIDTH(WIDTH), .REGBITS(REGBITS)) dp(
        .clk(clk),
        .reset(reset),
        .memtoreg(memtoreg),
        .iord(iord),
        .pcen(pcen),
        .regwrite(regwrite),
        .regdst(regdst),
        .pcsource(pcsource),
        .alusrca(alusrca),
        .alusrcb(alusrcb),
        .irwrite(irwrite),
        .memdata(memdata),
        .zero(zero),
        .alucont(alucont),
        .instr(instr),
        .writedata(writedata),
        .adr(adr),
        .aluout_hold(aluout_hold),
        .mem_offset_en(mem_offset_en)
    );
endmodule
