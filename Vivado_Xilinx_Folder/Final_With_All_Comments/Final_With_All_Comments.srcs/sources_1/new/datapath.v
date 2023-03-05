`timescale 1ns / 1ps

module datapath #(parameter WIDTH = 8, REGBITS = 3) (
    input clk,
    input reset,
    input [8-1 : 0] memdata,
    input alusrca,
    input memtoreg,
    input iord,
    input pcen,
    input regwrite,
    input regdst,
    input [1:0] pcsource,
    input [1:0] alusrcb,
    input [3:0] irwrite,
    input [3:0] alucont,
    input aluout_hold,
    output zero,
    output [31:0] instr,
    output [11 : 0] adr,
    output [8-1 : 0] writedata,
    
    input mem_offset_en
    );
    
    localparam CONST_ZERO = {WIDTH{1'b0}};
    localparam CONST_ONE = CONST_ZERO + 1'b1;
    
    assign writedata = writedata_int[7:0];
    wire [11:0] adr_int;
    
    wire [REGBITS-1 : 0] ra1, ra2, wa;
    wire [WIDTH-1 : 0] rd1, rd2, wd, a, src1, src2, aluresult, aluout, constx4, writedata_int;
    wire [11:0] pc, nextpc;
    wire [7:0] md;
    
    wire [3:0] mem_offset;
    
    assign constx4 = {instr[WIDTH-3:0], 2'b00};
    assign ra1 = instr[REGBITS + 20:21];
    assign ra2 = instr[REGBITS + 15:16];
    mux2 #(REGBITS) regmux(
        .d0(instr[REGBITS + 15:16]),
        .d1(instr[REGBITS + 10:11]),
        .s(regdst),
        .y(wa)
    );
    flopenr #(8) ir0(
        .clk(clk),
        .reset(reset),
        .en(irwrite[0]),
        .d(memdata[7:0]),
        .q(instr[7:0])
    );
    flopenr #(8) ir1(
        .clk(clk),
        .reset(reset),
        .en(irwrite[1]),
        .d(memdata[7:0]),
        .q(instr[15:8])
    );
    flopenr #(8) ir2(
        .clk(clk),
        .reset(reset),
        .en(irwrite[2]),
        .d(memdata[7:0]),
        .q(instr[23:16])
    );
    flopenr #(8) ir3(
        .clk(clk),
        .reset(reset),
        .en(irwrite[3]),
        .d(memdata[7:0]),
        .q(instr[31:24])
    );
    flopenr #(12) pcreg(
        .clk(clk),
        .reset(reset),
        .en(pcen),
        .d(nextpc),
        .q(pc)
    );
    flopenr #(4) mem_offset_reg( //Special register for memory offset
        .clk(clk),
        .reset(reset),
        .en(mem_offset_en), //new controller output signal from WRSPEC state
        .d(a),
        .q(mem_offset)
    );
    flop #(8) mdr(
        .clk(clk),
        .d(memdata),
        .q(md)
    );
    flop #(WIDTH) areg(
        .clk(clk),
        .d(rd1),
        .q(a)
    );
    flop #(WIDTH) wrd(
        .clk(clk),
        .d(rd2),
        .q(writedata_int)
    );
    flopen #(WIDTH) res(
        .clk(clk),
        .en(~aluout_hold), //Had to change this from flop to flopen so that this signal could be added because we need to be able to stall while waiting to read or write RAM
        .d(aluresult),
        .q(aluout)
    );
    mux2 #(WIDTH) adrmux(
        .d0(pc),
        .d1(aluout),
        .s(iord),
        .y(adr_int)
    );
    mux2 #(WIDTH) src1mux(
        .d0({4'b0000, pc}),
        .d1(a),
        .s(alusrca),
        .y(src1)
    );
    mux4 #(WIDTH) src2mux(
        .d0(writedata_int),
        .d1(CONST_ONE),
        .d2(instr[WIDTH-1:0]),
        .d3(constx4),
        .s(alusrcb),
        .y(src2)
    );
    mux4 #(WIDTH) pcmux(
        .d0(aluresult),
        .d1(aluout),
        .d2(constx4),
        .d3(CONST_ZERO),
        .s(pcsource),
        .y(nextpc)
    );
    mux2 #(WIDTH) wdmux(
        .d0(aluout),
        .d1({8'b0, md}),
        .s(memtoreg),
        .y(wd)
    );
    regfile #(WIDTH,REGBITS) rf(
        .clk(clk),
        .regwrite(regwrite),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .rd1(rd1),
        .rd2(rd2),
        .wd(wd)
    );
    alu #(WIDTH) alunit(
        .a(src1),
        .b(src2),
        .alucont(alucont),
        .result(aluresult)
    );
    zerodetect #(WIDTH) zd(
        .a(aluresult),
        .y(zero)
    );
    
    assign adr = adr_int[11] ? {mem_offset, adr_int[7:0]} : {4'b0000, adr_int[7:0]}; // Virtual memory remapping if the address is 0x800 or greater, otherwise access the lowest 256 bytes where the physical devices are
endmodule
