package com.mrbbp {
	
	import flash.events.Event;
	/**
	 * Used for dispatching events from the Marbotic Smart Number lib. <br /><br />
	 * 	  
	 * @author mrbbp, eric@mrbbp.com
	 */
	
	public class PieceEvent extends Event {
		/** @private **/
		public static const VERSION:Number = 1.0;
		public static const PIECE_DETECTED:String = "pieceDetected";
		
		// this is the object you want to pass through your event.
		public var id:Number; 			// id of the smart_toy
		public var angle:Number;		// angle of the smart_toy (the tactil pattern pod) on the screen
		public var reverse:Boolean;		// is the smart_toy is up side down
		public var rho:Number;			// is the satellite point's distance(in millimeters) detected
		public var theta:Number;		// is the satellite point's angle from the base (in degres) detected
		public var baseWidth:Number;	// the width of base (in millimeters) detected
		public var alpha:Number;		// initial orientation of the pattern on the piece
		
		public function PieceEvent(type:String, idPiece:Number, anglePiece:Number, pieceInverse:Boolean, pieceRho:Number, pieceTheta:Number, baseAlpha:Number, baseEcart:Number, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.id = idPiece;
			this.angle = anglePiece;
			this.reverse = pieceInverse;
			this.theta = pieceTheta;
			this.rho = pieceRho;
			this.baseWidth = baseEcart;
			this.alpha = baseAlpha;
		}
		
		// useless
		public function get ID():Number {
			return this.id;
		}

		override public function clone():Event { 
			return new PieceEvent(this.type, this.id, this.angle, this.reverse, this.rho, this.theta, this.alpha, this.baseWidth, this.bubbles, this.cancelable);
		}
		
		override public function toString():String {
			return formatToString("Piece", "type", "rho", "theta", "baseWidth", "id", "angle", "alpha", "reverse");
		}
	}
}