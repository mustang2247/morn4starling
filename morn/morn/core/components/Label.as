/**
 * Morn UI Version 2.4.1027 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.components {
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import morn.core.utils.ObjectUtils;
	import morn.core.utils.StringUtils;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**文本发生改变后触发*/
	[Event(name="change",type="starling.events.Event")]
	
	/**文字标签*/
	public class Label extends Component {
		protected var _textField:TextField;
		protected var _format:TextFormat;
		protected var _text:String = "";
		protected var _isHtml:Boolean;
		protected var _stroke:String;
		protected var _skin:String;
		protected var _bitmap:AutoBitmap;
		protected var _margin:Array = [0, 0, 0, 0];
		
		protected var _bgTexture:Texture = null;
		protected var _bgImg:starling.display.Image = null;
		
		protected var _textTexture:Texture = null;
		protected var _textImg:starling.display.Image = null;
		
		public function Label(text:String = "", skin:String = null) {
			this.text = text;
			this.skin = skin;
		}
		
		override protected function preinitialize():void {
			//mouseEnabled = false;
			mouseChildren = true;
		}
		
		override protected function createChildren():void {
			_bitmap = new AutoBitmap();
			_textField = new TextField();
		}
		
		override protected function initialize():void {
			_format = _textField.defaultTextFormat;
			_format.font = Styles.fontName;
			_format.size = Styles.fontSize;
			_format.color = Styles.labelColor;
			_textField.selectable = false;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_bitmap.sizeGrid = [2, 2, 2, 2];
		}
		
		/**显示的文本*/
		public function get text():String {
			_isHtml ? _text = App.lang.getLang(_textField.htmlText) : _text = App.lang.getLang(_textField.text);
			return _text;
		}
		
		public function set text(value:String):void {
			if (_text != value) 
			{
				_text = value || "";
				changeText();
				sendEvent(starling.events.Event.CHANGE);
			}
		}
		
		protected function changeText():void {
			if(_format != null) {
				_textField.defaultTextFormat = _format;
			}
			_isHtml ? _textField.htmlText = App.lang.getLang(_text) : _textField.text = App.lang.getLang(_text);
			
			reDraw();
		}
		
		override public function reDraw():void {
			//画到场景里
			removeAll();
			
			var tempWidth:Number = width;
			if(tempWidth == 0)
			{
				tempWidth = _textField.textWidth + 5;
			}
			var tempHeight:Number = height;
			if(tempHeight == 0)
			{
				tempHeight = _textField.textHeight + 5;
			}
			
			if(tempWidth > 0 && tempHeight > 0)
			{
				if(_bitmap.clips != null)
				{
					var bitdata:BitmapData = new BitmapData(_bitmap.width, _bitmap.height, true, 0x0);
					bitdata.draw(_bitmap.bitmapData);
					_bgTexture = Texture.fromBitmapData(bitdata);
					bitdata.dispose();
					_bgImg = new starling.display.Image(_bgTexture);
					_bgImg.scaleX = tempWidth / _bitmap.bitmapData.width;
					_bgImg.scaleY = tempHeight / _bitmap.bitmapData.height;
					_bgImg.smoothing = TextureSmoothing.NONE;
					addChild(_bgImg);
				}
				
				if(_textField.type == TextFieldType.INPUT)
				{
					//trace("input");
				}
				else
				{
					var bitmapData:BitmapData = new BitmapData(tempWidth, tempHeight, true, 0x0);
					bitmapData.draw(_textField, null, null, null, new Rectangle(0, 0, tempWidth, tempHeight));
					_textTexture = Texture.fromBitmapData(bitmapData, false, false, scale);
					bitmapData.dispose();
					_textImg = new starling.display.Image(_textTexture);
					_textImg.touchable = true;
					_textImg.smoothing = TextureSmoothing.NONE;
					addChild(_textImg);
				}
			}
		}
		
		override public function removeAll():void {
			if(_bgTexture != null){
				_bgTexture.dispose();
				_bgTexture = null;
			}
			if(_bgImg != null){
				_bgImg.dispose();
				_bgImg = null;
			}
			if(_textTexture != null) {
				_textTexture.dispose();
				_textTexture = null;
			}
			if(_textImg != null){
				_textImg.dispose();
				_textImg = null;
			}
			removeChildren(0, -1, true);
		}
		
		override protected function changeSize():void {
			if (!isNaN(_width)) {
				_textField.autoSize = TextFieldAutoSize.NONE;
				_textField.width = _width - _margin[0] - _margin[2];
				if (isNaN(_height) && wordWrap) {
					_textField.autoSize = TextFieldAutoSize.LEFT;
				} else {
					_height = isNaN(_height) ? 18 : _height;
					_textField.height = _height - _margin[1] - _margin[3];
				}
			} else {
				_width = _height = NaN;
				_textField.autoSize = TextFieldAutoSize.LEFT;
			}
			changeText();
			super.changeSize();
		}
		
		/**是否是html格式*/
		public function get isHtml():Boolean {
			return _isHtml;
		}
		
		public function set isHtml(value:Boolean):void {
			if (_isHtml != value) {
				_isHtml = value;
				callLater(changeText);
			}
		}
		
		/**描边(格式:color,alpha,blurX,blurY,strength,quality)*/
		public function get stroke():String {
			return _stroke;
		}
		
		public function set stroke(value:String):void {
			if (_stroke != value) {
				_stroke = value;
				ObjectUtils.clearFilter(_textField, GlowFilter);
				if (Boolean(_stroke)) {
					var a:Array = StringUtils.fillArray(Styles.labelStroke, _stroke);
					ObjectUtils.addFilter(_textField, new GlowFilter(a[0], a[1], a[2], a[3], a[4], a[5]));
				}
			}
		}
		
		/**是否是多行*/
		public function get multiline():Boolean {
			return _textField.multiline;
		}
		
		public function set multiline(value:Boolean):void {
			_textField.multiline = value;
		}
		
		/**是否是密码*/
		public function get asPassword():Boolean {
			return _textField.displayAsPassword;
		}
		
		public function set asPassword(value:Boolean):void {
			_textField.displayAsPassword = value;
		}
		
		/**宽高是否自适应*/
		public function get autoSize():String {
			return _textField.autoSize;
		}
		
		public function set autoSize(value:String):void {
			_textField.autoSize = value;
		}
		
		/**是否自动换行*/
		public function get wordWrap():Boolean {
			return _textField.wordWrap;
		}
		
		public function set wordWrap(value:Boolean):void {
			_textField.wordWrap = value;
		}
		
		/**是否可选*/
		public function get selectable():Boolean {
			return _textField.selectable;
		}
		
		public function set selectable(value:Boolean):void {
			_textField.selectable = value;
			//mouseEnabled = value;
		}
		
		/**是否具有背景填充*/
		public function get background():Boolean {
			return _textField.background;
		}
		
		public function set background(value:Boolean):void {
			_textField.background = value;
		}
		
		/**文本字段背景的颜色*/
		public function get backgroundColor():uint {
			return _textField.backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void {
			_textField.backgroundColor = value;
		}
		
		/**字体颜色*/
		public function get color():Object {
			return _format.color;
		}
		
		public function set color(value:Object):void {
			_format.color = value;
			callLater(changeText);
		}
		
		/**字体类型*/
		public function get font():String {
			return _format.font;
		}
		
		public function set font(value:String):void {
			_format.font = value;
			callLater(changeText);
		}
		
		/**对齐方式*/
		public function get align():String {
			return _format.align;
		}
		
		public function set align(value:String):void {
			_format.align = value;
			callLater(changeText);
		}
		
		/**粗体类型*/
		public function get bold():Object {
			return _format.bold;
		}
		
		public function set bold(value:Object):void {
			_format.bold = value;
			callLater(changeText);
		}
		
		/**垂直间距*/
		public function get leading():Object {
			return _format.leading;
		}
		
		public function set leading(value:Object):void {
			_format.leading = value;
			callLater(changeText);
		}
		
		/**第一个字符的缩进*/
		public function get indent():Object {
			return _format.indent;
		}
		
		public function set indent(value:Object):void {
			_format.indent = value;
			callLater(changeText);
		}
		
		/**字体大小*/
		public function get size():Object {
			return _format.size;
		}
		
		public function set size(value:Object):void {
			_format.size = value;
			callLater(changeText);
		}
		
		/**下划线类型*/
		public function get underline():Object {
			return _format.underline;
		}
		
		public function set underline(value:Object):void {
			_format.underline = value;
			callLater(changeText);
		}
		
		/**字间距*/
		public function get letterSpacing():Object {
			return _format.letterSpacing;
		}
		
		public function set letterSpacing(value:Object):void {
			_format.letterSpacing = value;
			callLater(changeText);
		}
		
		/**边距(格式:左边距,上边距,右边距,下边距)*/
		public function get margin():String {
			return _margin.join(",");
		}
		
		public function set margin(value:String):void {
			_margin = StringUtils.fillArray(_margin, value, int);
			_textField.x = _margin[0];
			_textField.y = _margin[1];
			callLater(changeSize);
		}
		
		/**格式*/
		public function get format():TextFormat {
			return _format;
		}
		
		public function set format(value:TextFormat):void {
			_format = value;
			callLater(changeText);
		}
		
		/**文本控件实体*/
		public function get textField():TextField {
			return _textField;
		}
		
		/**将指定的字符串追加到文本的末尾*/
		public function appendText(newText:String):void {
			text += newText;
		}
		
		/**皮肤*/
		public function get skin():String {
			return _skin;
		}
		
		public function set skin(value:String):void {
			if (_skin != value) {
				_skin = value;
				_bitmap.bitmapData = App.asset.getBitmapData(_skin);
				_contentWidth = _bitmap.bitmapData.width;
				_contentHeight = _bitmap.bitmapData.height;
			}
		}
		
		/**九宫格信息(格式:左边距,上边距,右边距,下边距)*/
		public function get sizeGrid():String {
			return _bitmap.sizeGrid.join(",");
		}
		
		public function set sizeGrid(value:String):void {
			_bitmap.sizeGrid = StringUtils.fillArray(Styles.defaultSizeGrid, value, int);
		}
		
		override public function commitMeasure():void {
			exeCallLater(changeText);
			exeCallLater(changeSize);
		}
		
		override public function get width():Number {
			if (!isNaN(_width) || Boolean(_skin) || Boolean(_text)) {
				return super.width;
			}
			return 0;
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			_bitmap.width = value;
			
			changeSize();
		}
		
		override public function get height():Number {
			if (!isNaN(_height) || Boolean(_skin) || Boolean(_text)) {
				return super.height;
			}
			return 0;
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			_bitmap.height = value;
			
			changeSize();
		}
		
		override public function set dataSource(value:Object):void {
			_dataSource = value;
			if (value is Number || value is String) {
				text = String(value);
			} else {
				super.dataSource = value;
			}
		}
	}
}