package com.mrbbp {
	
	import com.mrbbp.App;
	import com.mrbbp.Debug;
	import flash.geom.Point;
	import utils.geom.*;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.MovieClip;
	
	import flash.system.Capabilities;
	import flash.display.Stage;
	import flash.display.DisplayObject;
	
	public class Piece extends MovieClip {
		
		
		private var pBaseG:Point = new Point();
		private var pBaseD:Point = new Point();
		private var pSat:Point = new Point();
		public var pBCentre:Point;
		
		// point en interne pour calcul
		private var pB1:Point;
		private var pB2:Point;
		private var pS:Point;
		
		// numero piece detectée
		public var idPiece:int = 99;
		
		// valeur accessibles
		public var ecartBase:Number;
		public var rho:Number;
		public var theta:Number;
		public var ecartBaseMM:Number;
		public var rhoMM:Number;

		// stage et le model de tablette (pour les dpi)
		private static var _racine:*;
		private var _device:Device;
		
		private var aEcartBase:Array = new Array();
		
		// pour le dessin de la piece en mode debug
		private var diamTrace:int;
		private var epTrace:int;
		private var aCoulTrace: Array = new Array("0xeeeeee", "0xaaaaaa", "0x666666", "0x222222");
		private var _debug:Boolean = false;
		private var INVERSE:Boolean = false;
		private var piece:Shape;
		private var numPiece:Shape;
		public var reperePiece:ReperePiece;
		public var objNumPiece:NumPiece;
		
		/*
		init(p0,p1,p2);
		- Dessine(); -> points detectés
		- Debug(); -> dessin pièces après réorientation
		- RhoTheta();
		- Stats();
		*/
		
		public function Piece(p0:Point, p1:Point, p2:Point, racine:*, device:Device, debug:Boolean = false) {
			
			_device = device;
			_debug = debug;
			
			if (flash.system.Capabilities.screenDPI < 150) {
				diamTrace = 25;
				epTrace = 2;
			} else {
				diamTrace = 50;
				epTrace = 4;
			}
			
			
			//trace("réf:",this,App._stage,MovieClip(_racine));
			
			 //App._stage = Stage;
			_racine = racine;
			
			// test de gestion de l'affichage dans la classe
			piece = new Shape();
			_racine.addChild(piece);
			
			piece.x = App._stage.stageWidth / 4; // au quart de l'écran
			piece.y = 2*App._stage.stageHeight / 3;
			
			if (debug ) {      // && !App._stage.(reperePiece as Shape)
				reperePiece = new ReperePiece();
				objNumPiece = new NumPiece();
				//App._stage.addChild(reperePiece);
				_racine.addChild(reperePiece);
				_racine.addChild(objNumPiece);
				// gere la taille du picto
				if (flash.system.Capabilities.screenDPI > 150) {
					reperePiece.scaleX = reperePiece.scaleY = 2;
					objNumPiece.scaleX = objNumPiece.scaleY = 2;
				}
				// le positionne correctement
				reperePiece.x = App._stage.stageWidth - 20 - reperePiece.width/2;
				reperePiece.y = reperePiece.height/2 + 20;
				objNumPiece.x = App._stage.stageWidth/4;
				objNumPiece.y = App._stage.stageHeight/2;
			}
			
			// constructor code
			//trace("touche à ton cul:", p0,p1,p2);
			var d0: Number = Point.distance(p0, p1);
			var d1: Number = Point.distance(p1, p2);
			var d2: Number = Point.distance(p2, p0);

			if (d0 < d1) {
				if (d0 < d2) {
					// [d0] est le plus petit
					ecartBase = d0;
					pB1 = p0;
					pB2 = p1;
					pS = p2;
				} else {
					if (d2 < d1) {
						// [d2] est le plus petit
						ecartBase = d2;
						pB1 = p2;
						pB2 = p0;
						pS = p1;
					} else {
						// [d1] est le plus petit
						ecartBase = d1;
						pB1 = p1;
						pB2 = p2;
						pS = p0;
					}
				}
			} else {
				if (d2 < d1) {
					// [d2]
					ecartBase = d2;
					pB1 = p2;
					pB2 = p0;
					pS = p1;
				} else {
					// [d1]
					ecartBase = d1;
					pB1 = p1;
					pB2 = p2;
					pS = p0;
				}
			}
			// calcule Rho et Theta
			RhoTheta();
		}
		
		private function Dessine():void {
			piece.graphics.clear();
			piece.graphics.lineStyle(epTrace, 0xff0000); // rouge
			piece.graphics.drawCircle(pBaseG.x, pBaseG.y, diamTrace);
			piece.graphics.lineStyle(epTrace, 0x00ff00); // vert
			piece.graphics.drawCircle(pBaseD.x, pBaseD.y, diamTrace);
			piece.graphics.lineStyle(epTrace, 0x0000ff); // bleu
			piece.graphics.drawCircle(pSat.x, pSat.y, diamTrace);
			piece.graphics.lineStyle(epTrace/1.5, 0x808080); // gris
			piece.graphics.drawCircle(pBCentre.x, pBCentre.y, diamTrace / 2);
		}
		
		public function Efface():void {
			//piece.graphics.clear();
			_racine.removeChild(piece);
			_racine.removeChild(reperePiece);
			_racine.removeChild(objNumPiece);
			piece = null;
			reperePiece = null;
			//reperePiece.visible = false;
		}
		
		private function rotatePI(point:Point, centerPoint:Point):void{
			var baseX:Number = point.x - centerPoint.x;
			var baseY:Number = point.y - centerPoint.y;

			point.x = (Math.cos(Math.PI) * baseX) - (Math.sin(Math.PI) * baseY) + centerPoint.x;
			point.y = (Math.sin(Math.PI) * baseX) + (Math.cos(Math.PI) * baseY) + centerPoint.y;
		}
		
		private function RhoTheta():void {
			//calcul le point median Base (.5)
			pBCentre = Point.interpolate(pB1, pB2, .5);

			//point Satellite en bas
			if (pS.y > pB1.y) {  
				// il faut retourner la piece
				rotatePI(pB1, pBCentre);
				rotatePI(pB2, pBCentre);
				rotatePI(pSat, pBCentre);
				INVERSE = true;
				//trace("base inversée");
				if (_debug) {
					reperePiece.rotation = 180;
				}
			} else {
				if (_debug) {
					reperePiece.rotation = 0;
				}
			}
			
			// décale les points de la Base avec 0,0 de Flash comme origine pour le calcul en polaire
			if (pB1.x <= pB2.x) {
				// p1 Base Gauche, p2 Base Droit
				pBaseG.setTo(pB1.x - pBCentre.x, (pB1.y - pBCentre.y) * 1);
				pBaseD.setTo(pB2.x - pBCentre.x, (pB2.y - pBCentre.y) * 1);
			} else {
				//p1 Base Droit, p2 Base Gauche
				pBaseG.setTo(pB2.x - pBCentre.x, (pB2.y - pBCentre.y) * 1);
				pBaseD.setTo(pB1.x - pBCentre.x, (pB1.y - pBCentre.y) * 1);
			}

			// déplace pSat sur nouveau repere
			pSat.setTo(pS.x - pBCentre.x, (pS.y - pBCentre.y) * 1);
			// place pCentre en 0,0
			pBCentre.setTo(0, 0);
			
			// inclinaison de la piece sur la tablette
			var angle: Number = Math.atan2(pBaseD.y, pBaseD.x);

			// tourne la pièce et la remet "droite"
			var pBgTemp: Point = new Point(Math.cos(-angle) * pBaseG.x - Math.sin(-angle) * pBaseG.y, Math.sin(-angle) * pBaseG.x + Math.cos(-angle) * pBaseG.y);
			var pBdTemp: Point = new Point(Math.cos(-angle) * pBaseD.x - Math.sin(-angle) * pBaseD.y, Math.sin(-angle) * pBaseD.x + Math.cos(-angle) * pBaseD.y);
			var pSatTemp: Point = new Point(Math.cos(-angle) * pSat.x - Math.sin(-angle) * pSat.y, Math.sin(-angle) * pSat.x + Math.cos(-angle) * pSat.y);

			// met à jour les points
			pBaseG.setTo(pBgTemp.x, pBgTemp.y); // pour controle
			pBaseD.setTo(pBdTemp.x, pBdTemp.y); // pour controle
			// IMPORTANT
			pSat.setTo(pSatTemp.x, pSatTemp.y);
			
			// si piece à l'envers, on la retourne pour la dessiner
			if (INVERSE) {
				rotatePI(pBaseG, pBCentre);
				rotatePI(pBaseD, pBCentre);
				rotatePI(pSat, pBCentre);
			}
			
			// dessine le resultat du calcul dans la premeière moitié de l'écran
			//(racine as MovieClip).dessinePiece(pBaseG,pBaseD,pSat,pBCentre);
			if (_debug) {
				Dessine();
			}

			// calcul de coordonnée polaires du point satellite
			var pPSat: Array = cartesianToPolarCoordinates(pSat.x, pSat.y);

			// pour obtenir l'angle à l'endroit (au dessus)
			pPSat[1] = 360 - pPSat[1];
			
			// remplit les bases de stats
			rho = pPSat[0];
			rhoMM = Math.round((pPSat[0]/_device._1mm)*10)/10;
			theta = Math.round(pPSat[1]*10)/10;
			ecartBaseMM = Math.round(ecartBase/_device._1mm);
			
			trace("point satellite - ecartBase:",ecartBaseMM,"mm RHO: ",rhoMM,"mm - THETA: ",theta,"°");

			IdPiece();
			
		}
		
		private function IdPiece():void {
			//	rhoMM, theta
			if (rhoMM > 40) { // 42,46
				if (rhoMM > 44) { // 46: 9,6
					if ( theta < 90) {// 6
						idPiece = 6;
					} else { // 9
						idPiece = 9;
					}
				} else { // 42: 2,5,7
					if (theta > 100) {
						idPiece = 2;
					}
					if (theta <= 100 && theta > 80) {
						idPiece = 5;
					}
					if (theta <= 80) {
						idPiece = 7;
					}
				}
			} else { //38,34
				if (rhoMM <=36) { // 34: 0,1,4
					if (theta > 100) {
						idPiece = 4;
					}
					if (theta <= 100 && theta > 80) {
						idPiece = 0;
					}
					if (theta <= 80) {
						idPiece = 1;
					}
				} else { // 38: 3,8
					if ( theta < 90) {
						idPiece = 8;
					} else { 
						idPiece = 3;
					}
				}
				
			}
			trace("Num Pièce:",idPiece);
			objNumPiece.tChiffre.text = String(idPiece);
		}
	}
	
}
