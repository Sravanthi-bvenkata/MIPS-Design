// Data_Memory.v
module Data_Memory (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] memory [0:255]; 

    assign read_data = (mem_read) ? memory[addr[9:2]] : 32'b0;

    always @(posedge clk) begin
        if (mem_write)
            memory[addr[9:2]] <= write_data;
    end

endmodule
