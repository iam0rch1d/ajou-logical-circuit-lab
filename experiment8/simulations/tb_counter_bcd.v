module tb_counter_bcd;
reg i_cp;
reg i_clr_;
wire [3:0] o_q;
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

counter_bcd dut(
    .clockpulse(i_cp),
    .clear_(i_clr_),
    .signal_q(o_q)
);

endmodule
