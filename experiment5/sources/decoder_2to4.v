module decoder_2to4(
    input [1:0] signal_i,
    output [3:0] signal_o
);

assign signal_o[0] = ~signal_i[1] & ~signal_i[0];
assign signal_o[1] = ~signal_i[1] & signal_i[0];
assign signal_o[2] = signal_i[1] & ~signal_i[0];
assign signal_o[3] = signal_i[1] & signal_i[0];

endmodule
