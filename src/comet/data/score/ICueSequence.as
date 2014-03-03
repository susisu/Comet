/*
* comet.data.score.ICueSequence
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{
    
    /**
    * The ICueSequence interface is implemented by cue sequence classes that represent sequences of cues.
    *
    * @author Susisu
    */
    public interface ICueSequence
    {

        /**
        * Adds a note cue to the sequence.
        *
        * @param hitFrame The frame of the note hitting.
        * @param relSpeed The relative speed of the note.
        * @param extension The frame of the note appearing.
        */
        function addNoteCue(hitFrame:int, relSpeed:Number, extension:Object = null):void

        /**
        * Adds a speed change cue to the sequence.
        *
        * @param frame The frame the speed change occurs.
        * @param speed The speed after the speed change.
        */
        function addSpeedChangeCue(frame:int, speed:Number):void;
        
        /**
        * Calculates the appearance information of the note cues.
        */
        function calcAppearanceInfo():void;

        /**
        * Returns the string representation of the sequence.
        *
        * @return A string representation of the sequence.
        */
        function toString():String;
        
    }

}
