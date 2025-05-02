// PC_Counter.v

module Program_Counter (
    input  wire        clk,
    input  wire        reset,
    input  wire        PCWrite,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'h00000000;
        else if (PCWrite)
            pc_out <= pc_in;
    end
endmodule
