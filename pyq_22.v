module REG_8BIT(
    output reg [7:0] reg_out,
    input [7:0] num_in,
    input clock,reset);
    always @(posedge clock) begin
        reg_out<=(!reset)?num_in:reg_out;
    end
endmodule

module EXPANSION_BOX(
    input [3:0] in,
    output [7:0] out);
    assign out={in[3],in[0],in[1],in[2],in[1],in[3],in[2],in[0]};
endmodule

module XOR_8BIT(
    output [7:0] xout_8,
    input [7:0] xin1_8,xin2_8); 
    assign xout_8=xin1_8^xin2_8;   
endmodule

module XOR_4BIT(
    output [3:0] xout_4,
    input [3:0] xin1_4,xin2_4);    
    assign xout_4=xin1_4^xin2_4;
endmodule

module fa(
    input cin,
    input in_a,in_b,
    output cout,out
);
    assign cout=in_a&in_b | in_a&cin | in_b&cin;
    assign out=in_a+in_b+cin;
endmodule

module full_adder(
    input cin,
    input [3:0] in_a,in_b,
    output cout,
    output [3:0] out);
    wire w,x,y,z;
    wire m,n,o,p;
    fa instance99(.cin(cin),.cout(w),.out(m),.in_a(in_a[0]),.in_b(in_b[0]));
    fa instance98(.cin(w),.cout(x),.out(n),.in_a(in_a[1]),.in_b(in_b[1]));
    fa instance97(.cin(x),.cout(y),.out(o),.in_a(in_a[2]),.in_b(in_b[2]));
    fa instance96(.cin(y),.cout(z),.out(p),.in_a(in_a[3]),.in_b(in_b[3]));
    assign out={p,o,n,m};
    assign cout=z;
endmodule

module mux_2isto1_1(
    input sel,in_a,in_b,
    output out
);
    assign out=(sel)?in_b:in_a;
endmodule

module mux_2isto1_4(
    input sel,
    input [3:0] in_a,in_b,
    output [3:0] out
);
    assign out=(sel)?in_b:in_a;
endmodule

module CSA_4BIT(
    input cin,
    input [3:0] inA,inB,
    output cout,
    output [3:0] out);
    wire w,x,b;
    wire [3:0] y,z,a;
    full_adder instance1(.cin(1'b1),.in_a(inA),.in_b(inB),.cout(w),.out(y));
    full_adder instance2(.cin(1'b0),.in_a(inA),.in_b(inB),.cout(x),.out(z));
    mux_2isto1_4 instance3(.sel(cin),.in_a(z),.in_b(y),.out(a));
    mux_2isto1_1 instance4(.sel(cin),.in_a(x),.in_b(w),.out(b));
    assign cout=b;
    assign out=a;
endmodule

module CONCAT(
    output [7:0] concat_out,
    input [3:0] concat_in1,concat_in2);
    assign concat_out={concat_in1,concat_in2};
endmodule

module ENCRYPT(
    input [7:0] number,
    input [7:0] key,
    input clock,reset,
    output [7:0] enc_number);
    wire [7:0] extended,xored,final;
    wire [3:0] csaed,xored_2;
    wire u;
    EXPANSION_BOX instance1(.in(number[3:0]),.out(extended));
    XOR_8BIT instance2(.xin1_8(extended[7:0]),.xin2_8(key[7:0]),.xout_8(xored));
    CSA_4BIT instance3(.cin(key[0]),.inA(xored[7:4]),.inB(xored[3:0]),.cout(u),.out(csaed));
    XOR_4BIT instance4(.xin1_4(number[7:4]),.xin2_4(csaed[3:0]),.xout_4(xored_2));
    CONCAT instance5(.concat_out(final),.concat_in1(xored_2),.concat_in2(number[3:0]));
    assign enc_number=final;
endmodule

// testbench
module testbench;
    reg clk,reset;
    reg [7:0] num,key;
    wire [7:0] result;
    ENCRYPT instance100 (.number(num),.key(key),.enc_number(result),.clock(clk),.reset(reset));
    initial begin
        $dumpfile("pyq_22.vcd");
        $dumpvars;
        clk=0;
        forever #5 clk=~clk;
    end
    initial begin
        reset=1;
        #10;
        reset=0;
        num=8'b01000110;key=8'b10010011;
        #5;
        num=8'b11001001;key=8'b10101100;
        #5;
        num=8'b10100101;key=8'b01011010;
        #5;
        num=8'b11110000;key=8'b10110001;
        #5;
        $finish;
    end
    initial begin
        $monitor("t=%3d, num=%d, key=%d, result=%d\n",$time,num,key,result);
    end
endmodule