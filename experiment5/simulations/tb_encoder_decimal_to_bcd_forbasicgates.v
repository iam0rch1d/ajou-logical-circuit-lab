module tb_encoder_decimal_to_bcd_forbasicgates;
reg [9:0] i_sw;
wire [3:0] o_d;

initial begin
    i_sw = 10'b00_0000_0001;
    
    #100;
    i_sw = 10'b00_0000_0010;
        
    #100;
    i_sw = 10'b00_0000_0100;

    #100;
    i_sw = 10'b00_0000_1000;

    #100;
    i_sw = 10'b00_0001_0000;

    #100;
    i_sw = 10'b00_0010_0000;

    #100;
    i_sw = 10'b00_0100_0000;
        
    #100;
    i_sw = 10'b00_1000_0000;

    #100;
    i_sw = 10'b01_0000_0000;

    #100;
    i_sw = 10'b10_0000_0000;
end

encoder_decimal_to_bcd_forbasicgates dut(
    .signal_i(i_sw),
    .signal_o(o_d)
);

endmodule
