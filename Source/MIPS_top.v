



module MIPS_top (
    input wire clk,
    input wire reset,
    // Added outputs for debugging
    output wire [31:0] pc_out,
    output wire [31:0] instr,
    output wire [31:0] id_ex_rs,
    output wire [31:0] id_ex_rt,
    output wire [31:0] id_ex_rd,
    output wire [31:0] id_ex_sign_ext,
    output wire [31:0] alu_result,
    output wire zero,
    output wire [31:0] mem_data_out,
    output wire [31:0] ex_mem_rt_data,
    output wire [4:0] mem_wb_rd,
    output wire mem_wb_mem_to_reg,
    output wire mem_wb_reg_write
);


    // IF Stage
wire [31:0] pc_plus4_IF;

PC_Adder pc_adder (
    .pc_in(pc_current),
    .pc_out(pc_plus4_IF)
);


Instruction_Memory instr_mem (
    .addr(pc_current),
    .instr(instr_IF)
);

// IF/ID Pipeline Register
wire [31:0] pc_ID, instr_ID;

IF_ID if_id (
    .clk(clk),
    .reset(reset),
    .IF_ID_Write(1'b1),  
    .flush(1'b0),        
    .pc_in(pc_plus4_IF),
    .instr_in(instr_IF),
    .pc_out(pc_ID),
    .instr_out(instr_ID)
);


// ID Stage
wire [5:0] opcode = instr_ID[31:26];
wire [4:0] rs_ID = instr_ID[25:21];
wire [4:0] rt_ID = instr_ID[20:16];
wire [4:0] rd_ID = instr_ID[15:11];
wire [15:0] imm_ID = instr_ID[15:0];

wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch;
wire [1:0] alu_op;

Control_Unit ctrl (
    .opcode(opcode),
    .reg_dst(reg_dst),
    .alu_src(alu_src),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .alu_op(alu_op)
);

wire [31:0] rs_data, rt_data;

Register_File reg_file (
    .clk(clk),
    .reg_write(reg_write_WB),
    .rs(rs_ID),
    .rt(rt_ID),
    .write_reg(write_reg_WB),
    .write_data(write_data_WB),
    .rs_data(rs_data),
    .rt_data(rt_data)
);

wire [31:0] imm_ext;

Sign_Extend sign_ext (
    .instr(imm_ID),    
    .imm_ext(imm_ext)  
);


// Hazard detection
wire control_stall; 
Hazard_Unit hazard (
    .id_ex_rt(rt_EX),
    .if_id_rs(rs_ID),
    .if_id_rt(rt_ID),
    .id_ex_mem_read(mem_read_EX),
    .control_stall(control_stall)  
);


// ID/EX Pipeline Register
wire reg_dst_EX, alu_src_EX, mem_to_reg_EX, reg_write_EX;
wire mem_read_EX, mem_write_EX;
wire [1:0] alu_op_EX;
wire [31:0] pc_EX, rs_data_EX, rt_data_EX, imm_ext_EX;
wire [4:0] rs_EX, rt_EX, rd_EX;

ID_EX id_ex (
    .clk(clk),
    .reset(reset),
    .enable(~stall),
    .reg_dst_in(reg_dst),
    .alu_src_in(alu_src),
    .mem_to_reg_in(mem_to_reg),
    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .alu_op_in(alu_op),
    .pc_in(pc_ID),
    .rs_data_in(rs_data),
    .rt_data_in(rt_data),
    .sign_ext_in(imm_ext), 
    .rs_in(rs_ID),
    .rt_in(rt_ID),
    .rd_in(rd_ID),

    .reg_dst_out(reg_dst_EX),
    .alu_src_out(alu_src_EX),
    .mem_to_reg_out(mem_to_reg_EX),
    .reg_write_out(reg_write_EX),
    .mem_read_out(mem_read_EX),
    .mem_write_out(mem_write_EX),
    .alu_op_out(alu_op_EX),
    .pc_out(pc_EX),
    .rs_data_out(rs_data_EX),
    .rt_data_out(rt_data_EX),
    .sign_ext_out(imm_ext_EX),  
    .rt_out(rt_EX),
    .rd_out(rd_EX)
);


// ALU Control + Forwarding
wire [3:0] alu_ctrl;
wire [1:0] forward_a, forward_b;

Forwarding_Unit forward (
    .id_ex_rs(rs_EX),
    .id_ex_rt(rt_EX),
    .ex_mem_rd(write_reg_MEM),
    .ex_mem_reg_write(reg_write_MEM),
    .mem_wb_rd(write_reg_WB),
    .mem_wb_reg_write(reg_write_WB),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

ALU_Control alu_ctrl_unit (
    .alu_op(alu_op_EX),
    .funct(imm_ext_EX[5:0]), 
    .alu_ctrl(alu_ctrl)
);

wire [31:0] forward_data_a, forward_data_b;
assign forward_data_a = (forward_a == 2'b00) ? rs_data_EX :
                        (forward_a == 2'b10) ? alu_result_MEM :
                        (forward_a == 2'b01) ? write_data_WB : rs_data_EX;

assign forward_data_b = (forward_b == 2'b00) ? rt_data_EX :
                        (forward_b == 2'b10) ? alu_result_MEM :
                        (forward_b == 2'b01) ? write_data_WB : rt_data_EX;

wire [31:0] alu_in_b = (alu_src_EX) ? imm_ext_EX : forward_data_b;
wire [31:0] alu_result_EX;
wire zero_EX;

ALU alu (
    .src_a(forward_data_a),
    .src_b(alu_in_b),
    .alu_ctrl(alu_ctrl),
    .alu_result(alu_result_EX),
    .zero(zero_EX)
);

wire [4:0] write_reg_EX = (reg_dst_EX) ? rd_EX : rt_EX;

// EX/MEM Pipeline Register
wire reg_write_MEM, mem_to_reg_MEM, mem_read_MEM, mem_write_MEM;
wire [31:0] alu_result_MEM, rt_data_MEM;
wire [4:0] write_reg_MEM;

EX_MEM ex_mem (
    .clk(clk),
    .reset(reset),
    .enable(1'b1),
    .reg_write_in(reg_write_EX),
    .mem_to_reg_in(mem_to_reg_EX),
    .mem_read_in(mem_read_EX),
    .mem_write_in(mem_write_EX),
    .alu_result_in(alu_result_EX),
    .rt_data_in(forward_data_b),
    .write_reg_in(write_reg_EX),

    .reg_write_out(reg_write_MEM),
    .mem_to_reg_out(mem_to_reg_MEM),
    .mem_read_out(mem_read_MEM),
    .mem_write_out(mem_write_MEM),
    .alu_result_out(alu_result_MEM),
    .rt_data_out(rt_data_MEM),
    .write_reg_out(write_reg_MEM)
);

// MEM Stage
wire [31:0] read_data_MEM;

Data_Memory data_mem (
    .clk(clk),
    .mem_read(mem_read_MEM),
    .mem_write(mem_write_MEM),
    .addr(alu_result_MEM),
    .write_data(rt_data_MEM),
    .read_data(read_data_MEM)
);

// MEM/WB Pipeline Register
wire reg_write_WB, mem_to_reg_WB;
wire [31:0] read_data_WB, alu_result_WB;
wire [4:0] write_reg_WB;

MEM_WB mem_wb (
    .clk(clk),
    .reset(reset),
    .enable(1'b1),
    .reg_write_in(reg_write_MEM),
    .mem_to_reg_in(mem_to_reg_MEM),
    .read_data_in(read_data_MEM),
    .alu_result_in(alu_result_MEM),
    .write_reg_in(write_reg_MEM),

    .reg_write_out(reg_write_WB),
    .mem_to_reg_out(mem_to_reg_WB),
    .read_data_out(read_data_WB),
    .alu_result_out(alu_result_WB),
    .write_reg_out(write_reg_WB)
);

// WB Stage
wire [31:0] write_data_WB = (mem_to_reg_WB) ? read_data_WB : alu_result_WB;

// Branch PC logic 
assign pc_next = pc_plus4_IF;  
assign pc_out = pc_current;  
assign instr = instr_IF;     
assign id_ex_rs = rs_data_EX;
assign id_ex_rt = rt_data_EX;
assign id_ex_rd = rd_EX;
assign id_ex_sign_ext = imm_ext_EX;
assign alu_result = alu_result_EX;
assign zero = zero_EX;
assign mem_data_out = read_data_MEM; 
assign ex_mem_rt_data = rt_data_MEM;
assign mem_wb_rd = write_reg_WB;
assign mem_wb_mem_to_reg = mem_to_reg_WB;
assign mem_wb_reg_write = reg_write_WB;


endmodule
