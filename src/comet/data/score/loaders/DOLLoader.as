/*
* comet.data.score.loaders.DOLLoader
*
* Copyright (C) 2014 Susisu
* see: license.txt
*/

package comet.data.score.loaders
{

    import comet.data.score.Score;
    import comet.data.score.IPart;
    import comet.data.score.INotePart;
    import comet.data.score.ICueSequence;
    import comet.data.score.NoteCueSequence;
    import comet.data.score.LongNoteCueSequence;

    /**
    * The DOLLoader class let you load a score data from DOL.
    *
    * @author Susisu
    */
    public class DOLLoader implements IScoreLoader
    {
        
        /**
        * The language version of DOL.
        */
        public static const LANGUAGE_VERSION:Number = 0.1;

        /**
        * Tokenizes the data.
        *
        * @param data The DOL source.
        * @return A vector of tokens.
        * @throws ArgumentError The given data is invalid.
        */
        private static function tokenize(data:String):Vector.<Token>
        {
            const EXP_COMMENT:Expression = new Expression(
                    /^(\-\-.*[\n\r\v]+)*\-\-.*(?=[\n\r\v]+)/,
                    function(exec:Object):Token { return null; }
                );

            const EXP_WHITESPACE:Expression = new Expression(
                    /^[ \f\t]/,
                    function(exec:Object):Token { return null; }
                );
            
            const EXP_SEPARATOR:Expression = new Expression(
                    /^[\n\r\v;]+/,
                    function(exec:Object):Token { return new SeparatorToken(); }
                );

            const EXP_REVERSER:Expression = new Expression(
                    /^\:/,
                    function(exec:Object):Token { return new ReverserToken(); }
                );

            const EXP_STRING:Expression = new Expression(
                    /^\"((\\(u[0-9A-Fa-f]{4}|[^u\f\n\r\v])|[^\\\"\f\n\r\v])*)\"/,//"
                    function(exec:Object):Token
                    {
                        var str:String = exec[1];
                        str = str.replace(/\\\"/g, "\"")
                                 .replace(/\\b/g, "\b")
                                 .replace(/\\f/g, "\f")
                                 .replace(/\\n/g, "\n")
                                 .replace(/\\r/g, "\r")
                                 .replace(/\\t/g, "\t")
                                 .replace(/\\v/g, "\v")
                                 .replace(/\\\u([0-9A-Fa-f]{4})/g,
                                    function():String { return String.fromCharCode(parseInt(arguments[1], 16)); })
                                 .replace(/\\(.)/g, "$1");
                        return new StringToken(str);
                    }
                );
            
            const EXP_NUMBER:Expression = new Expression(
                    /^[\+\-]?(\d+(\.\d+)?|\.\d+)([Ee][\+\-]?\d+)?/,
                    function(exec:Object):Token { return new NumberToken(parseFloat(exec[0])); }
                );

            const EXP_IDENTIFIER:Expression = new Expression(
                    /^[^\s\;\:#\"\.\,\+\-\d][^\s\;\:#\"\.\,\+\-]*/,//"
                    function(exec:Object):Token { return new IdentifierToken(exec[0]); }
                );
            
            const EXP_META_IDENTIFIER:Expression = new Expression(
                    /^#([^\s\;\:#\"\.\,\+\-\d][^\s\;\:#\"\.\,\+\-]*)/,//"
                    function(exec:Object):Token { return new MetaIdentifierToken(exec[1]); }
                );

            var expressions:Vector.<Expression> = Vector.<Expression>([
                    EXP_COMMENT,
                    EXP_WHITESPACE,
                    EXP_SEPARATOR,
                    EXP_REVERSER,
                    EXP_STRING,
                    EXP_NUMBER,
                    EXP_META_IDENTIFIER,
                    EXP_IDENTIFIER
                ]);
            var numExps:int = expressions.length;

            var rest:String = data;
            var restLength:int = rest.length;
            var lines:int = 1;
            var cols:int = 1;
            var exec:Object;
            var tokens:Vector.<Token> = new Vector.<Token>();

            while(restLength > 0)
            {
                for(var i:int = 0; i < numExps; i++)
                {
                    exec = expressions[i].exp.exec(rest);
                    if(exec)
                    {
                        var token:Token = expressions[i].reviver(exec) as Token;
                        if(token)
                        {
                            token.sourcePos = new SourcePos(lines, cols);
                            tokens.push(token);
                        }

                        var execLength:int = exec[0].length;
                        rest = rest.substr(execLength);
                        restLength -= execLength;

                        var execLines:Array = exec[0].split(/\r\n|\r|\n/);
                        var numLines:int = execLines.length;
                        lines += numLines - 1;
                        if(numLines > 1)
                        {
                            cols = 1;
                        }
                        cols += execLines[numLines - 1].length;

                        break;
                    }
                }

                if(!exec)
                {
                    throw new ArgumentError("syntax error at (" + lines.toString() + ":" + cols.toString() + "): "
                        + rest.substr(0, 16) + "...");
                }
            }

            return tokens;
        }

        /**
        * Compiles the sequence of the operaions from tokens.
        *
        * @param tokens The vector of tokens.
        * @return A vector of operations.
        */
        private static function compile(tokens:Vector.<Token>):Vector.<Operation>
        {
            var operations:Vector.<Operation> = new Vector.<Operation>();
            var reverseStack:Vector.<Operation> = new Vector.<Operation>();
            var numReverseStack:int = 0;
            var operator:Token = null;
            var operands:Vector.<Token> = new Vector.<Token>();
            var numTokens:int = tokens.length;
            for(var i:int = 0; i < numTokens; i++)
            {
                var token:Token = tokens[i];
                if(token is SeparatorToken)
                {
                    if(operator)
                    {
                        operations.push(new Operation(operator, operands));
                        operator = null;
                        operands = new Vector.<Token>();
                    }
                    while(numReverseStack > 0)
                    {
                        operations.push(reverseStack.pop());
                        numReverseStack--;
                    }
                }
                else if(token is ReverserToken)
                {
                    if(operator)
                    {
                        reverseStack.push(new Operation(operator, operands));
                        numReverseStack++;
                        operator = null;
                        operands = new Vector.<Token>();
                    }
                }
                else
                {
                    if(operator)
                    {
                        operands.push(token);
                    }
                    else
                    {
                        operator = token;
                    }
                }
            }
            if(operator)
            {
                operations.push(new Operation(operator, operands));
                operator = null;
                operands = new Vector.<Token>();
            }
            while(numReverseStack > 0)
            {
                operations.push(reverseStack.pop());
                numReverseStack--;
            }
            return operations;
        }


        private var _fps:Number;
        
        /**
        * The FPS of the game.
        */
        public function get fps():Number
        {
            return this._fps;
        }

        /**
        * The dictionary of the parts.
        */
        private var _partsDict:Object;
        

        /**
        * Creates a new DOLLoader object.
        *
        * @param fps The fps of the game.
        */
        public function DOLLoader(fps:Number = 60.0)
        {
            this._fps = fps;
            this._partsDict = {};
        }


        /**
        * Assigns a part object to a name.
        *
        * @param name The name to which the part is assinged.
        * @param type The INotePart object to assign.
        */
        public function assignNotePart(name:String, part:INotePart):void
        {
            this._partsDict[name] = part;
        }

        /**
        * Loads a score data from DOL.
        *
        * @param data The DOL source.
        * @return A Score object that contains a score data generated from DOL.
        * @throws ArgumentError The given data is invalid.
        */
        public function load(data:String):Score
        {
            var tokens:Vector.<Token> = DOLLoader.tokenize(data);
            var operations:Vector.<Operation> = DOLLoader.compile(tokens);
            var score:Score = this.run(operations);
            return score;
        }

        /**
        * Runs the compiled operations.
        *
        * @param operations The vector of operations.
        * @return A Score object that is generated by the operations.
        * @throws ArgumentError Invalid data.
        */
        private function run(operations:Vector.<Operation>):Score
        {
            var loader:DOLLoader = this;
            
            var score:Score;

            var numCols:int = 0;
            var numTypes:int = 0;
            var isHeader:Boolean = true;
            var userDefinitions:Object = {};
            
            var bpm:Number = 120.0;
            var length:Number = 4.0;
            var time:Number = 0.0;
            var deferring:Number = 0.0;
            var relSpeed:Number = 1.0;

            /*
            * The definitions of the functions.
            */

            const _BOOST:Function = function(boost:NumberToken):void
            {
                relSpeed = boost.value;
            };

            const _BPM:Function = function(beatsPerMinute:NumberToken):void
            {
                if(beatsPerMinute.value == 0.0)
                {
                    throw new OperationalError("bpm sould not be zero: " + beatsPerMinute.toString());
                }
                else
                {
                    bpm = beatsPerMinute.value;
                }
            };

            const _DEFER:Function = function(n:NumberToken):void
            {
                if(n.value == 0.0)
                {
                    deferring = 0.0;
                }
                else
                {
                    deferring = 4.0 / n.value * 60.0 / bpm;
                }
            };

            const _DEFER_F:Function = function(frame:NumberToken):void
            {
                deferring = frame.value / loader._fps;
            };

            const _DEFER_S:Function = function(sec:NumberToken):void
            {
                deferring = sec.value;
            };

            const _ECHO:Function = function(token:Token):void
            {
                throw token.toString();
            };

            const _FEED:Function = function():void
            {
                time += 4.0 / length * 60.0 / bpm;
            };

            const _FRAME:Function = function(frame:NumberToken):void
            {
                time = frame.value / loader._fps;
            };

            const _LENGTH:Function = function(n:NumberToken):void
            {
                if(n.value == 0.0)
                {
                    throw new OperationalError("length should not be zero: " + n.toString());
                }
                else
                {
                    length = n.value;
                }
            };

            const _LINE:Function = function(...args):void
            {
                var numArgs:int = Math.min(args.length, numCols);
                for(var i:int = 0; i < numArgs; i++)
                {
                    var type:NumberToken = args[i] as NumberToken;
                    if(type == null)
                    {
                        throw new OperationalError("invalid arguments applied: " + this.toString());
                    }

                    if(Math.floor(type.value) < 0 || Math.floor(type.value) > numTypes)
                    {
                        throw new OperationalError("type is out of range: " + type.toString());
                    }
                    else if(Math.floor(type.value) != 0)
                    {
                        var seq:ICueSequence =
                            (score.parts[numCols * (Math.floor(type.value) - 1) + i] as INotePart).cueSequence;
                        if(seq === null)
                        {
                            throw new OperationalError("type is not initialized: " + this.toString());
                        }
                        else
                        {
                            seq.addNoteCue((time + deferring) * loader._fps, relSpeed, null);
                        }
                    }
                }
                _FEED();
            };

            const _METRONOME:Function = function(col:NumberToken, type:NumberToken, times:NumberToken):void
            {
                if(Math.floor(times.value) <= 0)
                {
                    throw new OperationalError("times should be a positive value: " + times.toString());
                }
                else
                {
                    for(var i:int = 0; i < Math.floor(times.value); i++)
                    {
                        _PUT(col, type);
                        _FEED();
                    }
                }
            };

            const _PUT:Function = function(col:NumberToken, type:NumberToken):void
            {
                if(Math.floor(col.value) <= 0 || Math.floor(col.value) > numCols)
                {
                    throw new OperationalError("col is out of range: " + col.toString());
                }
                else if(Math.floor(type.value) <= 0 || Math.floor(type.value) > numTypes)
                {
                    throw new OperationalError("type is out of range: " + type.toString());
                }
                else
                {
                    var seq:ICueSequence =
                        (score.parts[numCols * (Math.floor(type.value) - 1) + Math.floor(col.value) - 1] as INotePart).cueSequence;
                    if(seq === null)
                    {
                        throw new OperationalError("type is not initialized: " + this.toString());
                    }
                    else
                    {
                        seq.addNoteCue((time + deferring) * loader._fps, relSpeed, null);
                    }
                }
            };

            const _SPEED:Function = function(speed:NumberToken):void
            {
                for(var i:int = 0; i < numCols * numTypes; i++)
                {
                    var seq:ICueSequence = (score.parts[i] as INotePart).cueSequence;
                    if(seq === null)
                    {
                        throw new OperationalError("type is not initialized: " + this.toString());
                    }
                    else
                    {
                        seq.addSpeedChangeCue((time + deferring) * loader._fps, speed.value);
                    }
                }
            };

            const _STOP:Function = function():void
            {
                for(var i:int = 0; i < numCols * numTypes; i++)
                {
                    var seq:ICueSequence = (score.parts[i] as INotePart).cueSequence;
                    if(seq === null)
                    {
                        throw new OperationalError("type is not initialized: " + this.toString());
                    }
                    else
                    {
                        seq.addSpeedChangeCue((time + deferring) * loader._fps, 0.0);
                    }
                }
            };

            const _TIME:Function = function(sec:NumberToken):void
            {
                time = sec.value;
            };

            var definitions:Object = {
                    "boost": new FunctionToken(_BOOST),
                    "bst": new FunctionToken(_BOOST),
                    "bpm": new FunctionToken(_BPM),
                    "defer": new FunctionToken(_DEFER),
                    "def": new FunctionToken(_DEFER),
                    "deferF": new FunctionToken(_DEFER_F),
                    "defF": new FunctionToken(_DEFER_F),
                    "deferS": new FunctionToken(_DEFER_S),
                    "defS": new FunctionToken(_DEFER_S),
                    "echo": new FunctionToken(_ECHO),
                    "feed": new FunctionToken(_FEED),
                    "\\": new FunctionToken(_FEED),
                    "frame": new FunctionToken(_FRAME),
                    "frm": new FunctionToken(_FRAME),
                    "length": new FunctionToken(_LENGTH),
                    "len": new FunctionToken(_LENGTH),
                    "line": new FunctionToken(_LINE),
                    "$": new FunctionToken(_LINE),
                    "metronome": new FunctionToken(_METRONOME),
                    "mn": new FunctionToken(_METRONOME),
                    "put": new FunctionToken(_PUT),
                    "@": new FunctionToken(_PUT),
                    "speed": new FunctionToken(_SPEED),
                    "spd": new FunctionToken(_SPEED),
                    "stop": new FunctionToken(_STOP),
                    "time": new FunctionToken(_TIME)
                };

            /*
            * The definitions of the metadata functions.
            */

            const _M_DEFINE:Function = function(name:StringToken, value:Token):void
            {
                userDefinitions[name.value] = value;
            }

            const _M_INIT:Function = function(cols:NumberToken, types:NumberToken):void
            {
                numCols = Math.floor(cols.value);
                if(numCols < 0)
                {
                    numCols = 0;
                }
                numTypes = Math.floor(types.value);
                if(numTypes < 0)
                {
                    numTypes = 0;
                }

                score = new Score(numCols * numTypes);
            };

            const _M_PART:Function = function(col:NumberToken, type:NumberToken, partName:StringToken):void
            {
                if(!score)
                {
                    throw new OperationalError("use #type after #init: " + this.toString());
                }

                if(Math.floor(col.value) <= 0 || Math.floor(col.value) > numCols)
                {
                    throw new OperationalError("col is out of range: " + col.toString());
                }

                if(Math.floor(type.value) <= 0 || Math.floor(type.value) > numTypes)
                {
                    throw new OperationalError("type is out of range: " + type.toString());
                }

                if(!loader._partsDict.hasOwnProperty(partName.value))
                {
                    throw new OperationalError("unknown part: " + partName.toString());
                }

                score.parts[(Math.floor(type.value) - 1) * numCols + Math.floor(col.value) - 1] = loader._partsDict[partName.value];
            };

            const _M_VERSION:Function = function(version:NumberToken):void
            {
                if(version.value != DOLLoader.LANGUAGE_VERSION)
                {
                    throw new OperationalError("version doesn't match "
                        + "(compiler version: " + DOLLoader.LANGUAGE_VERSION.toString() + "): "
                        + version.toString());
                }
            };

            var metaDefinitions:Object = {
                    "define": new FunctionToken(_M_DEFINE),
                    "init": new FunctionToken(_M_INIT),
                    "part": new FunctionToken(_M_PART),
                    "version": new FunctionToken(_M_VERSION)
                };

            /*
            * utility functions
            */

            /**
            * Resolves the reference the IdentifierToken object represents.
            *
            * @param token The token to resolve its reference.
            * @return The token the reference resolved.
            */
            function resolveReference(token:Token):Token
            {
                var refTarget:Token;
                if(token is IdentifierToken)
                {
                    var name:String = (token as IdentifierToken).name;
                    if(userDefinitions.hasOwnProperty(name))
                    {
                        refTarget = userDefinitions[name].clone();
                        refTarget.name = name;
                        refTarget.sourcePos = token.sourcePos;
                        return refTarget;
                    }
                    else if(definitions.hasOwnProperty(name))
                    {
                        refTarget = definitions[name].clone();
                        refTarget.name = name;
                        refTarget.sourcePos = token.sourcePos;
                        return refTarget;
                    }
                    else
                    {
                        throw new ReferenceError("unknown value: " + token.toString());
                        return null;
                    }
                }
                else if(token is MetaIdentifierToken)
                {
                    throw new ReferenceError("unexpected metadata: " + token.toString());
                    return null;
                }
                else
                {
                    return token;
                }
            }
            
            /**
            * Converts the Vector.<T> data to Array.
            *
            * @param vector The Vector.<T> data.
            * @return The converted array.
            */
            function vectorToArray(vector:*):Array
            {
                var array:Array = [];
                var len:int = vector.length;
                for(var i:int = 0; i < len; i++)
                {
                    array[i] = vector[i];
                }
                return array;
            }


            /*
            * Runs the operations.
            */
            var numOperations:int = operations.length;
            for(var i:int = 0; i < numOperations; i++)
            {
                var operation:Operation = operations[i];
                var operator:Token = operation.operator;
                var operands:Vector.<Token> = operation.operands;
                if(operator is MetaIdentifierToken)
                {
                    if(!isHeader)
                    {
                        throw new ArgumentError("unexpected metadata: " + operator.toString());
                    }

                    var name:String = (operator as MetaIdentifierToken).name;
                    if(metaDefinitions.hasOwnProperty(name))
                    {
                        var refTarget:Token = metaDefinitions[name].clone();
                        refTarget.name = "#" + name;
                        refTarget.sourcePos = operator.sourcePos;
                        operator = refTarget;
                        if(operator is FunctionToken)
                        {
                            try
                            {
                                (operator as FunctionToken).func.apply(operator,
                                    vectorToArray(
                                        operands.map(
                                            function(token:Token, index:int, vec:Vector.<Token>):Token
                                            {
                                                return resolveReference(token);
                                            }
                                        )
                                    )
                                );
                            }
                            catch(typeError:TypeError)
                            {
                                throw new ArgumentError("invalid arguments applied: " + operator.toString());
                            }
                            catch(argError:ArgumentError)
                            {
                                throw new ArgumentError("invalid arguments applied: " + operator.toString());
                            }
                            catch(error:Error)
                            {
                                throw new ArgumentError(error.message);
                            }
                        }
                        else
                        {
                            throw new ArgumentError(operator.toString() + " is not a function.");
                        }
                    }
                    else
                    {
                        throw new ArgumentError("unknown metadata: " + operator.toString());
                    }
                }
                else
                {
                    if(isHeader)
                    {
                        isHeader = false;
                    }

                    operator = resolveReference(operator);
                    if(operator is FunctionToken)
                    {
                        try
                        {
                            (operator as FunctionToken).func.apply(operator,
                                vectorToArray(
                                    operands.map(
                                        function(token:Token, index:int, vec:Vector.<Token>):Token
                                        {
                                            return resolveReference(token);
                                        }
                                    )
                                )
                            );
                        }
                        catch(typeError:TypeError)
                        {
                            throw new ArgumentError("invalid arguments applied: " + operator.toString());
                        }
                        catch(argError:ArgumentError)
                        {
                            throw new ArgumentError("invalid arguments applied: " + operator.toString());
                        }
                        catch(error:Error)
                        {
                            throw new ArgumentError(error.message);
                        }
                    }
                    else
                    {
                        throw new ArgumentError(operator.toString() + " is not a function.");
                    }
                }
            }

            score.parts.forEach(
                function(part:IPart, index:int, vec:Vector.<IPart>):void
                {
                    (part as INotePart).cueSequence.calcAppearanceInfo();
                }
            );

            return score;
        }

    }

}


/**
* An Expression object represents an expression of the language.
*/
class Expression
{

    public var exp:RegExp;

    public var reviver:Function;

    public function Expression(exp:RegExp, reviver:Function)
    {
        this.exp = exp;
        this.reviver = reviver;
    }

}


/**
* A SourcePos object represents position in the source.
*/
class SourcePos
{

    public var line:int;

    public var column:int;

    public function SourcePos(line:int, column:int)
    {
        this.line = line;
        this.column = column;
    }
    
    public function toString():String
    {
        return "(" + line.toString() + ":" + column.toString() + ")";
    }

}


/**
* A Token object represents a token of the language.
*/
class Token
{

    public var name:String;

    public var sourcePos:SourcePos;

    public function Token()
    {
        this.name = null;
        this.sourcePos = null;
    }

    public function toString():String
    {
        if(this.name !== null)
        {
            return this.name + "<(token)>" + this.sourcePos.toString();
        }
        else
        {
            return "(token)" + this.sourcePos.toString();
        }
    }

    public function clone():Token
    {
        var copy:Token = new Token();
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* A SeparatorToken object represents a separator of operations.
*/
class SeparatorToken extends Token
{

    public function SeparatorToken()
    {

    }

    override public function toString():String
    {
        return ";" + this.sourcePos.toString();
    }

    override public function clone():Token
    {
        var copy:SeparatorToken = new SeparatorToken();
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* A ReverserToken object represents a reverser of the operations.
*/
class ReverserToken extends Token
{

    public function ReverserToken()
    {

    }

    override public function toString():String
    {
        return " : " + this.sourcePos.toString();
    }

    override public function clone():Token
    {
        var copy:ReverserToken = new ReverserToken();
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* A StringToken object represents a string value.
*/
class StringToken extends Token
{

    public var value:String;

    public function StringToken(value:String)
    {
        this.value = value;
    }

    override public function toString():String
    {
        if(this.name !== null)
        {
            return this.name + "<\"" + this.value + "\">" + this.sourcePos.toString();
        }
        else
        {
            return "\"" + this.value + "\"" + this.sourcePos.toString();
        }
    }

    override public function clone():Token
    {
        var copy:StringToken = new StringToken(this.value);
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* A NumberToken object represents a number value.
*/
class NumberToken extends Token
{

    public var value:Number;

    public function NumberToken(value:Number)
    {
        this.value = value;
    }

    override public function toString():String
    {
        if(this.name !== null)
        {
            return this.name + "<" + this.value.toString() + ">" + this.sourcePos.toString();
        }
        else
        {
            return this.value.toString() + this.sourcePos.toString();
        }
    }

    override public function clone():Token
    {
        var copy:NumberToken = new NumberToken(this.value);
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* A FunctionToken object represents a function.
*/
class FunctionToken extends Token
{

    public var func:Function;

    public function FunctionToken(func:Function)
    {
        this.func = func;
    }

    override public function toString():String
    {
        if(this.name !== null)
        {
            return this.name + "<(function)>" + this.sourcePos.toString();
        }
        else
        {
            return "(function)" + this.sourcePos.toString();
        }
    }

    override public function clone():Token
    {
        var copy:FunctionToken = new FunctionToken(this.func);
        copy.name = this.name;
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}

/**
* An IdentifierToken object represents an identifier.
*/
class IdentifierToken extends Token
{

    public function IdentifierToken(name:String)
    {
        this.name = name;
    }

    override public function toString():String
    {
        return this.name + this.sourcePos.toString();
    }

    override public function clone():Token
    {
        var copy:IdentifierToken = new IdentifierToken(this.name);
        copy.sourcePos = this.sourcePos;
        return copy;
    }
}

/**
* A MetaIdentifierToken object represents a meta-identifier.
*/
class MetaIdentifierToken extends Token
{

    public function MetaIdentifierToken(name:String)
    {
        this.name = name;
    }

    override public function toString():String
    {
        return "#" + this.name + this.sourcePos.toString();
    }

    override public function clone():Token
    {
        var copy:MetaIdentifierToken = new MetaIdentifierToken(this.name);
        copy.sourcePos = this.sourcePos;
        return copy;
    }

}


/**
* An Operation object represents an operation.
*/
class Operation
{

    public var operator:Token;

    public var operands:Vector.<Token>;

    public function Operation(operator:Token, operands:Vector.<Token>)
    {
        this.operator = operator;
        this.operands = operands;
    }

    public function toString():String
    {
        return this.operator.toString() + "(" + this.operands.join(", ") + ")";
    }

}


/**
* An OperationalError exception is thrown when an error occurs in operational function.
*/
class OperationalError extends Error
{

    public function OperationalError(message:String = "")
    {
        super(message);
    }

    public function toString():String
    {
        if(message != "")
        {
            return "OperationalError: " + message;
        }
        else
        {
            return "OperationalError";
        }
    }

}
