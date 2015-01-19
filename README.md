# wooden-smart-toy
<strong>This project is an as3 lib to detect and identify on iPad,
patented wooden pieces created and sold by Marbotic.fr.</strong>

I've just done reverse engineering to find a way to detect and read touch grid.

Each wooden piece is connected to touchscreen by 3 touch pad with specific configuration.
Two pads are for the "base" (always the same identical gap).
The last pad is the satellite point which made the pattern, give the significant part.
The satellite point is define by angle and distance from the middle point of the base. in polar's coords.

To avoid screensize pb detection, i've decided to work in millimeter and made a truth table with true dpi of the screen.
<em>flash.system.Capabilities.screenDPI</em> return fake value.
i use the ipad number (ex. iPad4,4 for ipad mini retina wifi) from <em>flash.system.Capabilities.os.split(" ")[3]</em> to find the real pixel size of a millimeter. 

I'm not developer, just graphic & interaction designer, i do apologize for my bad english and my hugly code.
Hope this will help!

The project compile with Adobe Flash CC 2014 on osx.

To use it you need at least 3 touch points on screen to instanciate a new Piece with 3 TouchPoint.
<code>import com.mrbbp.Piece;</code>

<code>var piece:Piece = new Piece(new Point(x1,y1), new Point(x2,y2), new Point(x3,3), stageRef, true <em>(DebugMode ON)</em>);</code>

Patents for touch grid and conduction way between capacitive screen and body are patented by
- Etienne Jean MINEUR and Bertrand DUPLAT from http://www.volumique.com [FR 2995423, FR 2994752, FR 2970352]*
- Marie Merouze http://www.marbotic.fr [FR 3003661]*




*[N° Patents find on http://xwww.inpi.fr]
