module tb_encoderPriority8To3;
reg ei;
reg [7:0] d;
wire [2:0] a;
wire gs;
wire eo;
integer i;

initial begin
    ei = 1'b1;
    d = 8'hff;
    #1;

    for (i = 0; i <= 8'hff; i = i + 1) begin
        ei = 1'b0;
        d = i;
        #1;
    end
end

encoderPriority8To3 dut(
    .enableIn(ei),
    .in(d),
    .out(a),
    .groupSignal(gs),
    .enableOut(eo)
    );

endmodule
