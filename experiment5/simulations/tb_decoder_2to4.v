module tb_decoder_2to4;
reg [1:0] i_sw;
wire [3:0] o_d;

initial begin
    i_sw = 2'b00;
    
    #100;
    i_sw = 2'b01;
        
    #100;
    i_sw = 2'b10;

    #100;
    i_sw = 2'b11;
end

decoder_2to4 dut(
    .signal_i(i_sw),
    .signal_o(o_d)
);

endmodule
