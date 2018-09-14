`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/14 13:19:11
// Design Name: 
// Module Name: spi_v1
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


module spi_v1(
	parameter                     CLK_FRE =100_000_000,
	parameter                     SPI_FRE =1_000_000
	
)#(
	input                         clk_i,
	input                         rst_n,
	
	input                         work_en,
	output 						  spi_cs,
	output 						  spi_sck,
	output 						  spi_sdo,
	input 						  spi_sdi
    );
	
	localparam                   SCK_COUNT_Half = CLK_FRE/SPI_FRE/2;
	
	reg [5:0]                    sck_counter_h_r;
	
	always @(posedge clk_i)
		if(!rst_n)
			sck_counter_h_r <= 0;
		else if(sck_counter_h_r == SCK_COUNT_Half-1)
			sck_counter_h_r <= 0;
		else 
			sck_counter_h_r <= sck_counter_h_r + 1;
	
	wire sck_change_flag;
	assign sck_change_flag = (sck_counter_h_r == SCK_COUNT_Half-1) ? 1'b1:1'b0;
	
	reg sck_r;
	always @(posedge clk_i)
		if(!rst_n)
			sck_r <= 0;
		else if(sck_change_flag == 1)
			sck_r <= ~sck_r;
	
	wire spi_sdo_flag;
	assign spi_sdo_flag = (sck_r==0 && sck_counter_h_r == SCK_COUNT_Half-1)? 1'b1:1'b0;
		
	reg [8:0] shift_sdo_r;	
	always @(posedge clk_i) 
		if(!rst_n)
			shift_sdo_r <= 0;
		else if(spi_sdo_flag)
			shift_sdo_r <= {shift_sdo_r[6:0],1'b1};
endmodule
