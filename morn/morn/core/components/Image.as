/**
 * Morn UI Version 2.4.1027 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.components {
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import morn.core.events.UIEvent;
	import morn.core.handlers.Handler;
	import morn.core.utils.StringUtils;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**图片被加载后触发*/
	[Event(name="imageLoaded",type="morn.core.events.UIEvent")]
	
	/**图像类*/
	public class Image extends Component {
		protected var _bitmap:AutoBitmap;
		protected var _url:String;
		
		protected var _mainTexture:Texture = null;
		protected var _mainImg:starling.display.Image = null;
		
		public function Image(url:String = null) {
			this.url = url;
		}
		
		override protected function createChildren():void {
			_bitmap = new AutoBitmap();
			//addChild(_bitmap = new AutoBitmap());
		}
		
		/**图片地址*/
		public function get url():String {
			return _url;
		}
		
		public function set url(value:String):void {
			if (_url != value) {
				_url = value;
				if (Boolean(value)) {
					if (App.asset.hasClass(_url)) {
						bitmapData = App.asset.getBitmapData(_url);
					} else {
						App.loader.loadBMD(_url, new Handler(setBitmapData, [_url]));
					}
				} else {
					bitmapData = null;
				}
			}
		}
		
		/**源位图数据*/
		public function get bitmapData():BitmapData {
			return _bitmap.bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void {
			if (value) {
				_contentWidth = value.width;
				_contentHeight = value.height;
			}
			_bitmap.bitmapData = value;
			sendEvent(UIEvent.IMAGE_LOADED);
			
			reDraw();
		}
		
		protected function setBitmapData(url:String, bmd:BitmapData):void {
			if (url == _url) {
				bitmapData = bmd;
			}
		}
		
		override public function reDraw():void {
			//画到场景里
			removeAll();
			
			if(_bitmap.clips != null)
			{
				if(_bitmap.bitmapData.width >= AGALMiniAssembler.MAX_TEXTURE_SIZE || _bitmap.bitmapData.height >= AGALMiniAssembler.MAX_TEXTURE_SIZE) {
					var bitmapData0:BitmapData = new BitmapData(_bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2, true, 0x0);
					bitmapData0.copyPixels(_bitmap.bitmapData, new Rectangle(0, 0, _bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2), new Point());
					var tex0:Texture = Texture.fromBitmapData(bitmapData0);
					bitmapData0.dispose();
					var im0:starling.display.Image = new starling.display.Image(tex0);
					im0.scaleX = width / _bitmap.width;
					im0.scaleY = height / _bitmap.height;
					im0.x = 0;
					im0.y = 0;
					addChild(im0);
					
					var bitmapData1:BitmapData = new BitmapData(_bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2, true, 0x0);
					bitmapData1.copyPixels(_bitmap.bitmapData, new Rectangle(_bitmap.bitmapData.width / 2, 0, _bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2), new Point());
					var tex1:Texture = Texture.fromBitmapData(bitmapData1);
					bitmapData1.dispose();
					var im1:starling.display.Image = new starling.display.Image(tex1);
					im1.scaleX = width / _bitmap.width;
					im1.scaleY = height / _bitmap.height;
					im1.x = width / 2;
					im1.y = 0;
					addChild(im1);
					
					var bitmapData2:BitmapData = new BitmapData(_bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2, true, 0x0);
					bitmapData2.copyPixels(_bitmap.bitmapData, new Rectangle(0, _bitmap.bitmapData.height / 2, _bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2), new Point());
					var tex2:Texture = Texture.fromBitmapData(bitmapData2);
					bitmapData2.dispose();
					var im2:starling.display.Image = new starling.display.Image(tex2);
					im2.scaleX = width / _bitmap.width;
					im2.scaleY = height / _bitmap.height;
					im2.x = 0;
					im2.y = height / 2;
					addChild(im2);
					
					var bitmapData3:BitmapData = new BitmapData(_bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2, true, 0x0);
					bitmapData3.copyPixels(_bitmap.bitmapData, new Rectangle(_bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2, _bitmap.bitmapData.width / 2, _bitmap.bitmapData.height / 2), new Point());
					var tex3:Texture = Texture.fromBitmapData(bitmapData3);
					bitmapData3.dispose();
					var im3:starling.display.Image = new starling.display.Image(tex3);
					im3.scaleX = width / _bitmap.width;
					im3.scaleY = height / _bitmap.height;
					im3.x = width / 2;
					im3.y = height / 2;
					addChild(im3);
				} else {
					_mainTexture = Texture.fromBitmapData(_bitmap.bitmapData);
					_mainImg = new starling.display.Image(_mainTexture);
					_mainImg.width = width;
					_mainImg.height = height;
					_mainImg.smoothing = TextureSmoothing.NONE;
					addChild(_mainImg);
				}
			}
		}
		
		override public function removeAll():void {
			if(_mainTexture != null){
				_mainTexture.dispose();
				_mainTexture = null;
			}
			if(_mainImg != null){
				_mainImg.dispose();
				_mainImg = null;
			}
			App.loader.clearResLoaded(_url);
			removeChildren(0, -1, true);
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			_bitmap.width = width;
			
			if(sizeGrid != ""){
				App.render.callLater(reDraw);
			}else{
				_mainImg.width = width;	
			}
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			_bitmap.height = height;
			
			if(sizeGrid != ""){
				App.render.callLater(reDraw);
			}else{
				_mainImg.height = height;	
			}
		}
		
		/**九宫格信息(格式:左边距,上边距,右边距,下边距)*/
		public function get sizeGrid():String {
			if (_bitmap.sizeGrid) {
				return _bitmap.sizeGrid.join(",");
			}
			return null;
		}
		
		public function set sizeGrid(value:String):void {
			_bitmap.sizeGrid = StringUtils.fillArray(Styles.defaultSizeGrid, value);
		}
		
		/**位图控件实例*/
		public function get bitmap():AutoBitmap {
			return _bitmap;
		}
		
		/**是否对位图进行平滑处理*/
		public function get smoothing():Boolean {
			return _bitmap.smoothing;
		}
		
		public function set smoothing(value:Boolean):void {
			_bitmap.smoothing = value;
		}
		
		override public function set dataSource(value:Object):void {
			_dataSource = value;
			if (value is String) {
				url = String(value);
			} else {
				super.dataSource = value;
			}
		}
		
		/**销毁资源
		 * @param	clearFromLoader 是否同时删除加载缓存*/
//		public function dispose(clearFromLoader:Boolean = false):void {
//			App.asset.disposeBitmapData(_url);
//			_bitmap.bitmapData = null;
//			if (clearFromLoader) {
//				App.loader.clearResLoaded(_url);
//			}
//		}
	}
}