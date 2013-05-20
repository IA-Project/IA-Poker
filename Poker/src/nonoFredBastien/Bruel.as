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
		
		override public function Play(_pokerTable:PokerTable):Boolean
		{
			perception(_pokerTable);
			var actionFact:String = analyse(_pokerTable);
			
			act(actionFact, _pokerTable);
			
			return (lastAction != PokerAction.NONE);
		}
		
		private function initSystem():void
		{
			expertSystem = new ExpertSystem();
			expertSystem.AddRule(["Gagné d'avance"], "All-In");
			expertSystem.AddRule(["Bon jeu"], "Relancer");
			expertSystem.AddRule(["Bon jeu final"], "RelancerFinal");
			expertSystem.AddRule(["Bluff"], "Relancer");
			expertSystem.AddRule(["Bluff final"], "RelancerFinal");
			expertSystem.AddRule(["Mauvais jeu"], "Laisser");
			expertSystem.AddRule(["Trop risqué"], "Laisser");
			expertSystem.AddRule(["Jeu moyen"], "Suivre");
		}
		
		private function perception(_pokerTable:PokerTable):void
		{
			expertSystem.ResetFactValues();
			
			
			
			
			
			
			var probaGain = calculproba(GetCard(0), GetCard(1), _pokerTable.GetBoard());
			trace("********************** ProbaGain :" + probaGain);
			
			var esperanceGain = esperance(probaGain, _pokerTable);
			trace("********************** Esperance :" + esperanceGain);
			
			if (_pokerTable.GetActivePlayersCount() == 2)
			{
				
				if (_pokerTable.GetBoard().length == 0)
				{
					var activePlayers = _pokerTable.GetActivePlayersCount() - 1;
					var probaGainPreflop = probaPreFlop(GetCard(0), GetCard(1), _pokerTable);
					trace("********************** probaGainPreflop :" + probaGainPreflop);
					var probaAdverse = (100 - probaGainPreflop) / activePlayers;
					trace ("********************** probaGainAdverse :" + probaAdverse);
					trace ("active players :" + activePlayers);
					var probaDiff = probaGainPreflop - probaAdverse;
					trace ("********************** probaDiff :" + probaDiff);
					
					
					if (probaDiff >= 20)
						expertSystem.SetFactValue("Bon jeu final", true);
					
					if (probaDiff >= 16 && probaDiff < 20)
						expertSystem.SetFactValue("Bon jeu", true);
					if (probaDiff >= 0 && probaDiff< 16)
					{
						if (_pokerTable.GetValueToCall() < GetStackValue() * 0.20)
							expertSystem.SetFactValue("Jeu moyen", true);
						else
							expertSystem.SetFactValue("Trop risqué", true);
					}
					else
						expertSystem.SetFactValue("Trop risqué", true);
					
					
					/*
					if (probaGain > 0.6)
						expertSystem.SetFactValue("Bon jeu", true);
						
					
					if (probaGain >= 0.5 && probaGain <= 0.6)
					{
						if (_pokerTable.GetValueToCall() < GetStackValue() * 0.20)
							expertSystem.SetFactValue("Jeu moyen", true);
						else
							expertSystem.SetFactValue("Trop risqué", true);
					}
					else
						expertSystem.SetFactValue("Trop risqué", true);
						
					*/
				}
				else
				{
					if (esperanceGain <= 0)
						expertSystem.SetFactValue("Trop risqué", true);
					if (esperanceGain > 0 && esperanceGain <= 0.02 * GetStackValue())
						expertSystem.SetFactValue("Mauvais jeu", true);
					if (esperanceGain > 0.02 * GetStackValue() && esperanceGain <= 0.25 * GetStackValue())
						expertSystem.SetFactValue("Jeu moyen", true);
					if (esperanceGain > 0.25 * GetStackValue() && esperanceGain <= 0.65 * GetStackValue())
						expertSystem.SetFactValue("Bon jeu", true);
					if (esperanceGain > 0.65 * GetStackValue() && esperanceGain <= 0.80 * GetStackValue())
						expertSystem.SetFactValue("Bon jeu Final", true);
					if (esperanceGain > 0.80 * GetStackValue())
						expertSystem.SetFactValue("Gagné d'avance", true);
					
					if (_pokerTable.IsRiverDealt && probaGain < 0.15)
						expertSystem.SetFactValue("Trop risqué", true);
					
					if (_pokerTable.GetDealer().GetName() == this.GetName())
					{
						if (Math.random() <= 0.1)
							expertSystem.SetFactValue("Bluff final", true);
					}
				}
			}
			
			else
			{
				if (_pokerTable.GetBoard().length == 0)
				{
					var activePlayers = _pokerTable.GetActivePlayersCount() - 1;
					var probaGainPreflop = probaPreFlop(GetCard(0), GetCard(1), _pokerTable);
					trace("********************** probaGainPreflop :" + probaGainPreflop);
					var probaAdverse = (100 - probaGainPreflop) / activePlayers;
					trace ("********************** probaGainAdverse :" + probaAdverse);
					trace ("active players :" + activePlayers);
					var probaDiff = probaGainPreflop - probaAdverse;
					trace ("********************** probaDiff :" + probaDiff);
					
					
					if (probaDiff >= 20)
						expertSystem.SetFactValue("Bon jeu final", true);
					if (probaDiff >= 16 && probaDiff < 20)
						expertSystem.SetFactValue("Bon jeu", true);
					if (probaDiff >= 0 && probaDiff < 16)
					{
						if (_pokerTable.GetValueToCall() < GetStackValue() * 0.20)
							expertSystem.SetFactValue("Jeu moyen", true);
					
						else
							expertSystem.SetFactValue("Trop risqué", true);
					}
					else
						expertSystem.SetFactValue("Trop risqué", true);
					
					
					
					/*
					if (probaGain > 0.7)
						expertSystem.SetFactValue("Bon jeu", true);
					if (probaGain >= 0.6 && probaGain <= 0.7)
					{
						if (_pokerTable.GetValueToCall() < GetStackValue() * 0.10)
							expertSystem.SetFactValue("Jeu moyen", true);
						else
							expertSystem.SetFactValue("Trop risqué", true);
					}
					else
						expertSystem.SetFactValue("Trop risqué", true);
					*/	
					
					
				}
				else
				{
					if (esperanceGain <= 0)
						expertSystem.SetFactValue("Trop risqué", true);
					if (esperanceGain > 0 && esperanceGain <= 0.02 * GetStackValue())
						expertSystem.SetFactValue("Mauvais jeu", true);
					if (esperanceGain > 0.02 * GetStackValue() && esperanceGain <= 0.35 * GetStackValue())
						expertSystem.SetFactValue("Jeu moyen", true);
					if (esperanceGain > 0.35 * GetStackValue() && esperanceGain <= 0.80 * GetStackValue())
						expertSystem.SetFactValue("Bon jeu", true);
					if (esperanceGain > 0.80 * GetStackValue() && esperanceGain <= 1 * GetStackValue())
						expertSystem.SetFactValue("Bon jeu Final", true);
					if (esperanceGain > 1 * GetStackValue())
						expertSystem.SetFactValue("Gagné d'avance", true);
					
					if (_pokerTable.IsRiverDealt && probaGain < 0.2)
						expertSystem.SetFactValue("Trop risqué", true);
					
					if (_pokerTable.GetDealer().GetName() == this.GetName())
					{
						if (Math.random() <= 0.05)
							expertSystem.SetFactValue("Bluff", true);
					}
				}
			}
		}
		
		private function analyse(_pokerTable:PokerTable):String
		{
			var conclusions:Array = expertSystem.InferForward();
			if (conclusions.length > 0)
			{
				return conclusions[0];
			}
			return null;
		}
		
		private function act(factLabel:String, _pokerTable:PokerTable):void
		{
			switch (factLabel)
			{
				case "Relancer": 
					Raise(_pokerTable.GetValueToCall(), Math.round(GetStackValue() * 0.08));
					break;
				
				case "RelancerFinal": 
					Raise(_pokerTable.GetValueToCall(), Math.round(GetStackValue() * 0.20));
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
		private function esperance(proba:Number, _pokerTable:PokerTable):Number
		{
			return proba * _pokerTable.GetCurrentPot().GetValue() - (1 - proba) * _pokerTable.GetValueToCall();
		}
		
		private function calculproba(premierecarte:PlayingCard, deuxiemecarte:PlayingCard, flop:Array):Number
		{
			var deck:Deck = new Deck();
			deck.RemoveCard(premierecarte);
			deck.RemoveCard(deuxiemecarte);
			var NB_TIRAGE = 1000;
			var nbgameplayed = 0;
			var valeurmainpotentiel = 0;
			var valeurmainadversairepotentiel = 0;
			var nbgamelosepotentiel = 0;
			var nbgamewinpotentiel = 0;
			var probabilitedegagnerpotentiel = 0;
			var jeudujoueurpotentiel;
			var jeuadversairepotentiel;
			for (nbgameplayed = 0; nbgameplayed < NB_TIRAGE; nbgameplayed++)
			{
				deck.Shuffle();
				if (flop.length == 3)
				{
					jeudujoueurpotentiel = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];
					jeuadversairepotentiel = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], deck.GetCard(2), deck.GetCard(3)];
				}
				if (flop.length == 4)
				{
					jeudujoueurpotentiel = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], deck.GetCard(2)];
					jeuadversairepotentiel = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], deck.GetCard(2)];
				}
				if (flop.length == 5)
				{
					jeudujoueurpotentiel = [premierecarte, deuxiemecarte, flop[0], flop[1], flop[2], flop[3], flop[4]];
					jeuadversairepotentiel = [deck.GetCard(0), deck.GetCard(1), flop[0], flop[1], flop[2], flop[3], flop[4]];
				}
				else
				{
					jeudujoueurpotentiel = [premierecarte, deuxiemecarte, deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
					jeuadversairepotentiel = [deck.GetCard(0), deck.GetCard(1), deck.GetCard(2), deck.GetCard(3), deck.GetCard(4), deck.GetCard(5), deck.GetCard(6)];
				}
				
				valeurmainpotentiel = PokerTools.GetCardSetValue(jeudujoueurpotentiel);
				valeurmainadversairepotentiel = PokerTools.GetCardSetValue(jeuadversairepotentiel);
				
				if (valeurmainpotentiel == 0 || valeurmainpotentiel > valeurmainadversairepotentiel)
					nbgamelosepotentiel++;
				else
					nbgamewinpotentiel++;
			}
			trace("***************** Taille du Flop " + flop.length);
			probabilitedegagnerpotentiel = nbgamewinpotentiel / NB_TIRAGE;
			return probabilitedegagnerpotentiel;
		}
		
		private function probaPreFlop(firstCard:PlayingCard, secondCard:PlayingCard, _pokerTable:PokerTable):Number
		{
			
			var heightFirstCard;
			var heightSecondCard;
			var probaPreFlop = 0;
			var nombreJoueurs = _pokerTable.GetActivePlayersCount() - 2;
			if (firstCard.GetHeight() == secondCard.GetHeight())
			{
				heightFirstCard = firstCard.GetHeight();
				heightSecondCard = secondCard.GetHeight();
			}
			else if (firstCard.GetHeight() > secondCard.GetHeight())
			{
				heightFirstCard = secondCard.GetHeight();
				heightSecondCard = firstCard.GetHeight();
			}
			else
			{
				heightFirstCard = firstCard.GetHeight();
				heightSecondCard = secondCard.GetHeight();
			}
			
			trace(heightFirstCard + "--" + heightSecondCard);
			
			var tableauProba:Array = new Array();
			var tableauProbaSuited:Array = new Array();
			
			tableauProba[12] = new Array();
			tableauProba[11] = new Array();
			tableauProba[10] = new Array();
			tableauProba[9] = new Array();
			tableauProba[8] = new Array();
			tableauProba[7] = new Array();
			tableauProba[6] = new Array();
			tableauProba[5] = new Array();
			tableauProba[4] = new Array();
			tableauProba[3] = new Array();
			tableauProba[2] = new Array();
			tableauProba[1] = new Array();
			tableauProba[0] = new Array();
			
			tableauProbaSuited[12] = new Array();
			tableauProbaSuited[11] = new Array();
			tableauProbaSuited[10] = new Array();
			tableauProbaSuited[9] = new Array();
			tableauProbaSuited[8] = new Array();
			tableauProbaSuited[7] = new Array();
			tableauProbaSuited[6] = new Array();
			tableauProbaSuited[5] = new Array();
			tableauProbaSuited[4] = new Array();
			tableauProbaSuited[3] = new Array();
			tableauProbaSuited[2] = new Array();
			tableauProbaSuited[1] = new Array();
			tableauProbaSuited[0] = new Array();
			
			//couleur
			tableauProbaSuited[11][12] = [67.94, 51.88, 42.68, 36.69, 32.37, 29.01, 26.28, 23.98, 22.01];
			tableauProbaSuited[10][12] = [67.19, 50.71, 41.27, 35.16, 30.81, 27.47, 24.81, 22.6, 20.74];
			tableauProbaSuited[10][11] = [64.55, 48.46, 39.58, 33.85, 29.68, 26.44, 23.84, 21.7, 19.89];
			tableauProbaSuited[9][12] = [66.5, 49.66, 40.05, 33.89, 29.56, 26.29, 23.71, 21.61, 19.86];
			tableauProbaSuited[9][11] = [63.83, 47.41, 38.37, 32.59, 28.45, 25.3, 22.79, 20.76, 19.08];
			tableauProbaSuited[9][10] = [61.74, 45.89, 37.34, 31.8, 27.78, 24.72, 22.28, 20.32, 18.71];
			tableauProbaSuited[8][9] = [59.31, 43.9, 35.73, 30.43, 26.62, 23.72, 21.48, 19.71, 18.29];
			tableauProbaSuited[8][12] = [65.84, 48.7, 38.99, 32.85, 28.56, 25.38, 22.89, 20.88, 19.22];
			tableauProbaSuited[8][11] = [63.16, 46.46, 37.34, 31.56, 27.49, 24.43, 22.03, 20.09, 18.52];
			tableauProbaSuited[8][10] = [61.07, 44.94, 36.32, 30.79, 26.86, 23.88, 21.57, 19.72, 18.23];
			tableauProbaSuited[7][9] = [57.64, 41.57, 33.19, 27.85, 24.1, 21.32, 19.2, 17.54, 16.21];
			tableauProbaSuited[7][8] = [56.2, 40.94, 32.98, 27.83, 24.19, 21.49, 19.45, 17.85, 16.59];
			tableauProbaSuited[7][12] = [64.17, 46.34, 36.42, 30.25, 26.06, 23, 20.64, 18.77, 17.25];
			tableauProbaSuited[7][11] = [61.53, 44.12, 34.76, 28.93, 24.93, 21.97, 19.69, 17.88, 16.41];
			tableauProbaSuited[7][10] = [59.41, 42.6, 33.73, 28.18, 24.31, 21.45, 19.25, 17.51, 16.12];
			tableauProbaSuited[6][9] = [56.15, 39.61, 31.15, 25.91, 22.31, 19.68, 17.69, 16.15, 14.93];
			tableauProbaSuited[6][8] = [54.7, 38.99, 30.98, 25.92, 22.43, 19.87, 17.96, 16.49, 15.32];
			tableauProbaSuited[6][7] = [53.34, 38.31, 30.53, 25.53, 22.03, 19.5, 17.6, 16.14, 14.99];
			tableauProbaSuited[6][12] = [63.51, 45.49, 35.56, 29.44, 25.31, 22.32, 20.03, 18.22, 16.75];
			tableauProbaSuited[6][11] = [60.04, 42.15, 32.72, 27.02, 23.16, 20.37, 18.25, 16.58, 15.23];
			tableauProbaSuited[6][10] = [57.95, 40.65, 31.72, 26.24, 22.53, 19.81, 17.74, 16.13, 14.84];
			tableauProbaSuited[5][9] = [54.62, 37.68, 29.24, 24.12, 20.66, 18.19, 16.33, 14.89, 13.76];
			tableauProbaSuited[5][8] = [53.17, 37.07, 29.04, 24.12, 20.77, 18.37, 16.58, 15.21, 14.13];
			tableauProbaSuited[5][7] = [51.85, 36.52, 28.78, 23.95, 20.64, 18.27, 16.52, 15.17, 14.11];
			tableauProbaSuited[5][6] = [50.86, 36.26, 28.76, 23.99, 20.73, 18.41, 16.7, 15.39, 14.36];
			tableauProbaSuited[5][12] = [62.72, 44.54, 34.65, 28.63, 24.6, 21.71, 19.5, 17.76, 16.37];
			tableauProbaSuited[5][11] = [59.43, 41.42, 32.04, 26.38, 22.59, 19.86, 17.79, 16.17, 14.87];
			tableauProbaSuited[5][10] = [56.41, 38.72, 29.8, 24.49, 20.94, 18.38, 16.47, 14.99, 13.82];
			tableauProbaSuited[4][9] = [52.97, 35.64, 27.21, 22.23, 18.94, 16.59, 14.85, 13.53, 12.47];
			tableauProbaSuited[4][8] = [51.51, 35.02, 26.99, 22.18, 18.96, 16.68, 14.99, 13.7, 12.67];
			tableauProbaSuited[4][7] = [50.21, 34.49, 26.75, 22.03, 18.86, 16.6, 14.94, 13.68, 12.67];
			tableauProbaSuited[4][6] = [49.22, 34.29, 26.83, 22.18, 19.08, 16.87, 15.26, 14.02, 13.05];
			tableauProbaSuited[4][5] = [48.45, 34.13, 26.78, 22.17, 19.06, 16.87, 15.26, 14.03, 13.06];
			tableauProbaSuited[4][12] = [61.62, 43.16, 33.26, 27.33, 23.4, 20.61, 18.49, 16.83, 15.48];
			tableauProbaSuited[4][11] = [58.56, 40.37, 30.98, 25.41, 21.7, 19.05, 17.05, 15.48, 14.22];
			tableauProbaSuited[4][10] = [55.78, 37.92, 28.99, 23.69, 20.17, 17.67, 15.78, 14.33, 13.18];
			tableauProbaSuited[3][9] = [52.61, 35.28, 26.96, 22.09, 18.88, 16.62, 14.95, 13.66, 12.64];
			tableauProbaSuited[3][8] = [50.05, 33.37, 25.53, 20.96, 17.95, 15.85, 14.29, 13.12, 12.17];
			tableauProbaSuited[3][7] = [48.77, 32.84, 25.25, 20.75, 17.76, 15.67, 14.14, 12.97, 12.03];
			tableauProbaSuited[3][6] = [47.77, 32.67, 25.38, 20.99, 18.08, 16.05, 14.56, 13.42, 12.53];
			tableauProbaSuited[3][5] = [47.08, 32.72, 25.62, 21.32, 18.48, 16.51, 15.07, 13.98, 13.1];
			tableauProbaSuited[3][4] = [46.48, 32.58, 25.5, 21.17, 18.31, 16.32, 14.86, 13.74, 12.83];
			tableauProbaSuited[3][12] = [61.92, 43.83, 34.18, 28.41, 24.59, 21.84, 19.76, 18.1, 16.75];
			tableauProbaSuited[3][11] = [57.97, 39.77, 30.53, 25.11, 21.55, 18.99, 17.08, 15.58, 14.37];
			tableauProbaSuited[3][10] = [55.18, 37.34, 28.54, 23.4, 20.01, 17.63, 15.83, 14.44, 13.33];
			tableauProbaSuited[2][9] = [51.72, 34.43, 26.23, 21.47, 18.38, 16.2, 14.57, 13.33, 12.33];
			tableauProbaSuited[2][8] = [49.4, 32.78, 24.99, 20.48, 17.54, 15.47, 13.95, 12.79, 11.87];
			tableauProbaSuited[2][7] = [46.95, 30.95, 23.54, 19.23, 16.41, 14.45, 13.02, 11.93, 11.06];
			tableauProbaSuited[2][6] = [45.98, 30.76, 23.6, 19.37, 16.62, 14.7, 13.3, 12.23, 11.38];
			tableauProbaSuited[2][5] = [45.31, 30.85, 23.89, 19.74, 17.06, 15.2, 13.83, 12.79, 11.96];
			tableauProbaSuited[2][4] = [44.76, 30.78, 23.88, 19.73, 17.04, 15.18, 13.8, 12.75, 11.89];
			tableauProbaSuited[2][3] = [45.13, 31.62, 24.84, 20.79, 18.19, 16.42, 15.11, 14.09, 13.27];
			tableauProbaSuited[2][12] = [61.07, 42.91, 33.38, 27.74, 24.02, 21.37, 19.34, 17.73, 16.42];
			tableauProbaSuited[2][11] = [57.09, 38.89, 29.76, 24.46, 21, 18.53, 16.68, 15.22, 14.04];
			tableauProbaSuited[2][10] = [54.3, 36.48, 27.8, 22.79, 19.5, 17.19, 15.46, 14.11, 13.03];
			tableauProbaSuited[1][9] = [50.87, 33.64, 25.54, 20.92, 17.91, 15.8, 14.24, 13.03, 12.06];
			tableauProbaSuited[1][8] = [48.54, 31.98, 24.32, 19.92, 17.07, 15.08, 13.61, 12.48, 11.58];
			tableauProbaSuited[1][7] = [46.34, 30.38, 23.04, 18.79, 16.03, 14.11, 12.72, 11.63, 10.78];
			tableauProbaSuited[1][6] = [44.13, 28.9, 21.9, 17.89, 15.3, 13.52, 12.21, 11.22, 10.42];
			tableauProbaSuited[1][5] = [43.49, 28.95, 22.14, 18.18, 15.63, 13.88, 12.61, 11.62, 10.83];
			tableauProbaSuited[1][4] = [42.96, 28.91, 22.17, 18.19, 15.64, 13.88, 12.6, 11.6, 10.79];
			tableauProbaSuited[1][3] = [43.37, 29.83, 23.25, 19.41, 16.98, 15.31, 14.09, 13.13, 12.36];
			tableauProbaSuited[1][2] = [42.32, 28.94, 22.42, 18.66, 16.29, 14.67, 13.48, 12.55, 11.79];
			tableauProbaSuited[1][12] = [60.27, 42.07, 32.65, 27.12, 23.51, 20.93, 18.97, 17.41, 16.14];
			tableauProbaSuited[1][11] = [56.27, 38.05, 29.05, 23.86, 20.5, 18.12, 16.32, 14.9, 13.76];
			tableauProbaSuited[1][10] = [53.46, 35.65, 27.09, 22.2, 19.02, 16.77, 15.1, 13.8, 12.75];
			tableauProbaSuited[0][9] = [50.02, 32.82, 24.87, 20.38, 17.48, 15.45, 13.95, 12.78, 11.85];
			tableauProbaSuited[0][8] = [47.68, 31.17, 23.66, 19.39, 16.65, 14.74, 13.34, 12.25, 11.38];
			tableauProbaSuited[0][7] = [45.48, 29.6, 22.41, 18.29, 15.63, 13.79, 12.44, 11.4, 10.57];
			tableauProbaSuited[0][6] = [43.55, 28.37, 21.47, 17.52, 14.99, 13.25, 11.97, 10.99, 10.21];
			tableauProbaSuited[0][5] = [41.61, 27.09, 20.5, 16.74, 14.37, 12.75, 11.58, 10.66, 9.93];
			tableauProbaSuited[0][4] = [41.11, 27.06, 20.48, 16.7, 14.31, 12.65, 11.45, 10.52, 9.77];
			tableauProbaSuited[0][3] = [41.54, 27.97, 21.57, 17.92, 15.63, 14.07, 12.93, 12.04, 11.31];
			tableauProbaSuited[0][2] = [40.52, 27.16, 20.88, 17.33, 15.12, 13.62, 12.53, 11.66, 10.95];
			tableauProbaSuited[0][1] = [39.66, 26.3, 20.1, 16.65, 14.53, 13.07, 12.02, 11.18, 10.48];
			tableauProbaSuited[0][12] = [59.47, 41.24, 31.94, 26.57, 23.06, 20.57, 18.67, 17.15, 15.91];
			tableauProbaSuited[0][11] = [55.43, 37.23, 28.38, 23.31, 20.05, 17.75, 16.01, 14.64, 13.54];
			tableauProbaSuited[0][10] = [52.58, 34.81, 26.42, 21.66, 18.59, 16.42, 14.82, 13.55, 12.54];
			
//pas couleur
			tableauProba[12][12] = [85.54, 73.89, 64.35, 56.43, 49.77, 44.13, 39.32, 35.21, 31.68];
			tableauProba[11][12] = [66.24, 49.4, 39.83, 33.65, 29.21, 25.77, 22.96, 20.6, 18.59];
			tableauProba[11][11] = [82.68, 69.24, 58.63, 50.18, 43.36, 37.83, 33.3, 29.58, 26.49];
			tableauProba[10][12] = [65.44, 48.15, 38.31, 31.98, 27.48, 24.05, 21.29, 19.02, 17.12];
			tableauProba[10][11] = [62.65, 45.8, 36.62, 30.69, 26.42, 23.11, 20.43, 18.24, 16.42];
			tableauProba[10][10] = [80.24, 65.33, 53.95, 45.18, 38.36, 33.01, 28.77, 25.42, 22.72];
			tableauProba[9][12] = [64.69, 47.01, 36.98, 30.58, 26.09, 22.71, 20.04, 17.87, 16.07];
			tableauProba[9][11] = [61.89, 44.67, 35.29, 29.31, 25.05, 21.8, 19.24, 17.16, 15.44];
			tableauProba[9][10] = [59.68, 43.11, 34.28, 28.58, 24.49, 21.35, 18.86, 16.87, 15.25];
			tableauProba[8][12] = [63.99, 45.97, 35.82, 29.41, 24.97, 21.66, 19.09, 17.02, 15.33];
			tableauProba[8][11] = [61.19, 43.66, 34.16, 28.18, 23.97, 20.81, 18.35, 16.38, 14.76];
			tableauProba[8][10] = [58.96, 42.1, 33.17, 27.46, 23.43, 20.38, 18.02, 16.15, 14.64];
			tableauProba[7][12] = [62.21, 43.46, 33.05, 26.63, 22.25, 19.09, 16.66, 14.72, 13.17];
			tableauProba[7][11] = [59.42, 41.13, 31.37, 25.34, 21.19, 18.14, 15.8, 13.95, 12.47];
			tableauProba[7][10] = [57.2, 39.59, 30.39, 24.65, 20.67, 17.73, 15.49, 13.74, 12.34];
			tableauProba[6][12] = [61.5, 42.52, 32.1, 25.72, 21.42, 18.31, 15.95, 14.09, 12.59];
			tableauProba[6][11] = [57.82, 39.02, 29.19, 23.25, 19.27, 16.39, 14.22, 12.53, 11.18];
			tableauProba[6][10] = [55.62, 37.48, 28.19, 22.53, 18.7, 15.92, 13.84, 12.22, 10.95];
			tableauProba[5][12] = [60.66, 41.49, 31.09, 24.8, 20.62, 17.62, 15.35, 13.58, 12.15];
			tableauProba[5][11] = [57.17, 38.21, 28.4, 22.52, 18.61, 15.81, 13.7, 12.07, 10.77];
			tableauProba[5][10] = [53.98, 35.4, 26.13, 20.63, 16.98, 14.39, 12.46, 10.98, 9.83];
			tableauProba[4][12] = [59.49, 40, 29.58, 23.38, 19.3, 16.42, 14.24, 12.55, 11.19];
			tableauProba[4][11] = [56.24, 37.09, 27.27, 21.47, 17.63, 14.9, 12.87, 11.3, 10.05];
			tableauProba[4][10] = [53.27, 34.54, 25.24, 19.76, 16.14, 13.58, 11.7, 10.26, 9.13];
			tableauProba[3][12] = [59.78, 40.69, 30.55, 24.52, 20.55, 17.73, 15.59, 13.9, 12.54];
			tableauProba[3][11] = [55.6, 36.44, 26.76, 21.12, 17.44, 14.84, 12.9, 11.39, 10.19];
			tableauProba[3][10] = [52.64, 33.9, 24.73, 19.41, 15.96, 13.53, 11.74, 10.37, 9.3];
			tableauProba[2][12] = [58.87, 39.69, 29.67, 23.78, 19.93, 17.19, 15.13, 13.51, 12.18];
			tableauProba[2][11] = [54.66, 35.48, 25.93, 20.41, 16.84, 14.33, 12.45, 11, 9.85];
			tableauProba[2][10] = [51.69, 32.93, 23.91, 18.73, 15.37, 13.04, 11.31, 9.99, 8.96];
			tableauProba[1][12] = [57.99, 38.77, 28.86, 23.09, 19.35, 16.71, 14.71, 13.14, 11.87];
			tableauProba[1][11] = [53.74, 34.55, 25.12, 19.74, 16.28, 13.86, 12.05, 10.66, 9.53];
			tableauProba[1][10] = [50.78, 32.04, 23.14, 18.08, 14.83, 12.58, 10.93, 9.65, 8.66];
			tableauProba[9][9] = [77.81, 61.61, 49.67, 40.78, 34.1, 29.05, 25.2, 22.22, 19.91];
			tableauProba[8][9] = [57.12, 41.05, 32.64, 27.2, 23.3, 20.36, 18.08, 16.3, 14.88];
			tableauProba[8][8] = [75.38, 58.06, 45.74, 36.9, 30.51, 25.83, 22.37, 19.79, 17.83];
			tableauProba[7][9] = [55.3, 38.52, 29.86, 24.39, 20.56, 17.74, 15.58, 13.92, 12.61];
			tableauProba[7][8] = [53.79, 37.91, 29.72, 24.46, 20.75, 18.01, 15.96, 14.38, 13.14];
			tableauProba[7][7] = [72.49, 54.12, 41.67, 33.12, 27.17, 22.96, 19.96, 17.75, 16.11];
			tableauProba[6][9] = [53.71, 36.43, 27.68, 22.3, 18.61, 15.93, 13.93, 12.4, 11.2];
			tableauProba[6][8] = [52.17, 35.82, 27.56, 22.4, 18.83, 16.25, 14.34, 12.89, 11.76];
			tableauProba[6][7] = [50.76, 35.14, 27.15, 22.03, 18.48, 15.93, 14.04, 12.6, 11.5];
			tableauProba[6][6] = [69.63, 50.48, 38.14, 30.02, 24.57, 20.85, 18.25, 16.39, 15.03];
			tableauProba[5][9] = [52.1, 34.38, 25.61, 20.35, 16.82, 14.3, 12.44, 11.04, 9.95];
			tableauProba[5][8] = [50.54, 33.75, 25.48, 20.44, 17.03, 14.61, 12.84, 11.5, 10.47];
			tableauProba[5][7] = [49.17, 33.21, 25.24, 20.3, 16.96, 14.58, 12.85, 11.55, 10.55];
			tableauProba[5][6] = [48.12, 32.96, 25.26, 20.41, 17.11, 14.8, 13.12, 11.86, 10.9];
			tableauProba[5][5] = [66.76, 47.04, 34.93, 27.31, 22.39, 19.13, 16.92, 15.34, 14.2];
			tableauProba[4][9] = [50.33, 32.15, 23.42, 18.29, 14.93, 12.57, 10.85, 9.55, 8.54];
			tableauProba[4][8] = [48.79, 31.54, 23.26, 18.33, 15.07, 12.78, 11.11, 9.86, 8.9];
			tableauProba[4][7] = [47.4, 31.02, 23.06, 18.22, 15.02, 12.78, 11.15, 9.94, 9.01];
			tableauProba[4][6] = [46.35, 30.84, 23.16, 18.44, 15.3, 13.12, 11.55, 10.39, 9.49];
			tableauProba[4][5] = [45.52, 30.68, 23.14, 18.45, 15.32, 13.16, 11.6, 10.45, 9.55];
			tableauProba[4][4] = [63.76, 43.6, 31.84, 24.74, 20.31, 17.44, 15.51, 14.16, 13.16];
			tableauProba[3][9] = [49.93, 31.78, 23.12, 18.12, 14.86, 12.6, 10.94, 9.69, 8.72];
			tableauProba[3][8] = [47.21, 29.79, 21.67, 17, 13.97, 11.88, 10.37, 9.24, 8.38];
			tableauProba[3][7] = [45.85, 29.25, 21.43, 16.83, 13.84, 11.76, 10.29, 9.18, 8.33];
			tableauProba[3][6] = [44.82, 29.12, 21.62, 17.14, 14.23, 12.23, 10.81, 9.75, 8.95];
			tableauProba[3][5] = [44.1, 29.2, 21.93, 17.55, 14.71, 12.79, 11.41, 10.4, 9.63];
			tableauProba[3][4] = [43.48, 29.06, 21.81, 17.4, 14.54, 12.59, 11.21, 10.17, 9.37];
			tableauProba[3][3] = [61.03, 40.73, 29.5, 23.01, 19.1, 16.63, 14.98, 13.81, 12.95];
			tableauProba[2][9] = [48.98, 30.85, 22.33, 17.45, 14.3, 12.11, 10.51, 9.33, 8.38];
			tableauProba[2][8] = [46.53, 29.14, 21.08, 16.48, 13.5, 11.45, 9.98, 8.88, 8.04];
			tableauProba[2][7] = [43.92, 27.21, 19.58, 15.18, 12.36, 10.45, 9.08, 8.07, 7.3];
			tableauProba[2][6] = [42.9, 27.06, 19.71, 15.41, 12.65, 10.78, 9.46, 8.48, 7.73];
			tableauProba[2][5] = [42.2, 27.16, 20.02, 15.84, 13.15, 11.35, 10.08, 9.14, 8.42];
			tableauProba[2][4] = [41.63, 27.14, 20.05, 15.86, 13.17, 11.37, 10.08, 9.13, 8.39];
			tableauProba[2][3] = [42.02, 28.03, 21.09, 17.01, 14.43, 12.71, 11.5, 10.58, 9.88];
			tableauProba[2][2] = [57.81, 37.47, 26.91, 21.14, 17.79, 15.73, 14.36, 13.38, 12.63];
			tableauProba[1][9] = [48.06, 29.96, 21.56, 16.8, 13.76, 11.67, 10.14, 8.98, 8.09];
			tableauProba[1][8] = [45.6, 28.24, 20.31, 15.84, 12.97, 11.02, 9.6, 8.55, 7.74];
			tableauProba[1][7] = [43.27, 26.6, 19.02, 14.69, 11.94, 10.06, 8.74, 7.75, 6.99];
			tableauProba[1][6] = [40.94, 25.05, 17.88, 13.8, 11.23, 9.51, 8.29, 7.41, 6.72];
			tableauProba[1][5] = [40.25, 25.12, 18.14, 14.14, 11.61, 9.93, 8.76, 7.89, 7.22];
			tableauProba[1][4] = [39.71, 25.13, 18.21, 14.19, 11.67, 9.98, 8.79, 7.91, 7.22];
			tableauProba[1][3] = [40.14, 26.11, 19.38, 15.51, 13.11, 11.52, 10.4, 9.58, 8.93];
			tableauProba[1][2] = [39.03, 25.16, 18.48, 14.71, 12.38, 10.84, 9.76, 8.96, 8.33];
			tableauProba[1][1] = [54.57, 34.36, 24.59, 19.56, 16.74, 15.03, 13.9, 13.06, 12.39];
			tableauProba[0][12] = [57.14, 37.85, 28.08, 22.47, 18.85, 16.3, 14.38, 12.86, 11.63];
			tableauProba[0][11] = [52.84, 33.64, 24.37, 19.14, 15.8, 13.46, 11.72, 10.38, 9.31];
			tableauProba[0][10] = [49.86, 31.16, 22.38, 17.47, 14.35, 12.19, 10.6, 9.38, 8.43];
			tableauProba[0][9] = [47.15, 29.09, 20.83, 16.22, 13.29, 11.28, 9.82, 8.72, 7.86];
			tableauProba[0][8] = [44.68, 27.38, 19.61, 15.26, 12.52, 10.65, 9.3, 8.3, 7.52];
			tableauProba[0][7] = [42.36, 25.75, 18.31, 14.12, 11.48, 9.71, 8.43, 7.49, 6.77];
			tableauProba[0][6] = [40.3, 24.46, 17.36, 13.37, 10.86, 9.19, 8.02, 7.15, 6.48];
			tableauProba[0][5] = [38.24, 23.12, 16.37, 12.59, 10.27, 8.73, 7.66, 6.87, 6.26];
			tableauProba[0][4] = [37.71, 23.1, 16.37, 12.58, 10.22, 8.66, 7.57, 6.76, 6.14];
			tableauProba[0][3] = [38.18, 24.12, 17.56, 13.89, 11.66, 10.19, 9.16, 8.4, 7.81];
			tableauProba[0][2] = [37.09, 23.25, 16.81, 13.27, 11.13, 9.72, 8.75, 8.02, 7.44];
			tableauProba[0][1] = [36.2, 22.34, 15.99, 12.54, 10.47, 9.14, 8.19, 7.49, 6.93];
			tableauProba[0][0] = [51.32, 31.46, 22.58, 18.29, 15.98, 14.58, 13.62, 12.89, 12.29];
			
			if (firstCard.GetSuit() == secondCard.GetSuit())
			{
				probaPreFlop = tableauProbaSuited[heightFirstCard][heightSecondCard][nombreJoueurs];
			}
			else
			{
				probaPreFlop = tableauProba[heightFirstCard][heightSecondCard][nombreJoueurs];
			}
			
			

			return probaPreFlop;
		
		}
	}

}
