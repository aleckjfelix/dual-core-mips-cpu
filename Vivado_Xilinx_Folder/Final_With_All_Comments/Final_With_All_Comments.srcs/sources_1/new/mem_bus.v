`timescale 1ns / 1ps

module mem_arbiter(
    input clk,
    input reset,
    output [15:0] memdata_cores,
    input [7:0] memdata_mem,
    input [23:0] adr_cores,
    output [11:0] adr_mem,
    input [15:0] writedata_cores,
    output [7:0] writedata_mem,
    input [1:0] memread_cores,
    output memread_mem,
    input [1:0] memwrite_cores,
    output memwrite_mem,
    input [1:0] bus_req,
    output [1:0] bus_grant
    );
    localparam NO_GRANT = 2'b00;
    localparam CORE_0_GRANT = 2'b01;
    localparam CORE_1_GRANT = 2'b10;
    
    reg [1:0] state, next_state;
    always @(posedge clk) begin
        if (reset) state <= 0;
        else state <= next_state;
    end
    
    assign bus_grant[0] = state == CORE_0_GRANT;
    assign bus_grant[1] = state == CORE_1_GRANT;
    
    always @(*) begin
        case(state)
            NO_GRANT: case(bus_req)
                2'b00: next_state <= NO_GRANT;
                2'b01: next_state <= CORE_0_GRANT;
                2'b10: next_state <= CORE_1_GRANT;
                2'b11: next_state <= CORE_0_GRANT; //Core 0 always wins initially
            endcase
            CORE_0_GRANT: case(bus_req)
                2'b00: next_state <= NO_GRANT;
                2'b01: next_state <= CORE_0_GRANT;
                2'b10: next_state <= CORE_1_GRANT;
                2'b11: next_state <= CORE_0_GRANT; //Let core 0 keep control if it has control
            endcase
            CORE_1_GRANT: case(bus_req)
                2'b00: next_state <= NO_GRANT;
                2'b01: next_state <= CORE_0_GRANT;
                2'b10: next_state <= CORE_1_GRANT;
                2'b11: next_state <= CORE_1_GRANT; //Let core 1 keep control if it has control
            endcase
            default: next_state <= NO_GRANT;
        endcase
    end
    
    assign memdata_cores = {2{memdata_mem}};
    mux4 #(12) adr_mux(
        .d0(12'b0),
        .d1({1'b0, adr_cores[11:0]}),
        .d2({1'b1, adr_cores[23:12]}),
        .d3(12'b0),
        .s(state),
        .y(adr_mem)
    );
    mux4 #(8) writedata_mux(
        .d0(8'b0),
        .d1(writedata_cores[7:0]),
        .d2(writedata_cores[15:8]),
        .d3(8'b0),
        .s(state),
        .y(writedata_mem)
    );
    mux4 #(1) memread_mux(
        .d0(1'b0),
        .d1(memread_cores[0]),
        .d2(memread_cores[1]),
        .d3(1'b0),
        .s(state),
        .y(memread_mem)
    );
    mux4 #(1) memwrite_mux(
        .d0(1'b0),
        .d1(memwrite_cores[0]),
        .d2(memwrite_cores[1]),
        .d3(1'b0),
        .s(state),
        .y(memwrite_mem)
    );
endmodule

module mem_map(
    input [11:0] adr,
    input read,
    input write,
    
    output reg rom_read,
    output reg ram_read,
    output reg ram_write,
    output reg io_read,
    output reg io_write,
    output reg mmu_read,
    output reg mmu_write,
    
    output reg [7:0] readdata,
    input [7:0] rom_readdata,
    input [7:0] ram_readdata,
    input [7:0] io_readdata,
    input [7:0] mmu_readdata
);
    always @(*) begin
        rom_read <= 0;
        ram_read <= 0;
        io_read <= 0;
        mmu_read <= 0;
        ram_write <= 0;
        mmu_write <= 0;
        io_write <= 0;
        if(read) begin
            if(adr >= 12'h400) begin
                ram_read <= 1;
                readdata <= ram_readdata;
            end
            if(adr < 12'h040) begin
                rom_read <= 1;
                readdata <= rom_readdata;
            end
            if(adr >= 12'h040 && adr < 12'h080) begin
                io_read <= 1;
                readdata <= io_readdata;
            end
            if(adr >= 12'h080 && adr < 12'h0C0) begin
                mmu_read <= 1;
                readdata <= mmu_readdata;
            end
        end
        if(write) begin
            if(adr >= 12'h400) ram_write <= 1;
            if(adr >= 12'h040 && adr < 12'h080) io_write <= 1;
            if(adr >= 12'h080 && adr < 12'h0C0) mmu_write <= 1;
        end
    end
endmodule