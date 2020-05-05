module tb_counter_modulo3_sync;
reg i_cp;
reg i_clr_;
wire [1:0] o_q;
wire [1:0] o_q_;
integer i;

initial begin
    i_cp = 1'b0;
    i_clr_ = 1'b0;
    
    #10;
    i_clr_ = 1'b1;

    for (i = 0; i < 4'hf; i = i + 1) begin
        i_cp = 1'b1;
        
        #5;
        i_cp = 1'b0;

        #5;
    end
end

counter_modulo3_sync dut(
    .clockpulse(i_cp),
    .clear_(i_clr_),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
