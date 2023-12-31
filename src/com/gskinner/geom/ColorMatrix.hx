﻿/**
* ColorMatrix by Grant Skinner. August 8, 2005
* Updated to AS3 November 19, 2007
* Updated to Haxe September 15, 2023 by Allan Dowdeswell, Confidant Communications
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
*
* Please contact info@gskinner.com prior to distributing modified versions of this class.
*/

package com.gskinner.geom;

class ColorMatrix  { 

// constant for contrast calculations:
	static final DELTA_INDEX:Array<Float> = [
		0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
		0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
		0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
		0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 
		0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
		1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
		1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25, 
		2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
		4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
		7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8, 
		10.0
	];

	// identity matrix constant:
	static final IDENTITY_MATRIX:Array<Float> = [
		1,0,0,0,0,
		0,1,0,0,0,
		0,0,1,0,0,
		0,0,0,1,0,
		0,0,0,0,1
	];
	static final LENGTH:Int = IDENTITY_MATRIX.length;
	
	private var thisArray:Array<Float>;

// initialization:
	public function new(p_matrix:Array<Float> = null) { //p_matrix:Array<Float>=null
		thisArray = [];
		p_matrix = fixMatrix(p_matrix);
		copyMatrix(((p_matrix.length == LENGTH) ? p_matrix : IDENTITY_MATRIX));
	}
	
// public methods:
	public function reset():Void {
		// for (var i:uint=0; i<LENGTH; i++) {
		for (i in 0...LENGTH) {
			thisArray[i] = IDENTITY_MATRIX[i];
		}
	}

	public function adjustColor(p_brightness:Float,p_contrast:Float,p_saturation:Float,p_hue:Float):Void {
		adjustHue(p_hue);
		adjustContrast(p_contrast);
		adjustBrightness(p_brightness);
		adjustSaturation(p_saturation);
	}

	public function adjustBrightness(p_val:Float):Void {
		p_val = cleanValue(p_val,100);
		if (p_val == 0 || Math.isNaN(p_val)) { return; }
		multiplyMatrix([
			1,0,0,0,p_val,
			0,1,0,0,p_val,
			0,0,1,0,p_val,
			0,0,0,1,0,
			0,0,0,0,1
		]);
	}

	public function adjustContrast(p_val:Float):Void {
		p_val = cleanValue(p_val,100);
		if (p_val == 0 || Math.isNaN(p_val)) { return; }
		var x:Float;
		if (p_val<0) {
			x = 127+p_val/100*127;
		} else {
			x = p_val%1;
			if (x == 0) {
				x = DELTA_INDEX[Math.round(p_val)];
			} else {
				//x = DELTA_INDEX[(p_val<<0)]; // this is how the IDE does it.
				x = DELTA_INDEX[(Math.round(p_val)<<0)]*(1-x)+DELTA_INDEX[(Math.round(p_val)<<0)+1]*x; // use linear interpolation for more granularity.
			}
			x = x*127+127;
		}
		multiplyMatrix([
			x/127,0,0,0,0.5*(127-x),
			0,x/127,0,0,0.5*(127-x),
			0,0,x/127,0,0.5*(127-x),
			0,0,0,1,0,
			0,0,0,0,1
		]);
	}

	public function adjustSaturation(p_val:Float):Void {
		p_val = cleanValue(p_val,100);
		if (p_val == 0 || Math.isNaN(p_val)) { return; }
		var x:Float = 1+((p_val > 0) ? 3*p_val/100 : p_val/100);
		var lumR:Float = 0.3086;
		var lumG:Float = 0.6094;
		var lumB:Float = 0.0820;
		multiplyMatrix([
			lumR*(1-x)+x,lumG*(1-x),lumB*(1-x),0,0,
			lumR*(1-x),lumG*(1-x)+x,lumB*(1-x),0,0,
			lumR*(1-x),lumG*(1-x),lumB*(1-x)+x,0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]);
	}

	public function adjustHue(p_val:Float):Void {
		p_val = cleanValue(p_val,180)/180*Math.PI;
		if (p_val == 0 || Math.isNaN(p_val)) { return; }
		var cosVal:Float = Math.cos(p_val);
		var sinVal:Float = Math.sin(p_val);
		var lumR:Float = 0.213;
		var lumG:Float = 0.715;
		var lumB:Float = 0.072;
		multiplyMatrix([
			lumR+cosVal*(1-lumR)+sinVal*(-lumR),lumG+cosVal*(-lumG)+sinVal*(-lumG),lumB+cosVal*(-lumB)+sinVal*(1-lumB),0,0,
			lumR+cosVal*(-lumR)+sinVal*(0.143),lumG+cosVal*(1-lumG)+sinVal*(0.140),lumB+cosVal*(-lumB)+sinVal*(-0.283),0,0,
			lumR+cosVal*(-lumR)+sinVal*(-(1-lumR)),lumG+cosVal*(-lumG)+sinVal*(lumG),lumB+cosVal*(1-lumB)+sinVal*(lumB),0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]);
	}

	public function concat(p_matrix:Array<Float>):Void {
		p_matrix = fixMatrix(p_matrix);
		if (p_matrix.length != LENGTH) { return; }
		multiplyMatrix(p_matrix);
	}
	
	public function clone():ColorMatrix {
		return new ColorMatrix(thisArray);
	}

	public function toString():String {
		return "ColorMatrix [ "+thisArray.join(" , ")+" ]";
	}
	
	// return a length 20 array (5x4):
	public function toArray():Array<Float> {
		return thisArray.slice(0,20);
	}

	public function value():Array<Float>{
		return thisArray;
	}

// private methods:
	// copy the specified matrix's values to this matrix:
	private function copyMatrix(p_matrix:Array<Float>):Void {
		var l:Int = LENGTH;
		// for (var i:uint=0;i<l;i++) {
		for (i in 0...l) {
			thisArray[i] = p_matrix[i];
		}
	}

	// multiplies one matrix against another:
	private function multiplyMatrix(p_matrix:Array<Float>):Void {
		var col:Array<Float> = [];
		
		// for (var i:uint=0;i<5;i++) {
		for (i in 0...5) {
			for (j in 0...5) {
				col[j] = thisArray[j+i*5];
			}
			for (j in 0...5) {
				var val:Float=0;
				for (k in 0...5) {
					val += p_matrix[j+k*5]*col[k];
				}
				thisArray[j+i*5] = val;
			}
		}
	}
	
	// make sure values are within the specified range, hue has a limit of 180, others are 100:
	private function cleanValue(p_val:Float,p_limit:Float):Float {
		return Math.min(p_limit,Math.max(-p_limit,p_val));
	}

	// makes sure matrixes are 5x5 (25 long):
	private function fixMatrix(p_matrix:Array<Float>=null):Array<Float> {
		if (p_matrix == null) { return IDENTITY_MATRIX; }
		if (Std.isOfType(p_matrix, ColorMatrix)) { p_matrix = p_matrix.slice(0); }
		if (p_matrix.length < LENGTH) {
			p_matrix = p_matrix.slice(0,p_matrix.length).concat(IDENTITY_MATRIX.slice(p_matrix.length,LENGTH));
		} else if (p_matrix.length > LENGTH) {
			p_matrix = p_matrix.slice(0,LENGTH);
		}
		return p_matrix;
	}
}
