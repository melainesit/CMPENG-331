`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2020 11:04:38 AM
// Design Name: 
// Module Name: Processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Processor(input clk_tb);
    //pc
    // wire clk;
    wire [31:0] pcIn;
    wire wpcir_PC;
    wire [31:0] pcOut;
    
    //adder
    wire [31:0] pcIn_adder;
    wire [31:0] pcOut_adder;
    
    // instMem
    wire [31:0] a_InstMem;
    wire [31:0] do_InstMem;
    
    // If/Id
    //wire clk;
    wire [31:0] do_IfId;
    wire wpcir_IfId;
    wire [5:0] op_IfId;
    wire [4:0] rs_IfId;
    wire [4:0] rt_IfId;
    wire [4:0] rd_IfId;
    wire [4:0] shamt_IfId;
    wire [5:0] func_IfId;
    wire [15:0] imme_IfId;
    
    // control unit
    //wire [5:0] op_CU;
    //wire [5:0] func_CU;
    //wire [4:0] rs_CU; //project
    //wire [4:0] rt_CU; //project
    //wire mrn_CU; //project
    //wire mm2reg_CU; //project
    //wire mwreg_CU; //project
    //wire ern_CU; //projet
    //wire em2reg_CU; //project
    //wire ewreg; //project
    wire wreg_CU;
    wire m2reg_CU;
    wire wmem_CU;
    wire [3:0] aluc_CU;
    wire aluimm_CU;
    wire regrt_CU;
    wire [1:0] fwdb_CU; //projecy
    wire [1:0] fwda_CU; //project
    wire wpcir_CU;
    
    //mux
    //wire [3:0] rd_Mux;
    //wire [3:0] rt_Mux;
    wire regrt_Mux;
    wire [4:0] rn;
    
    // Forward A mux
    //wire [1:0] fwda_fwda;
    //wire [31:0] qa_fwda;
    //wire [31:0] r_fwda;
    //wire [31:0] mr_fwda;
    //wire [31:0] do_fwda;
    wire [31:0] a_fwda;
    
    // Forward B mux
    //wire [1:0] fwdb_fwdb;
    //wire [31:0] qb_fwdb;
    //wire [31:0] r_fwdb;
    //wire [31:0] mr_fwdb;
    //wire [31:0] do_fwdb;
    wire [31:0] b_fwdb;
    
    // register file
    // wire clk;
    // wire wwreg;
    // wire [4:0] rs_RegFile;
    // wire [4:0] rt_RegFile;
    // wire [4:0] wrn_RegFile;
    // wire [31:0] d_RegFile;
    wire [31:0] qa_RegFile;
    wire [31:0] qb_RegFile;
    
    // sign extend
    //wire [15:0] imm_SignEx;
    wire [31:0] signEx_SignEx;
    
    // Id/Exe
    // wire clk;
    // wire wreg_IdExe;
    // wire m2reg_IdExe;
    // wire wmem_IdExe;
    // wire [3:0] aluc_IdExe;
    // wire aluimm_IdExe;
    // wire [4:0] rn_IdExe;
    // wire [31:0] fwda_IdExe;
    // wire [31:0] fwdb_IdExe;
    // wire [31:0] signEx_IdExe;
    wire ewreg_IdExe;
    wire em2reg_IdExe;
    wire ewmem_IdExe;
    wire [3:0] ealuc_IdExe;
    wire ealuimm_IdExe;
    wire [4:0] ern_IdExe;
    wire [31:0] efwda_IdExe;
    wire [31:0] efwdb_IdExe;
    wire [31:0] esignEx_IdExe;
    
    // Mux exe
    //wire [31:0] eqb_Exe;
    //wire [31:0] esignEx_Exe;
    //wire [3:0] ealuim_Exe;
    wire [31:0] b_Exe;
    
    // ALU
    //wire [3:0] aluc_Exe;
    //wire [31:0] a_Exe;
    //wire [31:0] b_Exe;
    wire [31:0] r_Exe;
    
    // Exe mem
    // wire clk;
    //wire ewreg_ExeMem;
    //wire em2reg_ExeMem;
    //wire ewmem_ExeMem;
    //wire [4:0] ern_ExeMem;
    //wire [31:0] er_ExeMem;
    //wire [31:0] efwdb_ExeMem;
    wire mwreg_ExeMem;
    wire mm2reg_ExeMem;
    wire mwmem_ExeMem;
    wire [4:0] mrn_ExeMem;
    wire [31:0] mr_ExeMem;
    wire [31:0] mfwdb_ExeMem;
    
    // data memory
    //wire we_Mem;
    //wire [31:0] a_Mem;
    //wire [31:0] di_Mem;
    wire [31:0] do_Mem;
    
    // Mem Write back
    // wire clk;
    //wire mwreg_MemWB;
    //wire mm2reg_MemWB;
    //wire [4:0] mrn_MemWB;
    //wire [31:0] mr_MemWB;
    //wire [31:0] mdo_MemWB;
    wire wwreg_MemWB;
    wire wm2reg_MemWB;
    wire [4:0] wrn_MemWB;
    wire [31:0] wr_MemWB;
    wire [31:0] wdo_MemWB;
    
    // MuxWB

    wire [31:0] d_WB;
    
    
        
    PC thePC( .clk(clk_tb), .pcIn(pcOut_adder), .wpcir(wpcir_CU), .pcOut(pcOut));
    
    Adder theAdder(.pcIn(pcOut),.pcOut(pcOut_adder));
    
    InstMem theInstMem(.a(pcOut), .do(do_InstMem));
    
    IfId theIfId(.clk(clk_tb), .do(do_InstMem), .wpcir(wpcir_CU), 
        .op(op_IfId), .rs(rs_IfId), .rt(rt_IfId),
        .rd(rd_IfId), .shamt(shamt_IfId), .func(func_IfId),
        .imme(imme_IfId));
        
    ControlUnit theControlUnit(.op(op_IfId),
        .func(func_IfId), .rs(rs_IfId), .rt(rt_IfId), .mrn(mrn_ExeMem), 
        .mm2reg(mm2reg_ExeMem), .mwreg(mwreg_ExeMem), .ern(ern_IdExe), 
        .em2reg(em2reg_IdExe), .ewreg(ewreg_IdExe), .wreg(wreg_CU), 
        .m2reg(m2reg_CU), .wmem(wmem_CU), .aluc(aluc_CU), 
        .aluimm(aluimm_CU), .regrt(regrt_CU), .fwdb(fwdb_CU), .fwda(fwda_CU));
        
    Mux theMux(.rd(rd_IfId), .rt(rt_IfId), .regrt(regrt_CU),
        .rn(rn));
        
    ForwardA theForwardA( .fwda(fwda_CU), .qa(qa_RegFile), .r(r_Exe),
        .mr(mr_ExeMem), .do(do_Mem), .a(a_fwda));
    
    ForwardB theForwardB( .fwdb(fwdb_CU), .qb(qb_RegFile), .r(r_Exe), 
        .mr(mr_ExeMem), .do(do_Mem), .b(b_fwdb));
        
    RegFile theRegFile( .clk(clk_tb), .wwreg(wwreg_MemWB), .rs(rs_IfId), 
        .rt(rt_IfId), .wrn(wrn_MemWB), .d(d_WB),  .qa(qa_RegFile), 
        .qb(qb_RegFile));
        
    SignExtend theSignExtend(.imm(imme_IfId),
        .signExtend(signEx_SignEx));
        
    IdExe theIdExe(.clk(clk_tb), .wreg(wreg_CU),
        .m2reg(m2reg_CU), .wmem(wmem_CU), .aluc(aluc_CU),
        .aluimm(aluimm_CU), .rn(rn), .fwda(a_fwda),
        .fwdb(b_fwdb), .signExtend(signEx_SignEx), 
        .ewreg(ewreg_IdExe), .em2reg(em2reg_IdExe),
        .ewmem(ewmem_IdExe), .ealuc(ealuc_IdExe),
        .ealuimm(ealuimm_IdExe), .ern(ern_IdExe),
        .esignExtend(esignEx_IdExe), .efwda(efwda_IdExe),
        .efwdb(efwdb_IdExe));
        
    MuxExe theMuxExe(.efwdb(efwdb_IdExe), .esignExtend(esignEx_IdExe), 
        .ealuimm(ealuimm_IdExe), .b(b_Exe)); 
          
    ALU theALU(.aluc(ealuc_IdExe), .a(efwda_IdExe), .b(b_Exe), .r(r_Exe));
    
    ExeMem theExeMem(.clk(clk_tb), .ewreg(ewreg_IdExe), .em2reg(em2reg_IdExe),
        .ewmem(ewmem_IdExe), .ern(ern_IdExe), .er(r_Exe),
        .efwdb(efwdb_IdExe), .mwreg(mwreg_ExeMem), .mm2reg(mm2reg_ExeMem), 
        .mwmem(mwmem_ExeMem), .mrn(mrn_ExeMem), .mr(mr_ExeMem), 
        .mfwdb(mfwdb_ExeMem));
    
    DMem theDMem(.we(mwmem_ExeMem), .a(mr_ExeMem), .di(mfwdb_ExeMem), .do(do_Mem));
    
    MemWB theMemWB(.clk(clk_tb), .mwreg(mwreg_ExeMem), .mm2reg(mm2reg_ExeMem),
        .mrn(mrn_ExeMem), .mr(mr_ExeMem), .mdo(do_Mem), 
        .wwreg(wwreg_MemWB), .wm2reg(wm2reg_MemWB), .wrn(wrn_MemWB), 
        .wr(wr_MemWB), .wdo(wdo_MemWB));
        
    MuxWB theMuxWB(.wm2reg(wm2reg_MemWB), .wr(wr_MemWB), .wdo(wdo_MemWB),
        .d(d_WB));
endmodule
