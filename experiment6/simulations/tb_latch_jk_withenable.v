module tb_latch_jk_withenable;
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
    i_cp = 1'b0;
    i_j = 1'b0;
    i_k = 1'b1;
        
    #100;  // 200ns
    i_cp = 1'b0;
    i_j = 1'b1;
    i_k = 1'b0;

    #100;  // 300ns
    i_cp = 1'b0;
    i_j = 1'b1;
    i_k = 1'b1;

    #100;  // 400ns
    i_cp = 1'b1;
    i_j = 1'b0;
    i_k = 1'b0;
    
    #100;  // 500ns
    i_cp = 1'b1;
    i_j = 1'b0;
    i_k = 1'b1;
        
    #100;  // 600ns
    i_cp = 1'b1;
    i_j = 1'b1;
    i_k = 1'b0;

    #100;  // 700ns
    i_cp = 1'b1;
    i_j = 1'b1;
    i_k = 1'b1;
end

latch_jk_withenable dut(
    .enable(i_cp),
    .jack(i_j),
    .kilby(i_k),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
