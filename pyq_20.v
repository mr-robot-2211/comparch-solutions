module SR_ff(
    input clock,s,r,reset,
    output reg q
);
    always @(posedge clock) begin
        if(reset) q<=0;
        else begin
            case({s,r})
                2'b01: q<=0;
                2'b10: q<=1;
                2'b11: q<=1;
            endcase
        end
    end
endmodule

module D_ff(
    input clock,d,reset,
    output q
);
    wire a;
    SR_ff instance0(.reset(reset),.clock(clock),.s(d),.r(~d),.q(a));
    assign q=a;
endmodule

module Ripple_Counter(
    input clock,reset,
    output [3:0] out
);
    wire a,b,c,d;
    D_ff instance1(.reset(reset),.clock(clock),.d(~a),.q(a));
    D_ff instance2(.reset(reset),.clock(~a),.d(~b),.q(b));
    D_ff instance3(.reset(reset),.clock(~b),.d(~c),.q(c));
    D_ff instance4(.reset(reset),.clock(~c),.d(~d),.q(d));
    assign out={a,b,c,d};
endmodule

module MEM1(
    input [2:0] addr,
    output parity,
    output reg [7:0] data
);
    assign parity=1'b1;
    always @(*) begin
        case (addr)
            3'b000: data=00011111;
            3'b001: data=00110001;
            3'b010: data=01010011;
            3'b011: data=01110101;
            3'b100: data=10010111;
            3'b101: data=10111001;
            3'b110: data=11011011;
            3'b111: data=11111101;
        endcase
    end
endmodule

module MEM2(
    input [2:0] addr,
    output parity,
    output reg [7:0] data
);
    assign parity=1'b0;
    always @(*) begin
        case (addr)
            3'b000: data=00000000;
            3'b001: data=00100010;
            3'b010: data=01000100;
            3'b011: data=01100110;
            3'b100: data=10001000;
            3'b101: data=10101010;
            3'b110: data=11001100;
            3'b111: data=11101110;
        endcase
    end
endmodule

module MUX16TO8(
    input sel,
    input [7:0] d1,d2,
    output [7:0] data
);
    wire a,b,c,d,e,f,g,h;
    MUX2TO1 instance8(.out(a),.sel(sel),.p1(d1[0]),.p2(d2[0]));
    MUX2TO1 instance9(.out(b),.sel(sel),.p1(d1[1]),.p2(d2[1]));
    MUX2TO1 instance10(.out(c),.sel(sel),.p1(d1[2]),.p2(d2[2]));
    MUX2TO1 instance11(.out(d),.sel(sel),.p1(d1[3]),.p2(d2[3]));
    MUX2TO1 instance12(.out(e),.sel(sel),.p1(d1[4]),.p2(d2[4]));
    MUX2TO1 instance13(.out(f),.sel(sel),.p1(d1[5]),.p2(d2[5]));
    MUX2TO1 instance14(.out(g),.sel(sel),.p1(d1[6]),.p2(d2[6]));
    MUX2TO1 instance15(.out(h),.sel(sel),.p1(d1[7]),.p2(d2[7]));
    assign data={h,g,f,e,d,c,b,a};
endmodule

module MUX2TO1(
    input sel,
    input p1,p2,
    output reg out
);
    always @(*) begin
        case (sel)
            1'b0: out=p1;
            1'b1: out=p2;
        endcase
    end
endmodule

module Fetch_Data(
    input clock,reset,
    output parity,
    output [7:0] data
);
    wire [3:0] addr;
    wire p1,p2;
    wire [7:0]m,n;
    wire par;
    wire [7:0] final;
    Ripple_Counter instance5( .clock(clock),.reset(reset),.out(addr));
    MEM1 instance6(.addr(addr[2:0]),.parity(p1),.data(m));
    MEM2 instance7(.addr(addr[2:0]),.parity(p2),.data(n));
    MUX16TO8 instance16(.sel(addr[3]),.d1(m),.d2(n),.data(final));
    MUX2TO1 instance17(.sel(addr[3]),.p1(p1),.p2(p2),.out(par));
    assign data=final;
    assign par=parity;
endmodule

module Parity_Checker(
    input [7:0]data,
    input parity,
    output out
);
    wire x;
    assign x=data[7]+data[6]+data[5]+data[4]+data[3]+data[2]+data[1]+data[0];
    assign out=(x==1)?1:0;
endmodule

module testbench;
    reg clock;
    reg reset;
    wire parity;
    wire [7:0] data;
    wire out;
    wire [3:0]x;
    Fetch_Data instance18(.clock(clock),.reset(reset),.parity(parity),.data(data));
    Parity_Checker instance19(.data(data),.parity(parity),.out(out));
    Ripple_Counter instance20(.clock(clock),.reset(reset),.out(x));
    initial begin
        $dumpfile("pyq_20");
        $dumpvars;
        clock=0;
        forever #5 clock=~clock;
    end
    initial begin
        #5 reset=1;
        #10 reset=0;
        #50 $finish;
    end
    initial begin
        $monitor("time:%3d, counter=%h, parity:%b, data:%d, match:%b",$time,x,parity,data,out);
    end
endmodule
