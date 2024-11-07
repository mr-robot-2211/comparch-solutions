module d_ff (
    input d,clk,
    output reg q
);
    always @(posedge clk) begin
        q<=d;
    end
endmodule

module ControlLogic (
    input s,z,x,clk,
    output t0,t1,t2
);
    and a1(a1,t0,~s);
    and a2(a2,t2,z);
    and a3(a3,t0,s);
    and a4(a4,t2,~x,~z);
    and a5(a5,t1,~x);
    and a6(a6,t1,x);
    and a7(a7,t2,~z,x);
    or o1(o1,a1,a2);
    or o2(o2,a3,a4,a5);
    or o3(o3,a6,a7);
    d_ff ff1(.d(o1),.clk(clk),.q(t0));
    d_ff ff2(.d(o2),.clk(clk),.q(t1));
    d_ff ff3(.d(o3),.clk(clk),.q(t2));
endmodule

module TFF (
    input t,clk,clear,en,
    output reg q
);
    always @(posedge clk) begin
        if(clear) q<=0;
        else begin
            if(t&en) begin
                q<=~q;
            end
            else q<=q;
        end
    end
endmodule

module COUNTER_4BIT (
    input clear,clk,enable,
    output [3:0]q
);
    TFF tff1(.t(1'b1),.clk(clk),.clear(clear),.q(q[0]),.en(enable));
    TFF tff2(.t(q[0]),.clk(clk),.clear(clear),.q(q[1]),.en(enable));
    TFF tff3(.t(q[1]&q[0]),.clk(clk),.clear(clear),.q(q[2]),.en(enable));
    TFF tff4(.t(q[2]&q[1]&q[0]),.clk(clk),.clear(clear),.q(q[3]),.en(enable));
endmodule

module INTG(
    input s,clk,x,
    output g,
    output [3:0] q
);
    wire t0,t1,t2;
    and a(a,q[0],q[1],q[2],q[3]);
    COUNTER_4BIT c(.clear(t0&s),.clk(clk),.q(q),.enable((t1&x)|(t2&~a&x)));
    ControlLogic cl(.s(s),.z(a),.x(x),.clk(clk),.t0(t0),.t1(t1),.t2(t2));
    d_ff d(.d(a&t2),.clk(clk),.q(g));
endmodule

module testbench;
    reg s,clk,x;
    wire g;
    wire [3:0] q;
    INTG i(.s(s),.clk(clk),.x(x),.g(g),.q(q));
    initial begin
        s=1;
        x=1;
        clk=0;
        forever #1 clk=~clk;
    end
    initial begin
        #50 $finish;
    end
    initial begin
        $monitor("time:%3d, clock:%b, s:%b, x:%b, g:%b, q:%3b",$time,clk,s,x,g,q);
    end
endmodule