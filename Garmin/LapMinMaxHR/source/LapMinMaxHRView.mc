using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.FitContributor as Fit;

const BORDER_PAD = 4;
const VSCREEN_BORDER = 40;
const HSCREEN_BORDER = 20;
const LAP_MIN_HR_FIELD_ID = 0;

var fonts = [Gfx.FONT_XTINY,Gfx.FONT_TINY,Gfx.FONT_SMALL,Gfx.FONT_MEDIUM,Gfx.FONT_LARGE,
             Gfx.FONT_NUMBER_MILD,Gfx.FONT_NUMBER_MEDIUM,Gfx.FONT_NUMBER_HOT,Gfx.FONT_NUMBER_THAI_HOT];

class LapMinMaxHRView extends Ui.DataField {
    
    //Heart Rate Variables
    hidden var mCurrentLapMinHR = 250;
	hidden var mCurrentLapMaxHR = -1;
	hidden var mLastLapMinHR = null;
	hidden var mLastLapMaxHR = null;

	// LastLap Min HR variables
    hidden var mLastLapMinHRX;
    hidden var mLastLapMinHRY;
    hidden var mLastLapMinHRLabelX;
    hidden var mLastLapMinHRLabelY;  
     	
	// Last Lap Max HR variables
    hidden var mLastLapMaxHRX;
    hidden var mLastLapMaxHRY;
    hidden var mLastLapMaxHRLabelX;
    hidden var mLastLapMaxHRLabelY;
        	
	// Lap Min HR variables
    hidden var mLapMinHRX;
    hidden var mLapMinHRY;
    hidden var mLapMinHRLabelX;
    hidden var mLapMinHRLabelY;
        	
	// Lap Max HR variables
    hidden var mLapMaxHRX;
    hidden var mLapMaxHRY;
    hidden var mLapMaxHRLabelX;
    hidden var mLapMaxHRLabelY;
    	
	//Fit Contributor Variables
	hidden var mLapMinHRField = null;
	hidden var mTimerRunning = false;
	
	// Font Values
    hidden var mDataFont;
    hidden var mDataFontAscent;
    hidden var mLabelFont = Gfx.FONT_XTINY;
    hidden var mLabelFontAscent;
    
    hidden var width;
    hidden var height;
    hidden var xCenter;
    hidden var yCenter;

    function initialize() {
        DataField.initialize();
        mLapMinHRField = createField("lap_min_hr", LAP_MIN_HR_FIELD_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>64, :mesgType=>Fit.MESG_TYPE_LAP, :units=>"bpm" });
        mLapMinHRField.setData(0);
    }

    // Set your layout here.
    function onLayout(dc) {
    	var layoutWidth;
        var layoutHeight;
        var layoutFontIdx;
        
        width = dc.getWidth();
        height = dc.getHeight();
        
        mLabelFontAscent = Gfx.getFontAscent(mLabelFont);
        
        xCenter = dc.getWidth() / 2;
        yCenter = dc.getHeight() / 2;
        
        layoutWidth = (width - (4 * BORDER_PAD) - (2 * HSCREEN_BORDER)) / 2;
        System.println("width... " + layoutWidth);
        layoutHeight = (height - (6 * BORDER_PAD) - (2 * VSCREEN_BORDER) - (2 * mLabelFontAscent)) /2;
        System.println("heigth... " + layoutHeight);
        layoutFontIdx = selectFont(dc, layoutWidth, layoutHeight);
        System.println("font... " + layoutFontIdx);
        
        mDataFont = fonts[layoutFontIdx];
        //mDataFont = Gfx.FONT_LARGE;
        mDataFontAscent = Gfx.getFontAscent(mDataFont);
        
        mLapMinHRX = HSCREEN_BORDER + BORDER_PAD + (layoutWidth / 2);
    	mLapMinHRY = yCenter - BORDER_PAD - (layoutHeight / 2) -  (mDataFontAscent / 2);
    	mLapMinHRLabelX = mLapMinHRX;
    	mLapMinHRLabelY = VSCREEN_BORDER + BORDER_PAD;  

        mLapMaxHRX = width - HSCREEN_BORDER - BORDER_PAD - (layoutWidth / 2);
    	mLapMaxHRY = mLapMinHRY;
    	mLapMaxHRLabelX = mLapMaxHRX;
    	mLapMaxHRLabelY = mLapMinHRLabelY;
    	
    	mLastLapMinHRX = mLapMinHRX;
    	mLastLapMinHRY = height - VSCREEN_BORDER - BORDER_PAD -  (layoutWidth / 2) + (mDataFontAscent / 2);
    	mLastLapMinHRLabelX = mLastLapMinHRX - 2 * BORDER_PAD;
    	mLastLapMinHRLabelY = yCenter + BORDER_PAD + (mLabelFontAscent / 2);  
    	
    	mLastLapMaxHRX = mLapMaxHRX;
    	mLastLapMaxHRY = mLastLapMinHRY;
    	mLastLapMaxHRLabelX = mLastLapMaxHRX + 2 * BORDER_PAD;
    	mLastLapMaxHRLabelY = mLastLapMinHRLabelY;         
    }

    function selectFont(dc, width, height) {
        var testString = "888"; //Dummy string to test data width
        var fontIdx;
        var dimensions;

        //Search through fonts from biggest to smallest
        for (fontIdx = (fonts.size() - 1); fontIdx > 0; fontIdx--) {
            dimensions = dc.getTextDimensions(testString, fonts[fontIdx]);
            if ((dimensions[0] <= width) && (dimensions[1] <= height)) {
                //If this font fits, it is the biggest one that does
                break;
            }
        }

        return fontIdx;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
	        if(mTimerRunning) {
		        if ((info.currentHeartRate != null) && (info.currentHeartRate < mCurrentLapMinHR)) {
		        	mCurrentLapMinHR = info.currentHeartRate;
		        }
		       	if ((info.currentHeartRate != null) && (info.currentHeartRate > mCurrentLapMaxHR)) {
	        		mCurrentLapMaxHR = info.currentHeartRate;
	        	}
	        	mLapMinHRField.setData(mCurrentLapMinHR);
		        System.println("Current: " + info.currentHeartRate);
		    }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        var bgColor = getBackgroundColor();
        var fgColor = Gfx.COLOR_WHITE;

        if (bgColor == Gfx.COLOR_WHITE) {
            fgColor = Gfx.COLOR_BLACK;
        }

        dc.setColor(Graphics.COLOR_RED, bgColor);
        dc.clear();
        
		dc.drawLine(xCenter, 0, xCenter, height);
		dc.drawLine(0, yCenter, width, yCenter);
		
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
        
        dc.drawText(mLapMinHRLabelX, mLapMinHRLabelY, mLabelFont, "LapMinHR", Gfx.TEXT_JUSTIFY_CENTER);
        if (mCurrentLapMinHR != 250) {
       		dc.drawText(mLapMinHRX, mLapMinHRY, mDataFont, mCurrentLapMinHR, Gfx.TEXT_JUSTIFY_CENTER);
       	} else {
       		dc.drawText(mLapMinHRX, mLapMinHRY, mDataFont, "---", Gfx.TEXT_JUSTIFY_CENTER);
       	}

        dc.drawText(mLapMaxHRLabelX, mLapMaxHRLabelY, mLabelFont, "LapMaxHR", Gfx.TEXT_JUSTIFY_CENTER);
        if (mCurrentLapMaxHR != -1) {
       		dc.drawText(mLapMaxHRX, mLapMaxHRY, mDataFont, mCurrentLapMaxHR, Gfx.TEXT_JUSTIFY_CENTER);
       	} else {
       		dc.drawText(mLapMaxHRX, mLapMaxHRY, mDataFont, "---", Gfx.TEXT_JUSTIFY_CENTER);
       	}     

        dc.drawText(mLastLapMinHRLabelX, mLastLapMinHRLabelY, mLabelFont, "LLapMinHR", Gfx.TEXT_JUSTIFY_CENTER);
        if (mLastLapMinHR != null) {
       		dc.drawText(mLastLapMinHRX, mLastLapMinHRY, mDataFont, mLastLapMinHR, Gfx.TEXT_JUSTIFY_CENTER);
       	} else {
       		dc.drawText(mLastLapMinHRX, mLastLapMinHRY, mDataFont, "---", Gfx.TEXT_JUSTIFY_CENTER);
       	}

        dc.drawText(mLastLapMaxHRLabelX, mLastLapMaxHRLabelY, mLabelFont, "LLapMaxHR", Gfx.TEXT_JUSTIFY_CENTER);
        if (mLastLapMaxHR != null) {
       		dc.drawText(mLastLapMaxHRX, mLastLapMaxHRY, mDataFont, mLastLapMaxHR, Gfx.TEXT_JUSTIFY_CENTER);
       	} else {
       		dc.drawText(mLastLapMaxHRX, mLastLapMaxHRY, mDataFont, "---", Gfx.TEXT_JUSTIFY_CENTER);
       	}        

        // Call parent's onUpdate(dc) to redraw the layout
        //View.onUpdate(dc);
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
    
   	function onTimerLap() {
        mLastLapMinHR = mCurrentLapMinHR;
        mCurrentLapMinHR = 250;
        
        mLastLapMaxHR = mCurrentLapMaxHR;
        mCurrentLapMaxHR = -1;
    }
}
