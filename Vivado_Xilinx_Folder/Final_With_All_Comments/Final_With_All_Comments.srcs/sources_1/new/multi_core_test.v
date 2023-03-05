`timescale 1ns / 1ps
import my_package::*;
module multi_core_test(
    );
    reg clk;
    reg reset;
    wire [15:0] memdata, writedata;
    wire [23:0] adr;
    wire [1:0] memread, memwrite;
    
    wire [7:0] selected_memdata, selected_writedata;
    wire [11:0] selected_adr;
    wire selected_memread, selected_memwrite;
    
    wire [1:0] bus_req, bus_grant;
    
    wire [7:0] ram_data, rom_data, io_data, mmu_data;
    wire rom_read, ram_read, ram_write, io_read, io_write, mmu_read, mmu_write;
    
    reg [7:0] switches;
    wire [15:0] seven_seg;
    
    instructions my_insts;
    
    seven_segment_controller(
        seven_seg, 
        clk100m, 
        reset
    );
    
    mips #(.WIDTH(16), .REGBITS(3)) my_core_0(
        .clk(clk),
        .reset(reset),
        .memdata(memdata[7:0]),
        .memread(memread[0]),
        .memwrite(memwrite[0]),
        .adr(adr[11:0]),
        .writedata(writedata[7:0]),
        .bus_req(bus_req[0]),
        .bus_grant(bus_grant[0])
    );
    
    mips #(.WIDTH(16), .REGBITS(3)) my_core_1(
        .clk(clk),
        .reset(reset),
        .memdata(memdata[15:8]),
        .memread(memread[1]),
        .memwrite(memwrite[1]),
        .adr(adr[23:12]),
        .writedata(writedata[15:8]),
        .bus_req(bus_req[1]),
        .bus_grant(bus_grant[1])
    );
    
    mem_arbiter my_arbiter(
        .clk(clk),
        .reset(reset),
        .memdata_cores(memdata),
        .memdata_mem(selected_memdata),
        .writedata_cores(writedata),
        .writedata_mem(selected_writedata),
        .adr_cores(adr),
        .adr_mem(selected_adr),
        .memread_cores(memread),
        .memread_mem(selected_memread),
        .memwrite_cores(memwrite),
        .memwrite_mem(selected_memwrite),
        .bus_req(bus_req),
        .bus_grant(bus_grant)
    );
    
    mem_map my_map(
        .adr(selected_adr),
        .read(selected_memread),
        .write(selected_memwrite),
        
        .readdata(selected_memdata),
        .ram_readdata(ram_data),
        .rom_readdata(rom_data),
        .io_readdata(io_data),
        .mmu_readdata(mmu_data),
        
        .rom_read(rom_read),
        .ram_read(ram_read),
        .ram_write(ram_write),
        .io_read(io_read),
        .io_write(io_write),
        .mmu_read(mmu_read),
        .mmu_write(mmu_write)
    );
    
    exmemory #(.WIDTH(8), .ADDR_WIDTH(10)) my_mem(
        .clk(clk),
        .memdata(ram_data),
        .memwrite(ram_write),
        .adr(selected_adr[9:0]),
        .writedata(selected_writedata)
    );
    
    ex_rom my_rom(
        .clk(clk),
        .adr(selected_adr[5:0]),
        .read(rom_read),
        .data(rom_data)
    );
    
    io_regs my_io(
        .clk(clk),
        .reset(reset),
        .adr(selected_adr[5:0]),
        .read(io_read),
        .write(io_write),
        .switches(switches),
        .seven_seg(seven_seg),
        .read_data(io_data),
        .write_data(selected_writedata)
    );
    
    mmu my_mmu(
        .clk(clk),
        .reset(reset),
        .adr(selected_adr[5:0]),
        .read(mmu_read),
        .write(mmu_write),
        .read_data(mmu_data),
        .write_data(selected_writedata)
    );
    
    initial begin
        clk <= 0;
        forever begin
            #1 clk <= ~clk;
        end
    end
 
    initial begin
        switches <= 8'd15;
        reset <= 1;
        #5;
        reset <= 0;
        my_insts = new();
        my_insts.randomize();
    end
endmodule
