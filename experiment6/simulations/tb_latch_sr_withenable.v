module tb_latch_sr_withenable;
reg i_cp;
reg i_s;
reg i_r;
wire o_q;
wire o_q_;

initial begin
    i_cp = 1'b0;
    i_s = 1'b0;
    i_r = 1'b0;
    
    #100;  // 100ns
    i_cp = 1'b0;
    i_s = 1'b0;
    i_r = 1'b1;
        
    #100;  // 200ns
    i_cp = 1'b0;
    i_s = 1'b1;
    i_r = 1'b0;

    #100;  // 300ns
    i_cp = 1'b0;
    i_s = 1'b1;
    i_r = 1'b1;

    #100;  // 400ns
    i_cp = 1'b1;
    i_s = 1'b0;
    i_r = 1'b0;
    
    #100;  // 500ns
    i_cp = 1'b1;
    i_s = 1'b0;
    i_r = 1'b1;
        
    #100;  // 600ns
    i_cp = 1'b1;
    i_s = 1'b1;
    i_r = 1'b0;

    #100;  // 700ns
    i_cp = 1'b1;
    i_s = 1'b1;
    i_r = 1'b1;
end

latch_sr_withenable dut(
    .enable(i_cp),
    .set(i_s),
    .reset(i_r),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
