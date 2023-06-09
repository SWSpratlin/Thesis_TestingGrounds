//Import Point class, important
import java.awt.Point; 

//Import Sound library. Important for NoteTrack to work
import processing.sound.*;

// name the PApplet master so we can refernce in other classes
public PApplet master = this;

//Create a PImage that will color the pixels around the mouse
PImage mouseLight;

//Zero out mouse location variable to start
int boxNumber;

//Call the Box Array
ArrayList<Box> boxes;
ArrayList<String> notes;

void setup() {
    //Set size, 1280
    size(1280, 480, P2D);
    
    //set BG color
    background(0);
    
    // Note names for file loading
    notes = new ArrayList<String>();
    notes.add("A__1.wav");
    notes.add("B__1.wav");
    notes.add("C__1.wav");
    notes.add("D__1.wav");
    notes.add("E__1.wav");
    notes.add("F__1.wav");
    notes.add("G__1.wav");
    notes.add("H__1.wav");
    notes.add("I__1.wav");
    notes.add("J__1.wav");
    notes.add("K__1.wav");
    notes.add("L__1.wav");
    notes.add("M__1.wav");
    notes.add("N__1.wav");
    notes.add("O__1.wav");
    notes.add("P__1.wav");
    notes.add("Q__1.wav");
    notes.add("R__1.wav");
    notes.add("S__1.wav");
    notes.add("T__1.wav");
    notes.add("U__1.wav");
    notes.add("V__1.wav");
    notes.add("W__1.wav");
    notes.add("X__1.wav");
    notes.add("Y__1.wav");
    notes.add("Z__1.wav");
    
    //Set number of boxes to spawn
    boxNumber = 60;
    
    //intialize the box array
    boxes = new ArrayList<Box>(boxNumber);
    
    //initialize the boxes
    for (int i = 0; i < boxNumber; i++) {
        Box tmpBox = new Box(int(random(width)), int(random(height)), 20, 20, 130);
        tmpBox.getCoord();
        boxes.add(tmpBox);
    }
    
    //initialize the mouseLight PImage
    mouseLight = new PImage(width, height, RGB);
    mouseLight.loadPixels();
    for (int i = 0; i < mouseLight.pixels.length; i++) {
        mouseLight.pixels[i] = color(0);
    }
    mouseLight.updatePixels();
}

//Reset function for mouse click. Also randomizes letters
void mouseReleased() {
    for (int i = 0; i < boxes.size(); i++) {
        boxes.get(i).bx = int(random(width));
        boxes.get(i).by = int(random(height));
        boxes.get(i).letterNumber = int(random(65, 65 + 24));
    }
}

void draw() {
    //Draw white circle around the mouse
    //copy/paste/adjust from "flashlight" Daniel Schiffman example
    //Not important, will be replaced with Kinect Image
    
    image(mouseLight, 0,0);
    mouseLight.loadPixels();
    for (int y = 0; y < height; y++) {
        
        // Apply Physics to all the boxes without another for loop
        // Also add the x coordinates and y coordinates to arrays for comparison
        if (y < boxNumber) {
            boxes.get(y).lookUnder(mouseLight);
            boxes.get(y).collisionPoint();
            boxes.get(y).collisionVector();
            boxes.get(y).edgeBounce();
            boxes.get(y).display();
        }
        for (int x = 0; x < width; x++) {
            int loc = x + y * width;
            float b = alpha(mouseLight.pixels[loc]);
            float maxDist = 35;
            float d = dist(x,y,mouseX,mouseY);
            float adjustBrightness = 255 * (maxDist - d) / maxDist;
            b *= adjustBrightness;
            b = constrain(b, 0, 255);
            color c = color(b);
            mouseLight.pixels[loc] = c;
            if (x < boxNumber && y < boxNumber && y != x) {
                boxes.get(x).boxBounce(boxes.get(y));
            }
        }
    }
    mouseLight.updatePixels();
    
    // Print the framerate to the window for Performance check purposes. 
    textSize(50);
    text(frameRate, 100, 100);
    stroke(255);
    strokeWeight(10);
    line(110, 110, frameRate * 4, 110);
}