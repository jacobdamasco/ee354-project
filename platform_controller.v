`timescale 1ns / 1ps

module platform_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb
   );
	wire block_fill;
	
	// platforms position
	reg [9:0] x1_pos, y1_pos;
	reg [9:0] x2_pos, y2_pos;
	reg [9:0] x3_pos, y3_pos;
	reg [9:0] x4_pos, y4_pos;
	reg [9:0] x5_pos, y5_pos;
	
	// colors
	// hex guide: A10 B11 C12 D13 E14 F15
	parameter RED = 12'b1111_0000_0000; // F00
	parameter OFF_RED = 12'b1100_0011_0011; // C33
	parameter DARK_GREEN = 12'b0010_0110_0010; // 262
    parameter GREEN = 12'b0111_1100_0011; // 7C3
	parameter PURPLE = 12'b1000_0010_1101; // 82D
	parameter PASTEL_BLUE = 12'b0110_1000_1111; // 68F
	parameter WHITE = 12'b1111_1111_1111;

	/* when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display */
	always@ (*) 
	begin : fill_platforms
        if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
    	else if (platform1_fill || platform2_fill || platform3_fill) 
            rgb = GREEN;
        else if (platform4_fill || platform5_fill) 
            rgb = OFF_RED;
		else	
			rgb = WHITE;
	end


	// fill in character w color from always block
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
	
	always@(posedge clk, posedge rst) 
	begin : main_mvmt_controls
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
