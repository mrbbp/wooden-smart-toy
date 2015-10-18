package com.mrbbp {
	
	/*
	Permet d'identifier le type de tablette en fonction des données fournies par les flash.system.capabilities + une table d'info techniques justes (DPI, dimension écran)
	
	MàJ 18/10/15:
		- ajout d'une gestion d'android pour les devices. sous android Capabilities.screenDPI semble fiable -> détection des pieces possible
	
	
	*/
	
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	public class Device {
		
			
		public var _1mm:Number;
		public var DPI:int;
		
		private var _resX:int;
		private var _resY:int;
		private var _model:String;
		
		private var oScreenDPI:Object = {"iPad1,1":132,"iPad2,1":132,"iPad2,2":132,"iPad2,3":132,"iPad2,4":132,"iPad2,5":163,"iPad2,6":163,"iPad2,7":163,"iPad3,1":264,"iPad3,2":264,"iPad3,3":264,"iPad3,4":264,"iPad3,5":264,"iPad3,6":264,"iPad4,1":264,"iPad4,2":264,"iPad4,3":264,"iPad4,4":326,"iPad4,5":326,"iPad4,6":326,"iPad4,7":326,"iPad4,8":326,"iPad4,9":326,"iPad5,1":326,"iPad5,2":326,"iPad5,3":264,"iPad5,4":264};
		private var oScreenSize:Object = {
		"iPad1,1":9.7,
		"iPad2,1":9.7,
		"iPad2,2":9.7,
		"iPad2,3":9.7,
		"iPad2,4":9.7,
		"iPad2,5":7.9,
		"iPad2,6":7.9,
		"iPad2,7":7.9,
		"iPad3,1":9.7,
		"iPad3,2":9.7,
		"iPad3,3":9.7,
		"iPad3,4":9.7,
		"iPad3,5":9.7,
		"iPad3,6":9.7,
		"iPad4,1":9.7,
		"iPad4,2":9.7,
		"iPad4,3":9.7,
		"iPad4,4":7.9,
		"iPad4,5":7.9,
		"iPad4,6":7.9,
		"iPad4,7":7.9,
		"iPad4,8":7.9,
		"iPad4,9":7.9,
		"iPad5,1":7.9,
		"iPad5,2":7.9,
		"iPad5,3":9.7,
		"iPad5,4":9.7
	};


		public function Device(_app:*) {
			// constructor code
			_resX = flash.system.Capabilities.screenResolutionX;
			_resY = flash.system.Capabilities.screenResolutionY;
			_model = flash.system.Capabilities.os.split(" ")[3];
			if (flash.system.Capabilities.version.split(" ")[0].toUpperCase() == "IOS") { // sous IOS
				if (_model != null) {
					_1mm = oScreenDPI[_model]/25.4;
					trace("sous IOS");
					trace("Device:",_model,oScreenDPI[_model],oScreenSize[_model],_1mm);
					DPI = oScreenDPI[_model];
				}
			} else if (flash.system.Capabilities.version.split(" ")[0] == "AND") { // sous Android
				trace("sous Android");
				_1mm = flash.system.Capabilities.screenDPI/25.4;
				DPI = flash.system.Capabilities.screenDPI;
			}  else {
				trace("pas sous ios");
				_1mm = flash.system.Capabilities.screenDPI/25.4;
				DPI = flash.system.Capabilities.screenDPI;
			}
		}
		
		public function Calcule1mm() {
			return (_1mm);
		}
		
		public function Calcule1cm() {
			return (_1mm*10);
		}

	}
	
}
