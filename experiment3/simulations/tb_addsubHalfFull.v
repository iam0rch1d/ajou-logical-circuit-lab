module tb_addsubHalfFull;
reg a, b, carryborrowIn;
wire carryborrowOut, sumdiff;

initial begin
    a = 1'b0;
    b = 1'b0;
    carryborrowIn = 1'b0;
    
    #100;
    a = 1'b0;
    b = 1'b0;
    carryborrowIn = 1'b1;
        
    #100;
    a = 1'b0;
    b = 1'b1;
    carryborrowIn = 1'b0;

    #100;
    a = 1'b0;
    b = 1'b1;
    carryborrowIn = 1'b1;

    #100;
    a = 1'b1;
    b = 1'b0;
    carryborrowIn = 1'b0;

    #100;
    a = 1'b1;
    b = 1'b0;
    carryborrowIn = 1'b1;       

    #100;
    a = 1'b1;
    b = 1'b1;
    carryborrowIn = 1'b0;
    
    #100;
    a = 1'b1;
    b = 1'b1;
    carryborrowIn = 1'b1;
end

exp3 dut(
    .modeAddSubtract(1'bx), // ** MODIFY HERE **
    .modeHalfFull(1'bx), // ** MODIFY HERE **
    .a(a),
    .b(b),
    .carryborrowIn(carryborrowIn),
    .carryborrowOut(carryborrowOut),
    .sumdiff(sumdiff)
    );

endmodule
