using Toybox.WatchUi as Ui;

class LapMaxHRView extends Ui.SimpleDataField {

	hidden var mLapMaxHR = -1;
	hidden var mTimerRunning = false;
	
    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Lap Max HR";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(mTimerRunning) {
	        if ((info.currentHeartRate != null) && (info.currentHeartRate > mLapMaxHR)) {
	        	mLapMaxHR = info.currentHeartRate;
	        }
	        System.println("Current: " + info.currentHeartRate);
	    }
	    if (mLapMaxHR == -1) {
        	return "---";
        } else {
	    	return mLapMaxHR;
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
        mLapMaxHR = -1;
    }
}