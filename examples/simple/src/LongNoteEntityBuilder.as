package
{
    
    import flash.display.Sprite;

    import comet.game.lanes.ILongNoteEntityBuilder;
    import comet.game.lanes.ILongNoteEntity

    public class LongNoteEntityBuilder extends Sprite implements ILongNoteEntityBuilder
    {

        public function LongNoteEntityBuilder()
        {

        }

        public function getLongNoteEntity(extension:Object):ILongNoteEntity
        {
            var entity:LongNoteEntity = new LongNoteEntity(this);
            this.addChild(entity);
            return entity;
        }

        public function kill(child:LongNoteEntity):void
        {
            this.removeChild(child);
        }

    }
}