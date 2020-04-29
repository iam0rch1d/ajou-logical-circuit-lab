module flipflopD (
    input clockpulse,
    input preset,
    input clear,
    input data,
    output reg out,
    output reg notout
    );

    always@ (posedge clockpulse, posedge clear, posedge preset) begin
        if (clear) begin
            out <= 1'b0;
            notout <= 1'b1;
        end
        else if (preset) begin
            out <= 1'b1;
            notout <= 1'b0;
        end
        else begin
            out <= data;
            notout <= ~data;
        end
    end

endmodule
