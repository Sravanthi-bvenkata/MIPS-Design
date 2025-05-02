// Sign_Extend.v (for immediate operations)
module  Sign_Extend (
    input  wire [31:0] instr,
    output wire [31:0] imm_ext
);
    wire [15:0] imm = instr[15:0];
    assign imm_ext = {{16{imm[15]}}, imm};  // Sign-extend to 32 bits
endmodule
