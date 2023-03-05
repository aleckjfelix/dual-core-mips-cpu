`timescale 1ns / 1ps

import Instructions::*;

module controller_testbench();

    reg clk;// clk for cpu
    reg reset;//reset signal to cpu
    wire [7:0] writedata;
    wire [11:0] adr;
    wire memread, memwrite;
    reg [31:0]data_reg;//used for cpu to read instr from
    reg [7:0] memdata;
    wire [16*8-1:0] internal_regs;//wire to internal regs of cpu
    integer allTestsPassed = 1;
    
    // MIPS core
    mips #(.WIDTH(16), .REGBITS(3)) my_core(
        .clk(clk),
        .reset(reset),
        .memdata(memdata),
        .memread(memread),
        .memwrite(memwrite),
        .adr(adr),
        .writedata(writedata),
        .bus_grant(1'b1)
    );
    
    //connect internal_regs wires to registers in cpu register file
    generate
        for(genvar j=0; j<8; j=j+1) begin
            assign internal_regs[16*j+:16] = my_core.dp.rf.RAM[j];
        end
    endgenerate
    
    // the randomized test
    task test();
        RandomizedRAM randRAM; // randomized RAM module
        randRAM = new();
        
        // perform 1000 randomizations of the RAM module
        for(integer i=0; i<10000; i=i+1) begin
            randRAM.randomize();
            // save inital values of cpu registers
            randRAM.read_initial_state(internal_regs, my_core.dp.pcreg.q);
            // put instrucion into data_reg
            data_reg = randRAM.RAM;
            
            // allow cpu to perform fetch
            memdata = data_reg[7:0]; 
            #1;
            clk <= 1; #1;
            clk <= 0; #1;
            memdata <= data_reg[15:8]; 
            clk <= 1; #1;
            clk <= 0; #1;
            memdata <= data_reg[23:16]; 
            clk <= 1; #1;
            clk <= 0; #1;
            memdata <= data_reg[31:24]; 
            clk <= 1; #1;
            clk <= 0; #1;
            
            // cycle cpu until back to FETCH#1
            while(mips.cont.state != 5'b00001) begin
                clk <= 1; #1;
                clk <= 0; #1;
            end
            
            // display message and stop test if final state isnt expected state
            if(randRAM.check_final_state(internal_regs, my_core.dp.pcreg.q) != 1) begin
                $display("%b", data_reg);
                allTestsPassed = 0;
                $finish();
               
            end
        end
        // display results of test
        if(allTestsPassed == 1)
            $display("All tests passed");
        $display("RTYPE funct coverage: %d percent", randRAM.r_instr.my_cg.funct_point.get_inst_coverage());
        $display("ITYPE opcode coverage: %d percent",randRAM.i_instr.my_cg.op.get_inst_coverage());
        $display("ITYPE immediate coverage: %d percent",randRAM.i_instr.my_cg.imm.get_inst_coverage());
        $display("JTYPE Address coverage: %d percent",randRAM.j_instr.my_cg.addr.get_inst_coverage());
    endtask
    
    initial begin
    // reset the cpu and cycle it a few times
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
        // clear CPUs registers
        for(integer i=0; i<8; i=i+1) my_core.dp.rf.RAM[i] <= 16'b0;
        // start the test
        test();
    end
        
endmodule