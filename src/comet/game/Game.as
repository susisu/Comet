/*
* comet.game.Game
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game
{

    import flash.events.EventDispatcher;
    import flash.events.Event;

    import comet.data.score.Score;
    import comet.game.lanes.ILane;
    import comet.music.IMusic;
    import comet.music.Metronome;
    import comet.events.MetronomeEvent;

    /**
    * The Game class let you make a game.
    *
    * @eventType flash.events.Event.COMPLETE
    *
    * @see comet.data.score.Score
    * @see comet.music.IMusic
    *
    * @author Susisu
    */
    public class Game extends EventDispatcher
    {

        /**
        * The lane objects the game contains.
        */
        private var _lanes:Vector.<ILane>;

        /**
        * The metronome object.
        */
        private var _metronome:Metronome;

        /**
        * The correction of frames of the game.
        */
        private var _frameCorrection:int;


        /**
        * Creates a new Game object.
        *
        * @param score The Score object that contains the score data.
        * @param music The music object that is played.
        * @param fps The FPS of the game.
        * @param frameCorrection The correction of frames of the game. If positive, the game will be late to the music.
        */
        public function Game(score:Score, music:IMusic, fps:Number = 60.0, frameCorrection:int = 0)
        {
            this._lanes = new Vector.<ILane>();
            var numLanes:int = score.parts.length;
            for(var i:int = 0; i < numLanes; i++)
            {
                this._lanes.push(score.parts[i].lane);
            }

            this._metronome = new Metronome(music, fps);

            this._frameCorrection = frameCorrection;
        }


        /**
        * Starts playing the game.
        *
        * @param startFrame The initial frame at which the game should start.
        */
        public function play(startFrame:int = 0):void
        {
            var numLanes:int = this._lanes.length;
            for(var i:int = 0; i < numLanes; i++)
            {
                this._lanes[i].init(startFrame - this._frameCorrection);
            }
            
            this._metronome.addEventListener(MetronomeEvent.TICK, onMetronomeTick);
            this._metronome.addEventListener(Event.COMPLETE, onMetronomeComplete);
            this._metronome.play(startFrame);
        }

        /**
        * Quits the game.
        */
        public function quit():void
        {
            this._metronome.removeEventListener(MetronomeEvent.TICK, onMetronomeTick);
            this._metronome.removeEventListener(Event.COMPLETE, onMetronomeComplete);
            this._metronome.stop();
        }

        /**
        * The event handler for tick events of the metronome.
        *
        * @param event The MetronomeEvent object.
        */
        private function onMetronomeTick(event:MetronomeEvent):void
        {
            var numLanes:int = this._lanes.length;
            for(var i:int = 0; i < numLanes; i++)
            {
                this._lanes[i].tick(event.currentFrame - this._frameCorrection);
            }
        }

        /**
        * The event handler for complete events of the metronome.
        *
        * @param event The Event object.
        */
        private function onMetronomeComplete(event:Event):void
        {
            this.quit();
            this.dispatchEvent(new Event(Event.COMPLETE));
        }

    }

}
