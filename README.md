# thermalp
Simple Ruby API for thermal printers through network, it DOESN'T support USB connected prointers.

Examples:
=========

require "Printer"

- specify ypur printer's IP, port number and flush mode
- default port number 9100
- auto flush disabled by default
printer = Printer.new "192.168.1.15", "PORT", false

# set label dimensions
printer.set_label_dimensions 20, 10