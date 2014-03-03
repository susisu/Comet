/*
* comet.events.MetronomeEvent
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.events
{

    import flash.events.Event;

    /**
    * A metronome object dispatches MetronomeEvent objects for its every tick (or frame).
    *
    * @eventType flash.events.Event.COMPLETE
    *
    * @see comet.music.Metronome
    *
    * @author Susisu
    */
    public class MetronomeEvent extends Event
    {

        /**
        * Defines the value of the type property of a tick event object.
        */
        public static const TICK:String = "tick";
        

        /**
        * The current frame of the music.
        */
        public var currentFrame:int;


        /**
        * Creates a new MetronomeEvent object with specific information relevant to metronome events.
        *
        * @param type The type of the event.
        * @param bubbles Determines whether the Event object bubbles.
        * @param cancelable Determines whether the Event object can be canceled.
        * @param currentFrame The current frame of the metronome.
        */
        public function MetronomeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, currentFrame:int = 0)
        {
            super(type, bubbles, cancelable);
            this.currentFrame = currentFrame;
        }


        /**
        * Creates a copy of the MetronomeEvent object.
        *
        * @return A new MetronomeEvent object with property values that match those of the original.
        */
        override public function clone():Event
        {
            return new MetronomeEvent(this.type, this.bubbles, this.cancelable, this.currentFrame)
        }

        /**
        * Returns a string that contains all the properties of the MetronomeEvent object.
        *
        * @return A string that contains all the properties of the MetronomeEvent object.
        */
        override public function toString():String
        {
            return this.formatToString("MetronomeEvent", "type", "bubbles", "cancelable", "currentFrame");
        }

    }

}
