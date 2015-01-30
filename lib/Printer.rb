class Printer
	require 'thread'
	require 'socket'
	require 'timeout'

	#printer IP adress
	@ip

	# printer port, defaults to 9100
	@port

	# auto_flush = true ---> sends instruction by instruction
	# default -> true
	@auto_flush

	# Queue of instructions
	@queue

	# constructor initializes printers basic info
	# 
	# Parameters:
	# 	ip: printer's IP address
	# 	port: printer's listening port, default -> 9100
	# 	auto_flush: boolean value to determine if should immediately send instructions to printer
	# 				or saves in buffer and flush them later
	# 				default -> true
	def initialize(ip, port="9100", auto_flush=true)
		@ip = ip
		@port = port
		@queue = Queue.new
	end

	# Sets label dimensions in mm
	# 
	# Parameters:
	# 	width: label width (in mm)
	# 	height: label height
	# 	unit: width unit (mm, inch, dot), default -> inch
	def set_label_dimensions width, height, unit = ""
		instruction ("SIZE " + width.to_s + " " + unit.to_s + ", " + height.to_s + " " + unit.to_s)
	end

	# Set printing direction (Choose one of the Predefined directions in DIrection.rb)
	# 
	# Parameters:
	# 	is_top_to_bottom: Boolean determines whether printing direction is top to bottom or bottom to up (from the printer's prespective)
	# 	is_mirrored: Boolean specifies if text should be printed mirrored (not human readable)
	def set_printing_direction is_top_to_bottom, is_mirrored
		direction = ""
		if is_top_to_bottom
			direction += "0"
		else
			direction += "1"
		end

		direction += ","

		if is_mirrored
			direction += "1"
		else
			direction += "0"
		end

		instruction ("DIRECTION " + direction)
	end

	# Specify the printed text denisty
	# 
	# Parameters:
	# 	darkness: 0..15
	# 		0: specifies the lightest level
	# 		15: specifies the darkest level
	def set_printing_darkness darkness = 8
		instruction ("DENSITY " + darkness.to_s)
	end

	# Set gap between labels (the empty area between two labels)
	# 
	# Parameters: 
	# 	distance: Float value determines the gap between two labels
	# 	offset: The offset distance of the gab, default -> 0
	# 	unit: unit of gap amount (mm, inch, dot), default -> inch
	def set_gap distance, offset = 0, unit = ""
		instruction ("GAP " + distance.to_s + " " + unit.to_s + ", " + offset.to_s + " " + unit.to_s)
	end

	# Enforce printer to re-callibrate to detect gap size
	# This command is executed immediately and ignores "auto_flush" value
	def callibrate
		send_instruction "GAPDETECT"
	end

	# Writes specified text (in content param)
	# 
	# Parameters:
	# 	x: 			The x-coordinate of the text
	#
	# 	y: 			The y-coordinate of the text
	# 
	# 	font:		String represents font name
	# 	    		0: 	Monotye CG Triumvirate Bold Condensed, font width and height is stretchable
	# 	 			1: 8 x 12 fixed pitch dot font
	# 				2: 12 x 20 fixed pitch dot font
	# 				3: 16 x 24 fixed pitch dot font
	# 				4: 24 x 32 fixed pitch dot font
	# 				5: 32 x 48 dot fixed pitch font
	# 				6: 14 x 19 dot fixed pitch font OCR-B
	# 				7: 21 x 27 dot fixed pitch font OCR-B
	# 				8: 14 x25 dot fixed pitch font OCR-A
	# 				ROMAN.TTF: Monotye CG Triumvirate Bold Condensed, font width and height proportion is fixed.
	# 	
	# 	rotation: 	Integer for the rotation angle of text, accepted values:
	# 	        	0: No rotation
	# 	       		90: degrees, in clockwise direction
	# 	      		180: degrees, in clockwise direction
	# 	     		270: degrees, in clockwise direction
	# 	
	# 	x_multiplication: 	Float value for horizontal multiplication, up to 10x, Acceptable values: 1~10
	# 	               		For "ROMAN.TTF" true type font, this parameter is ignored.
	# 	              		For font "0", this parameter is used to specify the width (point) of true type
	# 	             		font. 1 point=1/72 inch.
	# 	
	# 	y_multiplication: 	Vertical multiplication, up to 10x
	# 						Available factors: 1~10
	# 						For true type font, this parameter is used to specify the height (point) of
	# 						true type font. 1 point=1/72 inch.
	# 						For *.TTF font, x-multiplication and y-multiplication support floating value. (V6.91 EZ)
	# 
	# 	alignment: 			Optional. Specify the alignment of text. (V6.73 EZ)
	# 						0 : Default (Left)
	# 						1 : Left
	# 						2 : Center
	# 						3 : Right
	# 		
	# 	content: Content of text string 
	def text x, y, font = "0", rotation, x_multiplication, y_multiplication, alignment, content
		instruction ('TEXT ' + x.to_s + ', ' + y.to_s + ', "' + font.to_s + '", ' + rotation.to_s + ', ' + x_multiplication.to_s + ', ' + y_multiplication.to_s + ', ' + alignment.to_s + ', "' + content.to_s + '"')
	end

	# Writes barcode
	# 
	# Parameters:
	# 	x: 	The x-coordinate of the barcode
	# 
	# 	y: 	The y-coordinate of the barcode
	# 
	# 	type: String specifying barcode type, accepted values:
	# 			128, 128M, EAN128, 25, 25C, 39, 39C, 93, EAN13, EAN13+2, EAN13+5, EAN8, EAN8+2, EAN8+5, CODA, POST, UPCA, UPCA+2, UPA+5, UPCE, UPCE+2, UPE+5, MSI, MSIC, PLESSEY, CPOST, ITF14, EAN14, 11, TELEPEN, TELEPENN, PLANET, CODE49, DPI, DPL, LOGMARS 
	# 
	# 	height: Barcode height (in dots)
	# 
	# 	human_readable: human readability and alignment, accepted values:
	# 					0: not readable
	# 					1: human readable aligns to left
	# 					2: human readable aligns to center
	# 					3: human readable aligns to right
	# 
	# 	rotation: Barcode rotation, accepted values:
	# 				0 : No rotation
	# 				90 : Rotate 90 degrees clockwise
	# 				180 : Rotate 180 degrees clockwise
	# 				270 : Rotate 270 degrees clockwise
	# 
	# 	narrow: Width of narrow element (in dots)
	# 
	# 	wide: Width of wide element (in dots)
	# 
	# 	alignment: Specify the alignment of barcode, accepted values:
	# 				0 : default (Left)
	# 				1 : Left
	# 				2 : Center
	# 				3 : Right
	# 
	# 	content: String containing content of barcode
	# 
	def barcode x, y, type, height, human_readable, rotation, narrow, wide, alignment=0, content
		instruction ('BARCODE ' + x.to_s + ', ' + y.to_s + ', "' + type.to_s + '", ' + height.to_s + ', ' + human_readable.to_s + ', ' + rotation.to_s + ', ' + narrow.to_s + ', ' + wide.to_s + ', ' + alignment.to_s + ', "' + content.to_s + '"')
	end

	# Sends the printing command to the printer. This method must be called at the end of any command sequence, if not printer will not print anything
	def print number_of_copies = "1"
		instruction ("PRINT 1," + number_of_copies.to_s)
	end

	def get_instructions_queue
		return nil if @queue.empty?
		return @queue
	end

	private
	# Sends the instruction directly to printer if and only if auto_flush is true
	# Otherwise it saves it in printing buffer
	# 
	# Parameters:
	# 	instruction_string: String containing single instruction
	def instruction instruction_string
		if @auto_flush
			send_instruction instruction_string
		else
			@queue << instruction_string
		end
	end

	# Sends Single instruction to printer
	# 
	# Raises Timeout::Error if couldn't connect to printer for 5 seconds
	# 
	# Parameters:
	# 	single_instruction: String containing a single instruction
	def send_instruction single_instruction 
		timeout(5) do
      # open socket on printer's ip and port
      socket = TCPSocket.open(@ip, @port)

      # send instruction
      socket.puts single_instruction

      # close socket
      socket.close
    end
  end

  
	# Flush all buffered instructions (stored in @queue) in order
	def flush
		if @queue.empty?
			return self
		end

		timeout(10) do
      # open socket on printer's ip and port
      socket = TCPSocket.open(@ip, @port)

      # send instructions one by one
      socket.puts single_instruction

      while !@queue.empty? do
      	socket.puts @queue.pop(true)
      end

      # close socket
      socket.close
    end
  end
end
