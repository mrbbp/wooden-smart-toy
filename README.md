# wooden-smart-toy
####This project is an as3 lib to detect and identify on iPad,<br />patented wooden pieces created and sold by Marbotic.fr.

I've just done reverse engineering to find a way to detect and read Touch patterns.

Each wooden piece is connected to touchscreen by 3 touch pad with specific configuration.<br />
Two pads are for the "base" (always the same identical gap).<br/>
The last pad is the satellite point which made the pattern, give the significant part.<br/>
The satellite point is define by angle and distance from the middle point of the base. in polar's coords.

To avoid screensize pb detection, i've decided to work in millimeter and made a truth table with true dpi of the screen.

<code>flash.system.Capabilities.screenDPI</code> return fake value.<br/>
I use the iPad number (ex. iPad4,4 for ipad mini retina wifi) from <code>flash.system.Capabilities.os</code> and a truth table to find the number of pixels for a millimeter. 

Detection on iPad is relatively easy because there is few hardware: retina or none, 7.9 inch or 9.7. So only 4 screenDPI.
I do not try to do the same truth table for Android, because hardware is so various (more screen size and more  resolution... a nigthmare.. if you need it, be my guest and share.)

I'm not developer, just graphic & interaction designer, i do apologize for my bad english and my hugly code.
Hope this will help!

The project compile with Adobe Flash CC 2014 on osx.

To use it you need at least 3 touch points on screen to instanciate a new Piece with 3 TouchPoint.
<pre><code>import com.mrbbp.Piece;

var piece:Piece = new Piece(new Point(x1,y1), new Point(x2,y2), new Point(x3,y3), this);</code></pre>

if you want to have some visual feedback you must instanciate a Debug() and add debug parameter to Piece Parameter

<pre><code>import com.mrbbp.Debug;
import com.mrbbp.Piece;

var debug:Debug = new Debug(this);
var piece:Piece = new Piece(new Point(x1,y1), new Point(x2,y2), new Point(x3,y3), this, true);</code></pre>

I've used additional lib with custom cartesianToPolar method, from Ian McLean

Patents for touch grid and conduction way between capacitive screen and body are patented by
- Etienne Jean MINEUR and Bertrand DUPLAT from http://www.volumique.com [FR 2995423, FR 2994752, FR 2970352]*
- Marie Merouze http://www.marbotic.fr [FR 3003661]*

*[N° Patents find on http://xwww.inpi.fr]
