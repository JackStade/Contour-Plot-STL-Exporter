//graphics object that stores the object
PGraphics drawer;
//functions and derivatives
function f;
function deriv;
function deriv2;
function fdxy;
function fdxz;
//resolution
int n = 32;
//graphing parameters
float x1= -4;
float x2 = 4;
float y1 = -4;
float y2 = 4;
float z1 = -4;
float z2 = 4;
//stores the polygons
ArrayList<poly> sides = new ArrayList<poly>();
String funct = "1";
//setup() used to initialized things
void setup() {
  //create a window for drawing with an opengl 3D renderer.
  size(1000, 600, P3D);
  //initialize the drawing window
  drawer = createGraphics(500, 500, P3D);
  //intialize the controller
  //this is the string that is the actual function we want to solve
  //this will be solved f = 0
  funct = "(sin(x)+sin(y)+sin(z))";
  //sets up differentiation rules
  setHash();
  setf(funct);
  //set the framerate
  frameRate(60);
  //turn on lights
  lights();
}
//draw gets called 60 time a second
void draw() {
  //set the perspective
  float fov = PI/3;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);
  //this makes things get drawn in the right order
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_SORT);
  //used to determin how long it took to run
  println("start", millis());
  //clear everything on screen
  background(255);
  //set the fill
  fill(0);
  //draw the function
  text(funct, 10, 70);
  //push to matrix stack
  pushMatrix();
  //move origin to center
  translate(400, 0);
  //scale so that x and y fit in graphing window
  scale(600/(x2-x1), 600/(y2-y1));
  //another translation to make the graphing window work
  translate(-x1, -y1);
  //set the stroke weight so lines aren't to huge
  strokeWeight((x2-x1)/150);
  //rotate the 3D graphing window
  //rotateX(3*PI/4);
  rotateX(1*PI/4);
  rotateZ(millis()*PI/4000);
  //scale down so the graph doesn't go all the way to the edge
  scale(.7);
  //draw green axis
  stroke(0, 255, 0);
  line(x1, 0, x2, 0);
  line(0, y1, 0, y2);
  line(0, 0, z1, 0, 0, z2);
  //set the line color to black
  stroke(0, 0, 0);
  //draw all the sides
  //this is relative self-explanatory
  //if one really wanted to, one could use the implicit derivative to define NURBS surfaces
  fill(230);
  //noStroke();
  println(sides.size());
  for (int i = 0; i<sides.size(); i++ ) {
    poly on = sides.get(i);
    beginShape();
    int len = on.xs.length;
    for (int k = 0; k<len; k++) {
      vertex(on.xs[k], on.ys[k], on.zs[k]);
    }
    //vertex(on.xs[0], on.ys[0]);
    endShape(CLOSE);
  }
  //pop the matrix
  popMatrix();
  //test the time
  println("end", millis());
}
//class to store a polygon
class poly {
  float[] xs;
  float[] ys;
  float[] zs;
  //takes a float[] of points
  poly(float... points) {
    xs = new float[points.length/3];
    ys = new float[points.length/3];
    zs = new float[points.length/3];
    //go through and save all the points
    for (int i = 0; i<xs.length; i++) {
      xs[i] = points[i*3];
      ys[i] = points[i*3+1];
      zs[i] = points[i*3+2];
    }
  }
}
//this finds roots, it can finds roots that are very close together, and even mono-roots
float[] critRoots(function f, function der, function d2, linear[] maps, float start, float end, boolean testEnds) {
  //linears define the plane that is used to find the roots
  linear[] maps2 = new linear[maps.length];
  for (int i = 0; i<maps.length; i++) {
    //we need to get the slope of each of these for the roots function
    maps2[i] = new linear(0, maps[i].m);
  }
  //we need to test every root of the derivative (critical points) and the endpoints
  float[] crits = concat(new float[]{start}, concat(roots(der, d2, (linear[]) concat(maps, maps2), start, end, false), new float[]{end}));
  //find the evaluation of each of these points
  float[] evals = new float[crits.length];
  ArrayList<Float> roots = new ArrayList<Float>();
  float[] vals = new float[maps.length];
  for (int i = 0; i<evals.length; i++) {
    for (int k = 0; k<maps.length; k++) {
      vals[k] = maps[k].get(crits[i]);
    }
    evals[i] = f.eval(vals);
  }
  //since the file we will export is solid for points where f>0, positive endpoints should be included as roots
  //this gauruntees that the results will have an even number of roots
  if (testEnds && evals[0]>=0) {
    roots.add(start);
  }
  for (int i = 1; i<crits.length; i++) {
    //if any consecutive critical points have different signs, there is a roots that can be found with newton's method
    if (evals[i-1]<0 ^ evals[i]<0) {
      float s = (evals[i-1]-evals[i])/(crits[i-1]-crits[i]);
      roots.add(root(f, der, maps, (-evals[i]/s)+crits[i], abs(crits[i-1]-crits[i])));
      //if there are 3 consecutive points that have the same sign and the middle point is small enough, it is considered as a mono-root
    } else if (i<crits.length-1 && !(evals[i]<0 ^ evals[i+1]<0) && abs(evals[i])<(.5/n)) {
      roots.add(crits[i]-.5/n);
      roots.add(crits[i]+.5/n);
    }
  }
  //check endpoint
  if (testEnds && evals[evals.length-1]>=0) {
    roots.add(end);
  }
  //turn the arraylist into an array
  float[] toReturn = new float[roots.size()];
  for (int i = 0; i<toReturn.length; i++) {
    toReturn[i] = roots.get(i);
  }
  //return it
  return toReturn;
}
//different way to call roots
float[] roots(function f, function der, linear[] maps, float start, float end) {
  return roots(f, der, maps, start, end, true);
}
//find one root of the function using newton's method
float root(function f, function der, linear[] maps, float pos, float range) {
  //time prevent getting stuck in the loop indefinately
  int time = 80;
  //initialize the roots
  float root = pos;
  //used to evaulate the maps, which define the direction being tested
  float[] vals = new float[maps.length];
  float[] derVals = new float[maps.length];
  //set the evaluations. derVals will never change, since the maps are linear
  for (int i = 0; i<maps.length; i++) {
    vals[i] = maps[i].get(root);
    derVals[i] = maps[i].m;
  }
  //create the val
  float val = f.eval(vals);
  //create a storage variable
  float nroot;
  //do the loop. ends when the root is sufficiently small, or it takes too long
  while (abs(val)>(.1/n) && time>0) {
    //find the the intersection of a tangent line to the function and the x axis (relative to the testing line)
    nroot = ((-val)/(der.eval(concat(vals, derVals))))+root;
    root = nroot;
    //reset the map evaluations
    for (int i = 0; i<maps.length; i++) {
      vals[i] = maps[i].get(root);
    }
    //reset the value of the function to this new position
    val = f.eval(vals);
    //lower the time
    time--;
  }
  //return the root
  return root;
}
//linear class - defines a line to take a directional derivative
class linear {
  float m;
  float add;
  //just stores it as slope-intercept form
  linear(float m, float add) {
    this.m = m;
    this.add = add;
  }
  float get(float val) {
    return m*val+add;
  }
}
//this is a different way to take roots
float[] roots(function f, function der, linear[] maps, float start, float end, boolean ends) {
  int n = this.n*8;
  //it evaluates the function at points that divide the range by n 
  float[] vals = new float[n+1];
  //used to store the roots
  ArrayList<Float> roots = new ArrayList<Float>();
  //save the derivative
  function deriv = der;
  //values and derivative values of maps, explained above
  float[] values = new float[maps.length];
  float[] derVals = new float[maps.length];
  for (int i = 0; i<n+1; i++) {
    float pos = start+i*(end-start)/(n);
    for (int k = 0; k<maps.length; k++) {
      values[k] = maps[k].get(pos);
      derVals[k] = maps[k].m;
    }
    //finds the values at each range
    vals[i] = f.eval(values);
  }
  //check the endpoints (if specified)
  if (vals[0]>0 && ends) {
    roots.add(start);
  }
  //go through each root
  for (int i = 0; i<n; i++) {
    if (vals[i]<0 ^ vals[i+1]<0) {
      //if there is a sign change, add the newton's method root
      roots.add(root(f, deriv, maps, start+i*(end-start)/(n), 50.0/n));
    }
  }
  //check the end
  if (vals[n]>0 && ends) {
    roots.add(end);
  }
  //float[] to return
  float[] aroots = new float[roots.size()];
  //save arraylist to the float[]
  for (int i = 0; i<aroots.length; i++) aroots[i] = roots.get(i);
  //return it
  return aroots;
}
void keyPressed() {
  if (key != CODED) {
    if (key == BACKSPACE) {
      if (funct.length()>0) {
        funct = funct.substring(0, funct.length()-1);
      }
    } else if (key == ENTER || key == RETURN) {
      if (setf(funct)) getSides();
    } else {
      funct+=(char) key;
    }
  }
}