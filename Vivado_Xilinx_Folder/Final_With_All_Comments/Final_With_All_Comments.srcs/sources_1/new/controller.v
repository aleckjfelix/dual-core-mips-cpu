`timescale 1ns / 1ps


module controller(
    input clk,
    input reset,
    input [5:0] op,
    input zero,
    output reg memread,
    output reg memwrite,
    output reg alusrca,
    output reg memtoreg,
    output reg iord,
    output pcen,
    output reg regwrite,
    output reg regdst,
    output reg [1:0] pcsource,
    output reg [1:0] alusrcb,
    output reg [1:0] aluop,
    output reg [3:0] irwrite,
    
    output reg aluout_hold,
    output reg mem_offset_en,
    
    input bus_grant
    );
    
    localparam FETCH1 = 5'b00001;
    localparam FETCH2 = 5'b00010;
    localparam FETCH3 = 5'b00011;
    localparam FETCH4 = 5'b00100;
    localparam DECODE = 5'b00101;
    localparam MEMADR = 5'b00110;
    localparam LBRD = 5'b00111;
    localparam LBWR = 5'b01000;
    localparam SBWR = 5'b01001;
    localparam RTYPEEX = 5'b01010;
    localparam RTYPEWR = 5'b01011;
    localparam BEQPREP = 5'b01100;
    localparam BEQEX = 5'b01101;
    localparam JEX = 5'b01110;
    localparam ADDIWR = 5'b01111;
    localparam WRSPEC = 5'b10000; //New state to write to special register
    
    localparam LB = 6'b100000;
    localparam SB = 6'b110000;
    localparam RTYPE = 6'b000000;
    localparam BEQ = 6'b000100;
    localparam J = 6'b000010;
    localparam ADDI = 6'b001000;
    localparam STRSPEC = 6'b000001; // New instruction op-code
    
    reg [4:0] state, nextstate;
    reg pcwrite, pcwritecond;
    assign pcen = pcwrite | (pcwritecond & zero);
    
    always @(posedge clk) begin
        if(reset) state <= FETCH1;
        else state <= nextstate;
    end
    always @(*) begin
        case(state)
            FETCH1: nextstate <= bus_grant ? FETCH2 : FETCH1; //If we don't have the bus, then the data from the memory isn't actually our data, so don't move to the next state
            FETCH2: nextstate <= bus_grant ? FETCH3 : FETCH2;
            FETCH3: nextstate <= bus_grant ? FETCH4 : FETCH3;
            FETCH4: nextstate <= bus_grant ? DECODE : FETCH4;
            DECODE: case(op)
                LB: nextstate <= MEMADR;
                SB: nextstate <= MEMADR;
                ADDI: nextstate <= MEMADR;
                RTYPE: nextstate <= RTYPEEX;
                BEQ: nextstate <= BEQPREP;
                J: nextstate <= JEX;
                STRSPEC: nextstate <= WRSPEC;
                default: nextstate <= FETCH1;
            endcase
            MEMADR: case(op)
                LB: nextstate <= LBRD;
                SB: nextstate <= SBWR;
                ADDI: nextstate <= ADDIWR;
                default: nextstate <= FETCH1;
            endcase
            LBRD: nextstate <= bus_grant ? LBWR : LBRD;
            LBWR: nextstate <= FETCH1;
            SBWR: nextstate <= bus_grant ? FETCH1 : SBWR;
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH1;
            BEQPREP: nextstate <= BEQEX; // I had to add an extra state for BEQ
            BEQEX: nextstate <= FETCH1;
            JEX: nextstate <= FETCH1; // Unconditional jump state
            ADDIWR: nextstate <= FETCH1;
            WRSPEC: nextstate <= FETCH1;
            default: nextstate <= FETCH1;
        endcase
        irwrite <= 4'b0000;
        pcwrite <= 0;
        pcwritecond <= 0;
        regwrite <= 0;
        regdst <= 0;
        memread <= 0;
        memwrite <= 0;
        alusrca <= 0;
        alusrcb <= 2'b00;
        aluop <= 2'b00;
        pcsource <= 2'b00;
        iord <= 0;
        memtoreg <= 0;
        aluout_hold <= 0;
        mem_offset_en <= 0;
        case(state)
            FETCH1: begin
                memread <= 1;
                irwrite <= 4'b0001;
                alusrcb <= 2'b01;
                pcwrite <= bus_grant; //Don't increment the PC unless we are actually leaving this state
            end
            FETCH2: begin
                memread <= 1;
                irwrite <= 4'b0010;
                alusrcb <= 2'b01;
                pcwrite <= bus_grant;
            end
            FETCH3: begin
                memread <= 1;
                irwrite <= 4'b0100;
                alusrcb <= 2'b01;
                pcwrite <= bus_grant;
            end
            FETCH4: begin
                memread <= 1;
                irwrite <= 4'b1000;
                alusrcb <= 2'b01;
                pcwrite <= bus_grant;
            end
            DECODE: begin
                alusrcb <= 2'b11;
            end
            MEMADR: begin
                alusrca <= 1;
                alusrcb <= 2'b10;
            end
            LBRD: begin
                memread <= 1;
                iord <= 1;
                aluout_hold <= 1;
            end
            LBWR: begin
                regwrite <= 1;
                regdst <= 0;
                memtoreg <= 1;
            end
            SBWR: begin
                memwrite <= 1;
                iord <= 1;
                aluout_hold <= 1;
            end
            RTYPEEX: begin
                alusrca <= 1;
                alusrcb <= 2'b00;
                aluop <= 2'b10; //go to default in alu controller
            end
            RTYPEWR: begin
                regwrite <= 1;
                regdst <= 1;
                memtoreg <= 0;
            end
            BEQPREP: begin
                alusrca <= 0;
                alusrcb <= 2'b11;
                aluop <= 2'b00;
            end
            BEQEX: begin
                alusrca <= 1;
                alusrcb <= 2'b00;
                pcwrite <= zero;
                pcsource <= 2'b01;
                aluop <= 2'b01; //Subtraction mode
            end
            JEX: begin
                alusrca <= 1; //bits 25-21 MUST be zeros
                alusrcb <= 2'b11;
                pcwrite <= 1;
                pcsource <= 0;
            end
            ADDIWR: begin
                regwrite <= 1;
                regdst <= 0;
                memtoreg <= 0;
            end
            WRSPEC: begin
                mem_offset_en <= 1;
            end
            default: begin
            end
        endcase
    end
endmodule
