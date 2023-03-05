`timescale 1ns / 1ps
/*
class instructions;
    integer instruction_count;
    instruction my_insts [100];
endclass
*/
/*
package my_package;
class instruction;
    covergroup my_cg;
        op: coverpoint op_code {
            bins RTYPE = {6'b000000};
            bins SPECIAL = {6'b000001};
            bins J = {6'b000010};
            bins BEQ = {6'b000100};
            bins ADDI = {6'b001000};
            bins LOAD = {6'b100000};          
            bins STORE = {6'b110000};
        }
        reg_a_pt: coverpoint reg_a {
            bins ZERO = {0};
            bins ONE = {1};
            bins TWO = {2};
            bins THREE = {3};
            bins FOUR = {4};
            bins FIVE = {5};
            bins SIX = {6};
            bins SEVEN = {7};
        }
        reg_b_pt: coverpoint reg_b {
            bins ZERO = {0};
            bins ONE = {1};
            bins TWO = {2};
            bins THREE = {3};
            bins FOUR = {4};
            bins FIVE = {5};
            bins SIX = {6};
            bins SEVEN = {7};
        }
        reg_c_pt: coverpoint reg_c {
            bins ZERO = {0};
            bins ONE = {1};
            bins TWO = {2};
            bins THREE = {3};
            bins FOUR = {4};
            bins FIVE = {5};
            bins SIX = {6};
            bins SEVEN = {7};
        }
        imm: coverpoint constant[3:0];
    endgroup
    bit [5:0] op_code;
    bit [4:0] reg_a, reg_b, reg_c;
    bit [5:0] funct;
    bit [15:0] constant;
    
    function bit [31:0] get_code;
        if(this.op_code == 6'b000000) return {op_code, reg_a, reg_b, reg_c, 5'b0, funct};
        if(this.op_code == 6'b000001) return {op_code, reg_a, 5'b0, constant};
        if(this.op_code == 6'b000010) return {op_code, 10'b0, constant};
        if(this.op_code == 6'b000100) return {op_code, reg_a, 5'b0, constant};
        if(this.op_code == 6'b001000) return {op_code, reg_a, 5'b0, constant};
        if(this.op_code == 6'b100000) return {op_code, reg_a, 5'b0, constant};
        if(this.op_code == 6'b110000) return {op_code, reg_a, 5'b0, constant};
    endfunction
    
    function void post_randomize();
        my_cg.sample();
    endfunction
endclass
endpackage*/