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

module vga_display(rst, resetloc, clk, R, G, B, HS, VS, R_control, G_control, B_control, up, down, left, right, AN, seg_7, dp, R1, G1, B1, R2, G2, B2);
	//..................
	// Define your parameters, inputs, regs, etc
	//..................
	input rst, clk;
	output reg [2:0] R, G;
	output reg [1:0] B;
	output HS, VS;
	input [2:0] R_control, G_control;
	input [1:0] B_control;
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire [10:0] hballcount, vballcount;
	output [2:0] R1, G1;
	output [1:0] B1; //Gameover's RBG
	
	output [2:0] R2, G2;
	output [1:0] B2; //You win's RBG 
	
	// for led display
	output [3:0] AN;
	output [6:0] seg_7;
	output dp;
	
	// for game over screen, memory interface:
	wire [14:0] addra;
	wire [7:0] douta;
	
	// for you win screen, memory interface:
	wire [14:0] addra2;
	wire [7:0] douta2;
	
	/////////////////////////////////////////
	// State machine parameters	
	parameter S_IDLE = 0;	// 0000 - no button pushed
	parameter S_UP = 1;		// 0001 - the first button pushed	
	parameter S_DOWN = 2;	// 0010 - the second button pushed
	parameter S_LEFT = 4; 	// 0100 - and so on	
	parameter S_RIGHT = 8;	// 1000 - and so on

	reg [3:0] state, next_state;
	////////////////////////////////////////	

	input up, down, left, right, resetloc; 	// 1 bit inputs
	parameter NBITS_COORDS = 11;
	//currentposition variables
	reg [NBITS_COORDS-1:0] x, y, xball, yball, 
		x1brick1, x2brick1, y1brick1, y2brick1,
			x1brick2, x2brick2, y1brick2, y2brick2,
			x1brick3, x2brick3, y1brick3, y2brick3,
			x1brick4, x2brick4, y1brick4, y2brick4,
			x1brick5, x2brick5, y1brick5, y2brick5,
			x1brick6, x2brick6, y1brick6, y2brick6;
	// Your MSB now is x[NBITS_COORDS-1]
	reg slow_clk;					// clock for position update,	
									// if it's too fast, every push
									// of a button willmake your object fly away.

	initial begin					// initial position of the box	
		x = 200; y=400;
		x1brick1 = 11'd320;
		x2brick1 = 11'd370;
		y1brick1 = 11'd200;
		y2brick1 = 11'd220;
		
		x1brick2 = 11'd270;
		x2brick2 = 11'd320;
		y1brick2 = 11'd170;
		y2brick2 = 11'd190;
		
		x1brick3 = 11'd360;
		x2brick3 = 11'd410;
		y1brick3 = 11'd170;
		y2brick3 = 11'd190;
		
		x1brick4 = 11'd230;
		x2brick4 = 11'd280;
		y1brick4 = 11'd140;
		y2brick4 = 11'd160;
		
		x1brick5 = 11'd320;
		x2brick5 = 11'd370;
		y1brick5 = 11'd140;
		y2brick5 = 11'd160;
		
		x1brick6 = 11'd410;
		x2brick6 = 11'd460;
		y1brick6 = 11'd140;
		y2brick6 = 11'd160;

		
	end	

	////////////////////////////////////////////	
	// slow clock for position update - optional
	reg [23:0] slow_count;	
	always @ (posedge clk)begin
		slow_count = slow_count + 1'b1;	
		slow_clk = slow_count[23];
	end	
	/////////////////////////////////////////
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	///////////////////////////////////////////
	// State Machine	
	always @ (posedge slow_clk)begin
		state = next_state;	
	end
	
	// track score for every hit brick
	reg [7:0] score = 0;
	// track times plank misses ball
	reg [1:0] countfailure;

	initial begin					// initial position of the ball	
		xball = 20;
		yball = 20;
		score = 0;
		countfailure = 0;
	end

	reg [10:0] xdot = 11'd8; //ball x step size
	reg [10:0] ydot = 11'd8; //ball y step size
		
	
	always @ (posedge slow_clk)begin
		// wall boundaries for plank
		if (x <= 20) begin
			x = 25;
		end
		if (x + 75 > 570) begin
			x = 495;
		end
		
		if (resetloc == 1)begin // when reset button is pressed
		x = 200;
		y = 200;
		xball = 20;
		yball = 20;
		xdot = 11'd8;
		ydot = 11'd8;
		score = 0;
		countfailure = 0;
		
		x1brick1 = 11'd320;
		x2brick1 = 11'd370;
		y1brick1 = 11'd200;
		y2brick1 = 11'd220;
		
		x1brick2 = 11'd270;
		x2brick2 = 11'd320;
		y1brick2 = 11'd170;
		y2brick2 = 11'd190;
		
		x1brick3 = 11'd360;
		x2brick3 = 11'd410;
		y1brick3 = 11'd170;
		y2brick3 = 11'd190;
		
		x1brick4 = 11'd230;
		x2brick4 = 11'd280;
		y1brick4 = 11'd140;
		y2brick4 = 11'd160;
		
		x1brick5 = 11'd320;
		x2brick5 = 11'd370;
		y1brick5 = 11'd140;
		y2brick5 = 11'd160;
		
		x1brick6 = 11'd410;
		x2brick6 = 11'd460;
		y1brick6 = 11'd140;
		y2brick6 = 11'd160;
		
		end
		
		else if (score == 60) begin // x1brick1 == 0 & x1brick2 == 0 & x1brick3 == 0 & x1brick4 == 0 & x1brick5 == 0 & x1brick6 == 0
			//xball = 100;
			//yball = 100;
			xdot = 0;
			ydot = 0;
			countfailure = 0;
			// YOU WIN
		end
		
		else if (countfailure >= 3) begin // when ball falls below plank 3 times, stop ball. GAME OVER
			//xball = 20;
			//yball = 20;
			xdot = 0;
			ydot = 0;
		end
		
		else if (yball > 435) begin // when ball goes below plank
			countfailure = countfailure + 1'b1;
			xball = 20;
			yball = 20;
			//xdot = 11'd8;
			//ydot = 11'd8;
			//score = 0;
		end
			
		else if (xball > 570 & xdot[10] == 0) begin//right wall collision
			xdot = -xdot;
			xball = xball - 11'd15;
			yball = yball + 11'd5;
			end
			
		else if (xball < 20) begin//left wall collision
			xdot = -xdot;
			xball = 11'd25;
			yball = yball + 11'd5;
			// & xdot[10] == 1'b1
			end
			
		else if (yball >= 390 & yball <= 410 & xball > x & xball <= x+11) begin//bottom_left
			ydot = -ydot;
			xdot = 11'd15;
			xball = xball + xdot;
			yball = yball - 11'd15;
			end
		else if (yball >= 390 & yball <= 410 & xball > x+12 & xball <= x+53) begin//bottom_middle
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball - 11'd15;
			end
		else if (yball >= 390 & yball <= 410 & xball > x+54 & xball <= x+65) begin//bottom_right
			ydot = -ydot;
			xdot = 11'd15;
			xball = xball + xdot;
			yball = yball - 11'd15;
			end
			
		else if (yball < 20) begin//top wall collision
			ydot = -ydot;
			xball = xball + xdot;
			yball = 11'd25;
			// & ydot[10] == 1'b1
			end
			
		// BRICK6 COLLISION
		// top and bottom
		else if (x1brick6!=1'd0 & xball <= x2brick6 & xball >= x1brick6  & yball - 10 <= y2brick6 & yball + 10 >= y1brick6) begin // top and bottom
			x1brick6 = 1'd0;
			x2brick6 = 1'd0;
			y1brick6 = 1'd0;
			y2brick6 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick6!=1'd0 & xball - 10 <= x2brick6 & xball + 10 >= x1brick6 & yball>= y1brick6 & yball <= y2brick6) begin
			x1brick6 = 1'd0;
			x2brick6 = 1'd0;
			y1brick6 = 1'd0;
			y2brick6 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// BRICK5 COLLISION
		// top and bottom
		else if (x1brick5!=1'd0 & xball <= x2brick5 & xball >= x1brick5  & yball - 10 <= y2brick5 & yball + 10 >= y1brick5) begin
			x1brick5 = 1'd0;
			x2brick5 = 1'd0;
			y1brick5 = 1'd0;
			y2brick5 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick5!=1'd0 & xball - 10 <= x2brick5 & xball + 10 >= x1brick5 & yball>= y1brick5 & yball <= y2brick5) begin
			x1brick5 = 1'd0;
			x2brick5 = 1'd0;
			y1brick5 = 1'd0;
			y2brick5 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// BRICK4 COLLISION
		// top and bottom
		else if (x1brick4!=1'd0 & xball <= x2brick4 & xball >= x1brick4 & yball - 10 <= y2brick4 & yball + 10 >= y1brick4) begin
			x1brick4 = 1'd0;
			x2brick4 = 1'd0;
			y1brick4 = 1'd0;
			y2brick4 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick4!=1'd0 & xball - 10 <= x2brick4 & xball + 10 >= x1brick4 & yball>= y1brick5 & yball <= y2brick4) begin
			x1brick4 = 1'd0;
			x2brick4 = 1'd0;
			y1brick4 = 1'd0;
			y2brick4 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// BRICK3 COLLISION
		// top and bottom
		else if (x1brick3!=1'd0 & xball <= x2brick3 & xball >= x1brick3  & yball - 10 <= y2brick3 & yball + 10 >= y1brick3) begin
			x1brick3 = 1'd0;
			x2brick3 = 1'd0;
			y1brick3 = 1'd0;
			y2brick3 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick3!=1'd0 & xball - 10 <= x2brick3 & xball + 10 >= x1brick3 & yball>= y1brick3 & yball <= y2brick3) begin
			x1brick3 = 1'd0;
			x2brick3 = 1'd0;
			y1brick3 = 1'd0;
			y2brick3 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// BRICK2 COLLISION
		// top and bottom
		else if (x1brick2!=1'd0 & xball <= x2brick2 & xball >= x1brick2  & yball - 10 <= y2brick2 & yball + 10 >= y1brick2) begin
			x1brick2 = 1'd0;
			x2brick2 = 1'd0;
			y1brick2 = 1'd0;
			y2brick2 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick2!=1'd0 & xball - 10 <= x2brick2 & xball + 10 >= x1brick2 & yball>= y1brick2 & yball <= y2brick2) begin
			x1brick2 = 1'd0;
			x2brick2 = 1'd0;
			y1brick2 = 1'd0;
			y2brick2 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// BRICK1 COLLISION
		// top and bottom
		else if (x1brick1!=1'd0 & xball <= x2brick1 & xball >= x1brick1  & yball - 10 <= y2brick1 & yball + 10 >= y1brick1) begin
			x1brick1 = 1'd0;
			x2brick1 = 1'd0;
			y1brick1 = 1'd0;
			y2brick1 = 1'd0;
			ydot = -ydot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		// left and right
		else if (x1brick1!=1'd0 & xball - 10 <= x2brick1 & xball + 10 >= x1brick1 & yball>= y1brick1 & yball <= y2brick1) begin
			x1brick1 = 1'd0;
			x2brick1 = 1'd0;
			y1brick1 = 1'd0;
			y2brick1 = 1'd0;
			xdot = -xdot;
			xball = xball + xdot;
			yball = yball + ydot;
			score = score + 10;
		end
		
		/*	
		else if (xball > 20 & xball < 570 & yball > 20) begin // & yball < 510
			xball = xball + xdot;
			yball = yball + ydot;
			end
		*/
		
		else begin
			//countfailure = countfailure + 1;
			xball = xball + xdot;
			yball = yball + ydot;
		end
			
	  /*
	  else
			begin
			xball = 100;
			yball = 100;
			xdot = 0;
			ydot = 0;
			// GAME OVER
			end
			*/
	
		case (state)
			S_IDLE: next_state = {right,left,down,up}; // if input is 0000
			S_UP: begin	// if input is 0001
				y = y - 11'd35;	
				next_state = {right,left,down,up};
			end	
			S_DOWN: begin // if input is 0010
				y = y + 11'd35;
				next_state = {right,left,down,up}; 
				//complete state machine
			end
			S_RIGHT: begin // if input is 0010
				x = x + 11'd35;
				next_state = {right,left,down,up}; 
				//complete state machine
			end
			S_LEFT: begin // if input is 0010
				x = x - 11'd35;
				next_state = {right,left,down,up}; 
				//complete state machine
			end
		endcase


	end
	
	// for bin2bcd
	wire [15:0] bcd_score;
	ec311_ver3_8bit_counter_bin2bcd bin2bcd (
		.bcd_out(bcd_score),
		.bin_in(score)
	 );

	// for clock divider
	 wire clk_out;
	 
	 clock_divider_4 clock_divider (
		.clk_out(clk_out),
		.clk_in(clk)
	 );
	
	// for seven_alternate
	 wire [15:0] big_bin;
	 assign big_bin = bcd_score;
	 wire [3:0] small_bin;
	 
	 seven_alternate seven_alternate(
		.big_bin(big_bin),
		.small_bin(small_bin),
		.AN(AN),
		.clk(clk_out)
	 );
	 
	 // for bin2led7
	 binary_to_segment bin2led7 (
		.bin(small_bin),
		.seven(seg_7)
	 );
	 
	 assign dp = 1'b1;
	 
	///////////////////////////
	
	//call the VGA driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank)
	);
		
	// Game over modules
	vga_bsprite #(.IMAGEWIDTH(344)) sprites_mem(
		.x0(0+100), 
		.y0(0+100),
		.x1(343+100),
		.y1(47+100),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta), 
		.rom_addr(addra), 
		.R(R1), 
		.G(G1), 
		.B(B1), 
		.blank(blank)
	);
	
	game_over_mem gameover_mem (
		.clka(clk_25Mhz), // input clka
		.addra(addra), // input [14 : 0] addra
		.douta(douta) // output [7 : 0] douta
	);
	
	// You win modules
	vga_bsprite #(.IMAGEWIDTH(344)) sprites_mem_2(
		.x0(0+100), 
		.y0(0+100),
		.x1(343+100),
		.y1(47+100),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta2), 
		.rom_addr(addra2), 
		.R(R2), 
		.G(G2), 
		.B(B2), 
		.blank(blank)
	);
	
	youwin_mem win_mem (
		.clka(clk_25Mhz), // input clka
		.addra(addra2), // input [14 : 0] addra
		.douta(douta2) // output [7 : 0] douta
	);

			
	//Complete the figure description
	//movement plus the figure
	
	wire plank;
	assign plank = ~blank & (hcount >= x & hcount <= x+75 & vcount >= 400 & vcount <= 430);
	wire ball;
	assign ball = ~blank & (hcount >= xball & hcount <= xball+10 & vcount >= yball & vcount <= yball+10);
	
	// bricks
	wire brick1;
	assign brick1 = ~blank & (hcount >= x1brick1 & hcount <= x2brick1 & vcount >= y1brick1 & vcount <= y2brick1);
	wire brick2;
	assign brick2 = ~blank & (hcount >= x1brick2 & hcount <= x2brick2 & vcount >= y1brick2 & vcount <= y2brick2);
	wire brick3;
	assign brick3 = ~blank & (hcount >= x1brick3 & hcount <= x2brick3 & vcount >= y1brick3 & vcount <= y2brick3);
	wire brick4;
	assign brick4 = ~blank & (hcount >= x1brick4 & hcount <= x2brick4 & vcount >= y1brick4 & vcount <= y2brick4);
	wire brick5;
	assign brick5 = ~blank & (hcount >= x1brick5 & hcount <= x2brick5 & vcount >= y1brick5 & vcount <= y2brick5);
	wire brick6;
	assign brick6 = ~blank & (hcount >= x1brick6 & hcount <= x2brick6 & vcount >= y1brick6 & vcount <= y2brick6);

	
		// send colors:
	always @ (posedge clk) begin
	
		// enable you win screen
		if (score == 60) begin
			R = R2;
			G = G2;
			B = B2;
		end
		
		// enable game over screen
		else if (countfailure >= 3) begin
			R = R1;
			G = G1;
			B = B1;
		end
		
		// enable plank and ball
		else if (plank) begin	// if you are within the valid region
			R = R_control;
			G = G_control;
			B = B_control;
		end
		else if (ball) begin
			R = R_control;
			G = G_control;
			B = B_control;
		end
		
		// enable all bricks
		else if (brick1) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else if (brick2) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else if (brick3) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else if (brick4) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else if (brick5) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else if (brick6) begin
			R = R_control+1;
			G = G_control+1;
			B = B_control+1;
		end
		else begin	// if you are outside the valid region
			R = 0;
			G = 0;
			B = 0;
		end
	end

		
endmodule
