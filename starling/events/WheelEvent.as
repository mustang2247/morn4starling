package starling.events
{
	public class WheelEvent extends Event
	{
		public static const MOUSEWHEEL:String = "mouseWheel";
		
		public var delta:int = 0;
		
		public function WheelEvent(type:String, bubbles:Boolean = false, delta:int=0):void
		{
			super(type, bubbles);
			
			this.delta = delta;
		}
	}
}