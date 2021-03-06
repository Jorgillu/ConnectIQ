using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.Activity as Act;
using Toybox.Application as App;
using Toybox.System as System;

var model;

class HeartRateChartView extends Ui.DataField {
    hidden var chart;
    hidden var label = "HR";
    hidden var settings_range_max_size;
    hidden var range_min_size = 30;
    hidden var mTimerRunning = false;

    function initialize()
    {
    	DataField.initialize();
    	
    	settings_range_max_size = App.getApp().getProperty("duration");
    	
        model = new ChartModel();
        model.set_value_size(240 - 2*20);
        model.set_range_minutes(10);
        model.set_range_expand(true);
        //model.set_max_range_minutes(30);
        model.set_max_range_minutes(settings_range_max_size);
        chart = new Chart(model);
    }

    function onLayout(dc) {
    	
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    function onHide() {
    }

    //! Update the view
    function onUpdate(dc) {
    	var backgroundColor = DataField.getBackgroundColor();
    	var foregroundColor = Graphics.COLOR_WHITE; 
    	if (backgroundColor ==  Graphics.COLOR_WHITE) {
        	foregroundColor = Graphics.COLOR_BLACK; 
        }
        dc.setColor(foregroundColor, backgroundColor);        
        dc.clear();

        // Fenix 3 full screen, copy the widget
        if (model.get_current() != null) {
        	dc.setColor(model.get_color(model.get_current()), Graphics.COLOR_TRANSPARENT);
        } else {
        	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(0,0,dc.getWidth(), 50);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        text(dc, dc.getWidth()/2, 24, Graphics.FONT_NUMBER_MEDIUM, fmt_num(model.get_current()));
        //text(dc, dc.getWidth()/2, 24, Graphics.FONT_NUMBER_MEDIUM, Graphics.getFontHeight(Graphics.FONT_NUMBER_MEDIUM));
        dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
        text(dc, dc.getWidth()/2, dc.getHeight() - 36, Graphics.FONT_SMALL, getActivityDuration());
        text(dc, dc.getWidth()/2, dc.getHeight() - 16, Graphics.FONT_XTINY, model.get_range_label());

        chart.draw(dc, [20, 60, dc.getWidth() - 20, dc.getHeight() - 60], Graphics.COLOR_LT_GRAY,  range_min_size);
    }

    function fmt_num(num) {
        if (num == null) {
            return "---";
        }
        else {
            return "" + num;
        }
    }

    function text(dc, x, y, font, s) {
        dc.drawText(x, y, font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function compute(activityInfo) {
        if(activityInfo has :currentHeartRate){
	        if(mTimerRunning) {
		        var val = activityInfo.currentHeartRate;
		        model.new_value(val);
		        return val;
		    }
		}
    }
    
    function getActivityDuration() {
    	var durationString = "00'00\"";
    	
    	//Duraci�n en segundos
    	if (Act.getActivityInfo().elapsedTime != null) {
	    	var duration = Act.getActivityInfo().timerTime / 1000;
	    	
	    	durationString = (duration % 60).format("%02d") + "\"";
	    	duration = duration / 60;
	    	if (duration != 0) {
	    		durationString = (duration % 60).format("%02d") + "'" + durationString;
	    		duration = duration / 60;   		
	    		if (duration != 0) {
	    			durationString = duration.format("%02d") + "h" + durationString;
	    		}
	    	} else {
	    		durationString = "00'" + durationString;
	    	}
	    }
    	return durationString;
    }
    
    function onTimerStart() {
        mTimerRunning = true;
    }

    function onTimerStop() {
        mTimerRunning = false;
    }

    function onTimerPause() {
        mTimerRunning = false;
    }

    function onTimerResume() {
        mTimerRunning = true;
    }
}