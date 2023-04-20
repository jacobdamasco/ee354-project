`timescale 1ns / 1ps

module char_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire[11:0] platform_rgb;
	
	// char position
	reg [9:0] cx_pos, cy_pos;
	reg [7:0] jump_ctr;

	
	// colors
	// hex guide: A10 B11 C12 D13 E14 F15
	parameter RED = 12'b1111_0000_0000; // F00
	parameter OFF_RED = 12'b1100_0011_0011; // C33
	parameter DARK_GREEN = 12'b0010_0110_0010; // 262
    parameter GREEN = 12'b0111_1100_0011; // 7C3
	parameter PURPLE = 12'b1000_0010_1101; // 82D
	parameter PASTEL_BLUE = 12'b0110_1000_1111; // 68F
	parameter WHITE = 12'b1111_1111_1111;

	// fill in character w color from always block above (currently a 10 by 10 square)
	assign char_fill = 	(vCount >= cy_pos) && 
						(vCount <= cy_pos+50) && 
						(hCount >= cx_pos-15) && 
						(hCount <= cx_pos+15);

	/* when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display */
	always@ (*) 
	begin : fill_char
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (char_fill)
			rgb = PURPLE; 
		else	
			rgb = platform_rgb;
	end


	always@(posedge clk, posedge rst)
	begin : jump_counter
		if (rst) begin
			jump_ctr <= 0;
		end
		else if (clk) begin
			jump_ctr <= jump_ctr + 1'b1;
			if (jump_ctr == 128) begin
				jump_ctr <= 0;
			end
		end
	end
	
	always@(posedge clk, posedge rst) 
	begin : main_mvmt_controls
		// starting position of char
		if(rst) begin 
			cx_pos <= 464;
			cy_pos <= 464;
		end
		else if (clk) begin
			// controlling the automatic jumping
			if (jump_ctr < 64) begin
				cy_pos <= cy_pos - 2;
			end
			else if (jump_ctr > 64) begin
				cy_pos <= cy_pos + 2;
			end

			// controls
			if (right) begin
				cx_pos <= cx_pos+2; 
				if (cx_pos == 766)
					cx_pos <= 766;
			end
			else if(left) begin
				cx_pos <= cx_pos-2;
				if(cx_pos == 160)
					cx_pos <= 160;
			end
		end
	end

endmodule
