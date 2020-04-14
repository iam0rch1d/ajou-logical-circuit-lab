module encoderPriority8To3 (
    input enableIn,
    input [7:0] in,
    output [2:0] out,
    output groupSignal,
    output enableOut
    );

    wire [3:0] wire_mintermOut0;
    wire [3:0] wire_mintermOut1;
    wire [3:0] wire_mintermOut2;
    wire wire_enableOut;
    
    assign wire_mintermOut0[0] = ~enableIn & in[6] & in[4] & in[2] & ~in[1];
    assign wire_mintermOut0[1] = ~enableIn & in[6] & in[4] & ~in[3];
    assign wire_mintermOut0[2] = ~enableIn & in[6] & ~in[5];
    assign wire_mintermOut0[3] = ~enableIn & ~in[7];
    
    assign wire_mintermOut1[0] = ~enableIn & in[5] & in[4] & ~in[2];
    assign wire_mintermOut1[1] = ~enableIn & in[5] & in[4] & ~in[3];
    assign wire_mintermOut1[2] = ~enableIn & ~in[6];
    assign wire_mintermOut1[3] = ~enableIn & ~in[7];
    
    assign wire_mintermOut2[0] = ~enableIn & ~in[4];
    assign wire_mintermOut2[1] = ~enableIn & ~in[5];
    assign wire_mintermOut2[2] = ~enableIn & ~in[6];
    assign wire_mintermOut2[3] = ~enableIn & ~in[7];

    assign out[0] = ~(wire_mintermOut0[0] | wire_mintermOut0[1] | wire_mintermOut0[2] | wire_mintermOut0[3]);
    assign out[1] = ~(wire_mintermOut1[0] | wire_mintermOut1[1] | wire_mintermOut1[2] | wire_mintermOut1[3]);
    assign out[2] = ~(wire_mintermOut2[0] | wire_mintermOut2[1] | wire_mintermOut2[2] | wire_mintermOut2[3]);

    assign enableOut = ~enableIn & in[7] & in[6] & in[5] & in[4] & in[3] & in[2] & in[1] & in[0];

    assign wire_enableOut = enableOut;
    assign groupSignal = enableIn & ~wire_enableOut;
    
endmodule
