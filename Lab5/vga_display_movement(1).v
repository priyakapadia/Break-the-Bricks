//////////////////////////////////////////////////////////////////////////////////
// Company: 		Boston University
// Engineer:		Zafar Takhirov
// 
// Create Date:		11/18/2015
// Design Name: 	EC311 Support Files
// Module Name:    	vga_display
// Project Name: 	Lab5 / Project
// Description:
//					This module is the modified version of the vga_display that
//					includes the movement of the box. In addition to the inputs
//					in the original file, this file also receives the directional
//					controls: up, down, left, right
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: INCOMPLETE CODE
//
//////////////////////////////////////////////////////////////////////////////////

module vga_display(rst, clk, R, G, B, HS, VS, R_control, G_control, B_control, up, down, left, right);
	input rst;	// global reset
	input clk;	// 100MHz clk
	
	// color inputs for a given pixel
	
	input [2:0] R_control, G_control;
	input [1:0] B_control; 
	
	// color outputs to show on display (current pixel)
	output reg [2:0] R, G;
	output reg [1:0] B;
	
	// Synchronization signals
	output HS;
	output VS;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	wire figure;	// the figure you want to display
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	
	
	// send colors:
	always @ (posedge clk) begin
		if (figure) begin	// if you are within the valid region
			R = R_control;
			G = G_control;
			B = B_control;
		end
		else begin	// if you are outside the valid region
			R = 0;
			G = 0;
			B = 0;
		end
	end
	/////////////////////////////////////////
	// State machine parameters	
	parameter S_IDLE = 0;	// 0000 - no button pushed
	parameter S_UP = 1;		// 0001 - the first button pushed	
	parameter S_DOWN = 2;	// 0010 - the second button pushed
	parameter S_LEFT = 4; 	// 0100 - and so on	
	parameter S_RIGHT = 8;	// 1000 - and so on

	reg [3:0] state, next_state;
	////////////////////////////////////////	

	input up, down, left, right; 	// 1 bit inputs	
	reg [10:0] x, y;				//currentposition variables
	reg slow_clk;					// clock for position update,	
									// if it’s too fast, every push
									// of a button willmake your object fly away.

	initial begin					// initial position of the box	
		x = 200; y=100;
	end	

	////////////////////////////////////////////	
	// slow clock for position update - optional
	reg [25:0] slow_count;	
	always @ (posedge clk)begin
		slow_count = slow_count + 1'b1;	
		slow_clk = slow_count[23];
	end	
	/////////////////////////////////////////

	///////////////////////////////////////////
	// State Machine	
	always @ (posedge slow_clk)begin
		state = next_state;	
	end

	always @ (posedge slow_clk) begin	
		case (state)
			S_IDLE: next_state = {right,left,down,up}; // if input is 0000
			S_UP: begin	// if input is 0001
				y = y - 5;	
				next_state = {right,left,down,up};
			end	
			S_DOWN: begin // if input is 0010
				y = y + 5;	
				next_state = {right,left,down,up};
			end
			S_RIGHT: begin // if input is 0011
				x = x + 5;	
				next_state = {right,left,down,up};
			end
			S_LEFT: begin // if input is 0100
				x = x - 5;	
				next_state = {right,left,down,up};
			end
			//complete state machine
		endcase
	end
 
	//call the VGA driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
	
	//Complete the figure description & create a box:
	assign figure = ~blank & (hcount >= 300 & hcount <= 500 & vcount >= 167 & vcount <= 367);
	
endmodule