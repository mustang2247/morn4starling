/**
 * 遮罩Sprite added by xiaoxiaofeitianma@gmail.com
 */
package starling.extensions
{
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import morn.core.components.Component;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.errors.MissingContextError;
    
    //public class ClippedSprite extends Sprite
	public class ClippedSprite extends Component
    {
        private var mClipRect:Rectangle;
        
        public override function render(support:RenderSupport, alpha:Number):void
        {
            if (mClipRect == null) super.render(support, alpha);
            else
            {
                var context:Context3D = Starling.context;
                if (context == null) throw new MissingContextError();
                
                support.finishQuadBatch();
				context.setScissorRectangle(mClipRect);
                
                super.render(support, alpha);
                
                support.finishQuadBatch();
				context.setScissorRectangle(null);
            }
        }
        
        public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            // without a clip rect, the sprite should behave just like before
            if (mClipRect == null) return super.hitTest(localPoint, forTouch); 
            
            // on a touch test, invisible or untouchable objects cause the test to fail
            if (forTouch && (!visible || !touchable)) return null;
            
            if (mClipRect.containsPoint(localToGlobal(localPoint)))
                return super.hitTest(localPoint, forTouch);
            else
                return null;
        }
        
        override public function get clipRect():Rectangle { return mClipRect; }
		override public function set clipRect(value:Rectangle):void
        {
            if (value) 
            {
                if (mClipRect == null) mClipRect = value.clone();
                else mClipRect.setTo(value.x, value.y, value.width, value.height);
            }
            else mClipRect = null;
        }
    }
}