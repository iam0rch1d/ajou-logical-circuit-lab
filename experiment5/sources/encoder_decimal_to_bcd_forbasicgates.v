module encoder_decimal_to_bcd_forbasicgates(
    input [9:0] signal_i,
    output [3:0] signal_o
);

assign signal_o[0] = signal_i[1] | signal_i[3] | signal_i[5] | signal_i[7] | signal_i[9];
assign signal_o[1] = signal_i[2] | signal_i[3] | signal_i[6] | signal_i[7];
assign signal_o[2] = signal_i[4] | signal_i[5] | signal_i[6] | signal_i[7];
assign signal_o[3] = signal_i[8] | signal_i[9];

endmodule
