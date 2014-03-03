/*
* comet.events.NoteJudgementEvent
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.events
{

    import flash.events.Event;

    /**
    * A NoteLane object dispatches NoteJudgementEvent objects when it hits or misses the note.
    *
    * @author Susisu
    */
    public class NoteJudgementEvent extends Event
    {

        /**
        * Defines the value of the type property of a note hit event object.
        */
        public static const NOTE_HIT:String = "noteHit";

        /**
        * Defines the value of the type property of a note miss event object.
        */
        public static const NOTE_MISS:String = "noteMiss";


        /**
        * The frame the note hit.
        */
        public var frame:int;


        /**
        * Creates a new NoteJudgementEvent object with specific information relevant to judgement events.
        *
        * @param type The type of the event.
        * @param bubbles Determines whether the Event object bubbles.
        * @param cancelable Determines whether the Event object can be canceled.
        * @param frame The frame the note hit.
        */
        public function NoteJudgementEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, frame:int = 0)
        {
            super(type, bubbles, cancelable);
            this.frame = frame;
        }


        /**
        * Creates a copy of the NoteJudgementEvent object.
        *
        * @return A new NoteJudgementEvent object with property values that match those of the original.
        */
        override public function clone():Event
        {
            return new NoteJudgementEvent(this.type, this.bubbles, this.cancelable, this.frame)
        }

        /**
        * Returns a string that contains all the properties of the NoteJudgementEvent object.
        *
        * @return A string that contains all the properties of the NoteJudgementEvent object.
        */
        override public function toString():String
        {
            return this.formatToString("NoteJudgementEvent", "type", "bubbles", "cancelable", "frame");
        }

    }

}
