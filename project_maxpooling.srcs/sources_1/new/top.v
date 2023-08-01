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
wire [6:0] data_out;
reg wea;
reg [6:0] addra, addr_out;
reg [6:0] dina;
reg [3:0] state;
reg [6:0] cnt_col1,cnt_col2;
reg [6:0] cnt_row1, cnt_control; 
reg [6:0] max1, max2, max3, max4, max_result1, max_result2, max_out;
reg wea_out;
blk_mem_gen_0  u0( .clka(clk),.wea(wea), .addra(addra), .dina(dina), .douta(data_out)); 
blk_mem_gen_1  u1( .clka(clk), .wea(wea_out), .addra(addr_out), .dina(max_out), .douta(dout)); 
localparam IDLE = 4'd0,  DELAY1 = 4'd1, DELAY2 = 4'd2, MAX1 = 4'd3, MAX2 = 4'd4, MAX3 = 4'd5, MAX4 = 4'd6, DELAY3 = 4'd7, DELAY4 = 4'd8, DONE = 4'd9;

always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
        IDLE : if(start) state <=  DELAY1; else state <= IDLE;
        DELAY1 : state <= DELAY2;
        DELAY2 : state <= MAX1;
        MAX1 : state <=  MAX2;
        MAX2 : if(addr_out == 24) state <=  DONE; else state <= DELAY1;
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
            MAX2 : if(cnt_col1 == 8) cnt_col1 <= 0; else cnt_col1 <= cnt_col1 + 2'd2;
            default : cnt_col1 <= cnt_col1;
            endcase
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row1 <= 7'd0;
    else
        case(state)
              MAX2 : if(cnt_row1 == 100) cnt_row1 <= 0; else if(cnt_col1 == 8) cnt_row1 <= cnt_row1 + 5'd20; else cnt_row1 <= cnt_row1;
            default : cnt_row1 <= cnt_row1;
            endcase
end





always@(posedge clk or posedge rst)
begin
    if(rst)
        addra <= 7'd0;
    else
        case(state)
        DELAY1 : addra <= cnt_row1 + cnt_col1;
        DELAY2 : addra <= cnt_row1 + cnt_col1 + 1'd1;
        MAX1 : addra <= cnt_row1 + cnt_col1  + 4'd10;
        MAX2 : addra <= cnt_row1 + cnt_col1  + 4'd11;
        default : addra <= addra;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_control <= 7'd0;
    else
        case(state)
        IDLE : cnt_control <= 0;
        DELAY1 : if(addra != 0) cnt_control <= cnt_control + 1; else cnt_control <= 0;
        DELAY2 : if(addra != 0) cnt_control <= cnt_control + 1; else cnt_control <= 0;
        MAX1 : if(cnt_control == 4) cnt_control <= 1; else cnt_control <= cnt_control + 1;
        default : cnt_control <= cnt_control + 1;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
    max1 <= 0;
    else
        case(cnt_control)
            1 : max1 <= data_out;
            default : max1 <= max1;
         endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    max2 <= 0;
    else
        case(cnt_control)
            2 : max2 <= data_out;
            default : max2 <= max2;
         endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    max3 <= 0;
    else
        case(cnt_control)
            3 : max3 <= data_out;
            default : max3 <= max3;
         endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    max4 <= 0;
    else
        case(cnt_control)
            4 : max4 <= data_out;
            default : max4 <= max4;
         endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    max_result1 <= 0;
   else
     case(state)
     MAX2 : max_result1 <= (max1 > max2) ? max1 : max2;
     default max_result1 <= max_result1;
     endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
    max_result2 <= 0;
   else
     case(state)
     MAX2 : max_result2 <= (max3 > max4) ? max3 : max4;
     default max_result2 <= max_result2;
     endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    max_out <= 0;
   else
     case(state)
     MAX2 : max_out <= (max_result1 > max_result2) ? max_result1 : max_result2;
     default max_out <= max_out;
     endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
    addr_out <= 0;
    else
    case(state)
    MAX2 :if(cnt_col1 < 4 && cnt_row1 == 0 ) addr_out <= 0; else if(addr_out == 25) addr_out <= 0; else addr_out <= addr_out + 1;
    default addr_out <= addr_out;
    endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
      wea_out <= 0;
    else
       case(state)
       MAX2: if(addr_out == 25) wea_out <= 0; else wea_out <= 1;
       default : wea_out <= 0;
       endcase
end 
endmodule