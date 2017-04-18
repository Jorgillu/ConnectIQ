using Toybox.WatchUi as Ui;

class LastLapMinHRView extends Ui.SimpleDataField {

	hidden var mCurrentLapMinHR = 250;
	hidden var mLastLapMinHR = null;
	hidden var mTimerRunning = false;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "L Lap Min HR";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(mTimerRunning) {
	        if ((info.currentHeartRate != null) && (info.currentHeartRate < mCurrentLapMinHR)) {
	        	mCurrentLapMinHR = info.currentHeartRate;
	        }
	        System.println("Current: " + info.currentHeartRate);
	    }
        if (mLastLapMinHR == null) {
        	return "---";
        } else {
        	return mLastLapMinHR;
        }
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
    }
}