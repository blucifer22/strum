`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	output audioOut,
	output audioEn,
	inout ps2c,
	inout ps2d);
	
	
	// Lab Memory Files Location
	//TODO: CHANGE THIS FOR EACH DEVICE
	//localparam FILES_PATH = "C:/Users/caryp/Desktop/Important Shit/ECE350/Final Project/strum/strum/";
	localparam FILES_PATH = "C:/Users/water/OneDrive/Documents/ECE-350/strum/strum/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;
	
	reg[9:0] xCoord = 0;
    reg[9:0] yCoord = 0;
    reg[9:0] xCoord2 = 80;
    reg[9:0] yCoord2 = 40;
    reg[9:0] xCoord3 = 160;
    reg[9:0] yCoord3 = 80;
    reg[9:0] xCoord4 = 240;
    reg[9:0] yCoord4 = 120;
    
    reg[1:0] note = 2'b00;
    reg[1:0] note2 = 2'b01;
    reg[1:0] note3 = 2'b10;
    reg[1:0] note4 = 2'b11;
    
    reg keyReset; //not sure why this is 8 bit... hesitant to change and wait 15 mins only to find out it's important
    wire scan_done_tick;
    wire [7:0] scan_out;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddrBackground; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

    //BACKGROUND IMAGE
	RAM_image #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddrBackground),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading
		
		
	
    //OVERLAY IMAGE
    wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddrForeground;
     RAM_image #(		
    .DEPTH(50*50), 				     // Set RAM depth to contain every pixel
    .DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
    .ADDRESS_WIDTH(12),     // Set address with according to the pixel count
    .MEMFILE({FILES_PATH, "Overlay.mem"})) // Memory initialization
    ImageOverlay(
        .clk(clk), 						     // Falling edge of the 100 MHz clk
        .addr((x-coordToUseX) + (y-coordToUseY)*51),					 // Image data address
        .dataOut(colorAddrForeground),				 // Color palette address
        .wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel
	
	reg inBounds = 0;
	reg[9:0] coordToUseX = 0;
	reg[9:0] coordToUseY = 0;
	reg[1:0] colorToUse = 0;
	reg[1:0] noteToPlay = 0;
	always @* begin
	   if ((y > yCoord) && (y < (yCoord+51)) && (x > xCoord) && (x < (xCoord+51))) begin
	       coordToUseX <= xCoord;
	       coordToUseY <= yCoord;
	       colorToUse <= note;
	       inBounds <= 1;
	   end else if ((y > yCoord2) && (y < (yCoord2+51)) && (x > xCoord2) && (x < (xCoord2+51))) begin
	       coordToUseX <= xCoord2;
	       coordToUseY <= yCoord2;
	       colorToUse <= note2;
	       inBounds <= 1;
	   end else if((y > yCoord3) && (y < (yCoord3+51)) && (x > xCoord3) && (x < (xCoord3+51))) begin
	       coordToUseX <= xCoord3;
	       coordToUseY <= yCoord3;
	       colorToUse <= note3;
	       inBounds <= 1;
	   end else if((y > yCoord4) && (y < (yCoord4+51)) && (x > xCoord4) && (x < (xCoord4+51))) begin
	       coordToUseX <= xCoord4;
	       coordToUseY <= yCoord4;
	       colorToUse <= note4;
	       inBounds <= 1;
	   end else begin
	       inBounds <= 0;
	   end
	end

    //COLOR PICKER
    wire goodColor = (colorAddrForeground > 'h1); ///Would prefer to check if it's nonzero, but that doesn't work for some reason???
    wire [PALETTE_ADDRESS_WIDTH-1:0] colorAddrToUse = (inBounds && goodColor) ? colorToUse : colorAddrBackground;
    
	RAM_image #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddrToUse),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading
	

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	assign colorOut = active ? colorData : 12'd0; // When not active, output black


    ps2_rx myInterface(.clk(clk), .reset(keyReset), .rx_en(1'b1), .ps2d(ps2d), .ps2c(ps2c), .rx_done_tick(scan_done_tick), .rx_data(scan_out));
    
    
//    always @(posedge clk & screenEnd) begin
//        if (scan_out == 8'h1d) begin
//            yCoord <= yCoord-4;
//            yCoord2 <= yCoord2-4;
//            yCoord3 <= yCoord3-4;
//            yCoord4 <= yCoord4-4;
//            keyReset <= 1'b1;
//        end else if (scan_out == 8'h1b) begin
//            yCoord <= yCoord+4;
//            yCoord2 <= yCoord2+4;
//            yCoord3 <= yCoord3+4;
//            yCoord4 <= yCoord4+4;
//            keyReset <= 1'b1;
//        end else if (scan_out == 8'h1c) begin
//            xCoord <= xCoord-4;
//            xCoord2 <= xCoord2-4;
//            xCoord3 <= xCoord3-4;
//            xCoord4 <= xCoord4-4;
//            keyReset <= 1'b1;
//        end else if (scan_out == 8'h23) begin
//            xCoord <= xCoord+4;
//            xCoord2 <= xCoord2+4;
//            xCoord3 <= xCoord3+4;
//            xCoord4 <= xCoord4+4;
//            keyReset <= 1'b1;
//        end else begin
//            keyReset <= 1'b0;
//        end
//    end

    always @(posedge clk & screenEnd) begin
            yCoord <= yCoord+1;
            yCoord2 <= yCoord2+1;
            yCoord3 <= yCoord3+1;
            yCoord4 <= yCoord4+1;
            if(yCoord >= 480) begin
                xCoord <= (xCoord + 80) % 320;
                note <= note + 1;
                noteToPlay <= 0;
                yCoord <= 0;
            end
            if(yCoord2 >= 480) begin
                xCoord2 <= (xCoord2 + 80) % 320;
                note2 <= note2 + 1;
                noteToPlay <= 1;
                yCoord2 <= 0;
            end
            if(yCoord3 >= 480) begin
                xCoord3 <= (xCoord3 + 80) % 320;
                note3 <= note3 + 1;
                noteToPlay <= 2;
                yCoord3 <= 0;
            end
            if(yCoord4 >= 480) begin
                xCoord4 <= (xCoord4 + 80) % 320;
                note4 <= note4 + 1;
                noteToPlay <= 3;
                yCoord4 <= 0;
            end
    end
    
	assign audioEn = 1'b1;  // Enable Audio Output    
    reg [31:0] counter = 0;
    wire [10:0] cur_freq;
    assign cur_freq = (noteToPlay + 1) * 100;
    wire[31:0] counter_limit;
    assign counter_limit = ((100000000/cur_freq) >> 1) - 1;
    reg toggle = 0;
    always @(posedge clk) begin
        if(counter < counter_limit) begin
            counter <= counter + 1;
        end
        else begin
            toggle <= ~toggle;
            counter <= 0;
        end
    end
    wire[6:0] duty_cycle;
    assign duty_cycle = toggle ? 7'd60 : 7'd40;
    PWMSerializer serializer(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle), .signal(audioOut));

    
            
	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule