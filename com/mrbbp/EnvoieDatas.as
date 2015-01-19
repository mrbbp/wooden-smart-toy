package com.mrbbp {
	
	import flash.events.*
	import flash.net.*;
	
	public class EnvoieDatas {

		public function EnvoieDatas() {
			// constructor code
		}
		
		public function EnvoieStats(_vars:URLVariables):void {
			var url:String = "http://www.faisonscourt.fr/stats/insert.php";
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);
		}
		private function handleComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			trace("reponse php:" + loader.data);
			//trace("Message: " + loader.data.msg);
		}
		private function onIOError(event:IOErrorEvent):void {
			trace("Error loading URL.");
		}

	}
	
}
