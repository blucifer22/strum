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
	inout ps2d,
	output CA,
	output CB,
	output CC,
	output CD,
	output CE,
	output CF,
	output CG,
	output AN0,
	output AN1,
	output AN2,
	output AN3,
	output AN4,
	output AN5,
	output AN6,
	output AN7);
	
	
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
	
	reg[9:0] xCoord = 160;
    reg[9:0] yCoord = 0;
    reg[9:0] xCoord2 = 240;
    reg[9:0] yCoord2 = 120;
    reg[9:0] xCoord3 = 320;
    reg[9:0] yCoord3 = 240;
    reg[9:0] xCoord4 = 400;
    reg[9:0] yCoord4 = 360;
    
    reg[2:0] note = 3'b000;
    reg[2:0] note2 = 3'b001;
    reg[2:0] note3 = 3'b010;
    reg[2:0] note4 = 3'b011;
    reg[2:0] noteMissed = 3'b100;
    
    
    reg keyReset;
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
	reg[2:0] noteToPlay = 0;
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

    reg [9:0] lowestCoord = 0;
    reg [1:0] lowestNote = 0;
    always @* begin
        if(yCoord >= yCoord2 && yCoord >= yCoord3 && yCoord >= yCoord4) begin
            lowestCoord <= yCoord;
            lowestNote <= (xCoord - 160) / 80;
        end
        else if (yCoord2 >= yCoord && yCoord2 >= yCoord3 && yCoord2 >= yCoord4) begin
            lowestCoord <= yCoord2;
            lowestNote <= (xCoord2 - 160) / 80;
        end
        else if (yCoord3 >= yCoord && yCoord3 >= yCoord2 && yCoord3 >= yCoord4) begin
            lowestCoord <= yCoord3;
            lowestNote <= (xCoord3 - 160) / 80;
        end
        else begin
            lowestCoord <= yCoord4;
            lowestNote <= (xCoord4 - 160) / 80;
        end
    end

    reg needsNewNote;
    reg needsCheckClose;
    reg lastInstruction; // 0 for needsNewNote; 1 for needsCheckClose
    wire [31:0] closeEnoughWire;
    assign closeEnoughWire[31:22] = 10'b1111000010;
    assign closeEnoughWire[21:10] = 12'b0;
    assign closeEnoughWire[9:0] = lowestCoord;
    wire [31:0] insnToUse = needsNewNote ? 32'b11111000010000000000000000000000 : closeEnoughWire;
    wire activeInsn = needsNewNote || needsCheckClose;
    reg CPUDone;
    reg[4:0] cyclesLeftCPU;
    wire [31:0] regVal;
    wire [4:0] regToRead = lastInstruction ? 5'b00010 : 5'b00001;
    wire reading = CPUDone;
    Wrapper myCPU(regVal, clk, 1'b0, insnToUse, activeInsn, regToRead, reading);
    
    
    reg [2:0] noteToReset;
    reg [7:0] lastNotePushed;
    reg rightKeyPressed = 1;
    reg noteCorrect = 1;
    reg [9:0] curStreak;
    reg beenCounted = 1;
    always @(posedge clk) begin
        lastNotePushed <= scan_out;
        if (screenEnd) begin
            yCoord <= yCoord+1;
            yCoord2 <= yCoord2+1;
            yCoord3 <= yCoord3+1;
            yCoord4 <= yCoord4+1;
            if(yCoord >= 480) begin
                needsNewNote <= 1;
                lastInstruction <= 0;
                cyclesLeftCPU <= 6;
                CPUDone <= 0;
                noteToReset <= 0;
            end else if(yCoord2 >= 480) begin
                needsNewNote <= 1;
                lastInstruction <= 0;
                cyclesLeftCPU <= 6;
                CPUDone <= 0;
                noteToReset <= 1;
            end else if(yCoord3 >= 480) begin
                needsNewNote<=1;
                lastInstruction <= 0;
                cyclesLeftCPU <= 6;
                CPUDone <= 0;
                noteToReset <= 2;
            end else if(yCoord4 >= 480) begin
                needsNewNote<=1;
                lastInstruction <= 0;
                cyclesLeftCPU <= 6;
                CPUDone <= 0;
                noteToReset <= 3;
            end
        end 
        
        else if (lastNotePushed == 8'h1c) begin // A
            beenCounted <= 0;
            needsCheckClose <= 1;
            lastInstruction <= 1;
            cyclesLeftCPU <= 6;
            CPUDone <= 0;
            noteToPlay <= 3'b00;
            rightKeyPressed <= (lowestNote == 2'b00);
            keyReset <= 1'b1;
        end else if (lastNotePushed == 8'h1b) begin // S
            beenCounted <= 0;
            needsCheckClose <= 1;
            lastInstruction <= 1;
            cyclesLeftCPU <= 6;
            CPUDone <= 0;
            noteToPlay <= 3'b01;
            rightKeyPressed <= (lowestNote == 2'b01);
            keyReset <= 1'b1;
        end else if (lastNotePushed == 8'h23) begin // D
            beenCounted <= 0;
            needsCheckClose <= 1;
            lastInstruction <= 1;
            cyclesLeftCPU <= 6;
            CPUDone <= 0;
            noteToPlay <= 3'b10;
            rightKeyPressed <= (lowestNote == 2'b10);
            keyReset <= 1'b1;
        end else if (lastNotePushed == 8'h2b) begin // F
            beenCounted <= 0;
            needsCheckClose <= 1;
            lastInstruction <= 1;
            cyclesLeftCPU <= 6;
            CPUDone <= 0;
            noteToPlay <= 3'b11;
            rightKeyPressed <= (lowestNote == 2'b11);
            keyReset <= 1'b1;
        end
        else begin
            keyReset <= 1'b0;
            if (cyclesLeftCPU > 1) begin
                needsNewNote <= 0;
                needsCheckClose <= 0;
                cyclesLeftCPU <= cyclesLeftCPU -1;
            end else if (cyclesLeftCPU > 0) begin
                CPUDone <= 1;
                needsNewNote <= 0;
                needsCheckClose <= 0;
                cyclesLeftCPU <= cyclesLeftCPU -1;
            end else if (!needsNewNote && !needsCheckClose && !lastInstruction) begin
                if (noteToReset == 0) begin
                    note <= regVal;
                    //xCoord <= note * 80;
                    xCoord <= (regVal[1:0])*80 + 160;
                    yCoord <= 0;
                    noteToReset <= 5;
                end else if (noteToReset == 1) begin
                    note2 <= regVal;
                    //xCoord2 <= note2*80;
                    xCoord2 <= (regVal[1:0])*80 + 160;
                    yCoord2 <= 0;
                    noteToReset <= 5;
                end else if (noteToReset == 2) begin
                    note3 <= regVal;
                    //xCoord3 <= note3*80;
                    xCoord3 <= (regVal[1:0])*80 + 160;
                    yCoord3 <= 0;
                    noteToReset <= 5;
                end else if (noteToReset == 3) begin
                    note4 <= regVal;
                    //xCoord4 <= note4*80;
                    xCoord4 <= (regVal[1:0])*80 + 160;
                    yCoord4 <= 0;
                    noteToReset <= 5;
                end
            end else if (!needsNewNote && !needsCheckClose && lastInstruction) begin
                noteCorrect <= regVal;
                if(regVal == 1 && rightKeyPressed && !beenCounted) begin
                    curStreak <= curStreak + 1;
                    beenCounted <= 1;
                end
                else if ((regVal == 0 || !rightKeyPressed) && !beenCounted) begin
                    curStreak <= 0;
                    beenCounted <= 1;
                end
            end
        end
    end
    
    reg [3:0] digit;
    reg [3:0] digit1;
    reg [3:0] digit2;
    reg [3:0] digit3;
    reg [1:0] lastDigitUpdated = 0;
    reg [3:0] digitToUse = 0;
    reg A, B, C, D, E, F, G, AN0Reg, AN1Reg, AN2Reg, AN3Reg;
    
    reg [1:0] ssCounter;
    
    reg [19:0] clockDivider = 0;
    reg ssClock = 0;
    
    always @(posedge clk) begin
        if(clockDivider < 10000) begin
            clockDivider <= clockDivider + 1;
        end
        else begin
            ssClock <= ~ssClock;
            clockDivider <= 0;
        end
    end
    
    reg [9:0] curStreakReduced = 0;
    always @(posedge ssClock) begin
        curStreakReduced <= curStreak / 2;
        digit <= curStreakReduced % 10;
        digit1 <= (curStreakReduced / 10) % 10;
        digit2 <= (curStreakReduced / 100) % 10;
        digit3 <= (curStreakReduced / 1000) % 10;
        if(lastDigitUpdated == 0) begin
            digitToUse <= digit1;
            lastDigitUpdated <= 2'b01; //lastDigitUpdate <= 2'b01;
            AN0Reg <= 1'b0;
            AN1Reg <= 1'b1;
            AN2Reg <= 1'b1;
            AN3Reg <= 1'b1;
        end
        else if(lastDigitUpdated == 1) begin
            digitToUse <= digit2;
            lastDigitUpdated <= 2'b10;
            AN0Reg <= 1'b1;
            AN1Reg <= 1'b0;
            AN2Reg <= 1'b1;
            AN3Reg <= 1'b1;
        end
        else if(lastDigitUpdated == 2) begin
            digitToUse <= digit3;
            lastDigitUpdated <= 2'b11;
            AN0Reg <= 1'b1;
            AN1Reg <= 1'b1;
            AN2Reg <= 1'b0;
            AN3Reg <= 1'b1;
        end
        else begin
            digitToUse <= digit;
            lastDigitUpdated <= 2'b00;
            AN0Reg <= 1'b1;
            AN1Reg <= 1'b1;
            AN2Reg <= 1'b1;
            AN3Reg <= 1'b0;
        end

//        digitToUse <= ssCounter;
//        lastDigitUpdated <= ssCounter;
//        ssCounter <= ssCounter + 1;
        
        A <= (digitToUse == 4 || digitToUse == 1);
        B <= (digitToUse == 5 || digitToUse == 6);
        C <= (digitToUse == 2);
        D <= (digitToUse == 1 || digitToUse == 4 || digitToUse == 7);
        E <= (digitToUse == 1 || digitToUse == 3 || digitToUse == 4 || digitToUse == 7 || digitToUse == 9);
        F <= (digitToUse == 1 || digitToUse == 2 || digitToUse == 3 || digitToUse == 7);
        G <= (digitToUse == 0 || digitToUse == 1 || digitToUse == 7);
        
        
//        AN0Reg <= !(lastDigitUpdated == 2'b00);
//        AN1Reg <= !(lastDigitUpdated == 2'b01);
//        AN2Reg <= !(lastDigitUpdated == 2'b10);
//        AN3Reg <= !(lastDigitUpdated == 3'b11);                  
    end
    
    assign CA = A;
    assign CB = B;
    assign CC = C;
    assign CD = D;
    assign CE = E;
    assign CF = F;
    assign CG = G;
    
    assign AN0 = AN0Reg;
    assign AN1 = AN1Reg;
    assign AN2 = AN2Reg;
    assign AN3 = AN3Reg;
    assign AN4 = 1'b1;
    assign AN5 = 1'b1;
    assign AN6 = 1'b1;
    assign AN7 = 1'b1;
        
	assign audioEn = 1'b1;  // Enable Audio Output    
    reg [31:0] counter = 0;
    wire [10:0] cur_freq;
    assign cur_freq = (noteCorrect && rightKeyPressed) ? ((noteToPlay + 1) * 100) : 2000;
    
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
    assign duty_cycle = toggle ? 7'd55 : 7'd45;
    PWMSerializer serializer(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle), .signal(audioOut));

    
            
	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule