using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Math as Math;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as Act;

class GillusliderView extends Ui.WatchFace {

    var xRefHour;
    var yRefHour;
    var xRefDate;
    var yRefDate;
    var xRefStep;
    var yRefStep;
    var xRefMovePoints;
    var yRefMovePoints;
    var width;
    var height;
    const HOUR_SPACES = 8;
    const DATE_SPACES = 8;
    const STEP_SPACES = 9;
    const STEPS_PER_SPACE = 500;
    var baseColor = Gfx.COLOR_WHITE;
    
    const BAR_THICKNESS = 7;
    const ARC_MAX_ITERS = 300;
    
    var moveBarEnabled = false;
    
	var blueToothConnectedIcon;
	var blueToothDisconnectedIcon;
	var alarmIcon;
	var alarmOffIcon;
	var backgroundHoursIcon;
	var backgroundDateIcon;
	var notificationsIcon;

    function initialize() {
       	blueToothConnectedIcon = Ui.loadResource(Rez.Drawables.bluetooth_connected);
    	blueToothDisconnectedIcon = Ui.loadResource(Rez.Drawables.bluetooth_disconnected);
    	alarmIcon = Ui.loadResource(Rez.Drawables.alarm);
    	alarmOffIcon = Ui.loadResource(Rez.Drawables.alarm_off);
    	backgroundHoursIcon = Ui.loadResource(Rez.Drawables.backgroundHours);
    	backgroundDateIcon = Ui.loadResource(Rez.Drawables.backgroundDate);
    	notificationsIcon = Ui.loadResource(Rez.Drawables.notifications);
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        width = dc.getWidth();
        height = dc.getHeight();
        xRefHour = width / 2;
        xRefDate = xRefHour;
        xRefStep = xRefHour;
        xRefMovePoints = xRefHour;
        yRefHour = (height / 2) + 28;
        yRefDate = (height / 2) - 63;
        yRefStep = (height / 2) + 76;
        yRefMovePoints = (height / 2) + 91;
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    	if (Act.getInfo().isSleepMode != true) {
	        // Get and show the current time
	        var hour= Sys.getClockTime().hour;
	        var min = Sys.getClockTime().min;
	        
	        var stepGoal = Act.getInfo().stepGoal;
	        stepGoal = stepGoal - (stepGoal % STEPS_PER_SPACE) + STEPS_PER_SPACE;
	        var steps = Act.getInfo().steps;
	        var moveBarLevel = Act.getInfo().moveBarLevel;
	        
	        //Se calcula el offset de horas, teniendo en cuenta que las marcas son cada 5 minutos
	   		var hourOffset = (min * HOUR_SPACES / 5); 
	   		//Se calcula el offset de días, teniendo en cuenta que las marcas son cada 2 horas.
	   		var dateOffset = (hour * 60 + min) * DATE_SPACES / 120;
	   		//Se calcula el offset de pasos, teniendo en cuenta que las marcas son cada 100 pasos.
	   		//var stepOffset = ((steps % (STEPS_PER_SPACE * 2)) * STEP_SPACES / 100);      
	   		var stepOffset = ((steps % (STEPS_PER_SPACE)) * STEP_SPACES / 100);
	        
	        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
	        dc.clear();
	        
	        drawDateSlider(dc,dateOffset);
	        drawHoursSlider(dc,hourOffset,hour);
	        drawStepSlider(dc,stepOffset,steps,stepGoal);
	        drawIcons(dc);
	        
	        drawLine(dc,moveBarLevel);
	        if (moveBarEnabled) {
	        	drawMoveBarCircle(dc,moveBarLevel);
	        } else {
	        	drawMoveBarText(dc,moveBarLevel);
	        }
	        	        
	        drawBatteryCircle(dc);
        }
    }
    
    function drawBatteryCircle(dc) { 
   		var battPerc = Sys.getSystemStats().battery;
    	
    	if (battPerc > 35) {
    		baseColor = Gfx.COLOR_WHITE;
    	} else if (battPerc > 25) {
    		baseColor = Gfx.COLOR_YELLOW;
    	} else if (battPerc > 15) {
    		baseColor = Gfx.COLOR_ORANGE;
    	} else if (battPerc > 5) {
    		baseColor = Gfx.COLOR_RED;
    	} else {
    		baseColor = Gfx.COLOR_DK_RED;
    	}
    	
    	if (battPerc <= 35) {
    		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    		dc.fillRectangle(dc.getWidth() / 2 - 2, 0, 6, 6);
    		dc.fillRectangle(dc.getWidth() / 2 - 2, dc.getHeight() - 6, 6, 6);
    		
    		dc.setColor(baseColor, Gfx.COLOR_TRANSPARENT);
    		var c = 109; 
    		dc.drawCircle(c,c,c+1);
			dc.drawCircle(c,c,c);
			dc.drawCircle(c,c,c-1);
			dc.drawCircle(c,c,c-2);
			
			dc.drawCircle(c-1,c-1,c+1);
			dc.drawCircle(c-1,c-1,c);
			dc.drawCircle(c-1,c-1,c-1);
			dc.drawCircle(c-1,c-1,c-2);
						
			dc.drawCircle(c-1,c,c+1);
			dc.drawCircle(c-1,c,c);
			dc.drawCircle(c-1,c,c-1);
			dc.drawCircle(c-1,c,c-2);
		
			dc.drawCircle(c,c-1,c+1);
			dc.drawCircle(c,c-1,c);
			dc.drawCircle(c,c-1,c-1);
			dc.drawCircle(c,c-1,c-2);
    	}
    }
    
    
    function drawIcons(dc) {
    	if (Sys.getDeviceSettings().phoneConnected == false) {
            dc.drawBitmap(dc.getWidth() / 2 + 14, 6, blueToothDisconnectedIcon);
        } else if (Sys.getDeviceSettings().notificationCount > 0) { 
        	dc.drawBitmap(dc.getWidth() / 2 + 11, 7, notificationsIcon);
        	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        	dc.drawText(dc.getWidth() / 2 + 18, 12, Gfx.FONT_XTINY, Sys.getDeviceSettings().notificationCount.format("%01d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        } else {
        	dc.drawBitmap(dc.getWidth() / 2 + 14, 6, blueToothConnectedIcon);
        }
        if (Sys.getDeviceSettings().alarmCount > 0) {
        	dc.drawBitmap(dc.getWidth() / 2 - 26, 6, alarmIcon);
        	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2 - 19, 14, Gfx.FONT_XTINY, Sys.getDeviceSettings().alarmCount.format("%01d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        } else {
        	dc.drawBitmap(dc.getWidth() / 2 - 26, 6, alarmOffIcon);
        }
    }
    
    function drawMoveBarText(dc, moveBarLevel) {
    	if (moveBarLevel  != null && moveBarLevel > 0) {
    		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    		dc.fillRectangle(xRefMovePoints - 20, yRefMovePoints - 6, 40, 26);
    		
    		var text = "MOVE!";
    		if (moveBarLevel < 2) {
    			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    		} else if (moveBarLevel < 3) {
    			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    		} else if (moveBarLevel < 4) {
    			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    			text = text + "!";
    		} else if (moveBarLevel < 5) {
    			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    			text = text + "!!";
    		} else {
    			dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    			text = text + "!!!";
    		}
    		dc.drawText(xRefMovePoints, yRefMovePoints + 3, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    	}
    }
    
    function drawLine(dc,moveBarLevel) {
    	dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    	dc.fillRectangle(xRefHour-1,0,3,width);
    }
    
    function drawStepSlider(dc,stepOffset,steps,stepGoal) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        var start = xRefStep - stepOffset - (2 * 5 * STEP_SPACES);
        for (var i = start, index = -2; i < width; i += (5 * STEP_SPACES)) {
        	    var tmp = steps - (steps % STEPS_PER_SPACE) + (index * STEPS_PER_SPACE);
        		if (tmp >= stepGoal) {
        			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
        		} else if (tmp >= 0) {
        			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        		}
        		dc.drawText(i-2, yRefStep-8, Gfx.FONT_XTINY, tmp.format("%01d"), Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
        		dc.drawLine(i, yRefStep-4, i, yRefStep+4);
        		dc.drawPoint(i + 1 * STEP_SPACES, yRefStep);
        		dc.drawPoint(i + 2 * STEP_SPACES, yRefStep);
        		dc.drawPoint(i + 3 * STEP_SPACES, yRefStep);
        		dc.drawPoint(i + 4 * STEP_SPACES, yRefStep);
        		index += 1;
        }   
    }
    
    function drawDateSlider(dc,dateOffset) {
        var today = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        var tomorrow = Calendar.info(Time.now().add(Calendar.duration({:days => 1})), Time.FORMAT_MEDIUM);
        var yesterday = Calendar.info(Time.now().add(Calendar.duration({:days => -1})), Time.FORMAT_MEDIUM);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var start = xRefDate - dateOffset - 12 * DATE_SPACES;
        for (var i = start; i < width + 20; i += HOUR_SPACES*12) {
        	var tmp_day = today.day;
        	var tmp_day_of_week = today.day_of_week;
        	if ((i < xRefDate) & ((i + (12 *DATE_SPACES)) < xRefDate)) {
        		tmp_day = yesterday.day;
        		tmp_day_of_week = yesterday.day_of_week;
        	}
        	if ((i >= xRefDate) & ((i + (12 *DATE_SPACES)) >= xRefDate)) {
        		tmp_day = tomorrow.day;
        		tmp_day_of_week = tomorrow.day_of_week;
        	}
        	dc.drawBitmap(i, yRefDate - 10, backgroundDateIcon);
        	dc.drawText(i + (6 *DATE_SPACES), yRefDate+11, Gfx.FONT_SMALL,tmp_day.format("%02d") , Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        	dc.drawText(i + (6 *DATE_SPACES), yRefDate-11, Gfx.FONT_SMALL,tmp_day_of_week , Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawHoursSlider(dc,hourOffset,hour) {
       	var start = xRefHour - hourOffset - 4 * (3 * HOUR_SPACES);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	for (var i = start, index = -1; i < width + 20; i += HOUR_SPACES*3) {
    	   	if ((i-start) % (HOUR_SPACES * 12) == 0) {
    			dc.drawBitmap(i, yRefHour - 9, backgroundHoursIcon);
    			var tmp = hour + index;
    			if (tmp >= 24) {
    					tmp -= 24;
    			}
    			if (tmp < 0) {
    				tmp += 24;
    			}
    			dc.drawText(i, yRefHour-44, Gfx.FONT_NUMBER_HOT, tmp.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    			index += 1;
    		}
    		var tmp =  (i-xRefHour+hourOffset+(HOUR_SPACES*12)) % (HOUR_SPACES * 12);
    		tmp = tmp * 15 / 24;
    		dc.drawText(i, yRefHour+17, Gfx.FONT_TINY, tmp.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    	}
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
}
