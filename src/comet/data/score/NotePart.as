/*
* comet.data.score.NotePart
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    import comet.game.lanes.ILane;
    import comet.game.lanes.NoteLane;

    /**
    * The NotePart class represents a part of normal notes.
    *
    * @see comet.data.score.NoteCueSequence
    * @see comet.game.lanes.NoteLane
    *
    * @author Susisu
    */
    public class NotePart implements INotePart
    {

        private var _cueSequence:NoteCueSequence;
        
        /**
        * The NoteCueSequence object.
        */
        public function get cueSequence():ICueSequence
        {
            return this._cueSequence;
        }

        private var _lane:NoteLane;

        /**
        * The NoteLane object.
        */
        public function get lane():ILane
        {
            return this._lane;
        }


        /**
        * Creates a new NotePart object.
        *
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        * @param hitRange The range of frames in which a note can be hit.
        */
        public function NotePart(stdDuration:int = 150, speedMultiplier:Number = 1.0, hitRange:int = 8)
        {
            this._cueSequence = new NoteCueSequence(stdDuration, speedMultiplier);
            this._lane = new NoteLane(this._cueSequence, stdDuration, speedMultiplier, hitRange);
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
