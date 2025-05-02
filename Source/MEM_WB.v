module MEM_WB (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    input  wire [31:0] read_data_in,
    input  wire [31:0] alu_result_in,
    input  wire [4:0]  write_reg_in,

    output reg         reg_write_out,
    output reg         mem_to_reg_out,
    output reg [31:0]  read_data_out,
    output reg [31:0]  alu_result_out,
    output reg [4:0]   write_reg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_write_out   <= 0;
            mem_to_reg_out  <= 0;
            read_data_out   <= 32'b0;
            alu_result_out  <= 32'b0;
            write_reg_out   <= 5'b0;
        end else if (enable) begin
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            read_data_out   <= read_data_in;
            alu_result_out  <= alu_result_in;
            write_reg_out   <= write_reg_in;
        end
    end

endmodule
