module tb_shiftregister_right6;
reg i_cp;
reg i_clr;
reg i_pe;
wire [5:0] o_q;
wire [5:0] o_q_;
integer i;

initial begin
    i_cp = 1'b0;
    i_clr = 1'b1;
    i_pe = 1'b0;
    i = 0;
    
    #10;
    i_clr = 1'b0;
    
    for (i = 0; i < 4'hf; i = i + 1) begin
        if (i == 0) begin
            i_pe = 1'b1;
        end
        
        i_cp = 1'b1;
        
        #5;
        i_cp = 1'b0;
        i_pe = 1'b0;
        
        #5;
    end
end

shiftregister_right6 dut(
    .clockpulse(i_cp),
    .clear(i_clr),
    .serial_input(1'b0),
    .preset_enable(i_pe),
    .preset(6'b110000),
    .signal_q(o_q),
    .signal_q_(o_q_)
);

endmodule
