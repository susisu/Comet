/*
* comet.events.InputDeviceEvent
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.events
{

    import flash.events.Event;

    /**
    * A input device object dispatches InputDeviceEvent objects when its state changes.
    *
    * @author Susisu
    */
    public class InputDeviceEvent extends Event
    {

        /**
        * Defines the value of the type property of a state change event object.
        */
        public static const STATE_CHANGE:String = "stateChange";

        /**
        * Defined the value of the type property of a not judged event object.
        */
        public static const NOT_JUDGED:String = "notJudged";


        /**
        * Creates a new InputDeviceEvent object with specific information relevant to input events.
        *
        * @param type The type of the event.
        * @param bubbles Determines whether the Event object bubbles.
        * @param cancelable Determines whether the Event object can be canceled.
        */
        public function InputDeviceEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }


        /**
        * Creates a copy of the InputDeviceEvent object.
        *
        * @return A new InputDeviceEvent object with property values that match those of the original.
        */
        override public function clone():Event
        {
            return new InputDeviceEvent(this.type, this.bubbles, this.cancelable)
        }

        /**
        * Returns a string that contains all the properties of the InputDeviceEvent object.
        *
        * @return A string that contains all the properties of the InputDeviceEvent object.
        */
        override public function toString():String
        {
            return this.formatToString("InputDeviceEvent", "type", "bubbles", "cancelable");
        }

    }

}
