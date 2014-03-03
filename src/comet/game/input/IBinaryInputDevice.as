/*
* comet.game.input.IBinaryInputDevice
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.input
{

    import flash.events.IEventDispatcher;

    /**
    * The IBinaryInputDevice interface is implemented by input device classes whose state is defined by a Boolean value.
    *
    * @author Susisu
    */
    public interface IBinaryInputDevice extends IEventDispatcher
    {

        /**
        * The state of the input device.
        */
        function get state():Boolean;

    }

}
