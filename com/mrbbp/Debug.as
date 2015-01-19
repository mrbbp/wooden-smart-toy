package com.mrbbp {

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.system.Capabilities;
	import flash.events.StageOrientationEvent;

	public class Debug {

		public var parent: App;
		public var debugField: TextField;
		public var dTF: TextFormat;
		public var enabled: Boolean;

		public function Debug(lApp: App) :void {
			// constructor code
			dTF = new TextFormat();
			parent = lApp;
			dTF.color = "0xFFFF11";
			dTF.font = "verdana";

			debugField = new TextField();
			// si ajouté à la display liste, il connait stage
			lApp.addChild(debugField);
			debugField.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, updateDebug);

			debugField.width = debugField.stage.stageWidth/2 - 20;
			
			debugField.stage.stageWidth >= debugField.stage.stageHeight ? parent.stageOrientation ="LANDSCAPE" : parent.stageOrientation="PORTRAIT";
			
			// mesure DPI pour lisibilité
			if (flash.system.Capabilities.screenDPI > 150) {
				dTF.size = 18;
				debugField.y = 50;
				debugField.height = (debugField.stage.stageHeight/2) - 60;
			} else {
				dTF.size = 9;
				debugField.y = 30;
				debugField.height = (debugField.stage.stageHeight/2) - 40;
			}
			//if (debugField.stage.stageWidth > 1280) {dTF.size = 18;}else{dTF.size = 9;}
			debugField.defaultTextFormat = dTF;
			debugField.x = 10;
			
			debugField.selectable = false;
			debugField.border = true;
			debugField.borderColor = 0x333333;
			debugField.name = "tDebug";
			debugField.wordWrap = true;
			debugField.multiline = true;
			debugField.mouseEnabled = false;
			clear();
			debugField.text = "version: " + lApp.MajorVersion + "." + lApp.MinorVersion + "\n";
		}

		public function write(text: String): void {
			if (!enabled) return;
			debugField.appendText(text);
		}
		
		public function update(m1:String, m2:String):void {
			if (!enabled) return;
			var theContent:String = debugField.text;
			theContent = theContent.split(m1).join(m2);
			debugField.text = theContent;
		}

		public function clear(): void {
			debugField.text = "";
		}
		
		public function show():void {
			debugField.visible = true;
			enabled = true;
		}
		
		public function hide():void {
			debugField.visible = false;
			enabled = false;
		}
		
		public function updateDebug(evt: StageOrientationEvent): void {
			debugField.width = evt.currentTarget.stage.stageWidth/2 - 20;
			if (flash.system.Capabilities.screenDPI > 150) {
				debugField.height = evt.currentTarget.stage.stageHeight - 60;
			} else {
				debugField.height = evt.currentTarget.stage.stageHeight - 40;
			}
			//trace(evt.beforeOrientation+" vers "+evt.afterOrientation);
			var oldSO:String = parent.stageOrientation;
			debugField.stage.stageWidth >= debugField.stage.stageHeight ? parent.stageOrientation ="LANDSCAPE" : parent.stageOrientation="PORTRAIT";
			/* remplace l'orientation dans debugField */
			var theContent:String = debugField.text;
			theContent = theContent.split(oldSO).join(parent.stageOrientation);
			debugField.text = theContent;
			
		}

	}
}