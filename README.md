#  ColorMatrix
This is ported from [the class by GSkinner.com.](https://blog.gskinner.com/archives/2007/12/colormatrix_cla.html) Thanks!

This can be used in OpenFL or any other code which can use a similar 5x5 color transform matrix.

ColorMatrix provides a way to adjust Brightness, Contrast, Saturation and Hue based on a range of numeric values as well as multiply matrices. The ColorMatrix can then be passed into ColorMatrixFilter (OpenFL or Flash) to apply color adjustments. The added bonus of ColorMatrix is that it uses the same calculations to generate matrix values as the Flash IDE (with the exception of contrast adjustment which uses linear interpolation to provide a bit more granularity).

##  Example Use

```
var bmd = Assets.getBitmapData("photo.png").clone(); //clone is necessary to avoid destructive operations on the original data
var cm = new ColorMatrix();
cm.adjustHue(-170);
cm.adjustSaturation(-15);
var cmf = new ColorMatrixFilter( cm.value() );
bmd.applyFilter(
	bmd,
	new Rectangle(0,0,bmd.width,bmd.height),
	new Point(),
	cmf
);

var b = new Bitmap(bmd);
addChild(b);
```
Note: The original library directly extended the Array class, while retrieving the data now makes use of the `value()` function. It may be possible to make it a static extension of Array in future.  