module tb_exp1;
reg i_a;
reg i_b;
reg i_c;
wire o_l1;
wire o_l2;
wire o_x;
wire o_y;
wire o_z;

initial begin
    i_a = 1'b0;
    i_b = 1'b0;
    i_c = 1'b0;
    
    #100;  // 100ns
    i_a = 1'b0;
    i_b = 1'b0;
    i_c = 1'b1;
        
    #100;  // 200ns
    i_a = 1'b0;
    i_b = 1'b1;
    i_c = 1'b0;

    #100;  // 300ns
    i_a = 1'b0;
    i_b = 1'b1;
    i_c = 1'b1;

    #100;  // 400ns
    i_a = 1'b1;
    i_b = 1'b0;
    i_c = 1'b0;

    #100;  // 500ns
    i_a = 1'b1;
    i_b = 1'b0;
    i_c = 1'b1;        

    #100;  // 600ns
    i_a = 1'b1;
    i_b = 1'b1;
    i_c = 1'b0;

    #100;  // 700ns
    i_a = 1'b1;
    i_b = 1'b1;
    i_c = 1'b1;
end

exp1 dut(.mode_task(1'bx),  // ** MODIFY HERE **
         .mode_subtask(2'bxx), // ** MODIFY HERE **
         .signal_a(i_a),
         .signal_b(i_b),
         .signal_c(i_c),
         .signal_l1(o_l1),
         .signal_l2(o_l2),
         .signal_x(o_x),
         .signal_y(o_y),
         .signal_z(o_z)
);

endmodule
