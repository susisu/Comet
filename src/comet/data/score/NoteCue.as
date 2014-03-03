/*
* comet.data.score.NoteCue
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{
    
    /**
    * A NoteCue object has information of a note.
    *
    * @author Susisu
    */
    public class NoteCue
    {

        /**
        * Compares two cues by their <code>hitFrame</code> properties.
        *
        * @param left The left element to be compared.
        * @param right The right element to be compared.
        * @return if left's hitFrame is less than right's, negative number; equals to right's, 0; greater than right's, positive number.
        */
        public static function compareByHitFrame(left:NoteCue, right:NoteCue):Number
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
        public static function compareByAppearFrame(left:NoteCue, right:NoteCue):Number
        {
            return left.appearFrame - right.appearFrame;
        }


        /**
        * The frame of the note hitting.
        */
        public var hitFrame:int;

        /**
        * The relative speed of the note.
        */
        public var relSpeed:Number;

        /**
        * The frame of the note appearing.
        */
        public var appearFrame:int;

        /**
        * The correction of the appearing position of the note.
        */
        public var posCorrection:int;

        /**
        * The extension field of the note. (e.g. color, effect, etc.)
        */
        public var extension:Object;


        /**
        * Creates a new NoteCue object.
        *
        * @param hitFrame The frame of the note hitting.
        * @param relSpeed The relative speed of the note.
        * @param extension The extension field of the note.
        */
        public function NoteCue(hitFrame:int, relSpeed:Number = 1.0, extension:Object = null)
        {
            this.hitFrame = hitFrame;
            this.relSpeed = relSpeed;
            this.appearFrame = 0;
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
            return this.hitFrame.toString() + "@" + this.relSpeed.toString();
        }

    }

}
