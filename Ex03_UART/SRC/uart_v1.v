`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/17 01:35:56
// Design Name: 
// Module Name: uart_v1
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


module uart_v1#(
	parameter               		CLK_PER = 50_000_000,
	parameter    					BAND_RATE = 9600
)(
	input 					clk_i,
	input 					rst_n,
	
	output 					uart_tx,
	input 					tx_data_valid,
	input [7:0] 			tx_data,
	
	input 					uart_rx,
	output 					rx_data_valid,
	output[7:0]   			rx_data
    );
	
	rx_ctrl#(
	    .CLK_PER   (CLK_PER  ),
	    .BAND_RATE (BAND_RATE)
	)rx_ctrl(
	    .clk_i			(clk_i		   ),
	    .rst_n			(rst_n		   ),
	    .uart_rx		(uart_rx	   ),
	    .rd_data		(rx_data	   ),
	    .rd_data_valid  (rx_data_valid )
    );
	
	tx_ctrl#(
		.CLK_PER   (CLK_PER  ),
		.BAND_RATE (BAND_RATE)
	)tx_ctrl(
		.clk_i			(clk_i	      ),
		.rst_n			(rst_n		  ),	
		.tx_data_valid	(tx_data_valid),
		.tx_data		(tx_data	  ),
		.uart_tx        (uart_tx      )
    );
endmodule
