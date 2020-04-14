module tb_encoderDecimalToBcdForBasicGates;
reg [9:0] sw;
wire [3:0] y;

initial begin
    sw = 10'b00_0000_0001;
    
    #100;
    sw = 10'b00_0000_0010;
        
    #100;
    sw = 10'b00_0000_0100;

    #100;
    sw = 10'b00_0000_1000;

    #100;
    sw = 10'b00_0001_0000;

    #100;
    sw = 10'b00_0010_0000;

    #100;
    sw = 10'b00_0100_0000;
        
    #100;
    sw = 10'b00_1000_0000;

    #100;
    sw = 10'b01_0000_0000;

    #100;
    sw = 10'b10_0000_0000;
end

encoderDecimalToBcdForBasicGates dut(
    .in(sw),
    .out(y)
    );

endmodule
