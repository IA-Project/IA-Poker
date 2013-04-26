package nonoFredBastien 
{
	import flash.display.GraphicsStroke;
	/**
	 * ...
	 * @author 
	 */
	public class ExpertSystem 
	{

		private var factBase:FactBase;
		private var ruleBase:RuleBase
		
		public function ExpertSystem() 
		{
			factBase = new FactBase();
			ruleBase = new RuleBase();
		}
		
		public function AddFact(_label:String) : void {	
			factBase.AddFact(_label);
		}
		
		public function AddRule(_premiseLabels:Array, _conclusionLabel:String) : void{
			var premises:Array = new Array();
			for each(var premiseLabel:String in _premiseLabels) {
				var premise:Fact = factBase.AddFact(premiseLabel);
				premises.push(premise);  
			}
			var conclusion:Fact = factBase.AddFact(_conclusionLabel);
			
			ruleBase.AddRule(premises, conclusion);
		}
		public function SetFactValue(_label:String, _value:Boolean) : void {
			var fact:Fact = factBase.GetFact(_label);
			if (fact) {
				fact.SetValue(_value); 
			}
		}
		
		public function InferForward() : Array {
			var result:Array = new Array();
			
			var finished:Boolean = false;
			while (!finished) {
				finished = true;
				var rules:Array = ruleBase.GetRules();
				for each(var rule:Rule in rules) {
					if (rule.IsValid() 
					&& (rule.GetConclusion().GetValue() == false)) {
						rule.GetConclusion().SetValue(true);						
						result.push(rule.GetConclusion().GetLabel());
						finished = false;
					}
				}
			}
			
			return result;
		}
		
		public function InfeckBackward() : Array {
			var result:Array = new Array();
			
			var terminalFacts:Array = GetTerminalFacts();
			
			for each(var fact:Fact in terminalFacts) {
				AddFactsToAsk(fact, result);
			}
			
			return result;
		}
		
		public function AddFactsToAsk(conclusion:Fact, result:Array) : void {
			var rules:Array = ruleBase.GetRulesWithConclusion(conclusion);
			for each(var rule:Rule in rules) {
				for each(var premise:Fact in rule.GetPremises())  {
					if (premise.GetValue() == false) {
						if (IsInitialFact(premise)) {
							var alreadyAdded:Boolean = false;
							for each(var label:String in result) {
								if (label == premise.GetLabel()) {
									alreadyAdded = true;
								}
							}		
							if(!alreadyAdded) {
								result.push(premise.GetLabel());
							}
						} else {
							AddFactsToAsk(premise, result);
						}
					}
				}
			}
		}
		
		public function GetTerminalFacts() : Array {
			var result:Array = new Array();
			for each(var fact:Fact in factBase.GetFacts()) {
				var isTerminal:Boolean = true;
				for each(var rule:Rule in ruleBase.GetRules()) {
					for each(var premise:Fact in rule.GetPremises()) {
						if (premise.GetLabel() == fact.GetLabel()) {
							isTerminal = false;
						}
					}
				}
				if (isTerminal) {
					result.push(fact);
				}
			}
			return result;
		}
		
		public function IsInitialFact(_fact:Fact) : Boolean {
			for each(var rule:Rule in ruleBase.GetRules()) {
				if (rule.GetConclusion().GetLabel() == _fact.GetLabel()) {
					return false;
				}
			}
			return true;
		}
		
		public function ResetFactValues() : void {
			for each(var fact:Fact in factBase.GetFacts()) {
				fact.SetValue(false);
			}
		}
		
		public function TraceRules() : void {
			for each(var rule:Rule in ruleBase.GetRules()) {
				var ruleTrace:String = "";
				for each(var premise:Fact in rule.GetPremises()) {
					ruleTrace += premise.GetLabel() + " ";
				}
				ruleTrace += "-> " + rule.GetConclusion().GetLabel();
				trace(ruleTrace);
			}
			
			var terminalFacts:Array = GetTerminalFacts();
			for each(var fact:Fact in terminalFacts) {
				trace("Terminal fact : " + fact.GetLabel());
			}
		}
		
	}

}