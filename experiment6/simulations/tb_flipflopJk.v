module tb_flipflopJk;
reg cp;
reg j;
reg k;
wire q;
wire notq;

initial begin
    cp = 1'b0;
    j = 1'b0;
    k = 1'b0;
    
    #100; // 100ns
    cp = 1'b1;
    j = 1'b0;
    k = 1'b0;

    #50; // 150ns
    cp = 1'b0;

    #50; // 200ns
    cp = 1'b1;
    j = 1'b0;
    k = 1'b1;
    
    #50; // 250ns
    cp = 1'b0;

    #50; // 300ns
    cp = 1'b1;
    j = 1'b1;
    k = 1'b0;

    #50; // 350ns
    cp = 1'b0;

    #50; // 400ns
    cp = 1'b1;
    j = 1'b1;
    k = 1'b1;
    
    #50; // 450ns
    cp = 1'b0;
end

flipflopJk dut(
    .clockpulse(cp),
    .preset(1'b1),
    .clear(1'b0),
    .jack(j),
    .kilby(k),
    .out(q),
    .notout(notq)
    );

endmodule
