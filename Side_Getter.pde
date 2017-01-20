//this sets the functions
boolean setf(String funct) {
  try {
    //create the function
    f = new function(funct, "x", "y", "z");
    //define the derivative of the function, the derivate of x is represented as dx... etc
    deriv = f.derive(new mapper[]{new mapper("x", new function("dx", "dx")), new mapper("y", new function("dy", "dy")), new mapper("z", new function("dz", "dz"))});
    //second derivative
    deriv2 = deriv.derive(new mapper[]{new mapper("x", new function("dx", "dx")), new mapper("y", new function("dy", "dy")), new mapper("z", new function("dz", "dz"))});
    //implicit derivatives
    fdxy = f.iderive("x", "y");
    fdxz = f.iderive("x", "z");
    return true;
  } 
  catch (java.lang.ArrayIndexOutOfBoundsException e) {
    return false;
  } 
  catch (java.lang.NullPointerException e) {
    return false;
  }
}
//this does all the work to find all the polygons
void getSides() {
  //reset the array
  sides = new ArrayList<poly>();
  //arrays used to store values that are currently being tested
  float[] vals = new float[0];
  float[] oldVals;
  float[] oldValsz;
  float[] oldValsyz;
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
  for (int i = 0; i<=n; i++) for (int k = 0; k<=n; k++) {
    //if the values are zero, it creates an empty array
    //this gauruntees that the edges will be filled in correctly, and there will be no holes
    if (i == 0 || k == 0) {
      sliceRoots[i][k] = new float[0];
    } else {
      //set the values of y and z
      y = y1+i*(y2-y1)/(n);
      z = z1+k*(z2-z1)/(n);
      //run critRoots to find the roots of the slice
      vals = critRoots(f, deriv, deriv2, new linear[]{new linear(1, 0), new linear(0, y), new linear(0, z)}, x1, x2, true);
      //used to test bugs - there should never be an odd number of roots
      if (floor(vals.length/2.0)*2 != vals.length) println("odd");
      //set that as part of the array
      sliceRoots[i][k] = vals;
    }
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
    //create storing arrays for this slice (though some corrospond to other things)
    doys[iy][iz] = new boolean[tlength];
    dozs[iy][iz] = new boolean[tlength];
    doyzs[iy][iz] = new boolean[tlength];
    firstsy[iy][iz] = new int[tlength];
    lastsy[iy][iz] = new int[tlength];
    firstsz[iy][iz] = new int[tlength];
    lastsz[iy][iz] = new int[tlength];
    firstsyz[iy][iz] = new int[tlength];
    lastsyz[iy][iz] = new int[tlength];
    firstsysz[iy][iz] = new int[plength];
    lastsysz[iy][iz] = new int[plength];
    firstsysyz[iy][iz] = new int[plength];
    lastsysyz[iy][iz] = new int[plength];
    firstszsy[iy][iz] = new int[zlength];
    lastszsy[iy][iz] = new int[zlength];
    connectsy[iy][iz] = new int[tlength];
    connectsz[iy][iz] = new int[tlength];
    connectsyz[iy][iz] = new int[tlength];
    connectsysz[iy][iz] = new int[plength];
    connectsysyz[iy][iz] = new int[plength];
    connectszsy[iy][iz] = new int[zlength];
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
    //now we have to do everything again starting with +1 +0 and connecting to +1 +1 (ysz) and +0 +1 (ysyz)
    for (int n = 0; n<plength; n++) {
      int firstysz = -1;
      int lastysz = -1;
      int firstysyz = -1;
      int lastysyz = -1;
      boolean doprev = n>0;
      for (int k = 0; k<yzlength; k++) {
        if (yszclears[n][k]) {
          if (firstysz == -1) firstysz = k;
          lastysz = k;
        }
      }
      for (int k = 0; k<zlength; k++) {
        if (ysyzclears[n][k]) {
          if (firstysyz == -1) firstysyz = k;
          lastysyz = k;
        }
      }
      int connectysz = n;
      int connectysyz = n;
      if (firstysz>=0) {
        for (connectysz = n; connectysz<plength && yszclears[connectysz][firstysz]; connectysz++);
        connectysz--;
      }
      if (firstysyz>=0) {
        for (connectysyz = n; connectysyz<plength && ysyzclears[connectysyz][firstysyz]; connectysyz++);
        connectysyz--;
      }
      firstsysz[iy][iz][n] = firstysz;
      lastsysz[iy][iz][n] = lastysz;
      firstsysyz[iy][iz][n] = firstysyz;
      lastsysyz[iy][iz][n] = lastysyz;
      connectsysz[iy][iz][n] = connectysz;
      connectsysyz[iy][iz][n] = connectysyz;
    }
    //now with the ranges +0 +1, connecting to +1 +1 (zsy)
    for (int n = 0; n<zlength; n++) {
      int firstzsy = -1;
      int lastzsy = -1;
      for (int k = 0; k<yzlength; k++) {
        if (zsyclears[n][k]) {
          if (firstzsy == -1) firstzsy = k;
          lastzsy = k;
        }
      }
      int connectzsy = n;
      if (firstzsy>=0) {
        for (connectzsy = n; connectzsy<zlength && zsyclears[connectzsy][firstzsy]; connectzsy++);
        connectzsy--;
      }
      firstszsy[iy][iz][n] = firstzsy;
      lastszsy[iy][iz][n] = lastzsy;
      connectszsy[iy][iz][n] = connectzsy;
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
      if (yl == -1) yl = lastsy[i][k][tn];
      if (zl == -1) zl = lastsz[i][k][tn];
      if (yzl == -1) yzl = lastsyz[i][k][tn];
      if (yf != -1) {
        if (zf != -1) {
          if (yzf != -1) {
            //there is a connection to +1 +1, +1 +0, and +0 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i+1][k+1][yzf*2], oy, oz, sliceRoots[i][k+1][zf*2], y, oz));
            println(con, yl, yzl, zl);
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i+1][k+1][yzl*2+1], oy, oz, sliceRoots[i][k+1][zl*2+1], y, oz));
            //fill the gaps between ranges, i.e. if con>tn, and yl>yf, then there is probably a hole that needs to be filled
            //this usually happens when the number of ranges is changing in one or both directions
            fillGaps(new float[][]{sliceRoots[i][k], sliceRoots[i+1][k], sliceRoots[i+1][k+1], sliceRoots[i][k+1]}, 
              new float[]{y, oy, oy, y}, new float[]{z, z, oz, oz}, new int[]{tn, yf, yzf, zf}, new int[]{con, yl, yzl, zl}, 0);
            //set the things that are used
            for (int p = yf; p<=yl; p++) yused[p] = true;
            for (int p = zf; p<=zl; p++) zused[p] = true;
            for (int p = yzf; p<=yzl; p++) yzused[p] = true;
          } else {
            //there is a connection to +1 +0 and +0 +1
            sides.add(new poly(sliceRoots[i][k][tn*2], y, z, sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i][k+1][zf*2], y, oz));
            sides.add(new poly(sliceRoots[i][k][con*2+1], y, z, sliceRoots[i+1][k][yl*2+1], oy, z, sliceRoots[i][k+1][zl*2+1], y, oz));
            sides.add(new poly(sliceRoots[i+1][k][yf*2], oy, z, sliceRoots[i][k+1][zf*2], y, oz, sliceRoots[i][k+1][zl*2+1], y, oz, sliceRoots[i+1][k][yl*2+1], oy, z));
            //fill the gaps. Because there is already a filled part, we won't fill the last edge
            fillGaps(new float[][]{sliceRoots[i+1][k], sliceRoots[i][k], sliceRoots[i][k+1]}, 
              new float[]{oy, y, y}, new float[]{z, z, oz}, new int[]{yf, tn, zf}, new int[]{yl, con, zl}, 1);
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
        int conz = connectsysz[i][k][yn];
        int conyz = connectsysyz[i][k][yn];
        int con = larger(conz, conyz);
        int zf = firstsysz[i][k][yn];
        int yzf = firstsysyz[i][k][yn];
        int zl = lastsysz[i][k][con];
        int yzl = lastsysyz[i][k][con];
        if (zl == -1) zl = lastsysz[i][k][yn];
        if (yzl == -1) yzl = lastsysyz[i][k][yn];
        if (zf != -1) {
          if (yzf != -1) {
            //we are on +1 +0, connections to +1 +1 and +0 +1
            sides.add(new poly(sliceRoots[i+1][k][yn*2], oy, z, sliceRoots[i+1][k+1][zf*2], oy, oz, sliceRoots[i][k+1][yzf*2], y, oz));
            sides.add(new poly(sliceRoots[i+1][k][con*2+1], oy, z, sliceRoots[i+1][k+1][zl*2+1], oy, oz, sliceRoots[i][k+1][yzl*2+1], y, oz));
            sides.add(new poly(sliceRoots[i+1][k][yn*2], oy, z, sliceRoots[i][k+1][yzf*2], y, oz, sliceRoots[i][k+1][yzl*2+1], y, oz, sliceRoots[i+1][k][con*2+1], oy, z));
            //set the ranges that are used
            for (int p = yn; p<=con; p++) yused[p] = true;
            for (int p = zf; p<=zl; p++) yzused[p] = true;
            for (int p = yzf; p<=yzl; p++) zused[p] = true;
          } else {
            //connections to +1 +1
            sides.add(new poly(sliceRoots[i+1][k][yn*2], oy, z, sliceRoots[i+1][k+1][zf*2], oy, oz, sliceRoots[i+1][k+1][zl*2+1], oy, oz, sliceRoots[i+1][k][con*2+1], oy, z));
            //set the ranges that are used
            for (int p = yn; p<=con; p++) yused[p] = true;
            for (int p = zf; p<=zl; p++) yzused[p] = true;
          }
        } else {
          if (yzf != -1) {
            //connection from +1 +0 to +0 +1
            sides.add(new poly(sliceRoots[i+1][k][yn*2], oy, z, sliceRoots[i][k+1][yzf*2], y, oz, sliceRoots[i][k+1][yzl*2+1], y, oz, sliceRoots[i+1][k][con*2+1], oy, z));
            for (int p = yn; p<=con; p++) yused[p] = true;
            for (int p = yzf; p<=yzl; p++) zused[p] = true;
          }
        }
        yn = con;
      }
    }
    for (int zn = 0; zn<zused.length; zn++) {
      if (!zused[zn]) {
        println("z", y, z);
        int con = connectszsy[i][k][zn];
        int yf = firstszsy[i][k][zn];
        int yl = lastszsy[i][k][con];
        if (yf != -1) {
          //there is a connection from +0 +1 to +1 +1
          sides.add(new poly(sliceRoots[i][k+1][zn*2], y, oz, sliceRoots[i+1][k+1][yf*2], oy, oz, sliceRoots[i+1][k+1][yl*2+1], oy, oz, sliceRoots[i][k+1][con*2+1], y, oz));
          for (int p = zn; p<=con; p++) zused[p] = true;
        }
        zn = con;
      }
    }
  }
}