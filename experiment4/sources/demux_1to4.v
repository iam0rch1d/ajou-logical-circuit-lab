module demux_1to4 (
    input data,
    input [1:0] signal_i,
    output [3:0] signal_o
);

signal_o[0] = ~signal_i[1] & ~signal_i[0] & data;
signal_o[1] = ~signal_i[1] & signal_i[0] & data;
signal_o[2] = signal_i[1] & ~signal_i[0] & data;
signal_o[3] = signal_i[1] & signal_i[0] & data;

endmodule
