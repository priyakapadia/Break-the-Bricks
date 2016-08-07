//////////////////////////////////////////////////////////////////////////////////
// Company: 		Boston University
// Engineer:		Zafar Takhirov
// 
// Create Date:		11/18/2015
// Design Name: 	EC311 Support Files
// Module Name:    	binary_to_segment
// Project Name: 	Lab4 / Project
// Description:
//					This module receives a 4-bit input and converts it to 7-segment
//					LED (HEX)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: INCOMPLETE CODE
//
//////////////////////////////////////////////////////////////////////////////////

module binary_to_segment(bin,seven);	
input [3:0] bin;
output reg [6:0] seven; //Assume MSB is A, and LSB is G	

initial	//Initial block, used for correct simulations	
	seven=0;

always @ (*)
	case(bin)	
		0:	seven = 7'b0000001;
		1:	seven = 7'b1001111;
		2: seven = 7'b0010010;
		3: seven = 7'b0000110;
		4: seven = 7'b1001100;
		5: seven = 7'b0100100;
		6: seven = 7'b0100000;
		7: seven = 7'b0001111;
		8: seven = 7'b0000000;
		9: seven = 7'b0000100;
		
		10: seven = 7'b0001000;
		11: seven = 7'b1100000;
		12: seven = 7'b0110001;
		13: seven = 7'b1000010;
		14: seven = 7'b0110000;
		15: seven = 7'b0111000; // This will show F	
		//remember 0 means ‘‘light-up’’

		default: seven = 7'b1001000;	
	endcase
endmodule
