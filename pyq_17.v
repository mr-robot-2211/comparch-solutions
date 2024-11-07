module MUX_SMALL (
    input a,b,sel,
    output out
);
    assign out=(sel)?b:a;
endmodule

module MUX_BIG (
    input [2:0] sel,
    input [7:0] in,
    output out
);
    wire w,x,y,z,m,n;
    MUX_SMALL instance0(.a(in[0]),.b(in[1]),.sel(sel[0]),.out(w));
    MUX_SMALL instance1(.a(in[2]),.b(in[3]),.sel(sel[0]),.out(x));
    MUX_SMALL instance2(.a(in[4]),.b(in[5]),.sel(sel[0]),.out(y));
    MUX_SMALL instance3(.a(in[6]),.b(in[7]),.sel(sel[0]),.out(z));
    MUX_SMALL instance4(.a(w),.b(x),.sel(sel[1]),.out(m));
    MUX_SMALL instance5(.a(y),.b(z),.sel(sel[1]),.out(n));
    MUX_SMALL instance7(.a(m),.b(n),.sel(sel[2]),.out(out));
endmodule

module TFF (
    input clear,t,clock,
    output reg q
);
    always @(posedge clock or posedge clear) begin
        if(clear) q<=1'b0;
        else if(t) q<=~q;
        else q<=q;
    end
endmodule

module  COUNTER_4BIT (
    input clear,clock,
    output [3:0] q
);
    TFF instance8 (.clear(clear),.t(1'b1),.clock(clock),.q(q[0]));
    TFF instance9 (.clear(clear),.t(q[0]),.clock(clock),.q(q[1]));
    TFF instance10 (.clear(clear),.t(q[1]),.clock(clock),.q(q[2]));
    TFF instance11 (.clear(clear),.t(q[2]),.clock(clock),.q(q[3]));
endmodule

module  COUNTER_3BIT (
    input clear,clock,
    output [2:0] q
);
    TFF instance12 (.clear(clear),.t(1'b1),.clock(clock),.q(q[0]));
    TFF instance13 (.clear(clear),.t(q[0]),.clock(clock),.q(q[1]));
    TFF instance14 (.clear(clear),.t(q[1]),.clock(clock),.q(q[2]));
endmodule

module MEMORY (
    input [3:0] addr,
    output reg [7:0] d
);
    always @(*) begin
        case (addr)
            4'b0000: d=8'hcc;
            4'b0001: d=8'haa;
            4'b0010: d=8'hcc;
            4'b0011: d=8'haa;
            4'b0100: d=8'hcc;
            4'b0101: d=8'haa;
            4'b0110: d=8'hcc;
            4'b0111: d=8'haa;
            4'b1000: d=8'hcc;
            4'b1001: d=8'haa;
            4'b1010: d=8'hcc;
            4'b1011: d=8'haa;
            4'b1100: d=8'hcc;
            4'b1101: d=8'haa;
            4'b1110: d=8'hcc;
            4'b1111: d=8'haa;
        endcase
    end
endmodule

module INTG (
    input clear,clock,
    output out
);
    wire [2:0] q;
    COUNTER_3BIT instance15(.clear(clear),.clock(clock),.q(q));
    wire clk;
    assign clk=q[0]&q[1]&q[2];
    wire [3:0] q2;
    wire [7:0]d;
    COUNTER_4BIT instance16(.clear(clear),.clock(clk),.q(q2));
    MEMORY instance17(.addr(q2),.d(d));
    MUX_BIG instance18(.sel(q),.in(d),.out(out));
endmodule

module testbench;
    reg clock,clear;
    wire out;
    INTG instance19(.clear(clear),.clock(clock),.out(out));
    initial begin
        clock=0;
        clear=0;
        forever #1 clock=~clock;
    end
    initial begin
        #1 clear=1;
        #10 $finish;
    end
    initial begin
        $monitor("time:%3d, clear:%b, out:%b, clock:%b",$time,clear,out,clock);
    end
endmodule