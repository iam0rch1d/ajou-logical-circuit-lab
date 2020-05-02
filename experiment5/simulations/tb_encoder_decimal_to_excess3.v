module tb_encoder_decimal_to_excess3;
reg [5:0] i_sw;
wire [3:0] o_y;

initial begin
    i_sw = 6'b00_0001;
    
    #100;
    i_sw = 6'b00_0010;
        
    #100;
    i_sw = 6'b00_0100;

    #100;
    i_sw = 6'b00_1000;

    #100;
    i_sw = 6'b01_0000;
        
    #100;
    i_sw = 6'b10_0000;
end

encoder_decimal_to_excess3 dut(
    .in(i_sw),
    .out(o_y)
);

endmodule
