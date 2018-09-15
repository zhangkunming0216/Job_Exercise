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


module spi_v1#(
	parameter                     SPI_FRE = 1_000_000,
	parameter                     CLK_FRE = 100_000_000
)(
	input                         clk_i,
	input                         rst_n,
	
	input                         work_en,
	output 						  spi_cs,
	output 						  spi_sck,
	output 						  spi_sdo
	//input 						  spi_sdi
    );
	localparam                 SCK_COUNT_Half = CLK_FRE/SPI_FRE;
	localparam                     IDLE = 5'b0_0001;
	localparam                	   WAIT = 5'b0_0010;
	localparam                 READ_MEM = 5'b0_0100;
	localparam                WRITE_REG = 5'b0_1000;
	localparam                     STOP = 5'b1_0000;
	
	localparam 				   REG0 = 8'h01;
	localparam 				   REG1 = 8'h02;
	localparam 				   REG2 = 8'h03;
	localparam 				   REG3 = 8'h04;
	
	reg [4:0]                 state;
	
	//FSM
	always @(posedge clk_i) begin
		if(!rst_n)
			state <= IDLE;
		else begin
			case(state)
				IDLE:
					if(work_en)
						state <= WAIT;
				WAIT:
					if(wait_end)
						state <= READ_MEM;
				READ_MEM:
					state <= WRITE_REG;
				WRITE_REG:
					if(shift_end == 1 && shift_all != 1)
						state <= WAIT;
					else if(shift_end == 1 && shift_all == 1)
						state <= STOP;
				STOP:
					state <= STOP;
				default:
					state <= IDLE;
			endcase
		end
	end
   
	wire wait_end;
	reg [15:0] wait_count_r;
	always @(posedge clk_i) begin
		if(!rst_n)
			wait_count_r <= 0;
		else if(state == WAIT)
			wait_count_r <= wait_count_r + 1;
		else 	
			wait_count_r <= 0;
	end	
	assign wait_end = wait_count_r[15];
	
	reg [7:0] shift_reg;
	always @(posedge clk_i) begin
		if(!rst_n)
			shift_reg <= 8'hff;
		else if(state == READ_MEM) 
				case(shift_counter_r)
					2'b00:    shift_reg <= REG0;
					2'b01:    shift_reg <= REG1;
					2'b10:    shift_reg <= REG2;
					2'b11:    shift_reg <= REG3;
					default:  shift_reg <= 0;
				endcase
		else if (state == WRITE_REG)
			if(sdo_change_w)
			shift_reg <= {shift_reg[6:0],1'b0};
	end
	
	wire shift_all;
	wire shift_end;
//	wire sck_half_w;

	reg [1:0] shift_counter_r;
	reg [2:0] send_num_counter_r;
	reg [5:0] spi_half_counter_r;
	always @(posedge clk_i) begin
		if(!rst_n)
			spi_half_counter_r <= 0;
		else if(state == WRITE_REG) begin
			if(spi_half_counter_r == SCK_COUNT_Half-1)
				spi_half_counter_r <= 0;
			else 	
				spi_half_counter_r <= spi_half_counter_r + 1;
		end
		else 
			spi_half_counter_r <= 0;
	end
//	assign sck_half_w = spi_half_counter_r == SCK_COUNT_Half-1;
	reg sck_r;
	always @(posedge clk_i) begin
		if(!rst_n)
			sck_r <= 0;
		else if(state == WRITE_REG) begin 
			if(spi_half_counter_r <= SCK_COUNT_Half/2-1)
				sck_r <= 1;
			else 
				sck_r <= 0;
		end
		else 
			sck_r <= 0;
	end
	assign spi_sck = sck_r;
	
	wire sdo_change_w;
	assign sdo_change_w = (spi_half_counter_r == SCK_COUNT_Half-1) ? 1'b1 : 1'b0;
	
	always @(posedge clk_i) begin
		if(!rst_n)
			send_num_counter_r <= 0;
		else if(state == WRITE_REG) begin
			if(sdo_change_w)
				send_num_counter_r <= send_num_counter_r + 1;
		end
		else 
			send_num_counter_r <= 0;
	end
	assign shift_end = (send_num_counter_r == 7 && sdo_change_w)? 1'b1 : 1'b0;
	
	always @(posedge clk_i) begin
		if(!rst_n)
			shift_counter_r <= 0;
		else if(shift_end)
			shift_counter_r <= shift_counter_r + 1;
	end
	assign shift_all = (shift_end && shift_counter_r == 3) ? 1'b1 : 1'b0;
	
	reg spi_cs_r;
	always @(posedge clk_i) begin
		if(!rst_n)
			spi_cs_r <= 0;
		else if(state == WRITE_REG) 
			spi_cs_r <= 1;
		else 
			spi_cs_r <= 0;
	end
	assign spi_cs = spi_cs_r;
	reg sdo_r;
	assign spi_sdo = sdo_r;
	always @(posedge clk_i) begin
		if(!rst_n)
			sdo_r <= 0;
		else if(state == WRITE_REG) begin
			sdo_r <= shift_reg[7];
		end
		else
			sdo_r <=  0;
	end
	
endmodule

