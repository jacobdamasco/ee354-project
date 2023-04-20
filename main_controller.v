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
	
	// char position
	reg [9:0] cx_pos, cy_pos;
	reg [7:0] jump_ctr;

	// platform positions
	reg [9:0] px1_pos, py1_pos;
	reg [9:0] px2_pos, py2_pos;
	reg [9:0] px3_pos, py3_pos;
	reg [9:0] px4_pos, py4_pos;
	reg [9:0] px5_pos, py5_pos;
	
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
	assign platform1_fill = (vCount >= py1_pos) &&
							(vCount <= py1_pos+15) &&
							(hCount >= px1_pos-25) &&
							(hCount <= px1_pos+25);

	assign platform2_fill = (vCount >= py2_pos) &&
							(vCount <= py2_pos+15) &&
							(hCount >= px2_pos-25) &&
							(hCount <= px2_pos+25);

	assign platform3_fill = (vCount >= py3_pos) &&
							(vCount <= py3_pos+15) &&
							(hCount >= px3_pos-25) &&
							(hCount <= px3_pos+25);

	assign platform4_fill = (vCount >= py4_pos) &&
							(vCount <= py4_pos+15) &&
							(hCount >= px4_pos-25) &&
							(hCount <= px4_pos+25);

	assign platform5_fill = (vCount >= py5_pos) &&
							(vCount <= py5_pos+15) &&
							(hCount >= px5_pos-25) &&
							(hCount <= px5_pos+25);

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
			px1_pos <= 197;
			py1_pos <= 56;

            px2_pos <= 624;
            py2_pos <= 312;

            px3_pos <= 588;
            py3_pos <= 473;

            px4_pos <= 500;
            py4_pos <= 234;

            px5_pos <= 217;
            py5_pos <= 466;
		end
	end

endmodule
