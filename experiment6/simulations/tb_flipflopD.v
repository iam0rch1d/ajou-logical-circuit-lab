module tb_flipflopD;
reg cp;
reg d;
wire q;
wire notq;

initial begin
    cp = 1'b0;
    d = 1'b0;
    
    #100; // 100ns
    cp = 1'b1;
    d = 1'b0;

    #50; // 150ns
    cp = 1'b0;

    #50; // 200ns
    cp = 1'b1;
    d = 1'b1;
    
    #50; // 250ns
    cp = 1'b0;

    #50; // 300ns
    cp = 1'b1;
    d = 1'b0;

    #20; // 320ns
    d = 1'b1;

    #20; // 340ns
    d = 1'b0;

    #10; // 350ns
    cp = 1'b0;

    #20; // 370ns
    d = 1'b1;

    #20; // 390ns
    d = 1'b0;

    #10; // 400ns
    cp = 1'b1;
    d = 1'b1;
    
    #20; // 420ns
    d = 1'b0;

    #20; // 440ns
    d = 1'b1;

    #10; // 450ns
    cp = 1'b0;

    #20; // 470ns
    d = 1'b0;

    #20; // 490ns
    d = 1'b1;

end

flipflopD dut(
    .clockpulse(cp),
    .preset(1'b1),
    .clear(1'b0),
    .data(d),
    .out(q),
    .notout(notq)
    );

endmodule
