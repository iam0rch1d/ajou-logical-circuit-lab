module tb_latch_d_withenable;
reg i_cp;
reg i_d;
wire o_q;
wire o_q_;

initial begin
    i_cp = 1'b0;
    i_d = 1'b0;
    
    #100;  // 100ns
    i_cp = 1'b0;
    i_d = 1'b1;

    #100;  // 200ns
    i_cp = 1'b1;
    i_d = 1'b0;
    
    #100;  // 300ns
    i_cp = 1'b1;
    i_d = 1'b1;
end

latch_d_withenable dut(
    .enable(i_cp),
    .data(i_d),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
