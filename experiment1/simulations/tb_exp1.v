module tb_exp1;
reg a, b, c;
wire l1, l2, x, y, z;

initial begin
    a = 1'b0;
    b = 1'b0;
    c = 1'b0;
    
    #100;
    a = 1'b0;
    b = 1'b0;
    c = 1'b1;
        
    #100;
    a = 1'b0;
    b = 1'b1;
    c = 1'b0;

    #100;
    a = 1'b0;
    b = 1'b1;
    c = 1'b1;

    #100;
    a = 1'b1;
    b = 1'b0;
    c = 1'b0;

    #100;
    a = 1'b1;
    b = 1'b0;
    c = 1'b1;        

    #100;
    a = 1'b1;
    b = 1'b1;
    c = 1'b0;

    #100;
    a = 1'b1;
    b = 1'b1;
    c = 1'b1;
end

exp1 dut(.taskMode(1'bxx), .subtaskMode(2'bxx), .a(a), .b(b), .c(c), .l1(l1), .l2(l2), .x(x), .y(y), .z(z));

endmodule
