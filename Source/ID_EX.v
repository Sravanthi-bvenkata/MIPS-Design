module ID_EX (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [31:0] pc_in,
    input  wire [31:0] rs_data_in,
    input  wire [31:0] rt_data_in,
    input  wire [31:0] sign_ext_in,
    input  wire [4:0]  rs_in,
    input  wire [4:0]  rt_in,
    input  wire [4:0]  rd_in,
    input  wire        reg_dst_in,
    input  wire        alu_src_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        branch_in,
    input  wire [1:0]  alu_op_in,
    
    output reg  [31:0] pc_out,
    output reg  [31:0] rs_data_out,
    output reg  [31:0] rt_data_out,
    output reg  [31:0] sign_ext_out,
    output reg  [4:0]  rs_out,
    output reg  [4:0]  rt_out,
    output reg  [4:0]  rd_out,
    output reg         reg_dst_out,
    output reg         alu_src_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         branch_out,
    output reg [1:0]   alu_op_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out        <= 32'b0;
            rs_data_out   <= 32'b0;
            rt_data_out   <= 32'b0;
            sign_ext_out  <= 32'b0;
            rs_out        <= 5'b0;
            rt_out        <= 5'b0;
            rd_out        <= 5'b0;
            reg_dst_out   <= 0;
            alu_src_out   <= 0;
            mem_to_reg_out<= 0;
            reg_write_out <= 0;
            mem_read_out  <= 0;
            mem_write_out <= 0;
            branch_out    <= 0;
            alu_op_out    <= 2'b0;
        end else if (enable) begin
            pc_out        <= pc_in;
            rs_data_out   <= rs_data_in;
            rt_data_out   <= rt_data_in;
            sign_ext_out  <= sign_ext_in;
            rs_out        <= rs_in;
            rt_out        <= rt_in;
            rd_out        <= rd_in;
            reg_dst_out   <= reg_dst_in;
            alu_src_out   <= alu_src_in;
            mem_to_reg_out<= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            mem_read_out  <= mem_read_in;
            mem_write_out <= mem_write_in;
            branch_out    <= branch_in;
            alu_op_out    <= alu_op_in;
        end
    end

endmodule
