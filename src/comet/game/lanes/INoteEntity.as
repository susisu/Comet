/*
* comet.game.lanes.INoteEntity
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    /**
    * The INoteEntity interface is implemented by note entity classes.
    *
    * @see comet.game.lanes.NoteLane
    * @see comet.game.lanes.INoteEntityBuilder
    *
    * @author Susisu
    */
    public interface INoteEntity
    {

        /**
        * The virtual t corrdinate value that represents the position of the note.
        */
        function get t():Number;
        
        function set t(value:Number):void;

        /**
        * The relative speed of the note.
        */
        function get relSpeed():Number;
        
        function set relSpeed(value:Number):void;

        /**
        * The current frame of the note.
        */
        function get frame():int;
        
        function set frame(value:int):void;

        /**
        * Kills the note itself.
        */
        function kill():void;
        
    }

}
