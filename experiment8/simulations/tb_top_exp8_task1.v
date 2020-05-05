module tb_top_exp8_task1;
reg i_cp;
reg i_clr_;
wire [1:0] o_q;
wire [3:0] o_d;
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

top_exp8_task1 dut(
    .clockpulse(i_cp),
    .clear_(i_clr_),
    .counter_out(o_q),
    .decoder_out(o_d)
);

endmodule
