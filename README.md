# wooden-smart-toy
####An as3 lib to detect and identify on iPad, iPhone and Android Device<br />patented wooden pieces created and sold by Marbotic.fr.

![marbotic wooden pieces] (http://www.marbotic.fr/wp-content/uploads/2013/11/chiffres-rond-400x400.jpg) ![marbotic wooden pieces - back view] (http://www.marbotic.fr/wp-content/uploads/2013/11/chiffres-picots-400x400.jpg)

I've just done reverse engineering to find a way to detect and read Touch patterns.

Each wooden piece is connected to touchscreen by 3 touch pad with specific configuration.<br />
Two pads are for the "base" (always the same width).<br/>
The last pad is the satellite point which made the pattern, give the significant part.<br/>
The satellite point is define by angle and distance from the middle point of the base, in polar's coords.
The base width is fixe and always the smallest from the 3.

To avoid screensize pb detection, i've decided to work in millimeter and made a truth table with true dpi of the iPad and iPhone screen.

<code>flash.system.Capabilities.screenDPI</code> return fake value on iPad and iPhone.<br/>
Therefore, i use the iPad number (ex. iPad4,4 for ipad mini retina wifi) from <code>flash.system.Capabilities.os</code> and a truth table to find the number of pixels for a millimeter.
On Android Device (on my MotoG (First Gen) and my cheap Lenovo A4) the value seems to be good and detection perform well. I decide to implement detection for them.

Detection on iPad is relatively easy because there is few hardware: retina or none, 7.9 inch or 9.7. So only 4 screenDPI.

I'm not developer, just graphic & interaction designer, i do apologize for my bad english and my hugly code.
Hope this will help!

The project compile with Adobe Flash CC 2014/15 on osx with AIR17 and AIR19.<br/>
there is no .fla file, you just need to create a new "AIR for Android" or "AIR for iOS" project and add <code>com.mrbbp.App</code> as your Main Class. (i've added custom icon for iOS and Android for fun)

To use it you need at least 3 touch points on screen to instanciate a new Piece with 3 TouchPoint.
```as3
import com.mrbbp.Piece;

var piece:Piece = new Piece(new Point(x1,y1), new Point(x2,y2), new Point(x3,y3));
```

if you want to have some visual feedback you must instanciate a Debug() and add debug parameter to Piece Parameter

```as3
import com.mrbbp.Debug;
import com.mrbbp.Piece;

var debug:Debug = new Debug(this);
var piece:Piece = new Piece(new Point(x1,y1), new Point(x2,y2), new Point(x3,y3), true);
```

lib v2:
	- Added a new <code>PieceEvent.PIECE_DETECTED</code> event

PieceEvent is populated with some cool values about the detected piece.
id : *the number for the Smart Numbers*
angle: *orientation of the piece on the screen*
reverse: *is the piece reverse on the screen? (some pieces have reversed pattern, this is **not** what it return)*
alpha: *the angle of the pattern on the wood piece (in degres)*
rho: *satellite point's angle vs the base (in degres)*
theta: *satellite point's distance from the base (in millimeters)*
baseWidth: *the width of the base (in millimeters)*

To use the PieceEvent:

```as3
import com.mrbbp.PieceEvent;
//... some code ...
// add the listener to the stage
stage.addEventListener(PieceEvent.PIECE_DETECTED, PieceEventHandler);
//...
function PieceEventHandler(pe:PieceEvent):void {
	trace("PieceEvent: id:",pe.id,"- angle:",Math.round(pe.angle*10)/10,(pe.reverse)?"° - pièce inversée":"pièce à l'endroit");
	trace(pe.toString());
	trace(pe.ID);
}
```


I've used additional lib with custom cartesianToPolar method (less generic), from Ian McLean (excerpt from a larger lib) http://www.github.com/as3/as3-utils

Patents for touch grid and conduction way between capacitive screen and body are patented by
- Etienne Jean MINEUR and Bertrand DUPLAT from http://www.volumique.com [FR 2995423, FR 2994752, FR 2970352]*
- Marie Merouze http://www.marbotic.fr [FR 3003661]*

*[N° Patents find on http://www.inpi.fr]
