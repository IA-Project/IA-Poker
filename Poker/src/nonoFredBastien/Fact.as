package nonoFredBastien 
{
	/**
	 * ...
	 * @author 
	 */
	public class Fact 
	{
		
		private var label:String;
		private var value:Boolean;
		
		public function Fact(_label:String) 
		{
			label = _label;
			value = false;
		}
			
		public function SetValue(_value:Boolean) : void {
			value = _value;
		}
		
		public function GetLabel() : String {
			return label;
		}
		
		public function GetValue() : Boolean {
			return value;
		}
		
	}

}