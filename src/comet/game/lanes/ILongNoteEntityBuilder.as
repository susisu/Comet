/*
* comet.game.lanes.ILongNoteEntityBuilder
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    /**
    * The ILongNoteEntityBuilder interface is implemented by builder classes of long note entities.
    *
    * @author Susisu
    */
    public interface ILongNoteEntityBuilder
    {

        /**
        * Gets a new ILongNoteEntity object.
        *
        * @param extension The extension field of the long note.
        */
        function getLongNoteEntity(extension:Object):ILongNoteEntity;

    }

}
