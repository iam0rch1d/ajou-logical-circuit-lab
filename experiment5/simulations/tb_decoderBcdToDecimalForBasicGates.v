module tb_decoderBcdToDecimalForBasicGates;
reg [3:0] sw;
wire [9:0] y;
integer i;

initial begin
    for (i = 0; i <= 4'hf; i = i + 1) begin
        sw = i;
        #10;
    end
end

decoderBcdToDecimalForBasicGates dut(
    .in(sw),
    .out(y)
);

endmodule
