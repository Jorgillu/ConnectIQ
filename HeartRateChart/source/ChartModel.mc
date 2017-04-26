using Toybox.Math as Math;
using Toybox.UserProfile as UserProfile;

class ChartModel {
    var ignore_sd = null;

    var current = null;
    var values_size = 100; // Must be even
    var values;
    var range_mult;
    var ori_range_mult;
    var compresion_ratio = 1;
    var range_mult_max;
    var range_expand = false;
    var range_mult_count = 0;
    var range_mult_count_not_null = 0;
    var next = 0;
   
   	var hr_zones;
   	var max_HR = 189;

    var min;
    var max;
    var min_i;
    var max_i;
    var mean;
    var sd;

    function initialize() {
        //set_range_minutes(2.5);
        if (UserProfile has :getHeartRateZones) {
        	hr_zones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        }        
    }

    function get_values() {
        return values;
    }

    function get_range_minutes() {
        return (values.size() * range_mult / 60);
    }

    function set_range_minutes(range) {
        var new_mult = Math.ceil(range * 60 / values_size);
        if (new_mult != range_mult) {
            range_mult = new_mult;
            ori_range_mult = new_mult;
            //System.println("range_mult " + range_mult);
            values = new [values_size];
            update_stats();
        }
    }
    
    function set_value_size(new_values_size) {
        values_size = new_values_size;
        //System.println("values_size " + values_size);
    }

    function set_max_range_minutes(range) {
        range_mult_max = range * 60 / values_size;
    }

    function set_range_expand(re) {
        range_expand = re;
    }

    // i.e. ignore values more than i standard deviations from the mean
    function set_ignore_sd(i) {
        ignore_sd = i;
    }

    function get_current() {
        return current;
    }

    function get_min() {
        return min;
    }

    function get_max() {
        return max;
    }

    function get_min_i() {
        return min_i;
    }

    function get_max_i() {
        return max_i;
    }

    function get_min_max_interesting() {
        return max != -99999999 and min != max;
    }

    function get_mean() {
        return mean;
    }

    function get_sd() {
        return sd;
    }

    function get_range_label() {
        var range = get_range_minutes();
        if (range < 60) {
            return "Last " + fmt_num_label(range) + "'";
        }
        else {
            return "Last " + fmt_num_label(range / 60) + "h";
        }
    }

    // Grr printf
    function fmt_num_label(num) {
        var before = num.toNumber();
        var after = (num * 10).toNumber() % 10;
        return after == 0 ? before : (before + "." + after);
    }

    function new_value(new_value) {
        current = new_value;
        if (current != null) {
            next += current;
            range_mult_count_not_null++;
        }
        range_mult_count++;
        if (range_mult_count >= range_mult) {
            var expand = range_expand && range_mult < range_mult_max &&
                values[0] == null && values[1] != null;

            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            values[values.size() - 1] = range_mult_count_not_null == 0 ?
                null : (next / range_mult_count_not_null);
            next = 0;
            range_mult_count = 0;
            range_mult_count_not_null = 0;

            if (expand) {
                do_range_expand();
            }

            update_stats();
        }
    }

    function do_range_expand() {
        var sz = values.size();
        //range_mult *= 2;
        range_mult += ori_range_mult;
        //System.println("range_mult " + range_mult);
        compresion_ratio += 1;
        //System.println("compresion_ratio " + compresion_ratio);
        var limit = Math.ceil(1.0*sz/compresion_ratio).toNumber();
        //System.println("limit " + limit);
        
        for (var i = sz - 1; i >= (sz - limit); i--) {
        	//System.println("i " + i);
            var old_i = (i * compresion_ratio) - (sz * (compresion_ratio - 1));
            //System.println("old_i " + old_i);
            var total = 0;
            var n = 0;
            //tenemos compresionRatio valores, que hay que pasar a compresion ratio-1
            for (var z = (compresion_ratio - 2) ; z >= 0 ; z--) {
            	//System.println("z " + z);
            	if ((old_i + z >= 0) && (values[old_i + z] != null)) {
            		total += values[old_i + z];
            		n++;
            	}
            	if ((old_i + z + 1 >= 0) && (values[old_i + z + 1] != null)) {
            		total += values[old_i + z + 1];
            		n++;
            	} 
	            //for (var j = old_i; j < old_i + 2; j++) {
	            //    if (values[j] != null) {
	            //        total += values[j];
	            //        n++;
	            //    }
	            //}
	            if (n > 0) {
	            	values[i-((sz-i)*(compresion_ratio-2)-z)] = total / n;
	            }
	            //values[i-((sz-i)*(compresion_ratio-2)-z)] = (n > 0) ? total / n : null;
	    	}
        }
        for (var i = 0; i < limit; i++) {
            values[i] = null;
        }
    }

    function update_stats() {
        min = 99999999;
        max = -99999999;
        min_i = 0;
        max_i = 0;

        var m = 0f;
        var s = 0f;
        var total = 0f;
        var n = 0;

        for (var i = 0; i < values.size(); i++) {
            var item = values[i];
            if (item != null) {
                // Welford
                n++;
                var m2 = m;
                m += (item - m2) / n;
                s += (item - m2) * (item - m);
                total += item;
            }
        }
        if (n == 0) {
            mean = null;
            sd = null;
        }
        else {
            mean = total / n;
            sd = Math.sqrt(s / n);
        }

        var ignore = null;
        if (sd != null && ignore_sd != null) {
            ignore = ignore_sd * sd;
        }

        for (var i = 0; i < values.size(); i++) {
            var item = values[i];
            if (item != null) {
                if (ignore != null &&
                    (item > mean + ignore || item < mean - ignore)) {
                    continue;
                }
                if (item < min) {
                    min_i = i;
                    min = item;
                }
                
                if (item > max) {
                    max_i = i;
                    max = item;
                }
            }
        }
    }
    
    function get_color(item){
    	if (item == null) {
    		return Graphics.COLOR_LT_GRAY;
    	} else if (item < get_zone1()) {
    		return Graphics.COLOR_LT_GRAY;
    	} else if (item < get_zone2()) {
    		return Graphics.COLOR_DK_GRAY;
    	} else if (item < get_zone3()) {
    		return Graphics.COLOR_BLUE;
    	} else if (item < get_zone4()) {
    		return Graphics.COLOR_GREEN;
    	} else if (item < get_zone5()) {
    		return Graphics.COLOR_ORANGE;
    	} else if (item < get_max_HR()) {
    		return Graphics.COLOR_RED;
    	} else {
    	    return Graphics.COLOR_PURPLE;
    	}
    }
    
    function get_zone1() {
    	if (hr_zones != null) {
    		return hr_zones[0];
    	}
    	return max_HR * 60 /100;
    }  
      
    function get_zone2() {
       	if (hr_zones != null) {
    		return hr_zones[1];
    	}
    	return max_HR * 68 / 100;
    }  
      
    function get_zone3() {
    	if (hr_zones != null) { 
    		return hr_zones[2];
    	}
    	return max_HR * 76 / 100;
    }   
     
    function get_zone4() {
    	if (hr_zones != null) {
    		return hr_zones[3];
    	}
    	return max_HR * 84 / 100;
    }  
     
    function get_zone5() {
    	if (hr_zones != null) {
    		return hr_zones[4];
    	}
    	return max_HR * 92 / 100;
    } 
    
         
    function get_max_HR() {
    	if (hr_zones != null) {
    		return hr_zones[5];
    	}
    	return max_HR;
    } 
}
