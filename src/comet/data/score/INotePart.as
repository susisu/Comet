/*
* comet.data.score.INotePart
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * The INotePart interface is implemented by part classes that has a sequence of cues.
    *
    * @see comet.data.score.ICueSequence
    *
    * @author Susisu
    */
    public interface INotePart extends IPart
    {

        /**
        * The cue sequence object of the part.
        */
        function get cueSequence():ICueSequence;
        
    }

}
