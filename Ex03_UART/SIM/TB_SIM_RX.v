`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/16 21:51:12
// Design Name: 
// Module Name: TB_SIM_RX
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


module TB_SIM_RX();
reg  clk_i;
reg  rst_n;
reg  rx;

always #1 clk_i = ~clk_i;

initial begin
	clk_i = 0;
	rst_n = 0;
	#100
end

task rx_byte();
	integer j;
	for(j=0;j<100;j=j+1)begin
		rx_data(j+10);
	end
endtask

task rx_data(
	input   [7:0] rx_data
	) begin
	integer i;
	for(i=0;i<10;i=i+1) begin
		case(i)
			0: rx <= 0;
			1: rx <= rx_data[1];
			2: rx <= rx_data[2];
			3: rx <= rx_data[3];
			4: rx <= rx_data[4];
			5: rx <= rx_data[5];
			6: rx <= rx_data[6];
			7: rx <= rx_data[7];
			8: rx <= rx_data[8];
			9: rx <= 1;
			default: rx <= 1;
		endcase
		#    //延时一段时间满足
	end
end


endmodule
