module tb_mux4;
reg e;
reg [1:0] s;
reg [3:0] d;
wire y;

initial begin
    e = 1'b0;
    s = 2'b00;
    d = 4'b1110;
    
    #100;
    e = 1'b0;
    s = 2'b00;
    d = 4'b0001;
        
    #100;
    e = 1'b0;
    s = 2'b01;
    d = 4'b1101;

    #100;
    e = 1'b0;
    s = 2'b01;
    d = 4'b0010;

    #100;
    e = 1'b0;
    s = 2'b10;
    d = 4'b1011;

    #100;
    e = 1'b0;
    s = 2'b10;
    d = 4'b0100;       

    #100;
    e = 1'b0;
    s = 2'b11;
    d = 4'b0111;
    
    #100;
    e = 1'b0;
    s = 2'b11;
    d = 4'b1000;
end

mux4 dut(
    .enable(e),
    .signal(s),
    .data(d),
    .y(y)
    );

endmodule
