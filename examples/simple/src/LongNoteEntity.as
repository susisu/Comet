package
{
    
    import flash.display.Sprite;
    import flash.display.Graphics;

    import comet.game.lanes.ILongNoteEntity;
    import comet.game.lanes.LongNoteEntityState;

    public class LongNoteEntity extends Sprite implements ILongNoteEntity
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

        private var _length:Number;
        public function get length():Number
        {
            return this._length;
        }
        public function set length(value:Number):void
        {
            this._length = value;
            draw();
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

        private var _duration:int;
        public function get duration():int
        {
            return this._duration;
        }
        public function set duration(value:int):void
        {
            this._duration = value;
        }

        private var _state:int;
        public function get state():int
        {
            return this._state;
        }
        public function set state(value:int):void
        {
            this._state = value;
            draw();
        }

        private var _parent:LongNoteEntityBuilder;

        public function LongNoteEntity(parent:LongNoteEntityBuilder)
        {
            this._parent = parent;
            
            this._t = 0.0;
            this._length = 0.0;
            this._relSpeed = 1.0;
            this._frame = 0;
            this._duration = 0;
            this._state = LongNoteEntityState.DEFAULT;
            
            draw();
        }

        private function draw():void
        {
            var g:Graphics = this.graphics;
            g.clear();
            if(this._state == LongNoteEntityState.DISABLED)
            {
                g.beginFill(0x000000, 0.25);
                g.drawRect(-16, -2, 32, 4);
                g.endFill();

                g.beginFill(0x000000, 0.25);
                g.drawRect(-16, -2 - this._length * 300, 32, 4);
                g.endFill();

                g.beginFill(0x000000, 0.125);
                g.drawRect(-16, -this._length * 300, 32, this._length * 300);
                g.endFill();
            }
            else
            {
                g.beginFill(0x000000, 0.5);
                g.drawRect(-16, -2, 32, 4);
                g.endFill();

                g.beginFill(0x000000, 0.5);
                g.drawRect(-16, -2 - this._length * 300, 32, 4);
                g.endFill();

                g.beginFill(0x000000, 0.25);
                g.drawRect(-16, -this._length * 300, 32, this._length * 300);
                g.endFill();
            }
        }

        public function kill():void
        {
            this._parent.kill(this);
            this._parent = null;
        }

    }
}