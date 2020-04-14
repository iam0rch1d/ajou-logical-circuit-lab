module tb_mux4To1;
reg d;
reg [1:0] s;
wire [3:0] y;

initial begin
    d = 1'b1;
    s = 2'b00;
    
    #100;
    d = 1'b1;
    s = 2'b01;
        
    #100;
    d = 1'b1;
    s = 2'b10;

    #100;
    d = 1'b1;
    s = 2'b11;
end

demux4 dut(
    .data(d),
    .signal(s),
    .y(y)
    );

endmodule
