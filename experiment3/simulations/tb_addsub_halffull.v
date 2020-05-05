module tb_addsub_halffull;
reg i_a;
reg i_b;
reg i_cbi;
wire o_cbo;
wire o_sd;

initial begin
    i_a = 1'b0;
    i_b = 1'b0;
    i_cbi = 1'b0;
    
    #100; // 100ns
    i_a = 1'b0;
    i_b = 1'b0;
    i_cbi = 1'b1;
        
    #100; // 200ns
    i_a = 1'b0;
    i_b = 1'b1;
    i_cbi = 1'b0;

    #100; // 300ns
    i_a = 1'b0;
    i_b = 1'b1;
    i_cbi = 1'b1;

    #100; // 400ns
    i_a = 1'b1;
    i_b = 1'b0;
    i_cbi = 1'b0;

    #100; // 500ns
    i_a = 1'b1;
    i_b = 1'b0;
    i_cbi = 1'b1;       

    #100; // 600ns
    i_a = 1'b1;
    i_b = 1'b1;
    i_cbi = 1'b0;
    
    #100; // 700ns
    i_a = 1'b1;
    i_b = 1'b1;
    i_cbi = 1'b1;
end

addsub_halffull dut(
    .mode_addsub(1'bx), // ** MODIFY HERE **
    .mode_halffull(1'bx), // ** MODIFY HERE **
    .signal_a(i_a),
    .signal_b(i_b),
    .carryborrow_in(i_cbi),
    .carryborrow_out(o_cbo),
    .sumdiff(o_sd)
);

endmodule
