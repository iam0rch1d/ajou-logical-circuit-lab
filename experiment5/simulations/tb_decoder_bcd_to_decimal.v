module tb_decoder_bcd_to_decimal;
reg [3:0] i_sw;
wire [9:0] o_d_;
integer i;

initial begin
    for (i = 0; i < 4'hf; i = i + 1) begin
        i_sw = i;
        #10;
    end
end

decoder_bcd_to_decimal dut(
    .signal_i(i_sw),
    .signal_o_(o_d_)
);

endmodule
