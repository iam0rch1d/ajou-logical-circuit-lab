module exp1 (
    input mode_task,
    input [1:0] mode_subtask,
    input signal_a,
    input signal_b,
    input signal_c,
    output reg signal_l1,
    output reg signal_l2,
    output reg signal_x,
    output reg signal_y,
    output reg signal_z
);

parameter ZERO = 2'b00;
parameter ONE = 2'b01;
parameter TWO = 2'b10;
parameter THREE = 2'b11;

always @(mode_subtask or signal_a or signal_b or signal_c or signal_l1 or signal_z) begin
    case(mode_subtask)
        ZERO: begin // mode_subtask(0): 3-input AND gate
            signal_l1 = signal_a & signal_b;
            signal_l2 = signal_l1 & signal_c;
        end
        
        ONE: begin // mode_subtask(1): 3-input OR gate
            signal_l1 = signal_a | signal_b;
            signal_l2 = signal_l1 | signal_c;
        end
        
        TWO: begin // mode_subtask(2): 3-input NAND gate
            signal_l1 = signal_a & signal_b;
            signal_l2 = ~(signal_l1 & signal_c);
        end
        
        default: begin // mode_subtask(3): 3-input NOR gate
            signal_l1 = signal_a | signal_b;
            signal_l2 = ~(signal_l1 | signal_c);
        end
    endcase
    
signal_y = signal_a | signal_b;
signal_z = ~(~signal_a & signal_b);
signal_x = signal_a | signal_z;

// mode_task(0): 3-input logical gate
signal_l1 = ~mode_task & signal_l1;
signal_l2 = ~mode_task & signal_l2;

// mode_task(1): Random logical gate
signal_x = mode_task & signal_x;
signal_y = mode_task & signal_y;
signal_z = mode_task & signal_z;
end

endmodule
