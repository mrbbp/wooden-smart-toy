package com.mrbbp {
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import com.mrbbp.Debug;
	import com.mrbbp.Piece;
	import com.mrbbp.PieceEvent;
	
	public class App extends MovieClip {
		
		private var debug:Debug;
		/***** instancie la classe Piece ******/
		private var piece:Piece;
		// détection du dpi du device (obligatoire pour détection des pièces)
		private var device:Device;
		
		public static var _stage:Stage = null;
		
		public var nbTouch: int = 0;
		// dictionnaire (table) des touch
		public var dPoints: Dictionary = new Dictionary();
		// permet de connaitre le format encours (PORTRAIT ou LANDSCAPE) - mis à jour dans Debug.as
		public var stageOrientation: String;
		
		
		public function App() {
			// constructor code
			addEventListener(Event.ACTIVATE, init);
			addEventListener(Event.DEACTIVATE, iosDeactivateListener);
		}
		
		public function init(e: Event) {
			
			removeEventListener(Event.ACTIVATE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			debug = new Debug(this);
			debug.show(); // show debug textField
			
			// pour Piece();
			_stage = stage;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, addPoint);
			stage.addEventListener(TouchEvent.TOUCH_END, rmPoint);
			// add the PieceEvent Listener
			stage.addEventListener(PieceEvent.PIECE_DETECTED, PieceEventHandler);
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
				
				if (piece != null) {
					piece.Efface();
					piece = null;
				}
				/*********** crée une nouvelle piece **************/
				piece = new Piece(aTouches[0],aTouches[1],aTouches[2]);
				addChild(piece);
			}
		}

		private function rmPoint(t: TouchEvent): void {
			delete dPoints[t.touchPointID];
			nbTouch--;
			if (nbTouch == 0) { // enlève la piece
				if (piece != null) { // evite erreur si pas 3 points > pas de creation de piece
					// efface le dessin de la pièce
					piece.Efface();
					piece = null;
				}
			}
		}
		
		private function iosDeactivateListener(e: Event): void {
			//do something when home button is pressed.

		}
		
		private function PieceEventHandler(pe:PieceEvent):void {
			trace("PieceEvent: id:",pe.id,"- angle:",Math.round(pe.angle*10)/10,(pe.reverse)?"° - pièce inversée":"pièce à l'endroit");
			trace(pe.toString());
			trace(pe.ID);
		}

	}
	
}
