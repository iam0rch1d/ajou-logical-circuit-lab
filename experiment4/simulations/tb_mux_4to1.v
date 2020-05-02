module tb_mux_4to1;
reg i_en_;
reg [1:0] i;
reg [3:0] i_d;
wire o;

initial begin
    i_en_ = 1'b0;
    i = 2'b00;
    i_d = 4'b1110;
    
    #100; // 100ns
    i_en_ = 1'b0;
    i = 2'b00;
    i_d = 4'b0001;
        
    #100; // 200ns
    i_en_ = 1'b0;
    i = 2'b01;
    i_d = 4'b1101;

    #100; // 300ns
    i_en_ = 1'b0;
    i = 2'b01;
    i_d = 4'b0010;

    #100; // 400ns
    i_en_ = 1'b0;
    i = 2'b10;
    i_d = 4'b1011;

    #100; // 500ns
    i_en_ = 1'b0;
    i = 2'b10;
    i_d = 4'b0100;       

    #100; // 600ns
    i_en_ = 1'b0;
    i = 2'b11;
    i_d = 4'b0111;
    
    #100; // 700ns
    i_en_ = 1'b0;
    i = 2'b11;
    i_d = 4'b1000;
end

mux_4to1 dut(
    .enable_(i_en_),
    .signal_i(i),
    .data(i_d),
    .signal_o(o)
);

endmodule
