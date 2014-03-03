/*
* comet.data.score.LongNotePart
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    import comet.game.lanes.ILane;
    import comet.game.lanes.LongNoteLane;

    /**
    * The LongNotePart class represents a part of long note.
    *
    * @see comet.data.score.LongNoteCueSequence
    * @see comet.game.lanes.LongNoteLane
    *
    * @author Susisu
    */
    public class LongNotePart implements INotePart
    {

        private var _cueSequence:LongNoteCueSequence;

        private var _lane:LongNoteLane;

        /**
        * The LongNoteCueSequence object.
        */
        public function get cueSequence():ICueSequence
        {
            return this._cueSequence;
        }

        /**
        * The LongNoteLane object.
        */
        public function get lane():ILane
        {
            return this._lane;
        }


        /**
        * Creates a new LongNotePart object.
        *
        * @param style The style of long notes.
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        * @param hitRange The range of frames in which a note can be hit.
        */
        public function LongNotePart(style:String = "ddr", stdDuration:int = 150, speedMultiplier:Number = 1.0, hitRange:int = 8)
        {
            this._cueSequence = new LongNoteCueSequence(stdDuration, speedMultiplier);
            this._lane = new LongNoteLane(this._cueSequence, style, stdDuration, speedMultiplier, hitRange);
        }


        /**
        * @inheritDoc
        */
        public function toString():String
        {
            return this._cueSequence.toString();
        }

    }

}
