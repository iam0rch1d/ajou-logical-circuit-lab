module latchSrWithEnableByNorGate (
    input enable,
    input set,
    input reset,
    output reg out,
    output reg notout
    );

    reg reg_outputFirstStage0;
    reg reg_outputFirstStage1;
    
    always@ (enable, set, reset) begin
        reg_outputFirstStage0 = ~(enable | reset);
        reg_outputFirstStage1 = ~(enable | set);
        
        out = ~(notout | reg_outputFirstStage0);
        notout = ~(out | reg_outputFirstStage1);
    end

endmodule
