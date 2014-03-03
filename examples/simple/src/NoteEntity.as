package
{
    
    import flash.display.Sprite;
    import flash.display.Graphics;

    import comet.game.lanes.INoteEntity;

    public class NoteEntity extends Sprite implements INoteEntity
    {

        private var _t:Number;
        public function get t():Number
        {
            return this._t;
        }
        public function set t(value:Number):void
        {
            this._t = value;
            this.y = value * 300;
        }

        private var _relSpeed:Number;
        public function get relSpeed():Number
        {
            return this._relSpeed;
        }
        public function set relSpeed(value:Number):void
        {
            this._relSpeed = value;
        }

        private var _frame:int;
        public function get frame():int
        {
            return this._frame;
        }
        public function set frame(value:int):void
        {
            this._frame = value;
        }

        private var _parent:NoteEntityBuilder;

        public function NoteEntity(parent:NoteEntityBuilder)
        {
            this._parent = parent;

            this._t = 0.0;
            this._relSpeed = 1.0;
            this._frame = 0;

            var g:Graphics = this.graphics;
            g.beginFill(0x000000, 0.5);
            g.drawRect(-16, -2, 32, 4)
            g.endFill();
        }

        public function kill():void
        {
            this._parent.kill(this);
            this._parent = null;
        }

    }
}