package nonoFredBastien 
{
	/**
	 * ...
	 * @author 
	 */
	public class FactBase 
	{
		private var facts:Array;
		
		public function FactBase() 
		{
			facts = new Array();
		}
		
		public function AddFact(_label:String) : Fact {
			var fact:Fact = GetFact(_label);
			if (!fact) {
				fact = new Fact(_label);
				facts[_label] = fact;
			}
			return fact;
		}
		
		public function GetFacts() : Array {
			return facts;
		}
		
		public function GetFact(_label:String) : Fact {
			return facts[_label];
		}
		
	}

}