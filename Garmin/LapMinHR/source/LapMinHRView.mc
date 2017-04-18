using Toybox.WatchUi as Ui;
using Toybox.FitContributor as Fit;

const LAP_MIN_HR_FIELD_ID = 0;

class LapMinHRView extends Ui.SimpleDataField {

	hidden var mLapMinHR = 250;
	hidden var mLapMinHRField = null;
	hidden var mTimerRunning = false;
	
    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Lap Min HR";
        mLapMinHRField = createField("lap_min_hr", LAP_MIN_HR_FIELD_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>64, :mesgType=>Fit.MESG_TYPE_LAP, :units=>"bpm" });
        mLapMinHRField.setData(0);
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(mTimerRunning) {
	        if ((info.currentHeartRate != null) && (info.currentHeartRate < mLapMinHR)) {
	        	mLapMinHR = info.currentHeartRate;
	        }
	        System.println("Current: " + info.currentHeartRate);
	        mLapMinHRField.setData(mLapMinHR);
	    }
	    if (mLapMinHR == 250) {
        	return "---";
        } else {
	    	return mLapMinHR;
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
        mLapMinHR = 250;
    }
}