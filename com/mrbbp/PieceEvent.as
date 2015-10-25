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
		
		public function PieceEvent(type:String, idPiece:Number, anglePiece:Number, pieceInverse:Boolean , bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.id = idPiece;
			this.angle = anglePiece;
			this.reverse = pieceInverse
		}
		
		// useless
		public function get ID():Number {
			return this.id;
		}

		override public function clone():Event { 
			return new PieceEvent(this.type, this.id, this.angle, this.reverse, this.bubbles, this.cancelable);
		}
		
		override public function toString():String {
			return formatToString("Piece", "type", "id", "angle", "reverse");
		}
	}
}