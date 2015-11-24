/**
 * Morn UI Version 2.4.1027 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 * 
 * change box to clippedSprite by xiaoxiaofeitianma@gmail.com
 */
package morn.core.components {
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import morn.core.events.UIEvent;
	import morn.editor.core.IContent;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.ClippedSprite;
	import starling.filters.BlurFilter;
	
	/**面板*/
	public class Panel extends Container implements IContent {
		//protected var _content:Box;
		protected var _content:ClippedSprite;
		protected var _vScrollBar:VScrollBar;
		protected var _hScrollBar:HScrollBar;
		
		public function Panel() {
			width = height = 100;
			addEventListener(Event.ADDED, onAdded);
			addEventListener(UIEvent.MOVE, onMoving);
		}
		
		override protected function onAdded(e:Event):void {
			super.onAdded(e);
			_content.x = x;
			_content.y = y;
			parent.addChild(_content);
			
			if(_vScrollBar != null) {
				parent.addChild(_vScrollBar);
			}
			
			if(_hScrollBar != null) {
				parent.addChild(_hScrollBar);
			}
		}
		
		private function onMoving(e:UIEvent):void {
			callLater(changeScroll);
		}
		
		override protected function createChildren():void {
			_content = new ClippedSprite();//new Box();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			trace(child);
			if(child is VScrollBar) {
				return null;
			}
			callLater(changeScroll);
			return _content.addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			callLater(changeScroll);
			return _content.addChildAt(child, index);
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject {
			callLater(changeScroll);
			return _content.removeChild(child, dispose);
		}
		
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject {
			callLater(changeScroll);
			return _content.removeChildAt(index, dispose);
		}
		
		override public function removeAllChild(except:DisplayObject = null):void {
			for (var i:int = _content.numChildren - 1; i > -1; i--) {
				if (except != _content.getChildAt(i)) {
					_content.removeChildAt(i);
				}
			}
			callLater(changeScroll);
		}
		
		override public function getChildAt(index:int):DisplayObject {
			return _content.getChildAt(index);
		}
		
		override public function getChildByName(name:String):DisplayObject {
			return _content.getChildByName(name);
		}
		
		override public function getChildIndex(child:DisplayObject):int {
			return _content.getChildIndex(child);
		}
		
		override public function get numChildren():int {
			return _content.numChildren;
		}
		
		private function changeScroll():void {
			oldStart = 0;
			
			var vShow:Boolean = _vScrollBar && _content.height > _height;
			var hShow:Boolean = _hScrollBar && _content.width > _width;
			var contentWidth:Number = vShow ? _width - _vScrollBar.width : _width;
			var contentHeight:Number = hShow ? _height - _hScrollBar.height : _height;
			//_content.scrollRect = new Rectangle(0, 0, contentWidth, contentHeight);
			if (_vScrollBar) {
				_vScrollBar.visible = _content.height > _height;
				if (_vScrollBar.visible) {
					if(_content.clipRect == null) {
						_content.clipRect = new Rectangle(parent.x + x, parent.y + y, contentWidth, contentHeight);
					}
					_content.clipRect.x = parent.x + x;
					_content.clipRect.y = parent.y + y;
					_vScrollBar.x = x + contentWidth;
					_vScrollBar.y = y;
					_vScrollBar.height = _height - (hShow ? _hScrollBar.height : 0);
					_vScrollBar.scrollSize = _content.height * 0.1;
					_vScrollBar.thumbPercent = contentHeight / _content.height;
					_vScrollBar.setScroll(0, _content.height - contentHeight, _vScrollBar.value);
					_vScrollBar.target = _content;
					
					oldStart = Math.round(_vScrollBar.value);
				}
			}
			if (_hScrollBar) {
				_hScrollBar.visible = _content.width > _width;
				if (_hScrollBar.visible) {
					if(_content.clipRect == null) {
						_content.clipRect = new Rectangle(parent.x + x, parent.y + y, contentWidth, contentHeight);
					}
					_content.clipRect.x = parent.x + x;
					_content.clipRect.y = parent.y + y;
					_hScrollBar.x = x;
					_hScrollBar.y = y + contentHeight;
					_hScrollBar.width = _width - (vShow ? _vScrollBar.width : 0);
					_hScrollBar.thumbPercent = contentWidth / _content.width;
					_hScrollBar.setScroll(0, _content.width - contentWidth, _hScrollBar.value);
					_hScrollBar.target = _content;
					
					oldStart = Math.round(_hScrollBar.value);
				}
			}
			
			createContentBg();
		}
		
		private function createContentBg():void {
//			var g:Graphics = _content.graphics;
//			g.clear();
//			g.beginFill(0xffff00, 0);
//			g.drawRect(0, 0, _content.width, _content.height);
//			g.endFill();
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			callLater(changeScroll);
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			callLater(changeScroll);
		}
		
		/**垂直滚动条皮肤*/
		public function get vScrollBarSkin():String {
			return _vScrollBar.skin;
		}
		
		public function set vScrollBarSkin(value:String):void {
			if (_vScrollBar == null) {
				_vScrollBar = new VScrollBar();
				_vScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
				_vScrollBar.target = this;
				callLater(changeScroll);
			}
			_vScrollBar.skin = value;
		}
		
		/**水平滚动条皮肤*/
		public function get hScrollBarSkin():String {
			return _hScrollBar.skin;
		}
		
		public function set hScrollBarSkin(value:String):void {
			if (_hScrollBar == null) {
				_hScrollBar = new HScrollBar()
				_hScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
				_hScrollBar.target = this;
				callLater(changeScroll);
			}
			_hScrollBar.skin = value;
		}
		
		/**垂直滚动条*/
		public function get vScrollBar():ScrollBar {
			return _vScrollBar;
		}
		
		/**水平滚动条*/
		public function get hScrollBar():ScrollBar {
			return _hScrollBar;
		}
		
		/**内容容器*/
		public function get content():Sprite {
			return _content;
		}
		
		private var oldStart:int = 0;
		protected function onScrollBarChange(e:Event):void {
			var rect:Rectangle = _content.clipRect;
			if (rect) {
				var scroll:ScrollBar = e.currentTarget as ScrollBar;
				var start:int = Math.round(scroll.value);
				if(start >= oldStart) {
					scroll.direction == ScrollBar.VERTICAL ? _content.y -= (start - oldStart) : _content.x -= (start - oldStart);
				} else {
					scroll.direction == ScrollBar.VERTICAL ? _content.y -= (start - oldStart) : _content.x -= (start - oldStart);
				}
				oldStart = start;
			}
		}
		
		override public function commitMeasure():void {
			exeCallLater(changeScroll);
		}
		
		/**滚动到某个位置*/
		public function scrollTo(x:Number = 0, y:Number = 0):void {
			commitMeasure();
			if (vScrollBar) {
				vScrollBar.value = y;
			}
			if (hScrollBar) {
				hScrollBar.value = x;
			}
		}
	}
}