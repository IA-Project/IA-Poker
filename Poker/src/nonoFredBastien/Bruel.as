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
			var probaGainPotentiel = calculprobapotentiel(GetCard(0), GetCard(1), _pokerTable.GetBoard(), _pokerTable.GetActivePlayersCount());
			var esperanceGainNow = esperance(probaGain, _pokerTable);
			var esperanceGainPotentiel = esperance(probaGainPotentiel, _pokerTable);
			trace("****************************************** ProbaGain :" + probaGain);
			trace("****************************************** ProbaGain Potentiel:" + probaGainPotentiel);
			trace("****************************************** Espérance :" + esperanceGainNow);
			trace("****************************************** Espérance Potentiel:" + esperanceGainPotentiel);
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
		// Espérance = Proba * Pot - (1 - proba) * suivre  
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
			var NB_TIRAGE = 100;
			var nbgamewin = 0;
			var nbgamelose = 0;
			var nbgameplayed = 0;
			var valeurmain = 0;
			var valeurmainadversaire = 0;
			var probabilitedegagner = 0;
			if (flop.length == 3)
			{
				//a finir en calculant le nombre de partie gagné sur 1000 parties et gérer le calcul de proba avec 7 cartes
				var jeudujoueur = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2]];
				var jeuadversaire;
				var jeudujoueurpotentiel;
				var jeuadversairepotentiel;
				for (nbgameplayed = 0; nbgameplayed<NB_TIRAGE; nbgameplayed++)
				{
					deck.Shuffle();
					valeurmain = PokerTools.GetCardSetValue(jeudujoueur);
					jeuadversaire = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2]];
					valeurmainadversaire = PokerTools.GetCardSetValue(jeuadversaire);
					trace("Moi:" + valeurmain + " - Lui:" + valeurmainadversaire);					
					// Le plus petit c'est le meilleur. Le Zéro c'est Null par contre
					if (valeurmain == 0 || valeurmain > valeurmainadversaire)
						nbgamelose++;
					else
						nbgamewin++;
				}
			}
			
/*			if (flop.length == 5)
			{
				//a finir en calculant le nombre de partie gagné sur 1000 parties et gérer le calcul de proba avec 7 cartes
				var jeudujoueur = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], flop[4]];
				{
					deck.Shuffle();
					valeurmain = PokerTools.GetCardSetValue(jeudujoueur);
					jeuadversaire = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], flop[4]];
					valeurmainadversaire = PokerTools.GetCardSetValue(jeuadversaire);
					if (valeurmain < valeurmainadversaire)
						nbgamelose++;
					else
						nbgamewin++;
				}
			}
*/			
			probabilitedegagner 		 = nbgamewin / NB_TIRAGE;
			var probamoyenne = 1 / nbjoueursactifs;
			trace("probabilite de gagner maintenant : " + probabilitedegagner);
			return probabilitedegagner;
		}
		
		private function calculprobapotentiel(premierecarte:PlayingCard, deuxiemecarte:PlayingCard, flop:Array, nbjoueursactifs:int) : Number
		{
			var deck:Deck = new Deck();
			deck.RemoveCard(premierecarte);
			deck.RemoveCard(deuxiemecarte);
			var NB_TIRAGE = 100;
			var nbgameplayed = 0;
			var valeurmainpotentiel = 0;
			var valeurmainadversairepotentiel = 0;
			var nbgamelosepotentiel = 0;
			var nbgamewinpotentiel = 0;
			var probabilitedegagnerpotentiel = 0;
			if (flop.length == 3)
			{
				//a finir en calculant le nombre de partie gagné sur 1000 parties et gérer le calcul de proba avec 7 cartes
				var jeudujoueurpotentiel;
				var jeuadversairepotentiel;
				for (nbgameplayed = 0; nbgameplayed<NB_TIRAGE; nbgameplayed++)
				{
					deck.Shuffle();
					jeudujoueurpotentiel = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];	
					valeurmainpotentiel = PokerTools.GetCardSetValue(jeudujoueurpotentiel);
					jeuadversairepotentiel = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];
					valeurmainadversairepotentiel = PokerTools.GetCardSetValue(jeuadversairepotentiel);
					trace("MoiPotentiel:" + valeurmainpotentiel + " - LuiPotentiel:" + valeurmainadversairepotentiel);
					
					if (valeurmainpotentiel == 0 || valeurmainpotentiel > valeurmainadversairepotentiel)
						nbgamelosepotentiel++;
					else
						nbgamewinpotentiel++;
				}
			}
			
			probabilitedegagnerpotentiel = nbgamewinpotentiel / NB_TIRAGE;
			var probamoyenne = 1 / nbjoueursactifs;
			trace("probabilite de gagner potentiel	: " + probabilitedegagnerpotentiel);
			return probabilitedegagnerpotentiel;
		}
		
	}
}