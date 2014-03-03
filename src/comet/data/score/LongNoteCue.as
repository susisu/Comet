/*
* comet.data.score.LongNoteCue
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * A LongNoteCue object has information of a long note.
    *
    * @author Susisu
    */
    public class LongNoteCue
    {

        /**
        * Compares two cues by their <code>hitFrame</code> properties.
        *
        * @param left The left element to be compared.
        * @param right The right element to be compared.
        * @return if left's hitFrame is less than right's, negative number; equals to right's, 0; greater than right's, positive number.
        */
        public static function compareByHitFrame(left:LongNoteCue, right:LongNoteCue):Number
        {
            return left.hitFrame - right.hitFrame;
        }

        /**
        * Compares two cues by their <code>appearFrame</code> properties.
        *
        * @param left The left element to be compared.
        * @param right The right element to be compared.
        * @return if left's appearFrame is less than right's, negative number; equals to right's, 0; greater than right's, positive number.
        */
        public static function compareByAppearFrame(left:LongNoteCue, right:LongNoteCue):Number
        {
            return left.appearFrame - right.appearFrame;
        }


        /**
        * The frame of the long note hitting.
        */
        public var hitFrame:int;

        /**
        * The frame of the end of the long note.
        */
        public var endFrame:int;
        
        /**
        * The relative speed of the long note.
        */
        public var relSpeed:Number;

        /**
        * The frame of the long note appearing.
        */
        public var appearFrame:int;
        
        /**
        * The length of the long note.
        */
        public var length:Number;
        
        /**
        * The correction of the appearing position of the long note.
        */
        public var posCorrection:int;

        /**
        * The extension field of the long note. (e.g. color, effect, etc.)
        */
        public var extension:Object;


        /**
        * Creates a new LongNoteCue object.
        *
        * @param hitFrame The frame of the long note hitting.
        * @param endFrame The frame of the end of the long note.
        * @param relSpeed The relative speed of the long note.
        * @param extension The extension field of the long note.
        */
        public function LongNoteCue(hitFrame:int, endFrame:int, relSpeed:Number = 1.0, extension:Object = null)
        {
            this.hitFrame = hitFrame;
            this.endFrame = endFrame;
            this.relSpeed = relSpeed;
            this.appearFrame = 0;
            this.length = 0;
            this.posCorrection = 0;
            this.extension = extension;
        }


        /**
        * Returns the string representation of the cue.
        *
        * @return A string representation of the cue.
        */
        public function toString():String
        {
            return this.hitFrame.toString() + ":" + this.endFrame.toString() + "@" + this.relSpeed.toString();
        }

    }

}
