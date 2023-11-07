package ImageGlitch;


import processing.core.*;

public class ImageGlitch extends PApplet {
		
	private PImage img;
	private PImage origImg;

	public ImageGlitch(PImage image) {
		img = image.copy();
		origImg = image.copy();
	}
	
	public PImage getImage() {
		return img.copy();
	}
	
	public void restore() {
		img = origImg.copy();
	}
	
	public void operatePixels(float amount, Operation op) {
		img.loadPixels();
		if (op == Operation.ADD) {
			for (int i = 0; i < img.pixels.length; i++) {
				img.pixels[i] = img.pixels[i]+(int)amount;
			}
		}
		else if (op == Operation.MULT) {
			for (int i = 0; i < img.pixels.length; i++) {
				img.pixels[i] = (int)(img.pixels[i]*amount);
			}
		}
		img.updatePixels();
	}
	
	public void operatePixels(float shift) {
		operatePixels(shift, Operation.ADD);
	}
	
	public void comparePixels(Value val, Direction dir, int threshold, boolean override) {
		for (int i = 0; i < img.width; i++) {
			for (int j = 0; j < img.height; j++) {
				int selectedColor = img.get(i, j);
				int compareColor = 0;
				Value currentVal = val;
				Direction currentDir = dir;
				if (val == Value.RANDOM) {
					int index = (int)random(Value.values().length-1);
					currentVal = Value.values()[index];
				}
				if (dir == Direction.RANDOM) {
					int index = (int)random(Direction.values().length-1);
					currentDir = Direction.values()[index];
				}
				switch(currentDir) {
					case UP:
						if (j > 0) {
							compareColor = img.get(i, j-1);
						} else {
							continue;
						}
						break;
					case DOWN:
						if (j < img.height-1) {
							compareColor = img.get(i, j+1);
						} else {
							continue;
						}
						break;
					case LEFT:
						if (i > 0) {
							compareColor = img.get(i-1, j);
						} else {
							continue;
						}
						break;
					case RIGHT:
						if (i < img.width-1) {
							compareColor = img.get(i+1, j);
						} else {
							continue;
						}
						break;
				}
				float selectedVal = 0;
				float compareVal = 0;
				int selectedR = (selectedColor >> 16) & 0xFF;
				int selectedG = (selectedColor >> 8) & 0xFF;
				int selectedB = selectedColor & 0xFF;
				int compareR = (compareColor >> 16) & 0xFF;
				int compareG = (compareColor >> 8) & 0xFF;
				int compareB = compareColor & 0xFF;
				switch(currentVal) {
					case RED:
						selectedVal = selectedR;
						compareVal = compareR;
						break;
					case GREEN:
						selectedVal = selectedG;
						compareVal = selectedG;
						break;
					case BLUE:
						selectedVal = selectedB;
						compareVal = selectedB;
						break;
					case HUE:
						selectedVal = ImageGlitch.hue(selectedR, selectedG, selectedB);
						compareVal = ImageGlitch.hue(compareR, compareG, compareB);
						break;
					case SAT:
						selectedVal = ImageGlitch.saturation(selectedR, selectedG, selectedB);
						compareVal = ImageGlitch.saturation(compareR, compareG, compareB);
						break;
					case BRI:
						selectedVal = ImageGlitch.brightness(selectedR, selectedG, selectedB);
						compareVal = ImageGlitch.brightness(compareR, compareG, compareB);
						break;
				}
				boolean swap = false;
				if (compareVal > (selectedVal + threshold)) {
					swap = true;
				}
				if (swap) { 
					img.loadPixels();
					switch(currentDir) {
						case UP:
							img.pixels[i+(j-1)*img.width] = selectedColor;
							break;
						case DOWN:
							img.pixels[i+(j+1)*img.width] = selectedColor;
							break;
						case LEFT:
							img.pixels[(i-1)+j*img.width] = selectedColor;
							break;
						case RIGHT:
							img.pixels[(i+1)+j*img.width] = selectedColor;
							break;
					}
					if (!override) {
						img.pixels[i+j*img.width] = compareColor;
					}
					img.updatePixels();
				}
			}
		}
	}
		
	public void comparePixels(Value val, Direction dir, int threshold) {
		comparePixels(val, dir, threshold, false);
	}
	
	public void comparePixels(Value val, Direction dir, boolean override) {
		comparePixels(val, dir, 0, override);
	}
	
	public void comparePixels(Value val, Direction dir) {
		comparePixels(val, dir, 0, false);
	}
	
	public void comparePixels(Value val) {
		comparePixels(val, Direction.UP, 0, false);
	}
	
	public void shiftBits(int amount, boolean ignoreA) {
		img.loadPixels();
		if (amount > 0) {
			for (int i = 0; i < amount; i++) {
				int last = img.pixels[img.pixels.length-1] & 1;
				for (int j = img.pixels.length-1; j > 0; j--) {
					int temp = img.pixels[j] >> 1;
					if (ignoreA) {
						int rollover = (img.pixels[j-1] & 1) << 23;
						img.pixels[j] = (temp & 0xFF7FFFFF) | rollover;
					}
					else {
						int rollover = (img.pixels[j-1] & 1) << 31;
				        img.pixels[j] = (temp & 0x7FFFFFFF) | rollover;
					}
				}
				int temp = img.pixels[0] >> 1;
				if (ignoreA) {
					int rollover = last << 23;
					img.pixels[0] = (temp & 0xFF7FFFFF) | rollover;
				}
				else {
					int rollover = last << 31;
					img.pixels[0] = (temp & 0x7FFFFFFF) | rollover;
				}
			}
		}
		else {
			for (int i = 0; i < abs(amount); i++) {
				int last;
				if (ignoreA) {
					last = (img.pixels[0] >> 23) & 1;
				}
				else {
					last = (img.pixels[0] >> 31) & 1;
				}
				for (int j = 0; j < img.pixels.length-1; j++) {
					int temp;
					int rollover;
					if (ignoreA) {
						temp = (img.pixels[j] << 1) | 0xFF000000;
						rollover = (img.pixels[j+1] >> 23) & 1;
					}
					else {
						temp = (img.pixels[j] << 1);
						rollover = (img.pixels[j+1] >>> 31) & 1;
					}
					img.pixels[j] = (temp & 0xFFFFFFFE) | rollover;
				}
				int temp;
				if (ignoreA) {
					temp = (img.pixels[img.pixels.length-1] << 1) | 0xFF000000;
				}
				else {
					temp = img.pixels[img.pixels.length-1] << 1;
				}
				img.pixels[img.pixels.length-1] = (temp & 0xFFFFFFFE) | last;
			}
		}
		img.updatePixels();
	}
	
	public void shiftBits(int amount) {
		shiftBits(amount, false);
	}
	
	private static int hue(int r, int g, int b) {
		if (r == b && b == g) {
			return 0;
		}
		else if (max(r, g, b) == r) {
			return (60*((g - b)/(max(r, g, b)-min(r, g, b))))%360;
		}
		else if (max(r, g, b) == g) {
			return (60*((b - r)/(max(r, g, b)-min(r, g, b))) + 120)%360;
		}
		else {
			return (60*((r - g)/(max(r, g, b)-min(r, g, b))) + 240)%360;
		}
	}
	
	private static int saturation(int r, int g, int b) { 
		if (r == 0 && g == 0 && b == 0) {
			return 0;
		}
		else {
			return 255*(max(r, g, b)-min(r, g, b))/max(r, g, b);
		}
	}
	
	private static int brightness(int r, int g, int b) { 
		return max(r, g, b);
	}
}

