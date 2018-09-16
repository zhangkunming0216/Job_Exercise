`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/16 23:57:56
// Design Name: 
// Module Name: rx_ctrl
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


module rx_ctrl#(
	parameter               		CLK_PER = 50_000_000,
	parameter    					BAND_RATE = 9600
)(
	input  							clk_i,
	input							rst_n,
	input 							uart_rx,
	output reg [7:0] 				rd_data,
	output reg		 				rd_data_valid
    );
	localparam            		 	UART_CNT = CLK_PER/BAND_RATE;
	localparam             			UART_NUM = 10;
	//异步信号打二级
	reg uart_rx_1, uart_rx_2;
	always @(posedge clk_i) begin
		if(!rst_n)
			{uart_rx_2,uart_rx_1} <= 2'b00;
		else 
			{uart_rx_2,uart_rx_1} <= {uart_rx_1,uart_rx};
	end
	//
	reg flag_rx;
	wire flag_bit;
	reg [13:0]   rx_uart_conter;
	reg [4:0]    rx_uart_num_counter;
	
	//flag_rx
	always @(posedge clk_i) begin
		if(!rst_n)
			flag_rx <= 0;
		else if(uart_rx_2 == 0)
			flag_rx <= 1;
		else if(rx_uart_conter == UART_CNT-1 && rx_uart_num_counter == UART_NUM -1)
			flag_rx <= 0;
	end
	//rx_uart_conter 
	always @(posedge clk_i) begin
		if(!rst_n)
			rx_uart_conter <= 0;
		else begin
			if(flag_rx) begin
				if(rx_uart_conter == UART_CNT-1)
					rx_uart_conter <= 0;
				else 	
					rx_uart_conter <= rx_uart_conter + 1;
			end
			else begin
				rx_uart_conter <= 0;
			end
		end
	end
	//rx_uart_num_counter
	always @(posedge clk_i) begin
		if(!rst_n)
			rx_uart_num_counter <= 0;
		if(flag_rx) begin
				if(rx_uart_conter == UART_CNT-1 && rx_uart_num_counter == UART_NUM -1)
					rx_uart_num_counter <= 0;
				else if(rx_uart_conter == UART_CNT-1 )
					rx_uart_num_counter <= rx_uart_conter + 1;
			end
			else begin
				rx_uart_num_counter <= 0;
			end
	end
	
	assign flag_bit = (rx_uart_conter ==  UART_CNT/2-1)? 1'b1 : 1'b0;
	
	// shift reg
	always @(posedge clk_i) begin
		if(!rst_n)
			rd_data <= 0;
		else if(rx_uart_num_counter >= 1 && rx_uart_num_counter <= 8 && flag_bit)
			rd_data <= {uart_rx_2,rd_data[7:1]};
	end
	always @(posedge clk_i) begin
		if(!rst_n)
			rd_data_valid <= 0;
		else if(rx_uart_conter == UART_CNT-1 && rx_uart_num_counter == UART_NUM -1)
			rd_data_valid <= 1;
		else 	
			rd_data_valid <= 0;
	end

endmodule
