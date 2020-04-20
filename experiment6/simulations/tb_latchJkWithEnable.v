module tb_latchJkWithEnable;
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
    cp = 1'b0;
    j = 1'b0;
    k = 1'b1;
        
    #100; // 200ns
    cp = 1'b0;
    j = 1'b1;
    k = 1'b0;

    #100; // 300ns
    cp = 1'b0;
    j = 1'b1;
    k = 1'b1;

    #100; // 400ns
    cp = 1'b1;
    j = 1'b0;
    k = 1'b0;
    
    #100; // 500ns
    cp = 1'b1;
    j = 1'b0;
    k = 1'b1;
        
    #100; // 600ns
    cp = 1'b1;
    j = 1'b1;
    k = 1'b0;

    #100; // 700ns
    cp = 1'b1;
    j = 1'b1;
    k = 1'b1;

end

latchJkWithEnable dut(
    .enable(cp),
    .jack(j),
    .kilby(k),
    .out(q),
    .notout(notq)
    );

endmodule
