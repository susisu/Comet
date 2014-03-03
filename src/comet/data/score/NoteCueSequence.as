/*
* comet.data.score.NoteCueSequence
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * A NoteCueSequence object has sequences of normal note cues and speed change cues.
    *
    * @see comet.data.score.NoteCue
    * @see comet.data.score.SpeedChangeCue
    *
    * @author Susisu
    */
    public class NoteCueSequence implements ICueSequence
    {

        private var _stdDuration:int;

        /**
        * The duration of a note of 1.0x speed, in frames.
        */
        public function get stdDuration():int
        {
            return this._stdDuration;
        }

        private var _speedMultiplier:Number;

        /**
        * The multiplier of the speed.
        */
        public function get speedMultiplier():Number
        {
            return this._speedMultiplier;
        }

        private var _noteCues:Vector.<NoteCue>;
        
        /**
        * The sequence of the note cues.
        */
        public function get noteCues():Vector.<NoteCue>
        {
            return this._noteCues;
        }

        private var _speedChangeCues:Vector.<SpeedChangeCue>;
        
        /**
        * The sequence of the speed change cues.
        */
        public function get speedChangeCues():Vector.<SpeedChangeCue>
        {
            return this._speedChangeCues;
        }


        /**
        * Creates a new NoteCueSequence object.
        *
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        */
        public function NoteCueSequence(stdDuration:int = 150, speedMultiplier:Number = 1.0)
        {
            this._stdDuration = stdDuration;
            this._speedMultiplier = speedMultiplier;

            this._noteCues = new Vector.<NoteCue>();
            this._speedChangeCues = new Vector.<SpeedChangeCue>();
        }


        /**
        * @inheritDoc
        */
        public function addNoteCue(hitFrame:int, relSpeed:Number, extension:Object = null):void
        {
            this._noteCues.push(new NoteCue(hitFrame, relSpeed, extension));
        }

        /**
        * @inheritDoc
        */
        public function addSpeedChangeCue(frame:int, speed:Number):void
        {
            this._speedChangeCues.push(new SpeedChangeCue(frame, speed));
        }

        /**
        * @inheritDoc
        */
        public function calcAppearanceInfo():void
        {
            /*
            *  Sorts the cues by (hitting) frames
            */
            this._speedChangeCues.sort(SpeedChangeCue.compareByFrame);
            this._noteCues.sort(NoteCue.compareByHitFrame);

            /*
            *  Calculates the appearance information of the note cues.
            */
            var numSpdChanges:int = this._speedChangeCues.length;
            var numNotes:int = this._noteCues.length;

            var spdIndex:int = 0;

            for(var i:int = 0; i < numNotes; i++)
            {
                var note:NoteCue = this._noteCues[i];

                while(spdIndex < 0 || spdIndex < numSpdChanges && this._speedChangeCues[spdIndex].frame < note.hitFrame)
                {
                    spdIndex++;
                }
                spdIndex--;

                var currentSpeed:Number = spdIndex < 0 ? 1.0 : this._speedChangeCues[spdIndex].speed;
                var currentFrame:int = note.hitFrame;
                var currentPos:Number = 0.0;

                while(currentPos > -1.0)
                {
                    currentFrame--;

                    while(spdIndex >= 0 && currentFrame < this._speedChangeCues[spdIndex].frame)
                    {
                        spdIndex--;

                        if(spdIndex < 0)
                        {
                            currentSpeed = 1.0;
                        }
                        else
                        {
                            currentSpeed = this._speedChangeCues[spdIndex].speed;
                        }
                    }

                    currentPos -= currentSpeed * note.relSpeed * this._speedMultiplier / this._stdDuration;
                }

                note.appearFrame = currentFrame;
                note.posCorrection = currentPos + 1.0;
            }

            /*
            *  Sorts the note cues by appearing frames
            */
            this._noteCues.sort(NoteCue.compareByAppearFrame);
        }

        /**
        * @inheritDoc
        */
        public function toString():String
        {
            return "[" + this._noteCues.join(",") + "|" + this._speedChangeCues.join(",") + "]";
        }

    }

}
