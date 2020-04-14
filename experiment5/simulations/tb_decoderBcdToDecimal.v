module tb_decoderBcdToDecimal;
reg [3:0] sw;
wire [9:0] y;
integer i;

initial begin
    for (i = 0; i < 4'hf; i = i + 1) begin
        sw = i;
        #10;
    end
end

decoderBcdToDecimal dut(
    .in(sw),
    .out(y)
    );

endmodule
