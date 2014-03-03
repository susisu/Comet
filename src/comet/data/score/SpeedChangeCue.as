/*
* comet.data.score.SpeedChangeCue
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * A SpeedChangeCue object has information of a speed change.
    *
    * @author Susisu
    */
    public class SpeedChangeCue
    {

        /**
        * Compares two cues by their <code>frame</code> properties.
        *
        * @param left The left element to be compared.
        * @param right The right element to be compared.
        * @return if left's frame is less than right's, negative number; equals to right's, 0; greater than right's, positive number.
        */
        public static function compareByFrame(left:SpeedChangeCue, right:SpeedChangeCue):Number
        {
            return left.frame - right.frame;
        }


        /**
        * The frame the speed change occurs.
        */
        public var frame:int;
        
        /**
        * The speed after the speed change.
        */
        public var speed:Number;
        

        /**
        * Creates a new SpeedChangeCue object.
        *
        * @param frame The frame the speed change occurs.
        * @param speed The speed after the speed change.
        */
        public function SpeedChangeCue(frame:int, speed:Number)
        {
            this.frame = frame;
            this.speed = speed;
        }


        /**
        * Returns the string representation of the cue.
        *
        * @return A string representation of the cue.
        */
        public function toString():String
        {
            return this.frame.toString() + "@" + this.speed.toString();
        }
        
    }

}
