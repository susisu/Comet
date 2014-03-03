/*
* comet.music.IMusic
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.music
{

    import flash.events.IEventDispatcher;
    
    /**
    * The IMusic interface is implemented by music classes that can be played in games.
    *
    * <p>A music object should dispatch a complete event when the music finished.</p>
    *
    * @author Susisu
    */
    public interface IMusic extends IEventDispatcher
    {

        /**
        * The length of the music in milliseconds.
        */
        function get length():Number;

        /**
        * The current position in milliseconds that is being played in the music.
        */
        function get position():Number;

        /**
        * Starts playing the music.
        *
        * @param startTime The initial position in milliseconds at which playback should start.
        */
        function play(startTime:Number = 0):void;

        /**
        * Stops playing the music.
        */
        function stop():void;

    }

}
