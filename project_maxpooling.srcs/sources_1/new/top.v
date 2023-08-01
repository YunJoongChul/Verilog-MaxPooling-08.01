`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/01 10:40:52
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(clk, rst, start, dout);

input clk, rst, start;
output [6:0] dout;
reg wea;
reg [6:0] addra;
reg [6:0] dina;
reg [3:0] state;
reg [6:0] cnt_col1,cnt_col2;
reg [6:0] cnt_row1, cnt_row2; 
blk_mem_gen_0  u0( .clka(clk),.wea(wea), .addra(addra), .dina(dina), .douta(dout)); 
localparam IDLE = 4'd0,  DEALY1 = 4'd1, DELAY2 = 4'd2, POOLING_COL1 = 4'd3, POOLING_COL2 = 4'd4, POOLING_ROW1 = 4'd5, POOLING_ROW2 = 4'd6, DONE = 4'd7;

always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
        IDLE : if(start) state <=  POOLING_COL1; else state <= IDLE;
        POOLING_COL1 : state <=  POOLING_COL2;
        POOLING_COL2 : state <=  POOLING_ROW1;
        POOLING_ROW1 : state <=  POOLING_ROW2;
        POOLING_ROW2 : if(cnt_row1 == 80 && cnt_col1 == 8) state <= DONE; else state <= POOLING_COL1;
        DONE : state <= IDLE;
        default : state <= IDLE;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_col1 <= 7'd0;
    else
        case(state)
            POOLING_ROW2 : if(cnt_col1 == 8) cnt_col1 <= 0; else cnt_col1 <= cnt_col1 + 2'd2;
            default : cnt_col1 <= cnt_col1;
            endcase
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row1 <= 7'd0;
    else
        case(state)
            POOLING_ROW2 : if(cnt_row1 == 100) cnt_row1 <= 0; else if(cnt_col1 == 8) cnt_row1 <= cnt_row1 + 5'd20; else cnt_row1 <= cnt_row1;
            default : cnt_row1 <= cnt_row1;
            endcase
end





always@(posedge clk or posedge rst)
begin
    if(rst)
        addra <= 7'd0;
    else
        case(state)
        POOLING_COL1 : addra <= cnt_row1 + cnt_col1;
        POOLING_COL2 : addra <= cnt_row1 + cnt_col1 + 1'd1;
        POOLING_ROW1 : addra <= cnt_row1 + cnt_col1  + 4'd10;
        POOLING_ROW2 : addra <= cnt_row1 + cnt_col1  + 4'd11;
        default : addra <= addra;
        endcase
end







endmodule
