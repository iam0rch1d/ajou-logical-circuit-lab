module exp1 (
    input taskMode,
    input [1:0] subtaskMode,
    input a,
    input b,
    input c,
    output l1,
    output l2,
    output x,
    output y,
    output z
    );
    
    reg reg_l1;
    reg reg_l2;
    reg reg_x;
    reg reg_y;
    reg reg_z;
    
    always @(subtaskMode or a or b or c or reg_l1 or reg_z) begin
        case(subtaskMode)
            // subtaskMode(0): 3-input AND gate
            2'b00: begin
                reg_l1 = a & b;
                reg_l2 = reg_l1 & c;
            end
            
            // subtaskMode(1): 3-input OR gate
            2'b01: begin
                reg_l1 = a | b;
                reg_l2 = reg_l1 | c;
            end
            
            // subtaskMode(2): 3-input NAND gate
            2'b10: begin
                reg_l1 = a & b;
                reg_l2 = ~(reg_l1 & c);
            end
            
            // subtaskMode(3): 3-input NOR gate
            default: begin
                reg_l1 = a | b;
                reg_l2 = ~(reg_l1 | c);
            end
        endcase
        
    reg_y = a | b;
    reg_z = ~(~a & b);
    reg_x = a | reg_z;
    end
    
    // taskMode(0): 3-input logical gate
    assign l1 = ~taskMode & reg_l1;
    assign l2 = ~taskMode & reg_l2;
    
    // taskMode(1): Random logical gate
    assign x = taskMode & reg_x;
    assign y = taskMode & reg_y;
    assign z = taskMode & reg_z;
    
endmodule
