boolean[][] calcer(float[] vals, float[] oldVals, float oy, float y, float z, boolean zdir) {
  int tlength = (vals.length)/2;
  int plength = (oldVals.length)/2;
  boolean[][] clears = new boolean[tlength][];
  boolean[][] iclears = new boolean[plength][];
  for (int n = 0; n<tlength; n++) {
    boolean[] tclears = new boolean[plength];
    for (int k = 0; k<plength; k++) {
      tclears[k] = (vals[n*2]<oldVals[k*2+1] && oldVals[k*2]<vals[n*2+1]);
    }
    clears[n] = tclears;
  }
  for (int n = 0; n<plength; n++) {
    boolean[] pclears = new boolean[tlength];
    for (int k = 0; k<tlength; k++) {
      pclears[k] = clears[k][n];
    }
    iclears[n] = pclears;
  }
  /*
  for (int i = 0; i<clears.length; i++) {
    for (int k = 0; k<clears[i].length; k++) {
      if (clears[i][k]) {
        for (int n = 0;n<iclears[k].length;n++) {
          if (iclears[k][n]) clears[i][k] = true;
        }
      }
    }
  }*/
  return clears;
}
boolean[][] oldcalcer(float[] vals, float[] oldVals, float oy, float y, float z, boolean zdir) {
  int tlength = (vals.length)/2;
  int plength = (oldVals.length)/2;
  function deri = fdxy;
  if (zdir) deri = fdxz;
  boolean[][] clears = new boolean[tlength][];
  for (int n = 0; n<tlength; n++) {
    boolean[] tclears = new boolean[plength];
    for (int k = 0; k<plength; k++) {
      float xt1 = (vals[n*2]+vals[n*2+1])/2;
      float xt2 = (oldVals[k*2]+oldVals[k*2+1])/2;
      float m = (y-oy)/(xt1-xt2);
      /*function sub = new function("("+m+")*(x-("+xt1+"))+("+y+")", "x");
       function test = f.substitute("y", sub);*/
      //linear sub = new linear(m, -xt1*m+y);
      linear subx = new linear(xt2-xt1, xt1);
      linear suby = new linear(oy-y, y);
      linear[] lin = new linear[]{subx, suby, new linear(0, z)};
      if (zdir) lin = new linear[]{subx, new linear(0, z), suby};
      float[] roots = critRoots(f, deriv, deriv2, lin, 0, 1, false);
      if (roots.length/2 == roots.length/2.0) {
        tclears[k] = true;
        for (int p = 0; p<roots.length && tclears[k]; p+=2) {
          tclears[k] = false;
          if (vals.length != oldVals.length) {
            float xi1 = subx.get(roots[p]);
            float xi2 = subx.get(roots[p+1]);
            float yi1 = suby.get(roots[p]);
            float yi2 = suby.get(roots[p+1]);
            float si1 = deri.eval(xi1, yi1, z);
            float si2 = deri.eval(xi2, yi2, z);
            float xint = (yi1-yi2+si2*roots[p+1]-si1*roots[p])/(si2-si1);
            float yint = si1*(xint-roots[p])+yi1;                
            if ((yint<=oy && yint>=y)) {
              if ((xint>vals[n*2] || xint>oldVals[k*2]) && (xint<vals[n*2+1] || xint<oldVals[k*2+1]))
                tclears[k] = true;
            } else {
              float slope = -(roots[p]-roots[p+1])/(yi1-yi2);
              /*function sub2 = new function(slope+"*(y-("+yint+"))+("+xint+")", "y");
               function test2 = f.substitute("x", sub2);*/
              linear sub2 = new linear(slope, -slope*yint+xint);
              float ys = y;
              float ye = oy;
              if (yint<y) ys = yint;
              if (yint>oy) ye = yint;
              linear[] lin2 = new linear[]{sub2, new linear(1, 0), new linear(0, z)};
              if (zdir) lin2 = new linear[]{sub2, new linear(0, z), new linear(1, 0)};
              float[] roots2 = critRoots(f, deriv, deriv2, lin2, ys, ye, false);
              if (roots2.length>0) {
                float y1 = roots2[0];
                float x1 = sub2.get(y1);
                if ((y1<=oy && y1>=y)) {
                  if ((x1>vals[n*2] || x1>oldVals[k*2]) && (x1<vals[n*2+1] || x1<oldVals[k*2+1]))
                    tclears[k] = true;
                }
              }
            }
          }
        }
      }
      if (tlength == plength) tclears[k] = (n==k);
    }
    clears[n] = tclears;
  }
  return clears;
}