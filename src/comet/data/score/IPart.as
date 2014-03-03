/*
* comet.data.score.IPart
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    import comet.game.lanes.ILane;

    /**
    * The IPart interface is implemented by part classes that represent parts of score.
    *
    * @see comet.game.lanes.ILane
    *
    * @author Susisu
    */
    public interface IPart
    {

        /**
        * The lane object of the part.
        */
        function get lane():ILane;

        /**
        * Returns the string representation of the part.
        *
        * @return A string representation of the par.
        */
        function toString():String;
        
    }

}
