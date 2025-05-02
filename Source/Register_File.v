// Register_File.v
module Register_File (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [4:0]  rs,
    input  wire [4:0]  rt,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] rs_data,
    output wire [31:0] rt_data
);

    reg [31:0] regs [0:31];
            integer i;


    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 0;
    end

    assign rs_data = regs[rs];
    assign rt_data = regs[rt];

    always @(posedge clk) begin
        if (reg_write && write_reg != 0)
            regs[write_reg] <= write_data;
    end
endmodule
