/*
* comet.music.Metronome
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.music
{
    
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import comet.music.IMusic;
    import comet.events.MetronomeEvent;

    /**
    * A Metronome object dispatches tick events synchronized with music.
    *
    * @eventType comet.events.MetronomeEvent.TICK
    * @eventType flash.events.Event.COMPLETE
    *
    * @see comet.music.IMusic
    *
    * @author Susisu
    */
    public class Metronome extends EventDispatcher
    {

        private var _music:IMusic;
        
        /**
        * The music object that the ticks is synchronized with.
        */
        public function get music():IMusic
        {
            return this._music;
        }

        private var _fps:Number;

        /**
        * The value of FPS (or ticks per second).
        */
        public function get fps():Number
        {
            return this._fps;
        }

        /**
        * The timer that is used to make the ticks synchronized with music.
        */
        private var _timer:Timer;

        private var _currentFrame:int;

        /**
        * The current frame.
        */
        public function get currentFrame():int
        {
            return this._currentFrame;
        }


        /**
        * Creates a new Metronome object.
        *
        * @param music The music object that the ticks is synchronized with.
        * @param fps The value of FPS (or ticks per second).
        */
        public function Metronome(music:IMusic, fps:Number = 60.0)
        {
            this._music = music;
            this._fps = fps;

            this._timer = new Timer(1000 / 60);
            this._timer.addEventListener(TimerEvent.TIMER, onTimer);
            
            this._currentFrame = 0;
        }


        /**
        * Starts playing the music and ticking.
        *
        * @param startFrame
        */
        public function play(startFrame:int = 0):void
        {
            this._currentFrame = startFrame;
            this._music.play(startFrame / this._fps * 1000);
            this._music.addEventListener(Event.COMPLETE, onMusicComplete);
            this._timer.start();
        }

        /**
        * Stops playing the music and ticking.
        */
        public function stop():void
        {
            this._music.stop();
            this._music.addEventListener(Event.COMPLETE, onMusicComplete);
            this._timer.reset();
        }

        /**
        * The event handler of timer events.
        *
        * @param event The TimerEvent object.
        */
        private function onTimer(event:TimerEvent):void
        {
            while(this._music.position / 1000 * this._fps > this._currentFrame)
            {
                this._currentFrame++;
                this.dispatchEvent(new MetronomeEvent(MetronomeEvent.TICK, false, false, this._currentFrame));
            }
        }

        /**
        * The event handler of complete events of the music.
        *
        * @param The Event object.
        */
        private function onMusicComplete(event:Event):void
        {
            this.stop();
            this.dispatchEvent(new Event(Event.COMPLETE));
        }

    }

}
