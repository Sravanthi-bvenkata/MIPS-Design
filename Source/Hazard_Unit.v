// Hazard_Unit.v
module Hazard_Unit (
    input  wire [4:0] id_ex_rt,
    input  wire       id_ex_mem_read,
    input  wire [4:0] if_id_rs,
    input  wire [4:0] if_id_rt,
    output reg        pc_write,
    output reg        if_id_write,
    output reg        control_stall
);

    always @(*) begin
        //  no stall
        pc_write      = 1;
        if_id_write   = 1;
        control_stall = 0;

        // Load-use hazard detection
        if (id_ex_mem_read &&
            ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            pc_write      = 0; // stall PC
            if_id_write   = 0; // stall IF/ID register
            control_stall = 1; // insert NOP 
        end
    end

endmodule
