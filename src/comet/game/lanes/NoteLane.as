/*
* comet.game.lanes.NoteLane
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    import flash.events.EventDispatcher;

    import comet.data.score.NoteCueSequence;
    import comet.data.score.NoteCue;
    import comet.data.score.SpeedChangeCue;
    import comet.game.input.IBinaryInputDevice;
    import comet.events.InputDeviceEvent;
    import comet.events.NoteJudgementEvent;

    /**
    * The NoteLane class represents lane of normal notes.
    *
    * @see comet.data.score.NoteCueSequence
    * @see comet.game.lanes.INoteEntity
    * @see comet.game.lanes.INoteEntityBuilder
    *
    * @author Susisu
    */
    public class NoteLane extends EventDispatcher implements ILane
    {

        /**
        * The sequence of the note cues of the lane.
        */
        private var _seq:NoteCueSequence;
        
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
        * The index of the sequence of the note cues.
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
        * The note entities the lane contains.
        */
        private var _entities:Vector.<INoteEntity>;

        private var _entityBuilder:INoteEntityBuilder;
        
        /**
        * The builder object of the note entities.
        */
        public function get entityBuilder():INoteEntityBuilder
        {
            return this._entityBuilder;
        }
        
        public function set entityBuilder(value:INoteEntityBuilder):void
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
        * Creates a new NoteLane object.
        *
        * @param seq The NoteCueSequence object which contains the sequence of the note cues and the speed change cues.
        * @param stdDuration The duration of a note of 1.0x speed, in frames.
        * @param speedMultiplier The multiplier of the speed.
        * @param hitRange The range of frames in which notes can be hit.
        */
        public function NoteLane(seq:NoteCueSequence, stdDuration:int = 150, speedMultiplier:Number = 1.0, hitRange:int = 8)
        {
            this._seq = seq;
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
            this._entities = new Vector.<INoteEntity>();
            this._noteIndex = 0;
            this._speed = 1.0;
            this._speedChangeIndex = 0;

            var currentFrame:int = Math.min(
                    this._seq.noteCues.length > 0 ? this._seq.noteCues[0].appearFrame : initialFrame,
                    this._seq.speedChangeCues.length > 0 ? this._seq.speedChangeCues[0].frame : initialFrame
                );
            while(currentFrame <= initialFrame)
            {
                initTick(currentFrame);
                currentFrame++;
            }
        }

        /**
        * @inheritDoc
        */
        public function tick(currentFrame:int):void
        {
            moveEntities();

            createEntities(currentFrame);
            
            changeSpeed(currentFrame);
        }

        /**
        * Does some operations on the tick of the game in the initializing phase.
        *
        * @param currentFrame The current frame of the game.
        */
        private function initTick(currentFrame:int):void
        {
            moveEntities(false);

            createEntities(currentFrame);
            
            changeSpeed(currentFrame);
        }

        /**
        * Moves the note entities the lane contains.
        *
        * @param dispatchEvents Specifies whether the method dispatch events or not.
        */
        private function moveEntities(dispatchEvents:Boolean = true):void
        {
            var numEntities:int = this._entities.length;
            for(var i:int = 0; i < numEntities; i++)
            {
                var entity:INoteEntity = this._entities[i];
                entity.t += this._speed * entity.relSpeed / this._stdDuration * this._speedMultiplier;
                entity.frame++;
                if(entity.frame >= this._hitRange)
                {
                    if(dispatchEvents)
                    {
                        this.dispatchEvent(new NoteJudgementEvent(NoteJudgementEvent.NOTE_MISS));
                    }
                    entity.kill();
                    this._entities.splice(i, 1);
                    numEntities--;
                    i--;
                }
            }
        }

        /**
        * Creates new note entities and adds it to the lane.
        *
        * @param currentFrame The current frame of the game.
        */
        private function createEntities(currentFrame:int):void
        {
            var cuesLength:int = this._seq.noteCues.length;
            while(this._noteIndex < cuesLength
                && this._seq.noteCues[this._noteIndex].appearFrame == currentFrame)
            {
                if(this._entityBuilder)
                {
                    var cue:NoteCue = this._seq.noteCues[this._noteIndex];
                    var entity:INoteEntity = this._entityBuilder.getNoteEntity(cue.extension);
                    entity.t = -1.0 + cue.posCorrection;
                    entity.relSpeed = cue.relSpeed;
                    entity.frame = cue.appearFrame - cue.hitFrame;
                    
                    insertEntity(entity);
                }
                this._noteIndex++;
            }
        }

        /**
        * Inserts a note entity to the vector of the entities.
        *
        * @param entity The note entity to insert.
        */
        private function insertEntity(entity:INoteEntity):void
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
            if(this._entities && this._entities.length > 0)
            {
                var headEntity:INoteEntity = this._entities[0];
                if(this._inputDevice.state)
                {
                    if(Math.abs(headEntity.frame) < this._hitRange)
                    {
                        this.dispatchEvent(new NoteJudgementEvent(NoteJudgementEvent.NOTE_HIT, false, false, headEntity.frame));
                        headEntity.kill();
                        this._entities.splice(0, 1);
                        event.preventDefault();
                    }
                }
            }
        }

    }

}
