module addsubHalfFull (
    input modeAddSubtract, // ADDER at 0, SUBTRACTOR at 1
    input modeHalfFull, // HALF at 0, FULL at 1
    input a,
    input b,
    input carryborrowIn, // CARRY at modeAddSubtract == 0, BORROW at modeAddSubtract == 1
    output carryborrowOut, // CARRY at modeAddSubtract == 0, BORROW at modeAddSubtract == 1
    output sumdiff // SUM at modeAddSubtract == 0, DIFFERENCE at modeAddSubtract == 1
    );
    
    wire wire_carryborrowIn;
    
    assign wire_carryborrowIn = carryborrowIn & modeHalfFull;
    
    assign carryborrowOut = (wire_carryborrowIn & (a ^ b ^ modeAddSubtract)) | ((a ^ modeAddSubtract) & b);
    assign sumdiff = a ^ b ^ wire_carryborrowIn;
    
endmodule
