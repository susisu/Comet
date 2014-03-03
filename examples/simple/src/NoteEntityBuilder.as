package
{
    
    import flash.display.Sprite;

    import comet.game.lanes.INoteEntityBuilder;
    import comet.game.lanes.INoteEntity

    public class NoteEntityBuilder extends Sprite implements INoteEntityBuilder
    {

        public function NoteEntityBuilder()
        {

        }

        public function getNoteEntity(extension:Object):INoteEntity
        {
            var entity:NoteEntity = new NoteEntity(this);
            this.addChild(entity);
            return entity;
        }

        public function kill(child:NoteEntity):void
        {
            this.removeChild(child);
        }

    }
}