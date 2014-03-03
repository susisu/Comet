/*
* comet.game.input.KeyboardInput
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.input
{
    
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.display.Stage;

    import comet.events.InputDeviceEvent;

    /**
    * The KeyboardInput class represents a input device whose state is determined by whether a key is down or up.
    *
    * @eventType comet.events.InputDeviceEvent.STATE_CHANGE
    * @eventType comet.events.InputDeviceEvent.NOT_JUDGED
    *
    * @author Susisu
    */
    public class KeyboardInput extends EventDispatcher implements IBinaryInputDevice
    {

        /**
        * The Stage object to get key inputs.
        */
        private var _stage:Stage;

        private var _keyCode:int;
        
        /**
        * The key code of the key that triggers the change of the state.
        */
        public function get keyCode():int
        {
            return this._keyCode;
        }

        private var _state:Boolean;
        
        /**
        * The state of the device.
        */
        public function get state():Boolean
        {
            return _state;
        }


        /**
        * Creates a new KeyboardInput object.
        *
        * @param stage The Stage object to get key inputs.
        * @param keyCode The key code of the key that triggers the change of the state.
        */
        public function KeyboardInput(stage:Stage, keyCode:int)
        {
            this._stage = stage;
            this._keyCode = keyCode;
            this._state = false;
        }


        /**
        * Enables on the device.
        */
        public function enable():void
        {
            this._stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
            this._stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
        }

        /**
        * Disables off the device.
        */
        public function disable():void
        {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
            this._stage.removeEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
        }

        /**
        * The event handler of key down events of the stage.
        *
        * @param event The KeyboardEvent object.
        */
        private function onStageKeyDown(event:KeyboardEvent):void
        {
            if(event.keyCode == this._keyCode)
            {
                if(!this._state)
                {
                    this._state = true;
                    var notJudged:Boolean = this.dispatchEvent(new InputDeviceEvent(InputDeviceEvent.STATE_CHANGE, false, true));
                    if(notJudged)
                    {
                        this.dispatchEvent(new InputDeviceEvent(InputDeviceEvent.NOT_JUDGED));
                    }
                }
            }
        }

        /**
        * The event handler of key up events of the stage.
        *
        * @param event The KeyboardEvent object.
        */
        private function onStageKeyUp(event:KeyboardEvent):void
        {
            if(event.keyCode == this._keyCode)
            {
                if(this._state)
                {
                    this._state = false;
                    var notJudged:Boolean = this.dispatchEvent(new InputDeviceEvent(InputDeviceEvent.STATE_CHANGE, false, true));
                    if(notJudged)
                    {
                        this.dispatchEvent(new InputDeviceEvent(InputDeviceEvent.NOT_JUDGED));
                    }
                }
            }
        }

    }
}
