/*
* comet.data.score.LongNoteCueSequence
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * A LongNoteCueSequence object has sequences of long note cues and speed change cues.
    *
    * @see LongNoteCue
    * @see SpeedChangeCue
    *
    * @author Susisu
    */
    public class LongNoteCueSequence implements ICueSequence
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

        private var _longNoteCues:Vector.<LongNoteCue>;
        
        /**
        * The sequence of the long note cues.
        */
        public function get longNoteCues():Vector.<LongNoteCue>
        {
            return this._longNoteCues;
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
        * The temporary field to cache a head cue for the addNoteCue method.
        */
        private var _tempHeadCue:HeadCue;


        /**
        * Creates a new LongNoteCueSequence object.
        *
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        */
        public function LongNoteCueSequence(stdDuration:int = 150, speedMultiplier:Number = 1.0)
        {
            this._stdDuration = stdDuration;
            this._speedMultiplier = speedMultiplier;

            this._longNoteCues = new Vector.<LongNoteCue>();
            this._speedChangeCues = new Vector.<SpeedChangeCue>();
        }


        /**
        * Adds a long note cue to the sequence.
        *
        * <p>Once this method is called, it caches a cue as the head cue that represents the head of a long note.
        * The next time this method is called, it considers a cue as the end cue,
        * ignores <code>relSpeed</code> and <code>extension</code> parameters, and adds a long note cue to the sequence.</p>
        *
        * @param hitFrame The frame of the long note hitting (or ending).
        * @param relSpeed The relative speed of the note.
        * @param extension The frame of the note appearing.
        */
        public function addNoteCue(hitFrame:int, relSpeed:Number, extension:Object = null):void
        {
            if(this._tempHeadCue)
            {
                this._longNoteCues.push(
                    new LongNoteCue(
                        this._tempHeadCue.hitFrame,
                        hitFrame,
                        this._tempHeadCue.relSpeed,
                        this._tempHeadCue.extension
                    )
                );
                this._tempHeadCue = null;
            }
            else
            {
                this._tempHeadCue = new HeadCue(hitFrame, relSpeed, extension);
            }
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
            * Sorts the cues by (hitting) frames
            */
            this._speedChangeCues.sort(SpeedChangeCue.compareByFrame);
            this._longNoteCues.sort(LongNoteCue.compareByHitFrame);

            /*
            * Calculates the appearance information of the long note cues.
            */
            var numSpdChanges:int = this._speedChangeCues.length;
            var numLongNotes:int = this._longNoteCues.length;

            var spdIndex:int = 0;

            for(var i:int = 0; i < numLongNotes; i++)
            {
                var longNote:LongNoteCue = this._longNoteCues[i];

                while(spdIndex < 0 || spdIndex < numSpdChanges && this._speedChangeCues[spdIndex].frame < longNote.endFrame)
                {
                    spdIndex++;
                }
                spdIndex--;

                var currentSpeed:Number = spdIndex < 0 ? 1.0 : this._speedChangeCues[spdIndex].speed;
                var currentFrame:int = longNote.endFrame;
                var currentPos:Number = 0.0;
                var currentLength:Number = 0.0;

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

                    if(longNote.hitFrame <= currentFrame)
                    {
                        currentLength += currentSpeed * longNote.relSpeed * this._speedMultiplier / this._stdDuration;
                    }
                    else
                    {
                        currentPos -= currentSpeed * longNote.relSpeed * this._speedMultiplier / this._stdDuration;
                    }
                }

                longNote.appearFrame = currentFrame;
                longNote.length = currentLength;
                longNote.posCorrection = currentPos + 1.0;
            }

            /*
            * Sorts the note cues by appearing frames.
            */
            this._longNoteCues.sort(LongNoteCue.compareByAppearFrame);
        }

        public function toString():String
        {
            return "[" + this._longNoteCues.join(",") + "|" + this._speedChangeCues.join(",") + "]";
        }

    }

}


/*
* The HeadCue class represents head of a long note.
*/
class HeadCue
{

    public var hitFrame:int;

    public var relSpeed:Number;
    
    public var extension:Object;

    public function HeadCue(hitFrame:int, relSpeed:Number, extension:Object = null)
    {
        this.hitFrame = hitFrame;
        this.relSpeed = relSpeed;
        this.extension = extension;
    }

}
