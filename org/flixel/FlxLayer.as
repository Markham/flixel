package org.flixel
{
	/**
	 * This is an organizational class that can update and render a bunch of FlxCore objects
	 */
	public class FlxLayer extends FlxCore
	{
		/**
		 * Array of all the FlxCore objects that exist in this layer.
		 */
		protected var _children:Array;
		
		//Various rendering helpers
		protected var _alpha:Number;
		protected var _alphaGlobal:Number;
		protected var _color:uint;
		protected var _colorGlobal:uint;

		/**
		 * Constructor
		 */
		virtual public function FlxLayer()
		{
			_alpha = _alphaGlobal= 1;
			_color = _colorGlobal = 0x00ffffff;
			_children = new Array();
		}
		
		/**
		 * Adds a new FlxCore subclass (FlxSprite, FlxBlock, etc) to the list of children
		 *
		 * @param	Core			The object you want to add
		 * @param	ShareScroll		Whether or not this FlxCore should sync up with this layer's scrollFactor
		 *
		 * @return	The same <code>FlxCore</code> object that was passed in.
		 */
		virtual public function add(Core:FlxCore,ShareScroll:Boolean=false):FlxCore
		{
			_children.push(Core);
			Core.alphaGlobal = _alpha*_alphaGlobal;
			Core.colorGlobal = _color&colorGlobal;
			if(ShareScroll)
				Core.scrollFactor = scrollFactor;
			return Core;
		}
		
		/**
		 * Automatically goes through and calls update on everything you added,
		 * override this function to handle custom input and perform collisions.
		 */
		override public function update():void
		{
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			if((x != last.x) || (y != last.y))
			{
				moved = true;
				mx = x - last.x;
				my = y - last.y;
			}
			super.update();
			
			var c:FlxCore;
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
			{
				c = _children[i] as FlxCore;
				if((c != null) && c.exists)
				{
					if(moved)
					{
						c.x += mx;
						c.y += my;
					}
					if(c.active)
						c.update();
				}
			}
		}
		
		/**
		 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
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
		 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
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
		
		internal function setColorTransform():void
		{
			var a = _alpha*_alphaGlobal;
			var clr = _color&_colorGlobal;
			var c:FlxCore;
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
			{
				c = _children[i];
				if((c != null) && c.exists && c.visible) {
					c.alphaGlobal = a;
					c.colorGlobal = clr;
				}
			}
		}
		
		/**
		 * Automatically goes through and calls render on everything you added,
		 * override this loop to control render order manually.
		 */
		override public function render():void
		{
			if(!visible)
				return;
			
			var c:FlxCore;
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
			{
				c = _children[i];
				if((c != null) && c.exists && c.visible) c.render();
			}
		}
		
		/**
		 * Override this function to handle any deleting or "shutdown" type operations you might need,
		 * such as removing traditional Flash children like Sprite objects.
		 */
		override public function destroy():void
		{
			super.destroy();
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
				_children[i].destroy();
			_children.length = 0;
		}
		
		/**
		 * Returns the array of children
		 */
		public function children():Array { return _children; }
	}
}
