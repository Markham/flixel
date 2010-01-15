package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * This is the basic "environment object" class, used to create simple walls and floors.
	 * It can be filled with a random selection of tiles to quickly add detail.
	 */
	public class FlxBlock extends FlxCore
	{
		/**
		 * Array of rectangles used to quickly blit the tiles to the screen.
		 */
		protected var _rects:Array;
		/**
		 * The size of the tiles (e.g. 8 means 8x8).
		 */
		protected var _tileSize:uint;
		protected var _tileWidth:uint;		
		
		//Various rendering helpers
		protected var _bw:uint;
		protected var _bh:uint;
		protected var _r:Rectangle;
		protected var _p:Point;
		protected var _pixels:BitmapData;
		protected var _framePixels:BitmapData;
		protected var _alpha:Number;
		protected var _alphaGlobal:Number;
		protected var _color:uint;
		protected var _colorGlobal:uint;
		protected var _ct:ColorTransform;
		//protected var _mtx:Matrix;
		
		
		/**
		 * Creates a new <code>FlxBlock</code> object with the specified position and size.
		 * 
		 * @param	X			The X position of the block.
		 * @param	Y			The Y position of the block.
		 * @param	Width		The width of the block.
		 * @param	Height		The height of the block.
		 */
		public function FlxBlock(X:int,Y:int,Width:uint,Height:uint)
		{
			super();
			last.x = x = X;
			last.y = y = Y;
			width = _bw = Width;
			height = _bh = Height;
			fixed = true;
			
			_alpha = _alphaGlobal = 1;
			_color = _colorGlobal = 0xffffffff;
		}
		
		/**
		 * Fills the block with a randomly arranged selection of graphics from the image provided.
		 * 
		 * @param	TileGraphic The graphic class that contains the tiles that should fill this block.
		 * @param	Empties		The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
		 */
		public function loadGraphic(TileGraphic:Class,Empties:uint=0):void
		{
			if(TileGraphic == null)
				return;

			_pixels = FlxG.addBitmap(TileGraphic);
			_rects = new Array();
			_p = new Point();
			_tileSize = _pixels.height;
			var widthInTiles:uint = Math.ceil(width/_tileSize);
			var heightInTiles:uint = Math.ceil(height/_tileSize);
			width = _bw = widthInTiles*_tileSize;
			height = _bh = heightInTiles*_tileSize;
			var numTiles:uint = widthInTiles*heightInTiles;
			var numGraphics:uint = _pixels.width/_tileSize;
			for(var i:uint = 0; i < numTiles; i++)
			{
				if(FlxG.random()*(numGraphics+Empties) > Empties)
					_rects.push(new Rectangle(_tileSize*Math.floor(FlxG.random()*numGraphics),0,_tileSize,_tileSize));
				else
					_rects.push(null);
			}
			calcFrame();
		}
		
		/**
		 * Draws this block.
		 */
		override public function render():void
		{
			super.render();
			getScreenXY(_p);
			var opx:int = _p.x;
			var rl:uint = _rects.length;
			for(var i:uint = 0; i < rl; i++)
			{
				if(_rects[i] != null) FlxG.buffer.copyPixels(_framePixels,_rects[i],_p,null,null,true);
				_p.x += _tileWidth;
				if(_p.x >= opx + width)
				{
					_p.x = opx;
					_p.y += _tileSize;
				}
			}
		}
		
		/**
		 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the block.
		 */
		override public function get alpha():Number
		{
			return _alpha;
		}
		
		/**
		 * @private
		 */
		override public function set alpha(Alpha:Number):void
		{
			if(Alpha > 1) Alpha = 1;
			if(Alpha < 0) Alpha = 0;
			if(Alpha == _alpha) return;
			_alpha = Alpha;
			setColorTransform();
		}
		
		/**
		 * @private
		 */
		override public function get alphaGlobal():Number
		{
			return _alphaGlobal;
		}
		
		/**
		 * @private
		 */
		override public function set alphaGlobal(Alpha:Number):void
		{
			if(Alpha > 1) Alpha = 1;
			if(Alpha < 0) Alpha = 0;
			if(Alpha == _alphaGlobal) return;
			_alphaGlobal = Alpha;
			setColorTransform();
		}
		
		/**
		 * Set <code>color</code> to a number in this format: 0xRRGGBB.
		 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
		 * Tints the whole block to be this color (similar to OpenGL vertex colors).
		 */
		override public function get color():uint
		{
			return _color;
		}
		
		/**
		 * @private
		 */
		override public function set color(Color:uint):void
		{
			Color &= 0x00ffffff;
			if(_color == Color) return;
			_color = Color;
			setColorTransform();
		}
		
		/**
		 * @private
		 */
		override public function get colorGlobal():uint
		{
			return _colorGlobal;
		}
		
		/**
		 * @private
		 */
		override public function set colorGlobal(Color:uint):void
		{
			Color &= 0x00ffffff;
			if(_color == Color) return;
			_colorGlobal = Color;
			setColorTransform();
		}
		
		private function setColorTransform():void
		{
			var a = _alpha*_alphaGlobal;
			var c = _color&_colorGlobal;
			if((a != 1) || (c != 0x00ffffff)) _ct = new ColorTransform(Number(c>>16)/255,Number(c>>8&0xff)/255,Number(c&0xff)/255,a);
			else _ct = null;
			calcFrame();
		}
		
		private function calcFrame() {
			//Update tile source bitmap
			if((_framePixels == null) || (_framePixels.width != _pixels.width) || (_framePixels.height != _pixels.height))
				_framePixels = new BitmapData(_pixels.width,_pixels.height,true,0x00000000);
			_framePixels = _pixels.clone();
			_r = new Rectangle(0,0,_pixels.width,_pixels.height);
			if(_ct != null) _framePixels.colorTransform(_r,_ct);
		}
	}
}