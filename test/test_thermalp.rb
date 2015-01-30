require 'minitest/autorun'
require 'Printer'
require 'timeout'

class PrinterTest < Minitest::Test
	describe "testing the error object" do
		it "as an assertion" do
			err = assert_raises Timeout::Error do 
				p = Printer.new("asd")
				p.callibrate
			end
			assert(err.message == "execution expired")
		end

		it "as an exception" do
			err = ->{ p = Printer.new("asd"); p.callibrate }.must_raise Timeout::Error
			assert(err.message == "execution expired")
		end
	end

	describe "testing queue order" do
		it "queue is empty" do
			p = Printer.new "asdsad"
			begin
				p.callibrate
			rescue Timeout::Error => e
				
			end
			assert_nil p.get_instructions_queue
		end

		it "queue has only one instruction" do
			p = Printer.new "192.168.1.18", "9100", false
			p.set_printing_darkness "14"
			queue = p.get_instructions_queue
			assert_equal queue.size, 1
		end

		it "instructions in same order" do
			p = Printer.new "192.168.1.18", "9100", false
			p.set_label_dimensions "3", 2, "mm"
			p.set_printing_direction false, false
			p.set_printing_darkness 3
			p.set_gap 2, 1
			p.text 25, 30, "1", 90, 1, 1, 0, "this is the content"
			p.barcode 100, 200, "128", 150, 0, 90, 1, 1, 0, "This is The ConTent"
			# start_with?

			queue = p.get_instructions_queue
			assert_equal queue.nil?, false
			assert_equal queue.size, 6

			str = queue.pop(true)
			assert_equal str, "SIZE 3 mm, 2 mm"
			
			str = queue.pop(true)
			assert_equal str, "DIRECTION 1,0"
			
			str = queue.pop(true)
			assert_equal str, "DENSITY 3"
			
			str = queue.pop(true)
			assert_equal str, "GAP 2 , 1 "
			
			str = queue.pop(true)
			assert_equal str, 'TEXT 25, 30, "1", 90, 1, 1, 0, "this is the content"'

			str = queue.pop(true)
			assert_equal str, 'BARCODE 100, 200, "128", 150, 0, 90, 1, 1, 0, "This is The ConTent"'
		end
	end
end