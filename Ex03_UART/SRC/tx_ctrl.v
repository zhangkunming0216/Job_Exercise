`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/17 01:13:57
// Design Name: 
// Module Name: tx_ctrl
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


module tx_ctrl#(
	parameter               		CLK_PER = 50_000_000,
	parameter    					BAND_RATE = 9600
)(
	input  							clk_i,
	input							rst_n,
	input							tx_data_valid,
	input							tx_data,
	output							uart_tx
    );
	localparam            		 	UART_CNT = CLK_PER/BAND_RATE;
	localparam             			UART_NUM = 10;
	
	reg  tx_flag;
	wire tx_bit_flag;
	reg [13:0]   tx_uart_conter;
	reg [4:0]    tx_uart_num_counter;
	
	// tx_flag
	always @(posedge clk_i) begin
		if(!rst_n)
			tx_flag <= 0;
		else if(tx_data_valid)
			tx_flag <= 1;
		else if(tx_uart_conter == UART_CNT-1 && tx_uart_num_counter == UART_NUM-1)
			tx_flag <= 0;
	end
	//tx_uart_conter
	always @(posedge clk_i) begin
		if(!rst_n)
			tx_uart_conter <= 0;
		else  begin
			if(tx_flag) begin
				if(tx_uart_conter == UART_CNT-1)
					tx_uart_conter <= 0;
				else	
					tx_uart_conter <= tx_uart_conter + 1;
			end
			else
				tx_uart_conter <= 0;
			
		end	
	end
	//tx_uart_num_counter
	always @(posedge clk_i) begin
		if(!rst_n)
			tx_uart_num_counter <= 0;
		else  begin
			if(tx_flag) begin
				if(tx_uart_conter == UART_CNT-1 && tx_uart_num_counter == UART_NUM-1)
					tx_uart_num_counter <= 0;
				else if(tx_uart_conter == UART_CNT-1)
					tx_uart_num_counter <= tx_uart_conter + 1;
			end
			else
				tx_uart_num_counter <= 0;
		end	
	end
	
	assign tx_bit_flag = (tx_uart_conter == 0 && tx_flag == 1)? 1'b1 : 1'b0;
	
	//shift reg
	reg [UART_NUM-1:0]  shift_tx;
	always @(posedge clk_i) begin
		if(!rst_n)
			shift_tx <= 0;
		else if(tx_data_valid) 
			shift_tx <= {1'b1,tx_data,1'b0};
		else if(tx_uart_num_counter>=1 && tx_bit_flag == 1)
			shift_tx <= {1'b1,shift_tx[UART_NUM-1:1]};
	end
	assign uart_tx = shift_tx[0];

endmodule


