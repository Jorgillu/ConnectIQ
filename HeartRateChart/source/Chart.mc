//@Gillu

class Chart {
    var model;

    function initialize(a_model) {
        model = a_model;
    }

    function draw(dc, x1y1x2y2,
                  line_color,
                  range_min_size) {
        // Work around 10 arg limit!
        var x1 = x1y1x2y2[0];
        var y1 = x1y1x2y2[1];
        var x2 = x1y1x2y2[2];
        var y2 = x1y1x2y2[3];

        var data = model.get_values();

        var range_border = 5;

        var width = x2 - x1;
        var height = y2 - y1;
        var x = x1;
        var x_next;
        var item;

        var min = model.get_min();
        var max = model.get_max();

        var range_min = min - range_border;
        var range_max = max + range_border;
        if (range_max - range_min < range_min_size) {
            range_max = range_min + range_min_size;
        }

        var x_old = null;
        var y_old = null;
        var color_old = null;
        for (var x = x1; x <= x2; x++) {
            item = data[x_item(x, x1, width, data.size())];
            dc.setColor(model.get_color(item), Graphics.COLOR_TRANSPARENT);
            if (item != null && item > range_max) {
                dc.drawLine(x, y1, x, y2);
                x_old = null;
                y_old = null;
                color_old = null;
            }
            else if (item != null && item >= range_min) {
                var y = item_y(item, y2, height, range_min, range_max);
                dc.drawLine(x, y, x, y2);
                if (x_old != null) {
                	if (y_old > y) {
                		dc.setColor(color_old, Graphics.COLOR_TRANSPARENT);
                		dc.drawLine(x_old, y_old, x_old, (y  + y_old)/2);
                	} else {
                		dc.drawLine(x, y, x, (y  + y_old)/2);
                		//dc.drawPoint(x, y);
                	}
                    
                    // TODO is the below line needed due to a CIQ bug
                    // or some subtlety I don't understand?
                    //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                }
                
                x_old = x;
                y_old = y;
                color_old = model.get_color(item);
            }
            else {
                x_old = null;
                y_old = null;
                color_old = null;
            }
    	}
    	dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
		if ((model.get_zone1() > range_min) && (model.get_zone1() < range_max)) {
			var y = item_y(model.get_zone1(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
		if ((model.get_zone2() > range_min) && (model.get_zone2() < range_max)) {
			var y = item_y(model.get_zone2(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
		if ((model.get_zone3() > range_min) && (model.get_zone3() < range_max)) {
			var y = item_y(model.get_zone3(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
		if ((model.get_zone4() > range_min) && (model.get_zone4() < range_max)) {
			var y = item_y(model.get_zone4(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
		if ((model.get_zone5() > range_min) && (model.get_zone5() < range_max)) {
			var y = item_y(model.get_zone5(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
		if ((model.get_max_HR() > range_min) && (model.get_max_HR() < range_max)) {
			var y = item_y(model.get_max_HR(), y2, height, range_min, range_max) + 1;
			dc.drawLine(x1, y, x2+1, y);
		}
    }

    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / (size - 1);
    }

    function x_item(x, orig_x, width, size) {
        return (x - orig_x) * (size - 1) / width;
    }

    function item_y(item, orig_y, height, min, max) {
        return orig_y - height * (item - min) / (max - min);
    }
}
