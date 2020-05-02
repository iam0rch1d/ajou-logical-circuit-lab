module tb_demux_4to1;
reg i_d;
reg [1:0] i;
wire [3:0] o;

initial begin
    i_d = 1'b1;
    i = 2'b00;
    
    #100; // 100ns
    i_d = 1'b1;
    i = 2'b01;
        
    #100; // 200ns
    i_d = 1'b1;
    i = 2'b10;

    #100; // 300ns
    i_d = 1'b1;
    i = 2'b11;
end

demux_4to1 dut(
    .data(i_d),
    .signal_i(i),
    .signal_o(o)
);

endmodule
