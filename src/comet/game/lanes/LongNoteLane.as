/*
* comet.game.lanes.LongNoteLane
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    import flash.events.EventDispatcher;

    import comet.data.score.LongNoteCueSequence;
    import comet.data.score.LongNoteCue;
    import comet.data.score.SpeedChangeCue;
    import comet.game.input.IBinaryInputDevice;
    import comet.events.InputDeviceEvent;
    import comet.events.LongNoteJudgementEvent;

    /**
    * The LonNoteLane class provides a way to deal with long notes.
    *
    * @see comet.data.score.LongNoteCueSequence
    * @see comet.game.lanes.LongNoteEntity
    * @see comet.game.lanes.LongNoteEntityBuilder
    *
    * @author Susisu
    */
    public class LongNoteLane extends EventDispatcher implements ILane
    {

        /**
        * The sequence of the long note cues of the lane.
        */
        private var _seq:LongNoteCueSequence;

        private var _style:String;

        /**
        * The style of long notes.
        */
        public function get style():String
        {
            return this._style;
        }

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

        private var _hitRange:int;

        /**
        * The range of frames in which a note can be hit.
        */
        public function get hitRange():int
        {
            return this._hitRange;
        }

        /**
        * The index of the sequence of the long note cues.
        */
        private var _noteIndex:int;

        /**
        * The index of the sequence of the speed change cues.
        */
        private var _speedChangeIndex:int;

        /**
        * The current speed of the lane.
        */
        private var _speed:Number;

        /**
        * The long note entities the lane contains.
        */
        private var _entities:Vector.<ILongNoteEntity>;

        private var _entityBuilder:ILongNoteEntityBuilder;

        /**
        * The builder object of the long note entities.
        */
        public function get entityBuilder():ILongNoteEntityBuilder
        {
            return this._entityBuilder;
        }

        public function set entityBuilder(value:ILongNoteEntityBuilder):void
        {
            this._entityBuilder = value;
        }

        private var _inputDevice:IBinaryInputDevice;

        /**
        * The input device to get inputs.
        */
        public function get inputDevice():IBinaryInputDevice
        {
            return this._inputDevice;
        }

        public function set inputDevice(value:IBinaryInputDevice):void
        {
            if(this._inputDevice)
            {
                this._inputDevice.removeEventListener(InputDeviceEvent.STATE_CHANGE, onInputDeviceStateChange);
            }
            this._inputDevice = value;
            if(this._inputDevice)
            {
                this._inputDevice.addEventListener(InputDeviceEvent.STATE_CHANGE, onInputDeviceStateChange);
            }
        }


        /**
        * Creates a new LongNoteLane object.
        *
        * @param seq The LongNoteCueSequence object which contains the sequence of the long note cues and the speed change cues.
        * @param style The style of long notes.
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        * @param hitRange The range of frames in which notes can be hit.
        */
        public function LongNoteLane(
            seq:LongNoteCueSequence, style:String = "ddr", stdDuration:int = 150, speedMultiplier:Number = 1.0, hitRange:int = 8)
        {
            this._seq = seq;
            this._style = style;
            this._stdDuration = stdDuration;
            this._speedMultiplier = speedMultiplier;
            this._hitRange = hitRange;
            this._noteIndex = 0;
            this._speedChangeIndex = 0;
            this._speed = 1.0;
            this._entities = null;
            this._entityBuilder = null;
            this._inputDevice = null;
        }


        /**
        * @inheritDoc
        */
        public function init(initialFrame:int = 0):void
        {
            this._entities = new Vector.<ILongNoteEntity>();
            this._noteIndex = 0;
            this._speed = 1.0;
            this._speedChangeIndex = 0;

            var currentFrame:int = Math.min(
                    this._seq.longNoteCues.length > 0 ? this._seq.longNoteCues[0].appearFrame : initialFrame,
                    this._seq.speedChangeCues.length > 0 ? this._seq.speedChangeCues[0].frame : initialFrame
                );
            while(currentFrame <= initialFrame)
            {
                this.initTick(currentFrame);
                currentFrame++;
            }
        }

        /**
        * @inheritDoc
        */
        public function tick(currentFrame:int):void
        {
            this.moveEntities();

            this.createEntities(currentFrame);
            
            this.changeSpeed(currentFrame);
        }

        /**
        * Does some operations on the tick of the game in the initializing phase.
        *
        * @param currentFrame The current frame of the game.
        */
        private function initTick(currentFrame:int):void
        {
            this.moveEntities(false);

            this.createEntities(currentFrame);

            this.changeSpeed(currentFrame);
        }

        /**
        * Moves the long note entities the lane contains.
        *
        * @param dispatchEvents Specifies whether the method dispatches events or not.
        */
        private function moveEntities(dispatchEvents:Boolean = true):void
        {
            var numEntities:int = this._entities.length;
            for(var i:int = 0; i < numEntities; i++)
            {
                var entity:ILongNoteEntity = this._entities[i];
                switch(entity.state)
                {
                    case LongNoteEntityState.HITTING:
                        entity.length -= this._speed * entity.relSpeed / this._stdDuration * this._speedMultiplier;
                        entity.frame++;
                        entity.duration--;
                        switch(this._style)
                        {
                            case LongNoteStyle.KM:
                                if(entity.duration <= -this._hitRange)
                                {
                                    if(dispatchEvents)
                                    {
                                        this.dispatchEvent(new LongNoteJudgementEvent(LongNoteJudgementEvent.LONG_NOTE_MISS));
                                    }
                                    entity.kill();
                                    this._entities.splice(i, 1);
                                    numEntities--;
                                    i--;
                                }
                                break;
                            case LongNoteStyle.DDR:
                            default:
                                if(entity.duration <= 0)
                                {
                                    if(dispatchEvents)
                                    {
                                        this.dispatchEvent(new LongNoteJudgementEvent(LongNoteJudgementEvent.LONG_NOTE_COMPLETE));
                                    }
                                    entity.kill();
                                    this._entities.splice(i, 1);
                                    numEntities--;
                                    i--;
                                }
                        }
                        break;
                    case LongNoteEntityState.DISABLED:
                        entity.t += this._speed * entity.relSpeed / this._stdDuration * this._speedMultiplier;
                        entity.frame++;
                        entity.duration--;
                        if(entity.duration <= -this._hitRange)
                        {
                            entity.kill();
                            this._entities.splice(i, 1);
                            numEntities--;
                            i--;
                        }
                        break;
                    case LongNoteEntityState.DEFAULT:
                    default:
                        entity.t += this._speed * entity.relSpeed / this._stdDuration * this._speedMultiplier;
                        entity.frame++;
                        if(entity.frame >= this._hitRange)
                        {
                            if(dispatchEvents)
                            {
                                this.dispatchEvent(new LongNoteJudgementEvent(LongNoteJudgementEvent.LONG_NOTE_MISS));
                            }
                            entity.state = LongNoteEntityState.DISABLED;
                        }
                }
            }
        }

        /**
        * Creates new long note entities and adds it to the lane.
        *
        * @param currentFrame The current frame of the game.
        */
        private function createEntities(currentFrame:int):void
        {
            var cuesLength:int = this._seq.longNoteCues.length;
            while(this._noteIndex < cuesLength
                && this._seq.longNoteCues[this._noteIndex].appearFrame == currentFrame)
            {
                var cue:LongNoteCue = this._seq.longNoteCues[this._noteIndex];
                if(this._entityBuilder)
                {
                    var entity:ILongNoteEntity = this._entityBuilder.getLongNoteEntity(cue.extension);
                    entity.t = -1.0 + cue.posCorrection;
                    entity.length = cue.length;
                    entity.relSpeed = cue.relSpeed;
                    entity.frame = cue.appearFrame - cue.hitFrame;
                    entity.duration = cue.endFrame - cue.hitFrame;
                    entity.state = LongNoteEntityState.DEFAULT;
                    
                    insertEntity(entity);
                }
                this._noteIndex++;
            }
        }

        /**
        * Inserts a long note entity to the vector of the entities.
        *
        * @param entity The note entity to insert.
        */
        private function insertEntity(entity:ILongNoteEntity):void
        {
            var numEntities:int = this._entities.length;
            for(var i:int = 0; i < numEntities; i++)
            {
                if(entity.frame > this._entities[i].frame)
                {
                    this._entities.splice(i, 0, entity);
                    return;
                }
            }
            this._entities.push(entity);
        }

        /**
        * Changes the speed of the lane.
        *
        * @param currentFrame The current frame of the game.
        */
        private function changeSpeed(currentFrame:int):void
        {
            var speedChangeCuesLength:int = this._seq.speedChangeCues.length;
            while(this._speedChangeIndex < speedChangeCuesLength
                && this._seq.speedChangeCues[this._speedChangeIndex].frame == currentFrame)
            {
                this._speed = this._seq.speedChangeCues[this._speedChangeIndex].speed;
                this._speedChangeIndex++;
            }
        }

        /**
        * The event handler of status change events of the input device.
        *
        * @param event The InputDeviceEvent object.
        */
        private function onInputDeviceStateChange(event:InputDeviceEvent):void
        {
            var headIndex:int = this.getHeadEnabledEntityIndex();
            if(headIndex >= 0)
            {
                var headEntity:ILongNoteEntity = this._entities[headIndex];
                switch(headEntity.state)
                {
                    case LongNoteEntityState.HITTING:
                        if(!this._inputDevice.state)
                        {
                            switch(this._style)
                            {
                                case LongNoteStyle.KM:
                                    if(Math.abs(headEntity.duration) < this._hitRange)
                                    {
                                        this.dispatchEvent(
                                            new LongNoteJudgementEvent(
                                                LongNoteJudgementEvent.LONG_NOTE_COMPLETE, false, false, -headEntity.duration)
                                        );
                                        headEntity.kill();
                                        this._entities.splice(headIndex, 1);
                                        event.preventDefault();
                                    }
                                    else
                                    {
                                        headEntity.state = LongNoteEntityState.DISABLED;
                                        this.dispatchEvent(new LongNoteJudgementEvent(LongNoteJudgementEvent.LONG_NOTE_MISS));
                                        event.preventDefault();
                                    }
                                    break;
                                case LongNoteStyle.DDR:
                                default:
                                    headEntity.state = LongNoteEntityState.DISABLED;
                                    this.dispatchEvent(new LongNoteJudgementEvent(LongNoteJudgementEvent.LONG_NOTE_MISS));
                                    event.preventDefault();
                            }
                        }
                        break;
                    case LongNoteEntityState.DISABLED:
                        break;
                    case LongNoteEntityState.DEFAULT:
                    default:
                        if(this._inputDevice.state)
                        {
                            if(Math.abs(headEntity.frame) < this._hitRange)
                            {
                                headEntity.state = LongNoteEntityState.HITTING;
                                headEntity.length -= headEntity.t;
                                headEntity.t = 0;
                                headEntity.duration -= headEntity.frame;
                                this.dispatchEvent(
                                    new LongNoteJudgementEvent(
                                        LongNoteJudgementEvent.LONG_NOTE_HIT, false, false, headEntity.frame)
                                );
                                event.preventDefault();
                            }
                        }
                }
            }
        }

        /**
        * Gets the index of the first enabled entity in the vector.
        *
        * @return The index of the first enabled entity.
        */
        private function getHeadEnabledEntityIndex():int
        {
            if(this._entities)
            {
                var numEntities:int = this._entities.length;
                for(var i:int = 0; i < numEntities; i++)
                {
                    if(this._entities[i].state != LongNoteEntityState.DISABLED)
                    {
                        return i;
                    }
                }
                return -1;
            }
            else
            {
                return -1;
            }
        }

    }

}
