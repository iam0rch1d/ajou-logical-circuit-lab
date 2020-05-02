module encoder_decimal_to_excess3 (
    input [5:0] signal_i,
    output [3:0] signal_o
);

assign signal_o[0] = signal_i[0] | signal_i[2] | signal_i[4];
assign signal_o[1] = signal_i[0] | signal_i[3] | signal_i[4];
assign signal_o[2] = signal_i[1] | signal_i[2] | signal_i[3] | signal_i[4];
assign signal_o[3] = signal_i[5];

endmodule
