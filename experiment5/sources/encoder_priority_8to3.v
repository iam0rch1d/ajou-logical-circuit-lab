module encoder_priority_8to3 (
    input enable_in_,
    input [7:0] signal_i_,
    output [2:0] signal_o_,
    output group_signal_,
    output enable_out_
);

wire [3:0] w_minterm0;
wire [3:0] w_minterm1;
wire [3:0] w_minterm2;
wire w_enable_out;

assign w_minterm0[0] = ~enable_in_ & signal_i_[6] & signal_i_[4] & signal_i_[2] & ~signal_i_[1];
assign w_minterm0[1] = ~enable_in_ & signal_i_[6] & signal_i_[4] & ~signal_i_[3];
assign w_minterm0[2] = ~enable_in_ & signal_i_[6] & ~signal_i_[5];
assign w_minterm0[3] = ~enable_in_ & ~signal_i_[7];

assign w_minterm1[0] = ~enable_in_ & signal_i_[5] & signal_i_[4] & ~signal_i_[2];
assign w_minterm1[1] = ~enable_in_ & signal_i_[5] & signal_i_[4] & ~signal_i_[3];
assign w_minterm1[2] = ~enable_in_ & ~signal_i_[6];
assign w_minterm1[3] = ~enable_in_ & ~signal_i_[7];

assign w_minterm2[0] = ~enable_in_ & ~signal_i_[4];
assign w_minterm2[1] = ~enable_in_ & ~signal_i_[5];
assign w_minterm2[2] = ~enable_in_ & ~signal_i_[6];
assign w_minterm2[3] = ~enable_in_ & ~signal_i_[7];

assign signal_o_[0] = ~(w_minterm0[0] | w_minterm0[1] | w_minterm0[2] | w_minterm0[3]);
assign signal_o_[1] = ~(w_minterm1[0] | w_minterm1[1] | w_minterm1[2] | w_minterm1[3]);
assign signal_o_[2] = ~(w_minterm2[0] | w_minterm2[1] | w_minterm2[2] | w_minterm2[3]);

assign enable_out_ = ~enable_in_ & signal_i_[7] & signal_i_[6] & signal_i_[5] & signal_i_[4] & signal_i_[3] & signal_i_[2] & signal_i_[1] & signal_i_[0];

assign w_enable_out = enable_out_;
assign group_signal_ = enable_in_ & ~w_enable_out;

endmodule
