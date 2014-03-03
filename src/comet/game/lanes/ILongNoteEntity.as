/*
* comet.game.lanes.ILongNoteEntity
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    /**
    * The INoteEntity interface implemented by long note entitiy classes.
    *
    * @author Susisu
    */
    public interface ILongNoteEntity
    {

        /**
        * The virtual t corrdinate value that represents the position of the long note.
        */
        function get t():Number;
        
        function set t(value:Number):void;

        /**
        * The length of the long note.
        */
        function get length():Number;
        
        function set length(value:Number):void;

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
        * The duration of the long note in frames.
        */
        function get duration():int;
        
        function set duration(value:int):void;

        /**
        * Indicates the state of the long note.
        */
        function get state():int;
        
        function set state(value:int):void;

        /**
        * Kills the long note itself.
        */
        function kill():void;
        
    }

}
