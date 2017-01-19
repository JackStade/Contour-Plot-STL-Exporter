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
//used to initialized things
void setup() {
  //create a window for drawing with an opengl 3D renderer.
  size(1000, 600, P3D);
  //this is the string that is the actual function we want to solve
  //this will be solved f = 0
  String funct = "(sin(x)+sin(y)+sin(z))";
  //sets up differentiation rules
  setHash();
  //create the function
  f = new function(funct, "x", "y", "z");
  //define the derivative of the function, the derivate of x is represented as dx... etc
  deriv = f.derive(new mapper[]{new mapper("x", new function("dx", "dx")), new mapper("y", new function("dy", "dy")), new mapper("z", new function("dz", "dz"))});
  //second derivative
  deriv2 = deriv.derive(new mapper[]{new mapper("x", new function("dx", "dx")), new mapper("y", new function("dy", "dy")), new mapper("z", new function("dz", "dz"))});
  //implicit derivatives
  fdxy = f.iderive("x", "y");
  fdxz = f.iderive("x", "z");
  //set the framerate
  frameRate(60);
  //turn on lights
  lights();
}
//draw gets called once a second (or less often if it takes more than a second to execute)
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
  //re-initialize/reset polygon array
  sides = new ArrayList<poly>();
  //clear everything on screen
  background(255);
  //arrays used to store values that are currently being tested
  float[] vals = new float[0];
  float[] oldVals;
  float[] oldValsz;
  float[] oldValsyz;
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
  //initialize variables
  float y = y1, oy;
  float z = z1, oz;
  //used to store how things connect and should be meshed
  int[][][] firstsy = new int[n+1][n+1][];
  int[][][] lastsy = new int[n+1][n+1][];
  int[][][] firstsz = new int[n+1][n+1][];
  int[][][] lastsz = new int[n+1][n+1][];
  int[][][] firstsyz = new int[n+1][n+1][];
  int[][][] lastsyz = new int[n+1][n+1][];
  int[][][] firstsysz = new int[n+1][n+1][];
  int[][][] lastsysz = new int[n+1][n+1][];
  int[][][] firstsysyz = new int[n+1][n+1][];
  int[][][] lastsysyz = new int[n+1][n+1][];
  int[][][] firstszsy = new int[n+1][n+1][];
  int[][][] lastszsy = new int[n+1][n+1][];
  int[][][] connectsy = new int[n+1][n+1][];
  int[][][] connectsz = new int[n+1][n+1][];
  int[][][] connectsyz = new int[n+1][n+1][];
  int[][][] connectsysz = new int[n+1][n+1][];
  int[][][] connectsysyz = new int[n+1][n+1][];
  int[][][] connectszsy = new int[n+1][n+1][];
  //used to prevent polygons from being draw multiple times
  boolean[][][] doys = new boolean[n+1][n+1][];
  boolean[][][] dozs = new boolean[n+1][n+1][];
  boolean[][][] doyzs = new boolean[n+1][n+1][];
  //the actual roots of the function
  float[][][] sliceRoots = new float[n+1][n+1][];
  //go through different slices
  for (int i = 0; i<n; i++) for (int k = 0; k<=n; k++) {
    //set the values of y and z
    y = y1+i*(y2-y1)/(n);
    z = z1+k*(z2-z1)/(n);
    //run critRoots to find the roots of the slice
    vals = critRoots(f, deriv, deriv2, new linear[]{new linear(1, 0), new linear(0, y), new linear(0, z)}, x1, x2, true);
    //used to test bugs - there should never be an odd number of roots
    if (floor(vals.length/2.0)*2 != vals.length) println("odd");
    //set that as part of the array
    sliceRoots[i+1][k] = vals;
    //the first set in y is empty so that the edges get filled in.
    //if we didn't do this, there would be a hole in the bottom of our file
    if (i == 0) sliceRoots[i][k] = new float[0];
  }
  //this is used to figure out how things connect
  for (int iy = 0; iy<=n; iy++) for (int iz = 0; iz<=n; iz++) {
    //set y, z, and the values of y and z for the next slices
    y = y1+iy*(y2-y1)/(n);
    oy = y1+(iy+1)*(y2-y1)/(n);
    z = z1+iz*(z2-z1)/(n);
    oz = z1+(iz+1)*(z2-z1)/(n);
    vals = sliceRoots[iy][iz];
    //at the edges, the sets are set to empty
    if (iy<n) {
      oldVals = sliceRoots[iy+1][iz];
    } else {
      oldVals = new float[0];
    }
    if (iz<n) {
      oldValsz = sliceRoots[iy][iz+1];
    } else {
      oldValsz = new float[0];
    }
    if (iz<n && iy<n) {
      oldValsyz = sliceRoots[iy+1][iz+1];
    } else {
      oldValsyz = new float[0];
    }
    //lengths of arrays
    //sets of 2 points corrospond
    int tlength = (vals.length)/2;
    int plength = (oldVals.length)/2;
    int zlength = (oldValsz.length)/2;
    int yzlength = (oldValsyz.length)/2;
    //use the clear finder the find which ranges get connected
    //this is how it tells how to connect it up at the end
    boolean[][] clears = calcer(vals, oldVals);
    boolean[][] zclears = calcer(vals, oldValsz);
    boolean[][] yzclears = calcer(vals, oldValsyz);
    boolean[][] yszclears = calcer(oldVals, oldValsyz);
    boolean[][] ysyzclears = calcer(oldVals, oldValsz);
    boolean[][] zsyclears = calcer(oldValsz, oldValsyz);
    //create storing arrays for this slice
    doys[iy][iz] = new boolean[tlength];
    dozs[iy][iz] = new boolean[tlength];
    doyzs[iy][iz] = new boolean[tlength];
    firstsy[iy][iz] = new int[tlength];
    lastsy[iy][iz] = new int[tlength];
    firstsz[iy][iz] = new int[tlength];
    lastsz[iy][iz] = new int[tlength];
    firstsyz[iy][iz] = new int[tlength];
    lastsyz[iy][iz] = new int[tlength];
    connectsy[iy][iz] = new int[tlength];
    connectsz[iy][iz] = new int[tlength];
    connectsyz[iy][iz] = new int[tlength];
    for (int n = 0; n<tlength; n++) {
      //a lot of stuff here I used to use to draw things before I had the 3D polygon drawing.
      /*ellipse(vals[2*n], y, .1, .1);
       ellipse(vals[2*n+1], y, .1, .1);*/
      //this takes the connections and finds the first and last things that are connect
      int first = -1;
      int last = -1;
      int firstz = -1;
      int lastz = -1;
      int firstyz = -1;
      int lastyz = -1;
      boolean doprev = n>0;
      boolean donext = n<tlength-1;
      /*stroke(0, 255, 0);
       ellipse(vals[n*2+1], y, (x2-x1)/128, (y2-y1)/128);
       ellipse(vals[n*2], y, (x2-x1)/128, (y2-y1)/128);
       stroke(0);*/
      //find the first and last connections in y
      for (int k = 0; k<plength; k++) {
        if (clears[n][k]) {
          if (first == -1) first = k;
          last = k;
        }
      }
      //find the first and last connections in y
      for (int k = 0; k<zlength; k++) {
        if (zclears[n][k]) {
          if (firstz == -1) firstz = k;
          lastz = k;
        }
      }
      //find the first and last connections in y and z
      for (int k = 0; k<yzlength; k++) {
        if (yzclears[n][k]) {
          if (firstyz == -1) firstyz = k;
          lastyz = k;
        }
      }
      //find how ranges on the same slice connect
      int connecty = n;
      int connectz = n;
      int connectyz = n;
      //only do this if it connects to one thing in that direction, and if it is the one before it doesn't connect
      //the second test prevent double-drawing of polygons
      if (first>=0) {
        for (connecty = n; connecty<tlength && clears[connecty][first]; connecty++);
        connecty--;
      }
      if (firstz>=0) {
        for (connectz = n; connectz<tlength && zclears[connectz][firstz]; connectz++);
        connectz--;
      }
      if (firstyz>=0) {
        for (connectyz = n; connectyz<tlength && yzclears[connectyz][firstyz]; connectyz++);
        connectyz--;
      }
      //save everything
      doys[iy][iz][n] = first != -1 && (!doprev || !clears[n-1][first]);
      dozs[iy][iz][n] = firstz != -1 && (!doprev || !zclears[n-1][firstz]);
      doyzs[iy][iz][n] = firstyz != -1 && (!doprev || !yzclears[n-1][firstyz]);
      firstsy[iy][iz][n] = first;
      lastsy[iy][iz][n] = last;
      firstsz[iy][iz][n] = firstz;
      lastsz[iy][iz][n] = lastz;
      firstsyz[iy][iz][n] = firstyz;
      lastsyz[iy][iz][n] = lastyz;
      connectsy[iy][iz][n] = connecty;
      connectsz[iy][iz][n] = connectz;
      connectsyz[iy][iz][n] = connectyz;
    }
  }
  //actually create the polygons
  for (int i = 0; i<connectsy.length; i++) for (int k = 0; k<connectsy[0].length; k++) {
    y = y1+i*(y2-y1)/(n);
    oy = y1+(i+1)*(y2-y1)/(n);
    z = z1+k*(z2-z1)/(n);
    oz = z1+(k+1)*(z2-z1)/(n);
    //these numbers tell which how far in the array has been paired
    int tn = 0;
    //these store the ranges that have not been connected too
    int ylength = 0;
    int zlength = 0;
    int yzlength = 0;
    if (i<connectsy.length-1) ylength = connectsy[i+1][k].length;
    if (k<connectsy[0].length-1) zlength = connectsy[i][k+1].length;
    if (i<connectsy.length-1 && k<connectsy[0].length-1) yzlength = connectsy[i+1][k+1].length;
    boolean[] yused = new boolean[ylength];
    boolean[] zused = new boolean[zlength];
    boolean[] yzused = new boolean[yzlength];
    for (int p = 0; p<ylength; p++) yused[p] = false;
    for (int p = 0; p<zlength; p++) zused[p] = false;
    for (int p = 0; p<yzlength; p++) yzused[p] = false;
    //this loops through the ranges
    for (tn = 0; tn<connectsy[i][k].length; tn++) {
      int cony = connectsy[i][k][tn];
      int conz = connectsz[i][k][tn];
      int conyz = connectsyz[i][k][tn];
      int con = larger(cony, larger(conz, conyz));
      int yf = firstsy[i][k][tn];
      int zf = firstsz[i][k][tn];
      int yzf = firstsyz[i][k][tn];
      int yl = lastsy[i][k][con];
      int zl = lastsz[i][k][con];
      int yzl = lastsyz[i][k][con];
      if (yf != -1) {
        if (zf != -1) {
          if (yzf != -1) {
            //there is a connection to +1 +1, +1 +0, and +0 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i+1][k+1][yzf*2], oy, oz, sliceRoots[i][k+1][zf*2], y, oz));
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz, sliceRoots[i][k+1][zl*2+1], y, oz));
            fillGaps(new float[][]{sliceRoots[i][k], sliceRoots[i+1][k], sliceRoots[i+1][k+1], sliceRoots[i][k+1]}, 
              new float[]{y, oy, oy, y}, new float[]{z, z, oz, oz}, new int[]{tn, yf, yzf, zf}, new int[]{con, yl, yzl, zl});
            //set the things that are used
            for (int p = yf; p<=yl; p++) yused[p] = true;
            for (int p = zf; p<=zl; p++) zused[p] = true;
            for (int p = yzf; p<=yzl; p++) yzused[p] = true;
          } else {
            //there is a connection to +1 +0 and +0 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i][k+1][zf*2], y, oz));
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i][k+1][zl*2+1], y, oz));
            sides.add(new poly(sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i][k+1][zf*2], y, oz, sliceRoots[i][k+1][zl*2+1], y, oz, sliceRoots[i+1][k][yl*2+1], oy, z));
            //set the things that are used
            for (int p = yf; p<=yl; p++) yused[p] = true;
            for (int p = zf; p<=zl; p++) zused[p] = true;
          }
        } else {
          if (yzf != -1) {
            //there is a connection to +1 +1 and +1 +0
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i+1][k+1][yzf*2], oy, oz));
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz));
            sides.add(new poly(sliceRoots[i+1][k+1][yzf*2], oy, oz, sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz));
            //set the things that are used
            for (int p = yf; p<=yl; p++) yused[p] = true;
            for (int p = yzf; p<=yzl; p++) yzused[p] = true;
          } else {
            //there is a connection to +1 +0
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i+1][k][yf*2], oy, z));
            //set the things that are used
            for (int p = yf; p<=yl; p++) yused[p] = true;
          }
        }
      } else {
        if (zf != -1) {
          if (yzf != -1) {
            //connections to +0 +1 and +1 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k+1][zf*2], y, oz, sliceRoots[i+1][k+1][yzf*2], oy, oz));
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i][k+1][zl*2+1], y, oz, sliceRoots[i+1][k+1][yzl*2+1], oy, oz));
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz, sliceRoots[i+1][k+1][yzf*2], oy, oz));
            //set the things that are used
            for (int p = zf; p<=zl; p++) zused[p] = true;
            for (int p = yzf; p<=yzl; p++) yzused[p] = true;
          } else {
            //connection to +0 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k][con*2+1], y, z, sliceRoots[i][k+1][zl*2+1], y, oz, sliceRoots[i][k+1][zf*2], y, oz));
            //set the things that are used
            for (int p = zf; p<=zl; p++) zused[p] = true;
          }
        } else {
          if (yzf != -1) {
            //connection to +1 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz, sliceRoots[i+1][k+1][yzf*2], oy, oz));
            //set the things that are used
            for (int p = yzf; p<=yzl; p++) yzused[p] = true;
          } else {
            //no connections
          }
        }
      }
      tn = con;
    }
    //now we go through the things that were not already accounted for
    for (int yn = 0; yn<yused.length; yn++) {
      if (!yused[yn]) {
      }
    }
  }
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