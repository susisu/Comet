/*
* comet.game.lanes.ILane
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    import comet.data.score.Score;

    /**
    * The ILane interface is inpremented by lane classes that is used in games.
    *
    * @author Susisu
    */
    public interface ILane
    {

        /**
        * Initializes frame position of the lane.
        *
        * @param initialFrame The initial frame of the initialized lane.
        */
        function init(initialFrame:int = 0):void;

        /**
        * Does some operations on the tick of the game.
        *
        * @param currentFrame The current frame of the game.
        */
        function tick(currentFrame:int):void;

    }

}
