/*
* comet.music.MP3Music
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.music
{
    
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.ByteArray;

    import comet.music.IMusic;

    /**
    * The MP3Music class let you play back MP3 music in games.
    *
    * @eventType flash.events.Event.COMPLETE
    *
    * @author Susisu
    */
    public class MP3Music extends EventDispatcher implements IMusic
    {

        /**
        * @inheritDoc
        */
        public function get length():Number
        {
            return this._sound.length;
        }

        private var _position:Number;
        
        /**
        * @inheritDoc
        */
        public function get position():Number
        {
            if(this._channel)
            {
                return this._channel.position;
            }
            else
            {
                return 0;
            }
        }

        /**
        * The Sound object to play the mp3 data.
        */
        private var _sound:Sound;
        
        /**
        * The channel of the sound that is currently played.
        */
        private var _channel:SoundChannel;


        /**
        * Creates a new MP3Music object.
        *
        * @param data The ByteArray object which contains MP3 sound data.
        */
        public function MP3Music(data:ByteArray)
        {
            this._sound = new Sound();
            this._sound.loadCompressedDataFromByteArray(data, data.length);

            this._channel = null;
        }


        /**
        * @inheritDoc
        */
        public function play(startTime:Number = 0):void
        {
            if(this._channel)
            {
                this.stop();
            }

            this._channel = this._sound.play(startTime);
            this._channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }

        /**
        * @inheritDoc
        */
        public function stop():void
        {
            this._channel.stop();
            this._channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }

        /**
        * The event handler of sound complete events.
        *
        * @param event An Event object.
        */
        private function onSoundComplete(event:Event):void
        {
            this.stop();
            this.dispatchEvent(new Event(Event.COMPLETE));
        }

    }

}
