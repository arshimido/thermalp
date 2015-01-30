# thermalp
Simple Ruby API for thermal barcode printers through network, it DOESN'T support USB connected printers.Provides simple and basic printer configurations and printing options.


Example:
--------

    require "Printer"

- specify ypur printer's IP, port number and flush mode.
- default port number 9100.
- auto flush ENABLED by default (auto flush: intstructions are sent immediately to the printer).

initialize printer

    printer = Printer.new "192.168.1.15", "6789", false

set label and printing paramters (dimensions, gap).

    printer.set_label_dimensions 2, 1, "inch"
    printer.set_gap 2 mm
    printer.set_printing_darkness 12

print whatever you want

    printer.text 25, 30, "1", 90, 1, 1, 0, "this is the content"
    printer.barcode 100, 200, "128", 150, 0, 90, 1, 1, 0, "This is The ConTent"

and here is the MOST IMPORTANT STEP, printer will not print until you tell it to print:
--------------------------------------

    printer.print 15          # now it will print 15 copies
