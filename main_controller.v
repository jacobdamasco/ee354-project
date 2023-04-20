`timescale 1ns / 1ps

module main_controller(
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

	/* CHARACTER POSITIONING */
	assign char_fill = 	(vCount >= cy_pos) && 
						(vCount <= cy_pos+50) && 
						(hCount >= cx_pos-15) && 
						(hCount <= cx_pos+15);
	
	/* PLATFORM POSITIONING */
	assign platform1_fill = (vCount >= y1_pos) &&
							(vCount <= y1_pos+15) &&
							(hCount >= x1_pos-25) &&
							(hCount <= x1_pos+25);

	assign platform2_fill = (vCount >= y2_pos) &&
							(vCount <= y2_pos+15) &&
							(hCount >= x2_pos-25) &&
							(hCount <= x2_pos+25);

	assign platform3_fill = (vCount >= y3_pos) &&
							(vCount <= y3_pos+15) &&
							(hCount >= x3_pos-25) &&
							(hCount <= x3_pos+25);

	assign platform4_fill = (vCount >= y4_pos) &&
							(vCount <= y4_pos+15) &&
							(hCount >= x4_pos-25) &&
							(hCount <= x4_pos+25);

	assign platform5_fill = (vCount >= y5_pos) &&
							(vCount <= y5_pos+15) &&
							(hCount >= x5_pos-25) &&
							(hCount <= x5_pos+25);

	/* when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display */
	always@ (*) 
	begin : fill_blocks
		if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (char_fill)
			rgb = PURPLE;
    	else if (platform1_fill || platform2_fill || platform3_fill) 
            rgb = GREEN;
        else if (platform4_fill || platform5_fill) 
            rgb = OFF_RED;
		else	
			rgb = WHITE;
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
	begin : char_mvmt_controls
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

	always@(posedge clk, posedge rst) 
	begin : platform_positioning
		// starting position of char
		if(rst) begin 
			x1_pos <= 197;
			y1_pos <= 56;

            x2_pos <= 624;
            y2_pos <= 312;

            x3_pos <= 588;
            y3_pos <= 473;

            x4_pos <= 500;
            y4_pos <= 234;

            x5_pos <= 217;
            y5_pos <= 466;
		end
	end

endmodule
