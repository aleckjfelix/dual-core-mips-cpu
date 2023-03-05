`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ENEE 459D - Final Project
// Instruction.sv
// Contain classes to represent R, I , and J type instructions for Randomization
//////////////////////////////////////////////////////////////////////////////////
package automatic Instructions;
    
    class RType;
        // randomized components of RTYPE instruction
        bit [5:0] opcode = 6'b000000; // opcode always 0
        rand bit [4:0] sourceReg1;// Rs reg (5bits)
        rand bit [4:0] sourceReg2;// Rt reg (5bits)
        rand bit [4:0] destReg;// Rd reg (5bits)
        bit [4:0] shamt = 5'b00000;//shamt always 0
        rand bit [5:0] funct;//funct for specific operation
        
        bit [8*16-1:0] old_regs;//store old state of the CPUs registers
        
        // constraint registers based on CPU spec. Only 7 registers
        constraint sourceReg1_constraint {sourceReg1 inside{[0:7]};}
        constraint sourceReg2_constraint {sourceReg2 inside{[0:7]};} 
        constraint destReg_constraint {destReg inside{[1:7]};} //Don't store to the constant 0 register
        // constraint funct to the MIPS instruction set spec
        constraint funct_constraint {(funct == 6'b100000) || (funct == 6'b100010) || (funct == 6'b100100) || (funct == 6'b100101) || (funct == 6'b101010) || (funct == 6'b101011);}
        
        // funct covergroup
        covergroup my_cg;
        funct_point: coverpoint funct {
            bins ADD_OP = {6'b100000};
            bins SUB_OP = {6'b100010};
            bins AND_OP = {6'b100100};
            bins OR_OP = {6'b100101};
            bins LSHIFT_OP = {6'b101010};
            bins RSHIFT_OP = {6'b101011};
        }
        endgroup
        
        function new();
            my_cg = new();
        endfunction // constructor
        
        // save the initial state of the CPUs registers
        function void read_initial_state(input [8*16-1:0] regs, input [11:0] pc);
            old_regs = regs;
        endfunction
        
        // verify final state of CPU is correct
        // performs the operation based on value of funct and the old registers value
        // returns boolean if the result of CPU matches the expected result of the operation
        function integer check_final_state(input [8*16-1:0] regs, input [11:0] pc);
            // set  sourceReg1 & sourceReg2 to any value
            bit [14:0] destData = regs[destReg*16+:15]; //Ignore MSB because of overflow errors
            bit [14:0] srcData1 = old_regs[sourceReg1*16+:15];
            bit [14:0] srcData2 = old_regs[sourceReg2*16+:15];
            //$display("%b, %b, %b, %b", destData, srcData1, srcData2, srcData1 & srcData2);
            case(funct)
            6'b100000: return destData == (srcData1 + srcData2);
            6'b100010: return destData == (srcData1 - srcData2);
            6'b100100: return destData == (srcData1 & srcData2);
            6'b100101: return destData == (srcData1 | srcData2);
            6'b101010: return destData == (srcData1 < srcData2 ? 1 : 0);
            default: return 1;
            endcase
        endfunction;
        
        function void post_randomize();
            this.my_cg.sample();
        endfunction
    endclass

    class IType;
        // randomized components of ITYPE instruction
        rand bit [5:0]opcode;
        rand bit [4:0] regA;
        rand bit [4:0] regB;
        rand bit [15:0]immediate;
        
        // constrain opcode to be valid for ITYPE instr
        constraint opcode_constraint {(opcode == 6'b001000) || (opcode == 6'b000100) || (opcode == 6'b100000) || (opcode == 6'b110000);}
        constraint immediate_constraint {(immediate[15] == 0);}
        constraint regA_constraint {regA inside{[0:7]};}
        constraint regB_constraint {regB inside{[1:7]};} //Don't store to constant 0 register
        
        bit [8*16-1:0] old_regs;// store values of register before executing instruction
        bit [11:0] pc_old;// store inital pc
        integer tmp;
        
        // covergroups for opcode and immediate
        covergroup my_cg;
        op: coverpoint opcode {
            bins BEQ = {6'b000100};
            bins ADDI = {6'b001000};
            bins LOAD = {6'b100000};          
            bins STORE = {6'b110000};
        }
        imm: coverpoint immediate[7:0];
        endgroup
        
        function new();
            my_cg = new();
        endfunction
        
        function void post_randomize();
            this.my_cg.sample();
        endfunction
        
        // stores pc and reg before CPU executes instruction
        function void read_initial_state(input [8*16-1:0] regs, input [11:0] pc);
            old_regs = regs;
            pc_old = pc;
        endfunction
        
        // verify the instruction executded correctly
        function integer check_final_state(input [8*16-1:0] regs, input [11:0] pc);
        bit [14:0] dataB = regs[16*regB+:15];
        bit [14:0] dataA = old_regs[16*regA+:15];
        tmp = pc_old + immediate[9:0]*4 + 12'd4;
        case(opcode)
            6'b001000: return dataB == (dataA + immediate[14:0]);
            6'b000100: return (dataA == dataB) ? (pc == tmp[11:0]) : (pc == pc_old + 12'd4);
            default: return 1;
        endcase
        endfunction;
    endclass
    
    class JType;
        bit [5:0]opcode = 6'b000010; // only opcode for jump instruction
        rand bit [25:0]address;
        //constraint address_constraint {}
        constraint address_constraint {(address[25:20] == 6'b0);}
        
        covergroup my_cg;
        addr: coverpoint address[7:0];
        endgroup
        
        function new();
            my_cg = new();
        endfunction
        
        function void post_randomize();
            this.my_cg.sample();
        endfunction
        
        function void read_initial_state(input [8*16-1:0] regs, input [11:0] pc);
        endfunction
        
        function integer check_final_state(input [8*16-1:0] regs, input [11:0] pc);
            return pc == {address[9:0], 2'b00};
        endfunction;
    endclass
    
    class InstructionType;
        rand integer instructionType;
        constraint instructionType_constraint {instructionType inside {[0:2]};}
    endclass;
    
     
    class RandomizedRAM;
        //rand bit for RAM
        rand bit [31:0] RAM; 
        
        
        // all possible instr types
        RType r_instr;
        IType i_instr;
        JType j_instr;
        InstructionType instructionType;
        
        function new();
            r_instr = new();
            i_instr = new();
            j_instr = new();
            instructionType = new();
        endfunction
        
        // generate random instr type and instruction
        function void post_randomize();
            instructionType.randomize();
            
            case(instructionType.instructionType)
                0: begin
                    r_instr.randomize(); // this will call the post_randomize of R Type
                    RAM ={r_instr.opcode, r_instr.sourceReg1,r_instr.sourceReg2, r_instr.destReg,  r_instr.shamt, r_instr.funct};
                end
                1: begin

                    i_instr.randomize(); // this will call the post_randomize of I Type
                    RAM ={i_instr.opcode,i_instr.regA,i_instr.regB, i_instr.immediate};
                end
                2: begin

                    j_instr.randomize(); // this will call the post_randomize of R Type
                    RAM ={j_instr.opcode,j_instr.address};
                end
            endcase        
        endfunction
        
        // check initial state of pc/reg
        function void read_initial_state(input [8*16-1:0] regs, input [11:0] pc);
            case(instructionType.instructionType)
                0: r_instr.read_initial_state(regs, pc);
                1: i_instr.read_initial_state(regs, pc);
                2: j_instr.read_initial_state(regs, pc);
            endcase
        endfunction
        
        // return true if final state is correct
        function integer check_final_state(input [8*16-1:0] regs, input [11:0] pc);
            case(instructionType.instructionType)
                0: return r_instr.check_final_state(regs, pc);
                1: return i_instr.check_final_state(regs, pc);
                2: return j_instr.check_final_state(regs, pc);
            endcase
        endfunction
        
    endclass
endpackage