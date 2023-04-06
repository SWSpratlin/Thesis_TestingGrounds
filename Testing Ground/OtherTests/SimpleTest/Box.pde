class Box{
    
    //X and Y size for the collision of the box
    int bW;
    int bH;
    
    //Corner coordinates, determines the location of the box
    int bx; 
    int by;
    
    //Threhsold for the search to return a collision point
    int threshold = 220; 
    
    //Center Coordinates of the Box
    int bCx; 
    int bCy;
    
    PImage box; //Box for collision detection area
    IntList px; //Array for collision detection
    ArrayList<Point> coord; //Coordinate array for Vector generation
    Point cPoint; //DISTINCT FROM THE METHOD for internal usage.
    char letter; //Random letter variable
    
    //objects for any movement related methods
    PVector location;
    PVector velocity;
    PVector acceleration;
    PVector friction = new PVector(0,0);
    
    float f; //friction coeffecient, used in collisionVector
    float mass = 1.5; //mass, just to find out if it helps. (it doesn't really)
    
    //Constructor. Called in SETUP
    //Intakes spawn coordinates, size, color
    Box(int x_, int y_, int sizeW, int sizeH, int bColor) {
        
        //Spawn Coordinate variables
        this.bx = x_;
        this.by = y_;
        
        //Size variables
        this.bW = sizeW;
        this.bH = sizeH;
        
        //Initialize Collision variables
        location = new PVector(this.bx, this.by);
        velocity = new PVector(0,0);
        acceleration = new PVector(0,0);
        
        //Create PImage for the Box
        imageMode(CORNER);
        box = createImage(bW,bH, HSB);
        
        //Color Letter
        fill(170);
        
        //Generate random character
        letter = char(int(random(65, 65 + 24)));
        
        //Color Box pixels (mostly for debugging)
        box.loadPixels();
        for (int i = 0; i < box.pixels.length; i++) {
            //Make collision box transparent
            box.pixels[i] = color(bColor, 0,0,0);
        }
        //Update Box pixels
        box.updatePixels(); 
    }
    
    //Fills a Point Array with the coordinates of the entire box
    //IN THE ORDER they are listed as per the Pixel array
    //Call this in SETUP to avoid redrawing the coordinate array every frame
    void getCoord() {
        //initialize coordinate array
        coord = new ArrayList<Point>();
        
        //comb through the entire area of the box to assign every pixel a coordinate
        for (int y = 0; y < this.bH; y++) {
            for (int x = 0; x < this.bW; x++) { 
                
                //assign coordinates. USES CALCULATION TO MAKE SURE THE CENTER
                //COORDINATE IS 0,0. COLLISION IS EXTREMELY BUGGY WITHOUT THIS
                coord.add(new Point(x - (bW / 2),y - (bH / 2)));
            }
        }
    }
    
    // Display the Box(if visible) and Letter
    void display() {
        // Call box image. Necessary for loadPixels() later to work
        image(box, bx, by);
        
        //Call the text and character. This is where the text can be 
        //customized visually
        textSize(50);
        text(letter, bx,(by + bH));
    }
    
    //Get the center point for the box. Will be used
    //to calculate a vector later on
    void getCenter() {
        int bCx = (this.bW / 2);
        int bCy = (this.bH / 2);
    }
    
    /* Look Under function. Used for examining the pixels under
    the box. Will need to figure out how to deciper the data
    and perform a function depending on the result
    
    Must be called in DRAW for any methods that reference
    the px[] array to work*/
    void lookUnder(PImage p) {
        //Generate PImage (and therefore a pixels array) for the space under the box
        PImage r = p.get(this.bx, this.by, this.bW, this.bH);
        //create pixels array that can be referenced 
        px = new IntList();
        px.append(r.pixels);
    }
    
    /*Method for finding the first white pixel, and it's location
    WITHIN the Box. Will use PVector(?) to apply a vector
    from the relationship to the center. */
    Point collisionPoint() {
        
        // Xand Y arrays to create a centroid coordinate 
        IntList collisionArrayX = new IntList();
        IntList collisionArrayY = new IntList();
        
        // Xand Y sum variables that clear every loop for the average
        //calculation to take place
        int sumX = 0;
        int sumY = 0;
        
        //scan the whole px array
        for (int i = 0; i < px.size(); i++) {
            // Check if any given pixel is brighter than the threshold
            if (int(brightness(px.get(i))) >= threshold) {
                
                //pupulate the X and Y arrays with the values from the
                // coord array. 
                collisionArrayX.append((coord.get(i).x));
                collisionArrayY.append((coord.get(i).y));
            }
            // Every 10 loops of the for loop, take the average of the array.
            //This is untested, may need additioanl conditions to properly operate
            if (i % 10 ==  0) {
                
                //Adding the size check here to stop empty arrays from trying to trigger a for loop
                if (collisionArrayY.size() != 0 && collisionArrayX.size() != 0) {
                    
                    // Add each value to the sum, to be divided for the mean
                    for (int o = 0; o < collisionArrayX.size(); o++) {
                        sumX += collisionArrayX.get(o);
                        sumY += collisionArrayY.get(o);
                    }
                    
                    //assign cPoint as the mean of the arrays rather than
                    // the first bright pixel in each pass                  
                    cPoint = new Point((sumX / collisionArrayX.size()),(sumY / collisionArrayY.size()));
                    
                    //return the centroid for collision purposes
                    collisionArrayX.clear();
                    collisionArrayY.clear();
                    return cPoint;
                }
            }
        }
        //ifthere are no bright pixel, return null
        cPoint = null;
        return null;
    }
    
    /* Needs to be called as a function AFTER lookUnder so the 
    px array is populated, and the collisionPoint method can
    run successfully.*/ 
    void collisionVector() {       
        
        //Pull Center point, should be 0,0 
        float centerX = float(bCx);
        float centerY = float(bCy);
        
        //Method variables.
        //Friction coeffecient. Change from between 0.01 and 0.5 for best results
        float f = 0.2;
        
        //Acceleration coeffecient for how much speed picks up after collision
        //Change between 8 and 20 for best results
        float aMult = 15;
        
        //speed limiter so things don't fly away
        //Change between 3 and 10 for best results
        float topSpeed = 4;
        
        //Method objects
        PVector force;
        
        //Directional Vector for collision direction
        PVector dir = new PVector();
        
        //Apply the force ONLY if there is a collision happening
        if (cPoint != null) {
            
            //Get collision vecotr
            //PVector centerPoint = new PVector(centerX, centerY);
            PVector colPoint = new PVector(cPoint.x, cPoint.y);
            PVector centerPoint = new PVector(centerX, centerY);
            
            //Calculate the direction between the center point and Collision Point
            dir = PVector.sub(centerPoint, colPoint);
            
            //Normalize the vector, and multiply it to create acceleration upon collision
            dir.normalize();
            dir.mult(aMult);
            
        } else {
            //If there is no collision, make sure the directional vector is zeroed out. 
            //Causes drift without this.
            dir.set(0,0);
        }
        
        //SET UPFRICTION
        friction = velocity.get();
        friction.mult( -1);
        friction.normalize();
        friction.mult(f);   
        
        //Apply collsition vector to acceleration
        acceleration.set(dir);
        
        //APPLY FRICTION
        friction.div(mass);
        acceleration.add(friction);
        
        //UPDATE
        location.set(this.bx,this.by);    
        velocity.add(acceleration);
        velocity.limit(topSpeed);
        location.add(velocity);
        acceleration.mult(0);
        
        //UPDATEPOSITION
        this.bx = int(location.x);
        this.by = int(location.y);
        
        //Drift elimination. If the velocity is within a certain threshold
        //zero it out. Threshold should be low enough that this seems natural
        float lowThresh = -0.03;
        float highThresh = 0.03;
        
        //lotta && statememtns to find out if 2 values are within a range
        if (lowThresh <= velocity.x && velocity.x <= highThresh && lowThresh <= velocity.y && velocity.y <= highThresh) {
            velocity.set(0,0);
        }
        
    }
    
    //bounce off the edges (now functional)
    void edgeBounce() {
        //Check if the box is on the edge (same for all)
        if (this.bx <= 0) {
            //set location to the lower bound, invert and multiply velocity to 
            //avoid getting stuck on the eges
            this.bx = 0;
            velocity.x *= -2;
        } else if (this.bx + bW >= width) {
            this.bx = width - bW;
            velocity.x *= -2;
        }
        if (0 >= this.by) {
            this.by = 0;
            velocity.y *= -2;
        } else if (this.by + bH >= height) {
            this.by = height - bH;
            velocity.y *= -2;
        }
    }
}   