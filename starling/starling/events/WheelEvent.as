package starling.events
{
	public class WheelEvent extends Event
	{
		public static const MOUSEWHEEL:String = "mouseWheel";
		
		public var delta:int = 0;
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		
		public function WheelEvent(type:String, bubbles:Boolean = false, delta:int=0, x:Number = 0.0, y:Number = 0.0):void
		{
			super(type, bubbles);
			
			this.delta = delta;
			this.x = x;
			this.y = y;
		}
	}
}