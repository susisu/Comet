/*
* comet.events.LongNoteJudgementEvent
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.events
{

    import flash.events.Event;

    /**
    * A LongNoteLane object dispatches LongNoteJudgementEvent objects when it hits, completes or misses the long note. 
    *
    * @author Susisu
    */
    public class LongNoteJudgementEvent extends Event
    {

        /**
        * Defines the value of the type property of a long note hit event object.
        */
        public static const LONG_NOTE_HIT:String = "longNoteHit";

        /**
        * Defines the value of the type property of a long note complete event object.
        */
        public static const LONG_NOTE_COMPLETE:String = "longNoteComplete";

        /**
        * Defines the value of the type property of a long note miss event object.
        */
        public static const LONG_NOTE_MISS:String = "longNoteMiss";
  

        /**
        * The frame the long note hit.
        */
        public var frame:int;


        /**
        * Creates a new LongNoteJudgementEvent object with specific information relevant to judgement events.
        *
        * @param type The type of the event.
        * @param bubbles Determines whether the Event object bubbles.
        * @param cancelable Determines whether the Event object can be canceled.
        * @param frame The frame the long note hit.
        */
        public function LongNoteJudgementEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, frame:int = 0)
        {
            super(type, bubbles, cancelable);
            this.frame = frame;
        }


        /**
        * Creates a copy of the LongNoteJudgementEvent object.
        *
        * @return A new LongNoteJudgementEvent object with property values that match those of the original.
        */
        override public function clone():Event
        {
            return new LongNoteJudgementEvent(this.type, this.bubbles, this.cancelable, this.frame)
        }

        /**
        * Returns a string that contains all the properties of the LongNoteJudgementEvent object.
        *
        * @return A string that contains all the properties of the LongNoteJudgementEvent object.
        */
        override public function toString():String
        {
            return this.formatToString("LongNoteJudgementEvent", "type", "bubbles", "cancelable", "frame");
        }

    }

}
