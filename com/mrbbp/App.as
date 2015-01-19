package com.mrbbp {

	import com.mrbbp.Debug;
	import com.mrbbp.EnvoieDatas;
	import com.mrbbp.Device;
	import com.mrbbp.Piece;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getTimer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;


	import flash.net.URLVariables;
	import flash.display.DisplayObject;

	public class App extends MovieClip {

		private var debug:Debug;
		/***** instancie la classe Piece ******/
		private var piece:Piece;
		// détection du device - ios uniquement
		private var device:Device;
		// pour les stats
		public var datasBdd:EnvoieDatas;
		
		
		public static var _stage:Stage = null;
		//public static var _root:root = null;

		/*****************************************
			Versions du programme à implémenter
		******************************************/
		public var MajorVersion: String = "0";
		public var MinorVersion: String = "035";
		private var NbrEchantillons: int = 50;
		/*****************************************/

		/*
		v028: 
			- les pièces sont détectées et tournées pour avoir la base horizontale. base en bas, point satellite en haut.
			- TODO: pb de détection parfois les points de la base sont incohérents ("fake") sur les recalculs (bons en détection - "sac") quand la pièce est à l'envers...
			- la recopie et le fake (après recalcule et stabilisation) sont affichés dans la partie gauche de l'écran
			- rho et theta sont cohérents et stables (légère variation à la détection
			- EnvoieDatas implémenté en partie mais pas testé. Manque les rho et theta mis dans une table
		v029: 
			- un peu de clean du code et changement de noms de méthodes (plus explicites)
			- ajout de commentaires
			- aRho, aTheta -> table avec les détections de pièces : pour EnvoieStats() -> fait
			- TODO: 
				faire une classe pour la détection des pièces avec un objet 
				"Piece":
					- les 3 points détectés: p0,p1,p2 (points bruts)
					- ecartBase = (null à l'init)
					- Rho = (null à l'init)
					- Theta : (null à l'init)
				avec les méthodes:
					- var truc:Piece = new Piece(p0,p1,p2);
					non - Dessine(); -> points detectés
					non - Debug(); -> dessin pièces après réorientation
					ok - CalculeRhoTheta();
					non- Stats();
		v030:
			- ajout de la classe Piece
				- CALCULE de RHO & THETA
				- ça ne dessine pas (pb d'accès au stage ou Piece est un displayObject qu'on place sur le stage et qui alors peus'afficher...
				 est-ce important?
				- quand piece retirée de l'écran, aTheta, aho et aEcartBase complétées avec la pièce
				- quand 100 touch collectés -> envoie dans la base
		v031:
			- gestion du sendAndLoad
			- TODO:
				-  Pas de réponse de la page php après envoie...
		v032:
			- récup de la réponse de la page php (envoie vers la bdd)
			- ajout de la classe Device (liste des model iPad avec résolution et DPI Réel;
			- rhoMM et ecartBaseMM sont en mm grâce à Device (dpi réel)
			- bdd utilise des valeurs arrondies (1 ch ap virgule)
			- bdd utilise rhoMM et ecartBaseMM
			- ajout de NbrEchantillons (pour remplir la bdd)
			- bloque le remplissage des tables de stats à la premiere pose de piece quand les tables sont vides (quand on enchaine les pieces sur la tablette ap envoie)
			- test nbr echantillon plus correct pour envoie bdd
			TODO:
			- retourner la pièce si elle est à l'envers (base en bas) pour eviter les problemes de calcul du point satellite
		v033:
			- retourne la piece si elle est à l'envers (pb de detection avec atan2)
		v034:
			l'affichage de la piece est pris en charge par la classe Piece
				- new Piece(p0,p1,p2, racine:stage, device:Device, Debug:Boolean);
				- Efface();
			l'affichage du picto aussi
		v035:
			- IdPiece() et idPiece dans Piece. trace(idPiece);
			// le nbr d'enfants grandit à chaque pose de piece risque de plantage après longue utilisation
		*/

		// permet de connaitre le format encours (PORTRAIT ou LANDSCAPE) - mis à jour dans Debug.as
		public var stageOrientation: String;

		public function App() {

			if (Capabilities.cpuArchitecture == "ARM") {
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, AndroidActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, AndroidDeactivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, AndroidKeys, false, 0, true);
			}
			addEventListener(Event.ACTIVATE, iosActivateListener);
			addEventListener(Event.DEACTIVATE, iosDeactivateListener);


		}
		

		public var nbTouch: int = 0;
		// dictionnaire (table) des touch
		public var dPoints: Dictionary = new Dictionary();
		// sac pour le dessin des traces de touch
		private var sac: Sprite = new Sprite();
		private var diamTrace: int;
		private var epTrace: int;
		private var aCoulTrace: Array = new Array("0xeeeeee", "0xaaaaaa", "0x666666", "0x222222"); //new Array("0xff0000","0x00ff00","0x0000ff","0xffff00","0x00ffff","0xff00ff");

		// tables + vars pour envoie des stats en ligne
		private var aEcartBase: Array = new Array();
		private var aRho: Array = new Array();
		private var aTheta: Array = new Array();
		private var nbrPieces:int;
		private var numPieceEncours: int = 0;
		
		// permet de ne pas remplir les tables à la première pose de piece
		private var bPremierePiece:Boolean = false;

		/*********************************************
				FONCTION d'initialisation
		*********************************************/
		public function init() {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			debug = new Debug(this);
			debug.enabled = true;
			//debug.hide();
			
			// instancie le device (DPI ecran -> mm)
			device = new Device(this);
			
			// instancie l'objet 
			datasBdd = new EnvoieDatas();
			
			// pour Piece();
			_stage = stage;

			debug.write("version player: " + flash.system.Capabilities.version +
				"\nscreenResolutionX: " + String(flash.system.Capabilities.screenResolutionX) + " | " +
				"screenResolutionY: " + String(flash.system.Capabilities.screenResolutionY) +
				"\nCPU: " + flash.system.Capabilities.cpuArchitecture +
				" | OS: " + flash.system.Capabilities.os +
				"\nStage: " + stage.stageWidth + " x " + stage.stageHeight +
				" | ScreenDPI: " + flash.system.Capabilities.screenDPI +
				" | DPI réel: "+ device.DPI+
				"\nstageOrientation :" + stageOrientation +
				"\n"
			);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, addPoint);
			stage.addEventListener(TouchEvent.TOUCH_END, rmPoint);
			
			// dessine une barre d'1cm (10mm) sur l'écran
			stage.addChild(sac);
			sac.graphics.clear();
			sac.graphics.beginFill(0xeeeeee);
			sac.graphics.drawRect(20,20, device.Calcule1cm(), 10);
		}

		/*********************************************
					gestion des Touch
		*********************************************/
		private function addPoint(t: TouchEvent): void {
			nbTouch++;
			dPoints[t.touchPointID] = new Point(t.stageX, t.stageY);
			if (nbTouch >= 3) {
				var aTouches: Array = new Array();
				for (var pt in dPoints) {
					aTouches.push(dPoints[pt]);
				}
				/*********** crée une nouvelle piece **************/
				if (piece != null) {
					piece.Efface();
					piece = null;
				}
				piece = new Piece(aTouches[0],aTouches[1],aTouches[2], this, device, true);
				addChild(piece);
				//trace("NUmChildren:",this.numChildren);
				// le nbr d'enfants grandit à chaque pose de piece risque de plantage après longue utilisation
			}
		}

		private function rmPoint(t: TouchEvent): void {
			delete dPoints[t.touchPointID];
			nbTouch--;
			// enlever les fonctions de dessin dans dessinePoints si pas de dessin
			//dessinePoints();
			if (nbTouch == 0) { // enlève la piece
				// remplit la table pour les stats
				if (piece != null) { // evite erreur si pas 3 points > pas de creation de piece
					// remplit les tables avec valeurs détectées
					if (piece.ecartBaseMM != 0 && piece.rhoMM !=0 && !bPremierePiece) { // evite de remplir les tables avec des valeurs impossibles
						aEcartBase.push(piece.ecartBaseMM);
						aRho.push(piece.rhoMM);
						aTheta.push(piece.theta);
						// efface le dessin de la pièce
						piece.Efface();
						bPremierePiece = false;
						piece.reperePiece = null;
						piece = null;
						
					}
					bPremierePiece = false; // permet de ne pas remplir les tables à la première pose de piece
					if (aEcartBase.length >= NbrEchantillons) {
						/********************/
							//EnvoieStats();
						/********************/
						// reset tables
						aEcartBase = new Array();
						aRho = new Array();
						aTheta = new Array();
						bPremierePiece = true;
						//envoie des infos dans la bdd
					}
				}
			}
		}

		private function EnvoieStats(): void {
			//trace("EnvoieStats()");
			var variables: URLVariables = new URLVariables();
			variables.Model = flash.system.Capabilities.os.split(" ")[3];
			variables.DPI = device.DPI;//flash.system.Capabilities.screenDPI;
			variables.ResX = flash.system.Capabilities.screenResolutionX;
			variables.ResY = flash.system.Capabilities.screenResolutionY;
			variables.NumPiece = numPieceEncours;
			variables.nbrEch = aEcartBase.length;
			variables.ecartBase = "(" + aEcartBase.join(",") + ")";
			variables.distSat = "(" + aRho.join(",") + ")";
			variables.anglSat = "(" + aTheta.join(",") + ")";
			trace("variables:", variables.toString());
			debug.write("envoie de l'échantillon dans la base\n");
			// envoie
			datasBdd.EnvoieStats(variables);
		}
		/*********************************************************
			pour quitter sous android proprement l'application
		/*********************************************************/
		private function AndroidActivate(event: Event): void {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}

		private function AndroidDeactivate(event: Event): void {
			NativeApplication.nativeApplication.exit();
		}

		private function AndroidKeys(event: KeyboardEvent): void {
			if (event.keyCode == Keyboard.BACK) {
				NativeApplication.nativeApplication.exit();
			}
		}

		/* à l'activation ou la désactivation */
		private function iosActivateListener(e: Event): void {
			if (!debug) {
				init();
			}
		}

		private function iosDeactivateListener(e: Event): void {
			//do something when home button is pressed.

		}
	}

}