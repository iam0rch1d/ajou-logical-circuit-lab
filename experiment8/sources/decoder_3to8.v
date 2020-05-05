module decoder_3to8(
    input [2:0] signal_i,
    output [7:0] signal_o
);

assign signal_o[0] = signal_i[2] & ~signal_i[1] & ~signal_i[0];
assign signal_o[1] = signal_i[2] & ~signal_i[1] & signal_i[0];
assign signal_o[2] = signal_i[2] & signal_i[1] & ~signal_i[0];
assign signal_o[3] = signal_i[2] & signal_i[1] & signal_i[0];
assign signal_o[4] = ~signal_i[2] & ~signal_i[1] & ~signal_i[0];
assign signal_o[5] = ~signal_i[2] & ~signal_i[1] & signal_i[0];
assign signal_o[6] = ~signal_i[2] & signal_i[1] & ~signal_i[0];
assign signal_o[7] = ~signal_i[2] & signal_i[1] & signal_i[0];

endmodule
