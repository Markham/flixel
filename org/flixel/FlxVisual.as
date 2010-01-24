package org.flixel
{
	import flash.geom.ColorTransform;
	
	/**
	 * This is a class dealing with functions and properties shared by visible FlxCore objects.
	 */
	public class FlxVisual extends FlxCore
	{
	
		//Various rendering helpers
		protected var _alpha:Number;
		protected var _alphaGlobal:Number;
		protected var _color:uint;
		protected var _colorGlobal:uint;
		protected var _ct:ColorTransform;
		
		/**
		 * Internal helper used for fading.
		 */
		protected var _fadeTimer:Number;
		
		/**
		 * Internal helper used for fading.
		 */
		protected var _fadeAlpha:Number;
		
		/**
		 * Internal helper used for fading.
		 */
		protected var _fadeSubtractor:Number;
		/**
		 * Internal helper used for fading.
		 */
		protected var _fadeCallback:Function;
		
		
		/**
		 * Creates a FlxVisual
		 */
		public function FlxVisual()
		{
			super();
			_alpha = _alphaGlobal = 1;
			_color = _colorGlobal = 0x00ffffff;
			
			_fadeTimer = -1;
			_fadeAlpha = 1;
			_fadeSubtractor = 0;
		}
		
		override public function update():void
		{
			if(fading())
			{
				if(_fadeTimer > 0)
				{
					_fadeTimer -= FlxG.elapsed;
					alpha -= _fadeSubtractor*FlxG.elapsed;
					if(_fadeTimer <= 0) {
						_fadeTimer = -1;
						alpha = _fadeAlpha;
						if (_fadeCallback != null) _fadeCallback();
					}
				}
			}
			super.update();
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
		
		/**
		 * Internal function called when alpha or color is changed.
		 */
		internal function setColorTransform():void
		{
			var a = _alpha*_alphaGlobal;
			var c = _color&_colorGlobal;
			if((a != 1) || (c != 0x00ffffff)) _ct = new ColorTransform(Number(c>>16)/255,Number(c>>8&0xff)/255,Number(c&0xff)/255,a);
			else _ct = null;
		}
		
		/**
		 * Fades the FlxVisual to the desired alpha in the set amount of time
		 * 
		 * @param	Duration			The time duration the fade takes place in.
		 * @param	Alpha				The alpha at the end of the fade.
		 * @param	Callback			A function called when the fade completes.
		 */
		public function fade(Duration:Number=1,Alpha:Number=0,Callback:Function=null):void {
			_fadeTimer = Duration;
			_fadeAlpha = Alpha;
			_fadeSubtractor = (_alpha-Alpha)/Duration;
			_fadeCallback = Callback;
		}
		
		/**
		 * Check to see if the object is still fading.
		 * 
		 * @return	Whether the object is fading or not.
		 */
		public function fading():Boolean { return _fadeTimer >= 0; }
	}
}
