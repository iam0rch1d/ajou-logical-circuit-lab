module tb_flipflopD;
reg i_cp;
reg i_d;
wire o_q;
wire o_q_;

initial begin
    i_cp = 1'b0;
    i_d = 1'b0;
    
    #100;  // 100ns
    i_cp = 1'b1;
    i_d = 1'b0;

    #50;  // 150ns
    i_cp = 1'b0;

    #50;  // 200ns
    i_cp = 1'b1;
    i_d = 1'b1;
    
    #50;  // 250ns
    i_cp = 1'b0;

    #50;  // 300ns
    i_cp = 1'b1;
    i_d = 1'b0;

    #20;  // 320ns
    i_d = 1'b1;

    #20;  // 340ns
    i_d = 1'b0;

    #10;  // 350ns
    i_cp = 1'b0;

    #20;  // 370ns
    i_d = 1'b1;

    #20;  // 390ns
    i_d = 1'b0;

    #10;  // 400ns
    i_cp = 1'b1;
    i_d = 1'b1;
    
    #20;  // 420ns
    i_d = 1'b0;

    #20;  // 440ns
    i_d = 1'b1;

    #10;  // 450ns
    i_cp = 1'b0;

    #20;  // 470ns
    i_d = 1'b0;

    #20;  // 490ns
    i_d = 1'b1;
end

flipflop_d dut(
    .clockpulse(i_cp),
    .preset(1'b1),
    .clear(1'b0),
    .data(i_d),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
