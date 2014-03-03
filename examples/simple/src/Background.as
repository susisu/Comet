package
{
    
    import flash.display.Shape;
    import flash.display.Graphics;

    public class Background extends Shape
    {

        public function Background()
        {
            var g:Graphics = this.graphics;
            g.lineStyle(1, 0xc0c0c0);
            g.beginFill(0xf0f0f0);
            g.drawRect(96, 0, 48, 360);
            g.endFill();
            g.beginFill(0xffffff);
            g.drawRect(96 + 48, 0, 48, 360);
            g.endFill();
            g.beginFill(0xf0f0f0);
            g.drawRect(96 + 96, 0, 48, 360);
            g.endFill();
            g.beginFill(0xf0f0f0);
            g.drawRect(96 + 144, 0, 48, 360);
            g.endFill();
            g.beginFill(0xffffff);
            g.drawRect(96 + 192, 0, 48, 360);
            g.endFill();
            g.beginFill(0xf0f0f0);
            g.drawRect(96 + 240, 0, 48, 360);
            g.endFill();


            g.lineStyle(4, 0x000000, 0.25);
            g.moveTo(0, 300);
            g.lineTo(480, 300);
        }

    }

}