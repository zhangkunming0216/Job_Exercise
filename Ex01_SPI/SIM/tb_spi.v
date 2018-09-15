`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/15 14:15:45
// Design Name: 
// Module Name: tb_spi
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


module tb_spi#(
	parameter                     SPI_FRE = 10,
	parameter                     CLK_FRE = 100
)(
);
	reg                         clk_i;
	reg                         rst_n;
	reg                         work_en;
	wire 						spi_cs;
	wire 						spi_sck;
	wire 						spi_sdo;
//instance 
 spi_v1#(
	.SPI_FRE (SPI_FRE),
	.CLK_FRE (CLK_FRE)
)spi_v1_inst(
	.clk_i    (clk_i  ),
	.rst_n    (rst_n  ),

	.work_en  (work_en),
	.spi_cs   (spi_cs ),
	.spi_sck  (spi_sck),
	.spi_sdo  (spi_sdo)
    );
 //clk_i
	always #1 clk_i = ~clk_i;
	
	initial begin
		clk_i = 0;
		rst_n = 0;
		#50
		rst_n = 1;
		#100
		work_en = 1;
	end


endmodule
