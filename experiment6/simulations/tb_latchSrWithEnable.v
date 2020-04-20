module tb_latchSrWithEnable;
reg cp;
reg s;
reg r;
wire q;
wire notq;

initial begin
    cp = 1'b0;
    s = 1'b0;
    r = 1'b0;
    
    #100; // 100ns
    cp = 1'b0;
    s = 1'b0;
    r = 1'b1;
        
    #100; // 200ns
    cp = 1'b0;
    s = 1'b1;
    r = 1'b0;

    #100; // 300ns
    cp = 1'b0;
    s = 1'b1;
    r = 1'b1;

    #100; // 400ns
    cp = 1'b1;
    s = 1'b0;
    r = 1'b0;
    
    #100; // 500ns
    cp = 1'b1;
    s = 1'b0;
    r = 1'b1;
        
    #100; // 600ns
    cp = 1'b1;
    s = 1'b1;
    r = 1'b0;

    #100; // 700ns
    cp = 1'b1;
    s = 1'b1;
    r = 1'b1;

end

latchSrWithEnable dut(
    .enable(cp),
    .set(s),
    .reset(r),
    .out(q),
    .notout(notq)
    );

endmodule
