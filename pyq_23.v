module jkff (
    input j,k,clock,
    output reg q
);
     always @(negedge clock) begin
        if(q==0)begin
            if(j==0)begin
                q<=0;        
            end
            else begin
                q<=1;
            end
        end
        else begin
            if(k==0)begin
                q<=1;        
            end
            else begin
                q<=0;
            end
        end
     end
endmodule

module BCD_Counter (
    output [3:0] Q_out,
    input clk
);
    and a0(q1q2,Q_out[1],Q_out[2]);
    jkff ff1(.j(1'b1),.k(1'b1),.clock(clk),.q(Q_out[0]));
    jkff ff2(.j(~Q_out[3]),.k(1'b1),.clock(Q_out[0]),.q(Q_out[1]));
    jkff ff3(.j(1'b1),.k(1'b1),.clock(Q_out[1]),.q(Q_out[2]));
    jkff ff4(.j(q1q2),.k(1'b1),.clock(Q_out[0]),.q(Q_out[3]));
endmodule

module MEM_16 (
    input [3:0] A_4,
    output reg [15:0] D_16
);
    always @(*) begin
        case (A_4)
            4'b0000: D_16=16'h0001;
            4'b0001: D_16=16'h0002;
            4'b0010: D_16=16'h0004;
            4'b0011: D_16=16'h0008;
            4'b0100: D_16=16'h0010;
            4'b0101: D_16=16'h0020;
            4'b0110: D_16=16'h0000;
            4'b0111: D_16=16'h0000;
            4'b1000: D_16=16'h0000;
            4'b1001: D_16=16'h0000;
            4'b1010: D_16=16'h0400;
            4'b1011: D_16=16'h0800;
            4'b1100: D_16=16'h1000;
            4'b1101: D_16=16'h0000;
            4'b1110: D_16=16'h0000;
            4'b1111: D_16=16'h0000;
        endcase
    end
endmodule

module MUX_16 (
    input [3:0] S_4,
    input [15:0] I_16,
    output reg O
);
    always @(*) begin
        case (S_4)
            4'b0000: O=I_16[0];
            4'b0001: O=I_16[1];
            4'b0010: O=I_16[2];
            4'b0011: O=I_16[3];
            4'b0100: O=I_16[4];
            4'b0101: O=I_16[5];
            4'b0110: O=I_16[6];
            4'b0111: O=I_16[7];
            4'b1000: O=I_16[8];
            4'b1001: O=I_16[9];
            4'b1010: O=I_16[10];
            4'b1011: O=I_16[11];
            4'b1100: O=I_16[12];
            4'b1101: O=I_16[13];
            4'b1110: O=I_16[14];
            4'b1111: O=I_16[15];
        endcase
    end
endmodule

module INTG (
    input CLK,
    output OUT
);
    wire [3:0] q;
    wire [15:0] d;
    BCD_Counter in1(.clk(CLK),.Q_out(q));
    MEM_16 in2(.D_16(d),.A_4(q));
    MUX_16 in3(.O(OUT),.I_16(d),.S_4(q));
endmodule

module testbench;
    reg clock;
    wire out;
    INTG c(.CLK(clock),.OUT(out));
    initial begin
        clock=0;
        forever #1 clock=~clock;
    end
    initial begin
        #22 $finish;
    end
    initial begin
        $monitor("time:%3d, output:%b, clock:%b",$time,out,clock);
    end
endmodule