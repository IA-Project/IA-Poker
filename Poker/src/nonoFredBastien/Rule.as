package nonoFredBastien 
{
	/**
	 * ...
	 * @author 
	 */
	public class Rule 
	{
		private var conclusion:Fact;
		private var premises:Array;
		
		public function Rule(_premise:Array, _conclusion:Fact) 
		{
			conclusion = _conclusion;
			premises = _premise;
		}
		
		public function GetPremises() : Array {
			return premises;
		}
		
		public function GetConclusion() : Fact {
			return conclusion;
		}
		
		public function IsValid() : Boolean {
			for each(var premise:Fact in premises) {
				if (premise.GetValue() == false) {
					return false;
				}
			}
			return true;
		}
		
	}

}