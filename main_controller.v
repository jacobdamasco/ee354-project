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

	// rng
	reg [9:0] seed;
	reg [9:0] rand_num;

	// collision detection
	reg collision;
	reg block_red;
	
	/************************************************/ 
	/* COLORS 										*/
	/************************************************/
	// hex guide: A10 B11 C12 D13 E14 F15
	parameter RED = 12'b1111_0000_0000; // F00
	parameter OFF_RED = 12'b1100_0011_0011; // C33
	parameter DARK_GREEN = 12'b0010_0110_0010; // 262
    parameter PURPLE = 12'b0111_1100_0011; // 7C3
	parameter GREEN = 12'b1000_0010_1101; // 82D
	parameter PASTEL_BLUE = 12'b0110_1000_1111; // 68F
	parameter WHITE = 12'b1111_1111_1111;


	/************************************************/ 
	/* CHARACTER POSITIONING 						*/
	/************************************************/
	assign char_fill = doodler_feet || doodler_vert || doodler_hor;
	// (vCount >= cy_pos) && (vCount <= cy_pos+64) && (hCount >= cx_pos) && (hCount <= cx_pos+64);

	assign doodler_feet = ((hCount >= cx_pos+10) && (hCount <= cx_pos+11) && (vCount >= cy_pos+57) && (vCount <= cy_pos+61)) || 
	((hCount >= cx_pos+18) && (hCount <= cx_pos+19) && (vCount >= cy_pos+55) && (vCount <= cy_pos+62)) ||
	((hCount >= cx_pos+27) && (hCount <= cx_pos+28) && (vCount >= cy_pos+55) && (vCount <= cy_pos+62)) ||
	((hCount >= cx_pos+35) && (hCount <= cx_pos+36) && (vCount >= cy_pos+54) && (vCount <= cy_pos+59)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+31) && (vCount >= cy_pos+62) && (vCount <= cy_pos+63)) ||
	((hCount >= cx_pos+37) && (hCount <= cx_pos+42) && (vCount >= cy_pos+60) && (vCount <= cy_pos+61)) ||
	((hCount >= cx_pos+20) && (hCount <= cx_pos+23) && (vCount >= cy_pos+63) && (vCount <= cy_pos+64)) ||
	((hCount >= cx_pos+12) && (hCount <= cx_pos+15) && (vCount >= cy_pos+63) && (vCount <= cy_pos+64)) ||
	((hCount == cx_pos+11) && (vCount >= cy_pos+62) && (vCount <= cy_pos+63)) ||
	((hCount == cx_pos+19) && (vCount == cy_pos+63)) ||
	((hCount == cx_pos+36) && (vCount == cy_pos+60));

	assign doodler_vert = ((hCount == cx_pos+6) && (vCount >= cy_pos+37) && (vCount <= cy_pos+54)) ||
	((hCount == cx_pos+4) && (vCount >= cy_pos+21) && (vCount <= cy_pos+30)) ||
	((hCount == cx_pos+5) && (vCount >= cy_pos+17) && (vCount <= cy_pos+21)) ||
	((hCount == cx_pos+40) && (vCount >= cy_pos+33) && (vCount <= cy_pos+53)) ||
	((hCount == cx_pos+6) && (vCount >= cy_pos+14) && (vCount <= cy_pos+17)) ||
	((hCount == cx_pos+6) && (vCount >= cy_pos+37) && (vCount <= cy_pos+54)) ||
	((hCount == cx_pos+7) && (vCount >= cy_pos+12) && (vCount <= cy_pos+14)) ||
	((hCount == cx_pos+8) && (vCount >= cy_pos+11) && (vCount <= cy_pos+12)) ||
	((hCount == cx_pos+9) && (vCount >= cy_pos+10) && (vCount <= cy_pos+11)) ||
	((hCount == cx_pos+10) && (vCount >= cy_pos+9) && (vCount <= cy_pos+10)) ||
	((hCount == cx_pos+11) && (vCount >= cy_pos+7) && (vCount <= cy_pos+8)) ||
	((hCount == cx_pos+12) && (vCount == cy_pos+7)) ||
	((hCount == cx_pos+13) && (vCount == cy_pos+6)) ||
	((hCount == cx_pos+40) && (vCount >= cy_pos+30) && (vCount <= cy_pos+37)) ||
	((hCount == cx_pos+40) && (vCount >= cy_pos+16) && (vCount <= cy_pos+18)) ||
	((hCount == cx_pos+42) && (vCount >= cy_pos+20) && (vCount <= cy_pos+21)) ||
	((hCount == cx_pos+43) && (vCount >= cy_pos+21) && (vCount <= cy_pos+22)) ||
	((hCount == cx_pos+44) && (vCount >= cy_pos+22) && (vCount <= cy_pos+23)) ||
	((hCount == cx_pos+56) && (vCount >= cy_pos+24) && (vCount <= cy_pos+30)) ||
	((hCount == cx_pos+61) && (vCount >= cy_pos+24) && (vCount <= cy_pos+32)) ||
	((hCount == cx_pos+30) && (vCount >= cy_pos+20) && (vCount <= cy_pos+21)) ||
	((hCount == cx_pos+31) && (vCount >= cy_pos+19) && (vCount <= cy_pos+22)) ||
	((hCount == cx_pos+35) && (vCount >= cy_pos+20) && (vCount <= cy_pos+21)) ||
	((hCount == cx_pos+36) && (vCount >= cy_pos+19) && (vCount <= cy_pos+22)) ||
	((hCount == cx_pos+41) && (vCount >= cy_pos+32) && (vCount <= cy_pos+33)) ||
	((hCount == cx_pos+42) && (vCount >= cy_pos+31) && (vCount <= cy_pos+32)) ||
	((hCount == cx_pos+60) && (vCount >= cy_pos+22) && (vCount <= cy_pos+23)) ||
	((hCount == cx_pos+4) && (vCount >= cy_pos+37) && (vCount <= cy_pos+38));

	assign doodler_hor = ((hCount >= cx_pos+14) && (hCount <= cx_pos+15) && (vCount == cy_pos+5)) ||
	((hCount >= cx_pos+15) && (hCount <= cx_pos+16) && (vCount == cy_pos+4)) ||
	((hCount >= cx_pos+16) && (hCount <= cx_pos+18) && (vCount == cy_pos+3)) ||
	((hCount >= cx_pos+18) && (hCount <= cx_pos+27) && (vCount == cy_pos+2)) ||
	((hCount >= cx_pos+18) && (hCount <= cx_pos+27) && (vCount == cy_pos+2)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+30) && (vCount == cy_pos+3)) ||
	((hCount >= cx_pos+30) && (hCount <= cx_pos+31) && (vCount == cy_pos+4)) ||
	((hCount >= cx_pos+31) && (hCount <= cx_pos+32) && (vCount == cy_pos+5)) ||
	((hCount >= cx_pos+32) && (hCount <= cx_pos+33) && (vCount == cy_pos+6)) ||
	((hCount >= cx_pos+33) && (hCount <= cx_pos+34) && (vCount == cy_pos+7)) ||
	((hCount >= cx_pos+34) && (hCount <= cx_pos+35) && (vCount == cy_pos+8)) ||
	((hCount >= cx_pos+35) && (hCount <= cx_pos+36) && (vCount == cy_pos+9)) ||
	((hCount >= cx_pos+36) && (hCount <= cx_pos+37) && (vCount == cy_pos+10)) ||
	((hCount == cx_pos+37) && (vCount == cy_pos+10)) ||
	((hCount >= cx_pos+37) && (hCount <= cx_pos+38) && (vCount == cy_pos+12)) ||
	((hCount >= cx_pos+38) && (hCount <= cx_pos+39) && (vCount == cy_pos+13)) ||
	((hCount == cx_pos+39) && (vCount == cy_pos+14)) ||
	((hCount >= cx_pos+39) && (hCount <= cx_pos+40) && (vCount == cy_pos+15)) ||
	((hCount == cx_pos+41) && (vCount == cy_pos+18)) ||
	((hCount >= cx_pos+41) && (hCount <= cx_pos+42) && (vCount == cy_pos+19)) ||
	((hCount >= cx_pos+45) && (hCount <= cx_pos+47) && (vCount == cy_pos+23)) ||
	((hCount >= cx_pos+47) && (hCount <= cx_pos+53) && (vCount == cy_pos+24)) ||
	((hCount >= cx_pos+53) && (hCount <= cx_pos+56) && (vCount == cy_pos+23)) ||
	((hCount >= cx_pos+44) && (hCount <= cx_pos+52) && (vCount == cy_pos+30)) ||
	((hCount >= cx_pos+53) && (hCount <= cx_pos+55) && (vCount == cy_pos+31)) ||
	((hCount >= cx_pos+59) && (hCount <= cx_pos+60) && (vCount == cy_pos+33)) ||
	((hCount >= cx_pos+57) && (hCount <= cx_pos+59) && (vCount == cy_pos+21)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+39) && (vCount == cy_pos+37)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+39) && (vCount == cy_pos+44)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+39) && (vCount == cy_pos+50)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+39) && (vCount == cy_pos+53)) ||
	((hCount >= cx_pos+15) && (hCount <= cx_pos+28) && (vCount == cy_pos+54)) ||
	((hCount >= cx_pos+9) && (hCount <= cx_pos+15) && (vCount == cy_pos+55)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+9) && (vCount == cy_pos+54)) ||
	((hCount == cx_pos+5) && (vCount == cy_pos+39)) ||
	((hCount == cx_pos+43) && (vCount == cy_pos+31)) ||
	((hCount == cx_pos+57) && (vCount == cy_pos+22)) ||
	((hCount == cx_pos+57) && (vCount == cy_pos+31)) ||
	((hCount == cx_pos+58) && (vCount == cy_pos+32));


	/************************************************/ 
	/* PLATFORM POSITIONING 						*/
	/************************************************/
	assign platform1_fill = (vCount >= py1_pos) &&
							(vCount <= py1_pos+15) &&
							(hCount >= px1_pos-50) &&
							(hCount <= px1_pos+50);

	assign platform2_fill = (vCount >= py2_pos) &&
							(vCount <= py2_pos+15) &&
							(hCount >= px2_pos-50) &&
							(hCount <= px2_pos+50);

	assign platform3_fill = (vCount >= py3_pos) &&
							(vCount <= py3_pos+15) &&
							(hCount >= px3_pos-50) &&
							(hCount <= px3_pos+50);

	assign platform4_fill = (vCount >= py4_pos) &&
							(vCount <= py4_pos+15) &&
							(hCount >= px4_pos-50) &&
							(hCount <= px4_pos+50);

	assign platform5_fill = (vCount >= py5_pos) &&
							(vCount <= py5_pos+15) &&
							(hCount >= px5_pos-50) &&
							(hCount <= px5_pos+50);


	/* when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display */
	/************************************************/ 
	/* OUTPUTTING RGB LOGIC 						*/
	/************************************************/
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


	/************************************************/ 
	/* COUNTERS 									*/
	/************************************************/
	always@(posedge clk, posedge rst)
	begin : jump_counter
		if (rst) begin
			jump_ctr <= 0;
		end
		else if (clk) begin
			jump_ctr <= jump_ctr + 1'b1;
			if (jump_ctr == 128 || collision == 1) begin
				jump_ctr <= 0;
			end
		end
	end
	

	always @(posedge clk) 
	begin : rng
		if (rst) begin
			seed <= 0;
			rand_num <= 0;
		end else begin
			seed <= seed + 1; // Increment seed for next iteration
			rand_num <= (seed * 437) % 541 + 190; // Generate random number between 190 and 730
			if (rand_num < 190)
				rand_num <= rand_num + 190;
			else if (rand_num > 730)
				rand_num <= rand_num - 100;
		end
	end


	/************************************************/ 
	/* CHAR MOVEMENT		 						*/
	/************************************************/
	always@(posedge clk, posedge rst) 
	begin : char_mvmt
		// starting position of char
		if(rst) begin 
			cx_pos <= 464;
			cy_pos <= 500;
			collision <= 0;
		end
		else if (clk) begin
			// controlling the automatic jumping
			if (jump_ctr < 64 && collision == 0) begin
				cy_pos <= cy_pos - 2;
			end
			else if (jump_ctr > 64 && collision == 0) begin
				cy_pos <= cy_pos + 2;
				// check for collision on the way down
				if ((cx_pos+32 <= (px1_pos + 50)) && (cx_pos+32 >= (px1_pos - 50)) && (cy_pos+64 == py1_pos + 1))
					collision <= 1;
				else if ((cx_pos+32 <= (px2_pos + 50)) && (cx_pos+32 >= (px2_pos - 50)) && (cy_pos+64 == py2_pos + 1))
					collision <= 1;
				else if ((cx_pos+32 <= (px3_pos + 50)) && (cx_pos+32 >= (px3_pos - 50)) && (cy_pos+64 == py3_pos + 1))
					collision <= 1;
				else if ((cx_pos+32 <= (px4_pos + 50)) && (cx_pos+32 >= (px4_pos - 50)) && (cy_pos+64 == py4_pos + 1))
					collision <= 1;
				else if ((cx_pos+32 <= (px5_pos + 50)) && (cx_pos+32 >= (px5_pos - 50)) && (cy_pos+64 == py5_pos + 1))
					collision <= 1;
			end

			if (collision) begin
				if ((cx_pos+32 <= (px1_pos + 50)) && (cx_pos+32 >= (px1_pos - 50)) && (cy_pos+64 == py1_pos + 1))
					cy_pos <= py1_pos - 64 + 1;
				else if ((cx_pos+32 <= (px2_pos + 50)) && (cx_pos+32 >= (px2_pos - 50)) && (cy_pos+64 == py2_pos + 1))
					cy_pos <= py2_pos - 64 + 1;
				else if ((cx_pos+32 <= (px3_pos + 50)) && (cx_pos+32 >= (px3_pos - 50)) && (cy_pos+64 == py3_pos + 1))
					cy_pos <= py3_pos - 64 + 1;
				else if ((cx_pos+32 <= (px4_pos + 50)) && (cx_pos+32 >= (px4_pos - 50)) && (cy_pos+64 == py4_pos + 1))
					cy_pos <= py4_pos - 64 + 1;
				else if ((cx_pos+32 <= (px5_pos + 50)) && (cx_pos+32 >= (px5_pos - 50)) && (cy_pos+64 == py5_pos + 1))
					cy_pos <= py5_pos - 64 + 1;
				collision <= 0; 
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
	begin : platform_mvmt
		// starting position of char
		if(rst) begin 
			px1_pos <= 197;
			py1_pos <= 100;

            px2_pos <= 624;
            py2_pos <= 312;

            px3_pos <= 588;
            py3_pos <= 473;

            px4_pos <= 500;
            py4_pos <= 234;

            px5_pos <= 217;
            py5_pos <= 466;
		end
		else if (clk) begin
			// if a collision is detected
			if (collision) begin
				py1_pos <= py1_pos + 10;
				py2_pos <= py2_pos + 10;
				py3_pos <= py3_pos + 10;
				py4_pos <= py4_pos + 10;
				py5_pos <= py5_pos + 10;
			end
    
			if (py1_pos > 516) begin
				py1_pos <= 50;
				px1_pos <= rand_num; 
			end 
			if (py2_pos > 516) begin
				py2_pos <= 50;
				px2_pos <= rand_num; 
			end 
			if (py3_pos > 516) begin
				py3_pos <= 50;
				px3_pos <= rand_num; 
			end 
			if (py4_pos > 516) begin
				py4_pos <= 50;
				px4_pos <= rand_num; 
			end 
			if (py5_pos > 516) begin
				py5_pos <= 50;
				px5_pos <= rand_num; 
			end
		end
	end

endmodule
