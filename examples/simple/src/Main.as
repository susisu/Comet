package
{
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.filters.DropShadowFilter;

    import comet.data.score.loaders.DOLLoader;
    import comet.data.score.NotePart;
    import comet.data.score.LongNotePart;
    import comet.data.score.Score;
    
    import comet.music.MP3Music;

    import comet.game.Game;
    import comet.game.lanes.ILane;
    import comet.game.lanes.NoteLane;
    import comet.game.lanes.LongNoteLane;
    import comet.game.lanes.LongNoteStyle;
    import comet.game.input.KeyboardInput;
    
    import comet.events.NoteJudgementEvent;
    import comet.events.LongNoteJudgementEvent;
    import comet.events.InputDeviceEvent;

    [SWF(width="480", height="360", frameRate="60", backgroundColor="0xffffff")]
    public class Main extends Sprite
    {

        private var _settingsURLLoader:URLLoader;
        private var _scoreURL:String;
        private var _scoreURLLoader:URLLoader;
        private var _musicURL:String;
        private var _musicURLLoader:URLLoader;
        private var _correction:int;

        private var _inputDevices:Vector.<KeyboardInput>;
        private var _game:Game;

        private var _judgementText:TextField;
        private var _combo:int;

        public function Main()
        {
            /*
            * 背景を追加
            */
            var background:Background = new Background();
            this.addChild(background);

            /*
            * メッセージ表示を追加
            */
            this._judgementText = new TextField();
            this._judgementText.selectable = false;
            this._judgementText.mouseEnabled = false;
            this._judgementText.wordWrap = true;
            this._judgementText.defaultTextFormat = new TextFormat("_sans", 36, 0xffffff, true, false, false, null, null, "center");
            this._judgementText.text = "now loading...";
            this._judgementText.alpha = 0.25;
            this._judgementText.y = 180 - 48;
            this._judgementText.width = 480;
            this._judgementText.height = 96;
            this._judgementText.filters = [new DropShadowFilter(0, 0, 0x000000, 1.0, 8.0, 8.0, 4.0)];
            this.addChild(this._judgementText);

            /*
            * 設定ファイルを読み込む
            */
            var request:URLRequest = new URLRequest("./settings.json");
            this._settingsURLLoader = new URLLoader();
            this._settingsURLLoader.addEventListener(Event.COMPLETE, onSettingsComplete);
            this._settingsURLLoader.load(request);
        }

        private function onSettingsComplete(event:Event):void
        {
            var data:Object = JSON.parse(this._settingsURLLoader.data);
            this._scoreURL = data["score"];
            this._musicURL = data["music"];
            this._correction = Math.round(data["correction"]);

            /*
            * 譜面を読み込む
            */
            var request:URLRequest = new URLRequest(this._scoreURL);
            this._scoreURLLoader = new URLLoader();
            this._scoreURLLoader.addEventListener(Event.COMPLETE, onScoreComplete);
            this._scoreURLLoader.load(request);
        }

        private function onScoreComplete(event:Event):void
        {
            /*
            * 音楽を読み込む
            */
            var request:URLRequest = new URLRequest(this._musicURL);
            this._musicURLLoader = new URLLoader();
            this._musicURLLoader.dataFormat = "binary";
            this._musicURLLoader.addEventListener(Event.COMPLETE, onMusicComplete);
            this._musicURLLoader.load(request);
        }

        private function onMusicComplete(event:Event):void
        {
            var code:String = String(this._scoreURLLoader.data);
            
            /*
            * 譜面 (DOL) 読み込み用のローダーを作成
            */
            var dolLoader:DOLLoader = new DOLLoader(60.0);

            /*
            * 入力装置を初期化
            */
            var sInput:KeyboardInput = new KeyboardInput(this.stage, 83);
            var dInput:KeyboardInput = new KeyboardInput(this.stage, 68);
            var fInput:KeyboardInput = new KeyboardInput(this.stage, 70);
            var jInput:KeyboardInput = new KeyboardInput(this.stage, 74);
            var kInput:KeyboardInput = new KeyboardInput(this.stage, 75);
            var lInput:KeyboardInput = new KeyboardInput(this.stage, 76);
            this._inputDevices = Vector.<KeyboardInput>([
                    sInput,
                    dInput,
                    fInput,
                    jInput,
                    kInput,
                    lInput
                ]);
            this._inputDevices.forEach(
                function(id:KeyboardInput, index:int, vec:Vector.<KeyboardInput>):void
                {
                    id.addEventListener(InputDeviceEvent.NOT_JUDGED, onInputNotJudged);
                }
            );
            var notePartNames:Array = ["s", "d", "f", "j", "k", "l"];
            var longNotePartNames:Array = ["s_long", "d_long", "f_long", "j_long", "k_long", "l_long"];

            /*
            * パートを作成、譜面ローダーに割り当て
            */

            /*
            * 通常ノートパート
            */
            for(var i:int = 0; i < 6; i++)
            {
                var notePart:NotePart = new NotePart(150, 1.0, 8);

                /*
                * パートに対応したレーンの設定
                */
                var noteLane:NoteLane = notePart.lane as NoteLane;
                
                var noteBuilder:NoteEntityBuilder = new NoteEntityBuilder();
                noteBuilder.x = i * 48 + 96 + 24;
                noteBuilder.y = 300;
                this.addChild(noteBuilder);
                noteLane.entityBuilder = noteBuilder;

                noteLane.inputDevice = this._inputDevices[i];
                noteLane.addEventListener(NoteJudgementEvent.NOTE_HIT, onNoteHit);
                noteLane.addEventListener(NoteJudgementEvent.NOTE_MISS, onNoteMiss);

                /*
                * 割り当て
                */
                dolLoader.assignNotePart(notePartNames[i], notePart);
            }

            /*
            * ロングノートパート
            */
            for(i = 0; i < 6; i++)
            {
                var longNotePart:LongNotePart = new LongNotePart(LongNoteStyle.DDR, 150, 1.0, 8);

                /*
                * パートに対応したレーンの設定
                */
                var longNoteLane:LongNoteLane = longNotePart.lane as LongNoteLane;

                var longNoteBuilder:LongNoteEntityBuilder = new LongNoteEntityBuilder();
                longNoteBuilder.x = i * 48 + 96 + 24;
                longNoteBuilder.y = 300;
                this.addChild(longNoteBuilder);
                longNoteLane.entityBuilder = longNoteBuilder;

                longNoteLane.inputDevice = this._inputDevices[i];
                longNoteLane.addEventListener(LongNoteJudgementEvent.LONG_NOTE_HIT, onLongNoteHit);
                longNoteLane.addEventListener(LongNoteJudgementEvent.LONG_NOTE_COMPLETE, onLongNoteComplete);
                longNoteLane.addEventListener(LongNoteJudgementEvent.LONG_NOTE_MISS, onLongNoteMiss);

                /*
                * 割り当て
                */
                dolLoader.assignNotePart(longNotePartNames[i], longNotePart);
            }

            /*
            * 譜面の読み込み
            */
            var score:Score = dolLoader.load(code);

            /*
            * 音楽オブジェクトの作成
            */
            var music:MP3Music = new MP3Music(this._musicURLLoader.data);

            /*
            * ゲームオブジェクトの作成
            */
            this._game = new Game(score, music, 60.0, this._correction);

            this._judgementText.text = "press any key\nS D F J K L";

            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
        }

        private function onStageKeyDown(event:KeyboardEvent):void
        {
            this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);

            this._judgementText.text = "";

            /*
            * コンボ数を初期化
            */
            this._combo = 0;

            /*
            * 入力装置を有効化
            */
            this._inputDevices.forEach(
                function(id:KeyboardInput, index:int, vec:Vector.<KeyboardInput>):void
                {
                    id.enable();
                }
            );

            /*
            * ゲームを開始
            */
            this._game.addEventListener(Event.COMPLETE, onGameComplete);
            this._game.play(0);
        }

        private function onNoteHit(event:NoteJudgementEvent):void
        {
            var f:int = Math.abs(event.frame);
            if(f <= 2)
            {
                this._combo++;
                this._judgementText.text = "Marvelous!\n" + this._combo.toString() + " combo";
            }
            else if(f <= 4)
            {
                this._combo++;
                this._judgementText.text = "Excellent!\n" + this._combo.toString() + " combo";
            }
            else
            {
                this._judgementText.text = "Good!";
            }
        }

        private function onNoteMiss(event:NoteJudgementEvent):void
        {
            this._combo = 0;
            this._judgementText.text = "Miss...";
        }

        private function onLongNoteHit(event:LongNoteJudgementEvent):void
        {
            var f:int = Math.abs(event.frame);
            if(f <= 2)
            {
                this._combo++;
                this._judgementText.text = "Marvelous!\n" + this._combo.toString() + " combo";
            }
            else if(f <= 4)
            {
                this._combo++;
                this._judgementText.text = "Excellent!\n" + this._combo.toString() + " combo";
            }
            else
            {
                this._judgementText.text = "Good!";
            }
        }

        private function onLongNoteComplete(event:LongNoteJudgementEvent):void
        {
            this._combo++;
            this._judgementText.text = "Complete!\n" + this._combo.toString() + " combo";
        }

        private function onLongNoteMiss(event:LongNoteJudgementEvent):void
        {
            this._combo = 0;
            this._judgementText.text = "Miss...";
        }

        private function onInputNotJudged(event:InputDeviceEvent):void
        {
            if((event.target as KeyboardInput).state)
            {
                /*
                * 空押し判定はここに記述
                */
                /*
                this._combo = 0;
                this._judgementText.text = "Boo...";
                */
            }
        }

        private function onGameComplete(event:Event):void
        {
            this._game.removeEventListener(Event.COMPLETE, onGameComplete);
            this._judgementText.text = "Clear";
        }
    }
    
}