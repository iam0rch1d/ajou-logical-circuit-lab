module tb_latchDWithEnable;
reg cp;
reg d;
wire q;
wire notq;

initial begin
    cp = 1'b0;
    d = 1'b0;
    
    #100; // 100ns
    cp = 1'b0;
    d = 1'b1;

    #100; // 200ns
    cp = 1'b1;
    d = 1'b0;
    
    #100; // 300ns
    cp = 1'b1;
    d = 1'b1;
end

latchDWithEnable dut(
    .enable(cp),
    .data(d),
    .out(q),
    .notout(notq)
    );

endmodule
