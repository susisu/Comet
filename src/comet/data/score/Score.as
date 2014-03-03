/*
* comet.data.score.Score
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score
{

    /**
    * The Score class represents score data that contains part objects.
    *
    * @see comet.data.score.IPart
    *
    * @author Susisu
    */
    public class Score
    {

        private var _parts:Vector.<IPart>;

        /**
        * The vector of the IPart objects that the score contains.
        */
        public function get parts():Vector.<IPart>
        {
            return this._parts;
        }
        

        /**
        * Creates a new Score object.
        *
        * @param numParts The number of the parts.
        */
        public function Score(numParts:int = 0)
        {
            this._parts = new Vector.<IPart>(numParts, true);
        }
        
        
        /**
        * Returns the string representation of the score.
        *
        * @return A string representation of the score.
        */
        public function toString():String
        {
            return this._parts.join("");
        }

    }

}
