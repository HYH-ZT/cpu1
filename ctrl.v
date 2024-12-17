`include "defines.v"

module ctrl(
    input wire rst,
    input wire stallreq_upstream_from_id,   //来自译码阶段的暂停上游的请求（用于跳转时clear后面一条的指令）
    input wire stallreq_downstream_from_id, //来自译码阶段的暂停下游的请求(名字有点不合适)
    input wire stallreq_from_ex,            //来自执行阶段的暂停（下游的）请求

    output reg[`StallBus] stall       //暂停流水线的控制信号
);

always @ (*)begin
    if(rst == `RstEnable) begin                     //复位信号有效，流水线不暂停
        stall =6'b000000;
    end 
    else if(stallreq_from_ex == `Stop) begin        //执行阶段暂停请求，执行阶段及此前的各阶段均暂停，后面的各阶段继续工作
        stall =6'b001111;
    end 
    else if(stallreq_upstream_from_id == `Stop) begin        //译码阶段暂停上游的请求
        stall =6'b000010;
    end
    else if(stallreq_downstream_from_id == `Stop) begin        //译码阶段暂停下游的请求
        stall = 6'b000111;
    end
    else begin
        stall =6'b000000;
    end
end
endmodule