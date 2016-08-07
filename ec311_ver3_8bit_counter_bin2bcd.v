`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:48:34 12/06/2015 
// Design Name: 
// Module Name:    ec311_ver3_8bit_counter_bin2bcd 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ec311_ver3_8bit_counter_bin2bcd(bcd_out, bin_in);
	output [15:0] bcd_out;
   input [7:0] bin_in;
	
	wire [3:0] bcd_thousands; // for thousands place in display
	wire [7:0] bcd_hundreds;
	wire [7:0] bcd_tens;
	wire [7:0] bcd_ones;
	
	wire [7:0] tens_part;
	
	assign bcd_thousands = 4'b0000; // for lab3 counter, max number is 255, so no thousands needed but will display
	
	assign bcd_hundreds = bin_in / 8'b01100100; // bin_in / dec(100)
	assign tens_part = bin_in % 8'b01100100; // bin_in % dec(100)
	assign bcd_tens = tens_part / 8'b00001010; // tens_part / dec(10)
	assign bcd_ones = tens_part % 8'b00001010; // tens_part % dec(10)
	
	assign bcd_out = {bcd_thousands, bcd_hundreds[3:0], bcd_tens[3:0], bcd_ones[3:0]};


endmodule
