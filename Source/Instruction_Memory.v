// Instruction_Memory.v
module Instruction_Memory (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:1023]; 

    initial begin
        $readmemh("instr_mem.hex", mem); 
    end

    assign instr = mem[addr[11:2]]; 
endmodule
