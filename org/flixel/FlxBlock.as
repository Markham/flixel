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
	public class FlxBlock extends FlxVisual
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
			if(!visible || _alpha == 0)
				return;
			
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
		
		override internal function setColorTransform():void
		{
			super.setColorTransform();
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