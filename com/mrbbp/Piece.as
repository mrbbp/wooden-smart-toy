﻿package com.mrbbp {
	
	import com.mrbbp.App; // change with your project main.as
	import com.mrbbp.Debug;
	import com.mrbbp.Device;
	
	import flash.geom.Point;
	import utils.geom.*;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.MovieClip;
	
	import flash.system.Capabilities;
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	// for customEvent
	import flash.events.EventDispatcher;
	import com.mrbbp.PieceEvent;
	
	public class Piece extends MovieClip {
		
		private var p0:Point;
		private var p1:Point;
		private var p2:Point;
		
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
		public var ecartBase:Number; 	// écart des points de la base en pixels
		public var rho:Number; 			// distance du point satellite en pixels
		public var theta:Number; 		// angle du point satellite en degrés par rapport au centre de la base
		public var ecartBaseMM:Number; 	// écart des points de la base en mm
		public var rhoMM:Number; 		// distance du point satellite en mm
		public var anglePiece:Number; 	// angle de la piece sur la tablette
		public var pieceInverse:Boolean;// si pièce sens inversé

		// tablet model (for screendpi)
		private var _device:Device;
		
		// pour le dessin de la piece en mode debug - for drawing Piece in debugMode
		private var diamTrace:int;
		private var epTrace:int;
		private var aCoulTrace: Array = new Array("0xeeeeee", "0xaaaaaa", "0x666666", "0x222222");
		private var _debug:Boolean;
		private var INVERSE:Boolean = false;
		private var piece:Shape;
		
		// inclinaison des patterns sur la pièce
		private var tAlpha:Array = new Array(0,35,0,-15,-35,0,0,-7,0,-20); 
		
		public function Piece(_p0:Point, _p1:Point, _p2:Point, debug:Boolean = false) {
			p0 = _p0;
			p1 = _p1;
			p2 = _p2;
			_debug = debug;
			addEventListener ( Event.ADDED_TO_STAGE, activePiece );
		}
		
		private function activePiece(evt:Event):void {
			
			removeEventListener ( Event.ADDED_TO_STAGE, activePiece );
			
			_device = new Device(stage);
			var plusGrandeDim:int;
			
			if (flash.system.Capabilities.screenResolutionY > flash.system.Capabilities.screenResolutionX) {
				plusGrandeDim = flash.system.Capabilities.screenResolutionY;
			} else {
				plusGrandeDim = flash.system.Capabilities.screenResolutionX;
			}
			
			
			// drawing purpose depend of retina display or not
			if (flash.system.Capabilities.screenDPI < 150 || plusGrandeDim < 1300) {
				diamTrace = 25;
				epTrace = 2;
			} else {
				diamTrace = 50;
				epTrace = 4;
			}
			
			// create a shape and add to stage
			piece = new Shape();
			stage.addChild(piece);
			
			piece.x = stage.stageWidth / 4; // au quart de l'écran
			piece.y = (2* stage.stageHeight) / 3;
			
			// looking for the Base's Points by looking for smallest distance.
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
			stage.removeChild(piece);
			piece = null;
		}
		
		private function rotatePI(point:Point, centerPoint:Point):void{
			var baseX:Number = point.x - centerPoint.x;
			var baseY:Number = point.y - centerPoint.y;

			point.x = (Math.cos(Math.PI) * baseX) - (Math.sin(Math.PI) * baseY) + centerPoint.x;
			point.y = (Math.sin(Math.PI) * baseX) + (Math.cos(Math.PI) * baseY) + centerPoint.y;
		}
		
		private function IdPiece():int {
			// only usefull for Marbotic Wooden Pieces // Smarts Numbers
			//	rhoMM, theta
			if (rhoMM > 40) { // 42,46
				if (rhoMM > 44) { // 46: 9,6
					if ( theta < 90) {// 6
						idPiece = 6;
					} else { // 9
						idPiece = 9;
						pieceInverse = !pieceInverse;
					}
				} else { // 42: 2,5,7
					if (theta > 100) {
						idPiece = 2;
					}
					if (theta <= 100 && theta > 80) {
						idPiece = 5;
						pieceInverse = !pieceInverse;
					}
					if (theta <= 80) {
						idPiece = 7;
						pieceInverse = !pieceInverse;
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
						pieceInverse = !pieceInverse;
					}
				} else { // 38: 3,8
					if ( theta < 90) {
						idPiece = 8;
					} else { 
						idPiece = 3;
					}
				}
				
			}
			// trace Piece Number
			return idPiece
		}
		
		private function RhoTheta():void {
			//calcul le point median Base (.5)
			// find Base midpoint
			pBCentre = Point.interpolate(pB1, pB2, .5);

			//point Satellite en bas
			// if Sat Point is lower than base
			if (pS.y > pB1.y) {  
				// il faut retourner la piece
				rotatePI(pB1, pBCentre);
				rotatePI(pB2, pBCentre);
				rotatePI(pSat, pBCentre);
				INVERSE = pieceInverse = true;
			}
			
			// décale les points de la Base avec 0,0 de Flash comme origine pour le calcul en polaire
			if (pB1.x <= pB2.x) {
				// p1 Base Left Point, p2 Base Right Point
				pBaseG.setTo(pB1.x - pBCentre.x, (pB1.y - pBCentre.y) * 1);
				pBaseD.setTo(pB2.x - pBCentre.x, (pB2.y - pBCentre.y) * 1);
			} else {
				//p1 Base Right Point, p2 Base Left Point
				pBaseG.setTo(pB2.x - pBCentre.x, (pB2.y - pBCentre.y) * 1);
				pBaseD.setTo(pB1.x - pBCentre.x, (pB1.y - pBCentre.y) * 1);
			}

			// déplace pSat sur nouveau repere
			// translate pSat point to new Origine
			pSat.setTo(pS.x - pBCentre.x, (pS.y - pBCentre.y) * 1);
			// move pCentre to 0,0
			pBCentre.setTo(0, 0);
			
			// inclinaison de la piece sur la tablette
			var angle:Number = Math.atan2(pBaseD.y, pBaseD.x);
			anglePiece = angle * (180/Math.PI);

			// tourne la pièce et la remet "droite"
			var pBgTemp: Point = new Point(Math.cos(-angle) * pBaseG.x - Math.sin(-angle) * pBaseG.y, Math.sin(-angle) * pBaseG.x + Math.cos(-angle) * pBaseG.y);
			var pBdTemp: Point = new Point(Math.cos(-angle) * pBaseD.x - Math.sin(-angle) * pBaseD.y, Math.sin(-angle) * pBaseD.x + Math.cos(-angle) * pBaseD.y);
			var pSatTemp: Point = new Point(Math.cos(-angle) * pSat.x - Math.sin(-angle) * pSat.y, Math.sin(-angle) * pSat.x + Math.cos(-angle) * pSat.y);

			// update Points coordinates
			pBaseG.setTo(pBgTemp.x, pBgTemp.y); // pour controle
			pBaseD.setTo(pBdTemp.x, pBdTemp.y); // pour controle
			// IMPORTANT
			pSat.setTo(pSatTemp.x, pSatTemp.y);
			
			// If Piece is reverse, it return it
			if (INVERSE) {
				rotatePI(pBaseG, pBCentre);
				rotatePI(pBaseD, pBCentre);
				rotatePI(pSat, pBCentre);
			}
			
			// dessine le resultat du calcul dans la première moitié de l'écran
			// draw detected piece in half left part of the screen
			if (_debug) {
				Dessine();
			}

			// calcul de coordonnée polaires du point satellite
			// polar coordinates
			var pPSat: Array = cartesianToPolarCoordinates(pSat.x, pSat.y);

			// pour obtenir l'angle à l'endroit (au dessus)
			pPSat[1] = 360 - pPSat[1];
			
			// create public var result
			rho = pPSat[0];
			// Distance in millimeters
			rhoMM = Math.round((pPSat[0]/_device._1mm)*10)/10;
			// Angle in Degres
			theta = Math.round(pPSat[1]*10)/10;
			// base gap
			ecartBaseMM = Math.round(ecartBase/_device._1mm);
			
			// add some debug trace
			//trace("angle de la pièce:",anglePiece, (pieceInverse) ?"piece inversée":"pièce droite");
			//trace("point satellite - ecartBase:",ecartBaseMM,"mm - RHO:",rhoMM,"mm - THETA:",theta,"°");

			// Identify Piece for Marbotic wooden pieces			
			idPiece = IdPiece();
			//trace("Piece Number:",idTemp);
			
			// dispatch PieceEvent
			stage.dispatchEvent(new PieceEvent(PieceEvent.PIECE_DETECTED, idPiece , anglePiece, pieceInverse, rhoMM, theta, tAlpha[idPiece], ecartBaseMM));
		}

	}
	
}
