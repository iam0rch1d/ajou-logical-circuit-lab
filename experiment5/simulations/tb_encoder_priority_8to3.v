module tb_encoderPriority8To3;
reg i_ei_;
reg [7:0] i_d_;
wire [2:0] o_a_;
wire o_gs_;
wire o_eo_;
integer i;

initial begin
    i_ei_ = 1'b1;
    i_d_ = 8'hff;
    #1;

    for (i = 0; i <= 8'hff; i = i + 1) begin
        i_ei_ = 1'b0;
        i_d_ = i;
        #1;
    end
end

encoderPriority8To3 dut(
    .enable_in_(i_ei_),
    .signal_i_(i_d_),
    .signal_o_(o_a_),
    .group_signal_(o_gs_),
    .enable_out_(o_eo_)
);

endmodule
