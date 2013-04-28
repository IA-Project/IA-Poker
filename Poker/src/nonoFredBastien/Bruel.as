package nonoFredBastien 
{
	import com.novabox.poker.PokerPlayer;
	import com.novabox.poker.PokerTable;
	import com.novabox.poker.PokerAction;
	import com.novabox.poker.PokerTools;
	import com.novabox.playingCards.*;
	
	public class Bruel extends PokerPlayer
	{
		var expertSystem:ExpertSystem;
		
		public function Bruel(_name:String, _stackValue:Number) 
		{
			super(_name, _stackValue);
			initSystem();
		}
		
		override public function Play(_pokerTable:PokerTable) : Boolean
		{
			perception(_pokerTable);
			var actionFact:String = analyse(_pokerTable);
			
			act(actionFact, _pokerTable);
			
			
			return (lastAction != PokerAction.NONE);
		}
		
		private function initSystem() : void
		{
			expertSystem = new ExpertSystem();
			expertSystem.AddRule(["Premier tour"], "Suivre");
			expertSystem.AddRule(["Quatrieme tour"], "Suivre");
			expertSystem.AddRule(["Gagné d'avance"], "All-In");
			expertSystem.AddRule(["Bon jeu"], "Relancer");
			expertSystem.AddRule(["Mauvais jeu"], "Laisser");
			expertSystem.AddRule(["Trop risqué"], "Laisser");
			expertSystem.AddRule(["Jeu moyen"], "Suivre");

		}
		
		private function perception(_pokerTable:PokerTable) : void
		{
			expertSystem.ResetFactValues();
			
			var probaGain = calculproba(GetCard(0), GetCard(1), _pokerTable.GetBoard(), _pokerTable.GetActivePlayersCount());
			trace("********************** ProbaGain :" + probaGain);
			
			var esperanceGain = esperance(probaGain, _pokerTable);
			trace("********************** Esperance :" + esperanceGain);
			
			if (esperanceGain <= 0) expertSystem.SetFactValue("Trop risqué", true);
			if (esperanceGain > 0 && esperanceGain <= 2) expertSystem.SetFactValue("Mauvais jeu", true);
			if (esperanceGain > 2 && esperanceGain <= 35) expertSystem.SetFactValue("Jeu moyen", true);
			if (esperanceGain > 35 && esperanceGain <= 80) expertSystem.SetFactValue("Bon jeu", true);
			if (esperanceGain > 80 ) expertSystem.SetFactValue("Gagné d'avance", true);
			
			if (_pokerTable.GetBoard().length == 0) {
				expertSystem.SetFactValue("Premier tour", true);
			}
			//if (_pokerTable.GetBoard().length == 4) {
			//	expertSystem.SetFactValue("Quatrieme tour", true);
			//}
			if (_pokerTable.GetAllInPlayersCount() >= 1 && probaGain <= 0.75)
			{
				expertSystem.SetFactValue("Trop risqué", true);
			}
			
			/*
			if (probaGain > 0.95) {
				expertSystem.SetFactValue("Gagné d'avance", true);
			}
			if (probaGain <= 0.95 && probaGain > 0.75) {
				expertSystem.SetFactValue("Bon jeu", true);
			}
			if (probaGain > 0.15 && probaGain <= 0.75) {
				expertSystem.SetFactValue("Jeu moyen", true);
			}
			if (probaGain <= 0.15) {
				expertSystem.SetFactValue("Mauvais jeu", true);
			}
			if (_pokerTable.GetBoard().length == 0) {
				expertSystem.SetFactValue("Premier tour", true);
			}
			if (_pokerTable.GetBoard().length == 4) {
				expertSystem.SetFactValue("Quatrieme tour", true);
			}
			if (_pokerTable.GetAllInPlayersCount() >= 1 && probaGain <= 0.75)
			{
				expertSystem.SetFactValue("Trop risqué", true);
			}
			*/
		}
		
		private function analyse(_pokerTable:PokerTable) : String
		{
			var conclusions:Array =  expertSystem.InferForward();
			if(conclusions.length > 0) {
				return conclusions[0];
			}
			return null;
		}
		
		private function act(factLabel:String, _pokerTable:PokerTable) : void
		{
			switch(factLabel) {
				case "Relancer":
					Raise(_pokerTable.GetValueToCall(), 50);
					break;
				
				case "Laisser":
					Fold();
					break;
					
				case "Suivre":
					Call(_pokerTable.GetValueToCall());
					break;
					
				case "All-In":
					Raise(_pokerTable.GetValueToCall(), GetStackValue());
					break;
					
				default:
					Call(_pokerTable.GetValueToCall());
					break;
			}
		}
		// Espérance = Proba * Pot - (1 - proba) * valToSuivre  
		// Espérance positive ok / Négative pas ok
		private function esperance(proba:Number,  _pokerTable:PokerTable) : Number
		{
			return proba * _pokerTable.GetCurrentPot().GetValue() - (1 - proba) * _pokerTable.GetValueToCall();
		}
		
		private function calculproba(premierecarte:PlayingCard, deuxiemecarte:PlayingCard, flop:Array, nbjoueursactifs:int) : Number
		{
			var deck:Deck = new Deck();
			deck.RemoveCard(premierecarte);
			deck.RemoveCard(deuxiemecarte);
			var NB_TIRAGE = 1000;
			var nbgameplayed = 0;
			var valeurmain;
			var valeurmainadversaire;
			var valeurmainpotentiel = 0;
			var valeurmainadversairepotentiel = 0;
			var nbgamelosepotentiel = 0;
			var nbgamewinpotentiel = 0;
			var probabilitedegagnerpotentiel = 0;
			var nbgamelose = 0;
			var nbgamewin = 0;
			var probabilitedegagner = 0;
			
			var jeudujoueur;
			var jeuadversaire;
			var jeudujoueurpotentiel;
			var jeuadversairepotentiel;
			for (nbgameplayed = 0; nbgameplayed<NB_TIRAGE; nbgameplayed++)
			{
				deck.Shuffle();
				if (flop.length == 3) {
					jeudujoueur 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2]];
					jeuadversaire	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2]];
					jeudujoueurpotentiel 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];	
					jeuadversairepotentiel 	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];
				}
				if (flop.length == 4) {
					jeudujoueur 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2]]; // A completer
					jeuadversaire 	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2]];// A completer
					jeudujoueurpotentiel 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], deck.GetCard(2)];
					jeuadversairepotentiel 	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], deck.GetCard(2)];
				}
				if (flop.length == 5) {
					jeudujoueur 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], flop[4]];
					jeuadversaire 	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], flop[4]];
					jeudujoueurpotentiel 	= [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], flop[4]];
					jeuadversairepotentiel 	= [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], flop[4]];
				}
				else {
					jeudujoueur 	= [premierecarte, deuxiemecarte, deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
					jeuadversaire 	= [deck.GetCard(0), deck.GetCard(1), deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
					jeudujoueurpotentiel 	= [premierecarte, deuxiemecarte, deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
					jeuadversairepotentiel 	= [deck.GetCard(0), deck.GetCard(1), deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
					}
					
				valeurmain 				= PokerTools.GetCardSetValue(jeudujoueur);
				valeurmainadversaire 	= PokerTools.GetCardSetValue(jeuadversaire);
				
				valeurmainpotentiel 			= PokerTools.GetCardSetValue(jeudujoueurpotentiel);
				valeurmainadversairepotentiel 	= PokerTools.GetCardSetValue(jeuadversairepotentiel);
				//trace("MoiPotentiel:" + valeurmainpotentiel + " - LuiPotentiel:" + valeurmainadversairepotentiel);
				
				if (valeurmain == 0 || valeurmain > valeurmainadversaire) nbgamelose++;
				else nbgamewin++;
				
				if (valeurmainpotentiel == 0 || valeurmainpotentiel > valeurmainadversairepotentiel) nbgamelosepotentiel++;
				else nbgamewinpotentiel++;
			}
			trace("Taille du Flop "+flop.length);
			probabilitedegagnerpotentiel = nbgamewinpotentiel / NB_TIRAGE;
			probabilitedegagner = nbgamewin / NB_TIRAGE;
			var moyenne = 1 / nbjoueursactifs;
			if (probabilitedegagner >= moyenne) return probabilitedegagner;
			return probabilitedegagnerpotentiel;			
		}
		
	}
}