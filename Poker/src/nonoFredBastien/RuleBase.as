package nonoFredBastien 
{
	/**
	 * ...
	 * @author 
	 */
	public class RuleBase 
	{
		private var rules:Array;
		
		public function RuleBase() 
		{
			rules = new Array();
		}
		
		public function AddRule(_premises:Array, _conclusion:Fact) : void {
			var rule:Rule = new Rule(_premises, _conclusion);
			rules.push(rule);
		}
		
		public function GetRules(): Array {
			return rules;
		}
		
		public function GetRulesWithConclusion(conclusion:Fact) : Array {
			var result:Array = new Array();
			
			for each(var rule:Rule in rules) {
				if (rule.GetConclusion().GetLabel() == conclusion.GetLabel()) {
					result.push(rule);
				}
			}
			
			return result;
		}
		
	}

}