module tb_flipflop_jk;
reg i_cp;
reg i_j;
reg i_k;
wire o_q;
wire o_q_;

initial begin
    i_cp = 1'b0;
    i_j = 1'b0;
    i_k = 1'b0;
    
    #100;  // 100ns
    i_cp = 1'b1;
    i_j = 1'b0;
    i_k = 1'b0;

    #50;  // 150ns
    i_cp = 1'b0;

    #50;  // 200ns
    i_cp = 1'b1;
    i_j = 1'b0;
    i_k = 1'b1;
    
    #50;  // 250ns
    i_cp = 1'b0;

    #50;  // 300ns
    i_cp = 1'b1;
    i_j = 1'b1;
    i_k = 1'b0;

    #50;  // 350ns
    i_cp = 1'b0;

    #50;  // 400ns
    i_cp = 1'b1;
    i_j = 1'b1;
    i_k = 1'b1;
    
    #50;  // 450ns
    i_cp = 1'b0;
end

flipflop_jk dut(
    .clockpulse(i_cp),
    .preset(1'b1),
    .clear(1'b0),
    .jack(i_j),
    .kilby(i_k),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
