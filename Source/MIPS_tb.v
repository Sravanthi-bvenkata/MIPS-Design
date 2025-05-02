module MIPS_tb;

    reg clk;
    reg reset;

    MIPS_top uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .instr(instr),
        .id_ex_rs(id_ex_rs),
        .id_ex_rt(id_ex_rt),
        .id_ex_rd(id_ex_rd),
        .id_ex_sign_ext(id_ex_sign_ext),
        .alu_result(alu_result),
        .zero(zero),
        .mem_data_out(mem_data_out),
        .ex_mem_rt_data(ex_mem_rt_data),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_reg_write(mem_wb_reg_write)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Initial block
    initial begin
        
        reset = 1;
        #20;
        reset = 0;
            $monitor("PC: %h, Instruction: %h", pc_out, instr);
        
        #50;

        $finish;
    end

    always @(posedge clk) begin
        $display("--------------------------------------------------------");
        $display("Cycle %0d", $time/10);

        // IF Stage
        $display("IF  : PC = 0x%08X, Instruction = 0x%08X",
                 pc_out,
                 instr);

        // ID Stage
        $display("ID  : rs = %0d, rt = %0d, rd = %0d, imm = 0x%04X",
                 id_ex_rs,
                 id_ex_rt,
                 id_ex_rd,
                 id_ex_sign_ext);

        // EX Stage
        $display("EX  : ALU Result = 0x%08X, Zero = %b",
                 alu_result,
                 zero);

        // MEM Stage
        $display("MEM : MemReadData = 0x%08X",
                 mem_data_out);

        // WB Stage
        $display("WB  : WriteReg = %0d, WriteData = 0x%08X, RegWrite = %b",
                 mem_wb_rd,
                 mem_wb_mem_to_reg ? mem_data_out : alu_result,
                 mem_wb_reg_write);
    end

endmodule
