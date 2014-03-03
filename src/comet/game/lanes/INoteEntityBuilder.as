/*
* comet.game.lanes.INoteEntityBuilder
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.game.lanes
{

    /**
    * The INoteEntityBuilder interface is implemented by builder classes of note entity.
    *
    * @see comet.game.lanes.NoteLane
    * @see comet.game.lanes.INoteEntity
    *
    * @author Susisu
    */
    public interface INoteEntityBuilder
    {

        /**
        * Gets a new INoteEntity object.
        *
        * @param extension The extension field of the note.
        */
        function getNoteEntity(extension:Object):INoteEntity;

    }

}
