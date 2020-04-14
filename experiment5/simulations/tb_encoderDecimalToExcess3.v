module tb_encoderDecimalToExcess3;
reg [5:0] sw;
wire [3:0] y;

initial begin
    sw = 6'b00_0001;
    
    #100;
    sw = 6'b00_0010;
        
    #100;
    sw = 6'b00_0100;

    #100;
    sw = 6'b00_1000;

    #100;
    sw = 6'b01_0000;
        
    #100;
    sw = 6'b10_0000;
end

encoderDecimalToExcess3 dut(
    .in(sw),
    .out(y)
    );

endmodule
