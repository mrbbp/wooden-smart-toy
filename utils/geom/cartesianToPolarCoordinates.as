/**
 * Created by IntelliJ IDEA.
 * User: Ian McLean
 * Date: Sep 30, 2010
 * Time: 11:56:07 AM
  modified by mrbbp
  June 8, 2014
 */
package utils.geom {

    /**
	    Converts cartesian coordinates to polar coordinates.

	   @param x: The x value of the cartesian point.
	   @param y: The y value of the cartesian point.
	   @return Returns an array containing polar coordinates r and q.
	 */

    public function cartesianToPolarCoordinates(x:Number,  y:Number) : Array {

        var r:Number = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
		var q:Number;
		/*if (x>0) {
			q = Math.atan2(y,x) * (180/Math.PI);
		} else {
			q = (Math.atan2(y,x)+Math.PI) * (180/Math.PI);
		}*/
		if (y > 0) {
			q = Math.atan2(y,x) * (180/Math.PI);
		} else {
			q = ((Math.PI*2)+Math.atan2(y,x)) * (180/Math.PI);
		}
        return [r, q];
    }

}