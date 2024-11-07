module MUX_2x1 (
    input a,b,sel,
    output out
);
    assign out=(sel)?b:a;
endmodule

module MUX_8x1 (
    input [7:0] in,
    input [2:0] sel,
    output out
);
    assign out=in[sel];
endmodule

module MUX_ARRAY (
    input [7:0] c,g,
    output [7:0] e
);
    generate
        genvar i;
        for(i=0;i<8;i=i+1)begin: mux_gen
            MUX_2x1 instance0(.a(1'b0),.b(c[i]),.sel(g[i]),.out(e[i]));
        end
    endgenerate
endmodule

module COUNTER_3BIT (
    input clear,clock,
    output reg [2:0] q
);
    always @(posedge clock or posedge clear ) begin
        if(clear) q<=3'b000;
        else q<=q+1;
    end
endmodule

module DECODER (
    input [2:0] a,
    input enable,
    output reg [7:0] out
);
    always @(*) begin
        if(enable) begin
            case (a)
                3'b000: out=8'b00000001;
                3'b001: out=8'b00000010;
                3'b010: out=8'b00000100;
                3'b011: out=8'b00001000;
                3'b100: out=8'b00010000;
                3'b101: out=8'b00100000;
                3'b110: out=8'b01000000;
                3'b111: out=8'b10000000;
            endcase
        end
        else begin
            out=8'b00000000;
        end
    end
endmodule

module MEMORY (
    input [2:0] addr,
    output reg [7:0] out
);
    always @(*) begin
         case (addr)
            3'b000: out=8'h01;
            3'b001: out=8'h03;
            3'b010: out=8'h07;
            3'b011: out=8'h0f;
            3'b100: out=8'h1f;
            3'b101: out=8'h3f;
            3'b110: out=8'h7f;
            3'b111: out=8'hff; 
         endcase
    end
endmodule

module TOP_MODULE (
    input [2:0] addr,
    input clock,clear,enable,
    output out
);
    wire [7:0]g,c,e;
    wire [2:0]q;
    MEMORY instance1(.addr(addr),.out(g));
    COUNTER_3BIT instance2(.clock(clock),.clear(clear),.q(q));
    DECODER instance3(.a(q),.enable(enable),.out(c));
    MUX_ARRAY instance4 (.c(c),.g(g),.e(e));
    MUX_8x1 instance5(.in(e),.sel(q),.out(out));
endmodule

module testbench;
    reg clock,clear,enable;
    reg [2:0] addr;
    wire out;
    TOP_MODULE instance6(.addr(addr),.clock(clock),.clear(clear),.enable(enable),.out(out));
    initial begin
        enable=1;
        clear=1;
        clock=0;
        addr=3'b000;
        forever #5 clock=~clock;
    end
    initial begin
        #0;clear=0;
        forever #8 addr=addr+1;
    end
    initial begin
        #100 $finish;
    end
    initial begin
        $monitor("time:%3d, address:%3b, enable=%b, output:%b",$time,addr,enable,out);
    end
endmodule

// module testbench;
//     reg clock,clear,enable;
//     reg [2:0] addr;
//     wire out;
//     TOP_MODULE instance6(.addr(addr),.clock(clock),.clear(clear),.enable(enable),.out(out));
//     initial begin
//         clear=1;
//         clock=0;
//         addr=3'b000;
//         forever #0.0005 clock=~clock;
//     end
//     initial begin
//         #0;clear=0;
//         forever #0.0008 addr=addr+1;
//     end
//     initial begin
//         #10 $finish;
//     end
//     initial begin
//         $monitor("time:%3d, address:%3b, output:%b",$time,addr,out);
//     end
// endmodule