`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2020 05:08:42 PM
// Design Name: 
// Module Name: ifid
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

module PC( 
    input clk,
    input wire[31:0] pcIn, 
    input wpcir, // project
    output reg[31:0] pcOut   
    );

initial
    begin
        pcOut = 100;
    end

always @(posedge clk)
    begin
        pcOut = pcIn;
    end
endmodule

module Adder( 
    input  [31:0] pcIn, 
    output [31:0] pcOut
    );
    assign pcOut = pcIn + 32'd4; 
endmodule

module InstMem(
    input [31:0] a,
    output reg[31:0] do
    );
    reg [31:0] IM[0:511];
    
    initial 
    begin
        //IM[100] = 32'b100011 00001 00010 00000 00000 000000; // lw $2, 00($1)
        //IM[104] = 32'b100011 00001 00011 00000 00000 000100; // lw $3, 04($1)
        //IM[108] = 32'b100011 00001 00100 00000 00000 001000; // lw $4, 08($1)
        //IM[112] = 32'b100011 00001 00101 00000 00000 001100; // lw $5, 12($1)
        //IM[116] = 32'b000000 00010 01010 00110 00000 100000; // add $6, $2, $10
        //              add     2       10  6     given  given
        //                     2st    3rd   1st
        IM[100] = 32'b00000000001000100001100000100000; // add $3, $1, $2
        IM[104] = 32'b00000001001000110010000000100010; // sub $4, $9, $3
        IM[108] = 32'b00000000011010010010100000100101; // or $5, $3, $9
        IM[112] = 32'b00000000011010010011000000100110; // xor $6, $3, $9
        IM[116] = 32'b00000000011010010011100000100000; // and $7, $3, $9
        //                add   3      9    7     
        
 
    end
    always @ (a)
        begin
            do = IM[a];
        end
endmodule

module IfId( 
    input clk,
    input wire[31:0] do,
    input wpcir,    // project
    output reg[5:0] op,
    output reg[4:0] rs,
    output reg[4:0] rt,
    output reg[4:0] rd,
    output reg[4:0] shamt,
    output reg[5:0] func,
    output reg[15:0] imme
    );
    
    always @(posedge clk)
        begin
            op = do [31:26];
            rs = do [25:21];
            rt = do [20:16];
            rd = do [15:11];
            shamt = do [10:6];
            func = do [5:0];
            imme = do [15:0];
        end   
endmodule

module ControlUnit(
    input [5:0] op,
    input [5:0] func,
    input [4:0] rs, // project
    input [4:0] rt, // project
    input [4:0] mrn, // project mwb
    input mm2reg, // project mwb
    input mwreg, // project mwb
    input [4:0] ern, // project em
    input em2reg, // project em
    input ewreg, // project em
    output reg wreg,
    output reg m2reg,
    output reg wmem,
    output reg [3:0] aluc,
    output reg aluimm,
    output reg regrt,
    output reg[1:0] fwdb, // project
    output reg[1:0] fwda // project
    //output reg wpcir // project
    );
    always @(*)
    begin
    if ( ewreg & (ern != 0) & (ern == rs))
        begin
            fwda = 2'b10;
        end 
    if ( ewreg & (ern != 0) & (ern == rt))
        begin
            fwdb = 2'b10;
        end
    if ( mwreg & (mrn != 0) & ~( ewreg & (ern != 0) & ( ern == rs)) & (mrn == rs))
        begin
            fwda = 2'b01;
        end
    if ( mwreg & (mrn != 0) & ~( ewreg & (ern != 0) & ( ern == rt)) & (mrn == rt))
        begin
            fwdb = 2'b01;
        end
    else 
        begin
            fwda = 2'b00;
            fwdb = 2'b00;
        end
            
     end
    always @(op)
    begin
        if (op == 6'b100011) begin
        //6'b100011: begin //lw
            aluc = 4'b0010;
            wreg = 1'b1;
            m2reg = 1'b1;
            wmem = 1'b0;
            aluimm = 1'b1;
            regrt = 1'b1; //1?
        end
        if (op == 6'b000000) begin //add
            aluc = 4'b0010;
            wreg = 1'b1;
            m2reg = 1'b0;
            wmem =  1'b0;
            aluimm = 1'b0;
            regrt = 1'b0;
        end
        if (op == 6'b000100) begin //beq
            aluc = 4'b0100;
            wreg = 1'b0;
            //m2reg = 1'b; //dont care
            wmem = 1'b0;
            aluimm = 1'b0;
            regrt = 1'b1;
        end
            
  
    end
endmodule

module Mux(
    input [4:0] rd,
    input [4:0] rt,
    input regrt, 
    output reg [4:0] rn
    );
    always @(*)
    begin
        if (regrt == 0) 
            begin
                rn = rd;
            end
        else
            begin
                rn = rt;
            end
     end
endmodule

module ForwardA(
    input [1:0] fwda,
    input [31:0] qa,
    input [31:0] r,  
    input [31:0] mr,
    input [31:0] do,
    output reg [31:0] a
    );
    always @(*)
        begin
            case (fwda)
                2'b00: a = qa;
                2'b01: a = r;
                2'b10: a = mr;
                2'b11: a = do;
            endcase
        end     
endmodule

module ForwardB(
    input [1:0] fwdb,
    input [31:0] qb,
    input [31:0] r,
    input [31:0] mr,
    input [31:0] do,
    output reg [31:0] b
    );
    
    always @(*)
        begin
            case (fwdb)
                2'b00: b = qb;
                2'b01: b = r;
                2'b10: b = mr;
                2'b11: b = do;
            endcase
        end
    
endmodule

module RegFile(
    input clk, //not clock?
    input wwreg,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] wrn,
    input [31:0] d,
    output reg [31:0] qa,
    output reg [31:0] qb
    );
    reg [31:0] RegFile[0:511];
    integer i;
    
    initial
        begin
            //for (i=0; i< 32; i= i+1)
            //    begin
            //        RegFile[i] = 32'd0;
            //    end
            RegFile[0] = 32'h00000000;
            RegFile[1] = 32'hA00000AA;
            RegFile[2] = 32'h10000011;
            RegFile[3] = 32'h20000022;
            RegFile[4] = 32'h30000033;
            RegFile[5] = 32'h40000044;
            RegFile[6] = 32'h50000055;
            RegFile[7] = 32'h60000066;
            RegFile[8] = 32'h70000077;
            RegFile[9] = 32'h80000088;
            RegFile[10] = 32'h90000099;
            
            
        end    
    always @(negedge clk,rs,rt) //rs, rt
        begin
            if (wwreg == 1) 
                begin
                    RegFile[wrn] = d;
                end   
        end
   always @(posedge clk, rs,rt) //rs,rt
        begin
            qa = RegFile[rs];
            qb = RegFile[rt];
        end
endmodule

module SignExtend(
    input [15:0] imm,
    output [31:0] signExtend
    );
    
    assign signExtend = {{16{imm[15]}},imm[15:0]};
endmodule

module IdExe(
    input clk,
    input wreg,
    input m2reg,
    input wmem,
    input [3:0] aluc,
    input aluimm,
    input [4:0] rn,
    input [31:0] fwda,
    input [31:00] fwdb,
    input [31:0] signExtend,
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg [3:0] ealuc,
    output reg ealuimm,
    output reg [4:0] ern,
    output reg [31:0] esignExtend,
    output reg [31:0] efwda,
    output reg [31:0] efwdb
    );
    
    always @ (posedge clk)
        begin
            ewreg = wreg;
            em2reg = m2reg;
            ewmem = wmem;
            ealuc = aluc;
            ealuimm = aluimm;
            ern = rn;
            efwda = fwda;
            efwdb = fwdb;
            esignExtend = signExtend;
        end
          
endmodule
           
module MuxExe(
    input [31:0] efwdb,
    input [31:0] esignExtend,
    input ealuimm,
    output reg [31:0] b
    );
    always  @(*)
        begin
            if (ealuimm == 0)
                begin
                    b = efwdb;
                end
            else
                begin
                    b = esignExtend;
                end
        end
endmodule
    
module ALU(
    input [3:0] aluc,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] r
    );
    always @ (*)
        begin
            case (aluc)
                4'b0000: r = a & b; //and
                4'b0001: r = a | b; //or
                4'b0010: r = a + b; //add
                4'b0110: r = a - b; //subtract
                4'b0111: r = a < b; //set on less than
                4'b1001: r = ((a & (~b)) | ((~a) & b)); //xor
                4'b1100: r = ~(a | b); //nor
            endcase
         end 
                    
endmodule

module ExeMem(
    input clk,
    input ewreg,
    input em2reg,
    input ewmem,
    input [4:0] ern,
    input [31:0] er,
    input [31:0] efwdb,
    output reg mwreg,
    output reg mm2reg,
    output reg mwmem,
    output reg [4:0] mrn,
    output reg [31:0] mr,
    output reg [31:0] mfwdb
    );
    
    always @(posedge clk)
        begin
            mwreg = ewreg;
            mm2reg = em2reg;
            mwmem = ewmem;
            mrn = ern;
            mr = er;
            mfwdb = efwdb;
        end
    
endmodule

module DMem(
    input we, //mwmem
    input [31:0] a, //r
    input [31:0] di, //eqb
    output reg [31:0] do
    );
    
    reg [31:0] words [511:0];
    initial
        begin
            words[0] = 32'hA00000AA;
            words[4] = 32'h10000011;
            words[8] = 32'h20000022;
            words[12] = 32'h30000033;
            words[16] = 32'h40000044;
            words[20] = 32'h50000055;
            words[24] = 32'h60000066;
            words[28] = 32'h70000077;
            words[32] = 32'h80000088;
            words[36] = 32'h90000099;
        end
    always @(*)
        begin
            if (we == 0)
                begin
                    do = words[a];
                end
        end
        

endmodule

module MemWB(
    input clk,
    input mwreg,
    input mm2reg,
    input [4:0] mrn,
    input [31:0] mr,
    input [31:0] mdo,
    output reg wwreg,
    output reg wm2reg,
    output reg [4:0] wrn,
    output reg [31:0] wr,
    output reg [31:0] wdo
    );
    
    always @ (posedge clk)
        begin
            wwreg = mwreg;
            wm2reg = mm2reg;
            wrn = mrn;
            wr = mr;
            wdo = mdo;
        end
           
endmodule

module MuxWB(
    input wm2reg,
    input [31:0] wr,
    input [31:0] wdo,
    output reg [31:0] d
    );
    always @(*)
        begin
            if (wm2reg ==0)
                begin
                    d = wr;
                end
            else 
                begin
                    d = wdo;
                end
        end
    
endmodule
    
         
    