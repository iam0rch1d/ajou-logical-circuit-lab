module tb_decoder2To4;
reg [1:0] sw;
wire [3:0] d;

initial begin
    sw = 2'b00;
    
    #100;
    sw = 2'b01;
        
    #100;
    sw = 2'b10;

    #100;
    sw = 2'b11;
end

decoder2To4 dut(
    .in(sw),
    .out(d)
    );

endmodule
