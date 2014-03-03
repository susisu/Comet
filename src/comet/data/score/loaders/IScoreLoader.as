/*
* comet.data.score.loaders.IScoreLoader
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score.loaders
{

    import comet.data.score.Score;

    /**
    * The IScoreLoader provides an interface for loaders that load score data from text data.
    *
    * @author Susisu
    */
    public interface IScoreLoader
    {

        /**
        * Loads a score data from a text data.
        *
        * @param data The text data that contains a score data.
        * @return A Score object that contains a score data loaded from the text data.
        */
        function load(data:String):Score;

    }

}
