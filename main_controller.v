`timescale 1ns / 1ps

module main_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output reg [15:0] score
   );

	wire block_fill;
	
	// char position
	reg [9:0] cx_pos, cy_pos;
	reg [7:0] jump_ctr;

	// platform positions
	// green blocks
	reg [9:0] px1_pos, py1_pos;
	reg [9:0] px2_pos, py2_pos;
	reg [9:0] px3_pos, py3_pos;
	reg [9:0] px6_pos, py6_pos;
	reg [9:0] px7_pos, py7_pos;
	reg [9:0] px8_pos, py8_pos;

	// red blocks
	reg [9:0] px4_pos, py4_pos;
	reg [9:0] px5_pos, py5_pos;

	// end screen positions;
	reg [9:0] endx_pos, endy_pos;
	reg [9:0] finx_pos, finy_pos;

	// rng
	reg [9:0] seed;
	reg [9:0] rand_num;

	// collision detection
	reg collision;
	reg red_hit;
	reg [15:0] score;

	// game over
	reg game_over;

	// inital block
	initial begin
		score = 15'd0;
	end
	
	/************************************************/ 
	/* COLORS 										*/
	/************************************************/
	// hex guide: A10 B11 C12 D13 E14 F15
	// [11:7] = red, [7:4] = blue, [3:0] = green
	parameter BLACK = 12'b0000_0000_0000; // 000
	parameter RED = 12'b1111_0000_0000; // F00
	parameter OFF_RED = 12'b1100_0011_0011; // C33
	parameter GREEN = 12'b1000_0010_1101; // 82D
	parameter CLOTHES_COLOR = 12'b0111_0100_1001; // 794
	parameter BODY_COLOR = 12'b1011_0100_1100; //BC4
	parameter WHITE = 12'b1111_1111_1111; // FFF


	/************************************************/ 
	/* CHARACTER POSITIONING 						*/
	/************************************************/
	assign char_outline = doodler_feet || doodler_vert || doodler_hor;
	// (vCount >= cy_pos) && (vCount <= cy_pos+64) && (hCount >= cx_pos) && (hCount <= cx_pos+64);

	assign doodler_clothes = ((hCount >= cx_pos+7) && (hCount <= cx_pos+39) && (vCount >= cy_pos+38) && (vCount <= cy_pos+43)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+39) && (vCount >= cy_pos+45) && (vCount <= cy_pos+49)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+27) && (vCount >= cy_pos+51) && (vCount <= cy_pos+53)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+39) && (vCount >= cy_pos+51) && (vCount <= cy_pos+52)) ||
	((hCount >= cx_pos+10) && (hCount <= cx_pos+14) && (vCount == cy_pos+54));

	assign doodler_body = ((hCount >= cx_pos+6) && (hCount <= cx_pos+39) && (vCount >= cy_pos+23) && (vCount <= cy_pos+36)) ||
	((hCount >= cx_pos+40) && (hCount <= cx_pos+55) && (vCount >= cy_pos+25) && (vCount <= cy_pos+29)) ||
	((hCount >= cx_pos+57) && (hCount <= cx_pos+60) && (vCount >= cy_pos+24) && (vCount <= cy_pos+30)) ||
	((hCount >= cx_pos+6) && (hCount <= cx_pos+29) && (vCount >= cy_pos+18) && (vCount <= cy_pos+22)) ||
	((hCount >= cx_pos+5) && (hCount <= cx_pos+10) && (vCount >= cy_pos+22) && (vCount <= cy_pos+29)) ||
	((hCount >= cx_pos+32) && (hCount <= cx_pos+34) && (vCount >= cy_pos+9) && (vCount <= cy_pos+22)) ||
	((hCount >= cx_pos+7) && (hCount <= cx_pos+31) && (vCount >= cy_pos+15) && (vCount <= cy_pos+18)) ||
	((hCount >= cx_pos+8) && (hCount <= cx_pos+37) && (vCount >= cy_pos+13) && (vCount <= cy_pos+14)) ||
	((hCount >= cx_pos+10) && (hCount <= cx_pos+36) && (vCount >= cy_pos+11) && (vCount <= cy_pos+12)) ||
	((hCount >= cx_pos+20) && (hCount <= cx_pos+27) && (vCount >= cy_pos+3) && (vCount <= cy_pos+10)) ||
	((hCount >= cx_pos+13) && (hCount <= cx_pos+19) && (vCount >= cy_pos+7) && (vCount <= cy_pos+10)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+31) && (vCount >= cy_pos+6) && (vCount <= cy_pos+10)) ||
	((hCount >= cx_pos+11) && (hCount <= cx_pos+14) && (vCount >= cy_pos+9) && (vCount <= cy_pos+13)) ||
	((hCount >= cx_pos+11) && (hCount <= cx_pos+14) && (vCount >= cy_pos+9) && (vCount <= cy_pos+13)) ||
	((hCount == cx_pos+12) && (vCount == cy_pos+8)) ||
	((hCount == cx_pos+30) && (vCount == cy_pos+22)) ||
	((hCount == cx_pos+30) && (vCount == cy_pos+19)) ||
	((hCount == cx_pos+35) && (vCount == cy_pos+22)) ||
	((hCount == cx_pos+35) && (vCount == cy_pos+19)) ||
	((hCount == cx_pos+35) && (vCount == cy_pos+10)) ||
	((hCount == cx_pos+30) && (vCount == cy_pos+5)) ||
	((hCount == cx_pos+16) && (vCount == cy_pos+5)) ||
	((hCount == cx_pos+32) && (vCount == cy_pos+7)) ||
	((hCount == cx_pos+38) && (vCount == cy_pos+14)) ||
	((hCount == cx_pos+40) && (vCount == cy_pos+32)) ||
	((hCount == cx_pos+53) && (vCount == cy_pos+30)) ||
	((hCount == cx_pos+58) && (vCount == cy_pos+31)) ||
	((hCount == cx_pos+57) && (vCount == cy_pos+23)) ||
	((hCount == cx_pos+40) && (vCount == cy_pos+19)) ||
	((hCount == cx_pos+42) && (vCount == cy_pos+22)) ||
	((hCount >= cx_pos+11) && (hCount <= cx_pos+14) && (vCount >= cy_pos+9) && (vCount <= cy_pos+13)) ||
	((hCount >= cx_pos+14) && (hCount <= cx_pos+17) && (vCount >= cy_pos+6) && (vCount <= cy_pos+7)) ||
	((hCount >= cx_pos+28) && (hCount <= cx_pos+29) && (vCount >= cy_pos+4) && (vCount <= cy_pos+6)) ||
	((hCount >= cx_pos+32) && (hCount <= cx_pos+33) && (vCount >= cy_pos+8) && (vCount <= cy_pos+9)) ||
	((hCount >= cx_pos+35) && (hCount <= cx_pos+38) && (vCount >= cy_pos+15) && (vCount <= cy_pos+18)) ||
	((hCount >= cx_pos+37) && (hCount <= cx_pos+39) && (vCount >= cy_pos+16) && (vCount <= cy_pos+22)) ||
	((hCount >= cx_pos+40) && (hCount <= cx_pos+43) && (vCount >= cy_pos+23) && (vCount <= cy_pos+30)) ||
	((hCount >= cx_pos+40) && (hCount <= cx_pos+41) && (vCount >= cy_pos+20) && (vCount <= cy_pos+31)) ||
	((hCount >= cx_pos+54) && (hCount <= cx_pos+55) && (vCount >= cy_pos+24) && (vCount <= cy_pos+30)) ||
	((hCount >= cx_pos+54) && (hCount <= cx_pos+55) && (vCount >= cy_pos+24) && (vCount <= cy_pos+30)) ||
	((hCount >= cx_pos+59) && (hCount <= cx_pos+60) && (vCount >= cy_pos+31) && (vCount <= cy_pos+32)) ||
	((hCount >= cx_pos+58) && (hCount <= cx_pos+59) && (vCount >= cy_pos+22) && (vCount <= cy_pos+23)) ||
	((hCount >= cx_pos+39) && (hCount <= cx_pos+46) && (vCount >= cy_pos+24) && (vCount <= cy_pos+27));

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
	((hCount == cx_pos+5) && (vCount >= cy_pos+30) && (vCount <= cy_pos+37)) ||
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

	assign platform6_fill = (vCount >= py6_pos) &&
							(vCount <= py6_pos+15) &&
							(hCount >= px6_pos-50) &&
							(hCount <= px6_pos+50);

	assign platform7_fill = (vCount >= py7_pos) &&
							(vCount <= py7_pos+15) &&
							(hCount >= px7_pos-50) &&
							(hCount <= px7_pos+50);

	assign platform8_fill = (vCount >= py8_pos) &&
							(vCount <= py8_pos+15) &&
							(hCount >= px8_pos-50) &&
							(hCount <= px8_pos+50);

	assign end_screen = (vCount >= endy_pos) && (vCount <= endy_pos+525) && 
						(hCount >= endx_pos+100) && (hCount <= endx_pos+800);

	assign end_FIN = letter_F || letter_I || letter_N;
	
	assign letter_F = ((hCount >= finx_pos+78) && (hCount <= finx_pos+109) && (vCount >= finy_pos+110) && (vCount <= finy_pos+117)) ||
	((hCount >= finx_pos+78) && (hCount <= finx_pos+85) && (vCount >= finy_pos+118) && (vCount <= finy_pos+149)) ||
	((hCount >= finx_pos+86) && (hCount <= finx_pos+101) && (vCount >= finy_pos+126) && (vCount <= finy_pos+133));

	assign letter_I = ((hCount >= finx_pos+118) && (hCount <= finx_pos+141) && (vCount >= finy_pos+110) && (vCount <= finy_pos+117)) ||
	((hCount >= finx_pos+126) && (hCount <= finx_pos+133) && (vCount >= finy_pos+118) && (vCount <= finy_pos+141)) ||
	((hCount >= finx_pos+118) && (hCount <= finx_pos+141) && (vCount >= finy_pos+142) && (vCount <= finy_pos+149));

	assign letter_N = ((hCount >= finx_pos+150) && (hCount <= finx_pos+157) && (vCount >= finy_pos+110) && (vCount <= finy_pos+149)) ||
	((hCount >= finx_pos+158) && (hCount <= finx_pos+165) && (vCount >= finy_pos+118) && (vCount <= finy_pos+125)) ||
	((hCount >= finx_pos+166) && (hCount <= finx_pos+173) && (vCount >= finy_pos+126) && (vCount <= finy_pos+133)) ||
	((hCount >= finx_pos+174) && (hCount <= finx_pos+181) && (vCount >= finy_pos+110) && (vCount <= finy_pos+149));


	/* when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display */
	/************************************************/ 
	/* OUTPUTTING RGB LOGIC 						*/
	/************************************************/
	always@ (*) 
	begin : fill_blocks
		if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (char_outline && !game_over)
			rgb = BLACK;
		else if (doodler_clothes && !game_over)
			rgb = CLOTHES_COLOR;
		else if (doodler_body && !game_over)
			rgb = BODY_COLOR;
    	else if ((platform1_fill || platform2_fill || platform3_fill || platform6_fill || platform7_fill || platform8_fill) && !game_over) 
            rgb = GREEN;
        else if ((platform4_fill || platform5_fill) && !game_over) 
            rgb = OFF_RED;
		else if (game_over && end_FIN)
			rgb = WHITE;
		else if (game_over && end_screen)
			rgb = BLACK;
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
			if ((jump_ctr > 64) && (collision == 1) && (red_hit == 0)) begin
				jump_ctr <= 0;
			end
			if (cy_pos <= 34) begin
				jump_ctr <= 65;
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
	begin : state_machine
		// starting position of char
		if(rst) begin 
			cx_pos <= 588;
            cy_pos <= 409;

			finx_pos <= 350;
			finy_pos <= 133;

			endx_pos <= 0;
			endy_pos <= 0;

			collision <= 0;
			red_hit <= 0;

			score <= 0;
			game_over <= 0;
		end
		else if (clk) begin
			// controlling the automatic jumping
			if (jump_ctr < 64 && collision == 0) begin
				// going up
				cy_pos <= cy_pos - 3;
			end
			else if (jump_ctr > 64 && collision == 0) begin
				cy_pos <= cy_pos + 3;
				// check for collision on the way down
				if ((cx_pos+32 <= (px1_pos+50)) && (cx_pos+32 >= (px1_pos-50)) && (cy_pos+64 >= py1_pos +1) && (cy_pos+64 <= py1_pos + 4))
					collision <= 1;
				if ((cx_pos+32 <= (px2_pos + 50)) && (cx_pos+32 >= (px2_pos - 50)) && (cy_pos+64 >= py2_pos + 1) && (cy_pos+64 <= py2_pos + 4))
					collision <= 1;
				if ((cx_pos+32 <= (px3_pos + 50)) && (cx_pos+32 >= (px3_pos - 50)) && (cy_pos+64 >= py3_pos + 1) && (cy_pos+64 <= py3_pos + 4))
					collision <= 1;
				if ((cx_pos+32 <= (px4_pos + 50)) && (cx_pos+32 >= (px4_pos - 50)) && (cy_pos+64 >= py4_pos + 1) && (cy_pos+64 <= py4_pos + 4))
					red_hit <= 1;
				if ((cx_pos+32 <= (px5_pos + 50)) && (cx_pos+32 >= (px5_pos - 50)) && (cy_pos+64 >= py5_pos + 1) && (cy_pos+64 >= py5_pos + 4))
					red_hit <= 1;
				if ((cx_pos+32 <= (px6_pos + 50)) && (cx_pos+32 >= (px6_pos - 50)) && (cy_pos+64 >= py6_pos + 1) && (cy_pos+64 <= py6_pos + 4))
					collision <= 1;
				if ((cx_pos+32 <= (px7_pos + 50)) && (cx_pos+32 >= (px7_pos - 50)) && (cy_pos+64 >= py7_pos + 1) && (cy_pos+64 <= py7_pos + 4))
					collision <= 1;
				if ((cx_pos+32 <= (px8_pos + 50)) && (cx_pos+32 >= (px8_pos - 50)) && (cy_pos+64 >= py8_pos + 1) && (cy_pos+64 <= py8_pos + 4))
					collision <= 1;
			end

			if (collision) begin
				if ((cx_pos+32 <= (px1_pos+50)) && (cx_pos+32 >= (px1_pos-50)) && (cy_pos+64 >= py1_pos +1) && (cy_pos+64 <= py1_pos + 4))
					cy_pos <= py1_pos - 64 + 1;
				if ((cx_pos+32 <= (px2_pos + 50)) && (cx_pos+32 >= (px2_pos - 50)) && (cy_pos+64 >= py2_pos + 1) && (cy_pos+64 <= py2_pos + 4))
					cy_pos <= py2_pos - 64 + 1;
				if ((cx_pos+32 <= (px3_pos + 50)) && (cx_pos+32 >= (px3_pos - 50)) && (cy_pos+64 >= py3_pos + 1) && (cy_pos+64 <= py3_pos + 4))
					cy_pos <= py3_pos - 64 + 1;
				if ((cx_pos+32 <= (px6_pos + 50)) && (cx_pos+32 >= (px6_pos - 50)) && (cy_pos+64 >= py6_pos + 1) && (cy_pos+64 <= py6_pos + 4))
					cy_pos <= py6_pos - 64 + 1;
				if ((cx_pos+32 <= (px7_pos + 50)) && (cx_pos+32 >= (px7_pos - 50)) && (cy_pos+64 >= py7_pos + 1) && (cy_pos+64 <= py7_pos + 4))
					cy_pos <= py7_pos - 64 + 1;
				if ((cx_pos+32 <= (px8_pos + 50)) && (cx_pos+32 >= (px8_pos - 50)) && (cy_pos+64 >= py8_pos + 1) && (cy_pos+64 <= py8_pos + 4))
					cy_pos <= py8_pos - 64 + 1;
				collision <= 0; 
			end

			if ((cy_pos >= 510) || (red_hit == 1)) begin
				game_over <= 1;
			end 

			if ((collision == 1) && (game_over == 0)) begin
				score <= score + 10;
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

            px6_pos <= 312;
            py6_pos <= 308;

            px7_pos <= 505;
            py7_pos <= 178;

            px8_pos <= 698;
            py8_pos <= 34;
		end
		else if (clk) begin
			// if a collision is detected
			if (collision) begin
				py1_pos <= py1_pos + 20;
				py2_pos <= py2_pos + 20;
				py3_pos <= py3_pos + 20;
				py4_pos <= py4_pos + 20;
				py5_pos <= py5_pos + 20;
				py6_pos <= py6_pos + 20;
				py7_pos <= py7_pos + 20;
				py8_pos <= py8_pos + 20;
			end
    
			if (py1_pos > 510) begin
				py1_pos <= 50;
				px1_pos <= rand_num; 
			end 
			if (py2_pos > 510) begin
				py2_pos <= 50;
				px2_pos <= rand_num; 
			end 
			if (py3_pos > 510) begin
				py3_pos <= 50;
				px3_pos <= rand_num; 
			end 
			if (py4_pos > 510) begin
				py4_pos <= 50;
				px4_pos <= rand_num; 
			end 
			if (py5_pos > 510) begin
				py5_pos <= 50;
				px5_pos <= rand_num; 
			end
			if (py6_pos > 510) begin
				py6_pos <= 50;
				px6_pos <= rand_num; 
			end
			if (py7_pos > 510) begin
				py7_pos <= 50;
				px7_pos <= rand_num; 
			end
			if (py8_pos > 510) begin
				py8_pos <= 50;
				px8_pos <= rand_num; 
			end
		end
	end

endmodule
