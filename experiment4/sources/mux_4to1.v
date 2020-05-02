module mux_4to1 (
    input enable_,
    input [1:0] signal_i,
    input [3:0] data,
    output signal_o
);

wire w_u1a;
wire w_u1b;
wire w_u2a;
wire w_u2b;

assign w_u1a = ~(~signal_i[1] & ~signal_i[0] & ~enable_ & data[0]);
assign w_u1b = ~(~signal_i[1] & signal_i[0] & ~enable_ & data[1]);
assign w_u2a = ~(signal_i[1] & ~signal_i[0] & ~enable_ & data[2]);
assign w_u2b = ~(signal_i[1] & signal_i[0] & ~enable_ & data[3]);
assign signal_o = ~(w_u1a & w_u1b & w_u2a & w_u2b);

endmodule
