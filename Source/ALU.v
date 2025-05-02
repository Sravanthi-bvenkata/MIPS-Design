// ALU.v
module ALU (
    input  wire [31:0] src_a,
    input  wire [31:0] src_b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] alu_result,
    output wire        zero,
    output wire        overflow
);

    reg signed [31:0] signed_src_a, signed_src_b;
    reg signed [31:0] signed_result;

    always @(*) begin
        signed_src_a = src_a;  
        signed_src_b = src_b;  

        case (alu_ctrl)
            4'b0010: begin  // ADD
                signed_result = signed_src_a + signed_src_b;
                alu_result = signed_result;
            end
            4'b0110: begin  // SUB
                signed_result = signed_src_a - signed_src_b;
                alu_result = signed_result;
            end
            4'b0000: begin  // AND
                alu_result = src_a & src_b;
            end
            4'b0001: begin  // OR
                alu_result = src_a | src_b;
            end
            4'b0111: begin  // SLT
                alu_result = (src_a < src_b) ? 1 : 0;
            end
            default: alu_result = 0;
        endcase
    end

    assign zero = (alu_result == 0);

    // Overflow for ADD and SUB operations
    assign overflow = (alu_ctrl == 4'b0010 && 
                       (signed_src_a[31] == signed_src_b[31]) && 
                       (signed_result[31] != signed_src_a[31])) ||  // Overflow in ADD
                      (alu_ctrl == 4'b0110 && 
                       (signed_src_a[31] != signed_src_b[31]) && 
                       (signed_result[31] != signed_src_a[31])); // Overflow in SUB

endmodule
