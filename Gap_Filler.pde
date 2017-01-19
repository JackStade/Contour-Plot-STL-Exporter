//takes the gaps in the ranges and finds how to fill them.
//vals is an array containing the 3 or 4 arrays with ranges to fill
//ys is the y value of each array in vals
//zs is like y, but the z coordinate
//firsts is the first connection on each vals
//last is the last one
//end turns off the last range, so it doesn't get double-filled in some cases
void fillGaps(float[][] vals, float[] ys, float[] zs, int[] firsts, int[] lasts, int end) {
  boolean[][] hasFace = new boolean[vals.length][];
  int[][] cons = new int[vals.length][];
  int[][] rfirsts = new int[vals.length][];
  int[][] rlasts = new int[vals.length][];
  for (int i = 0; i<hasFace.length; i++) {
    hasFace[i] = new boolean[vals[i].length];
    cons[i] = new int[vals[i].length];
    rfirsts[i] = new int[vals[i].length];
    rlasts[i] = new int[vals[i].length];
    for (int k = 0; k<hasFace[i].length; k++) {
      hasFace[i][k] = false;
    }
  }
  for (int i = 0; i<vals.length-end; i++) {
    int slicen = 0;
    if (i+1<vals.length) slicen = i+1;
    int[] tfirsts = new int[lasts[i]-firsts[i]];
    int[] tlasts = new int[lasts[i]-firsts[i]];
    boolean[][] connects = new boolean[tfirsts.length][lasts[slicen]-firsts[slicen]];
    for (int k = firsts[i]; k<lasts[i]; k++) {
      float x1 = vals[i][k*2+1];
      float x2 = vals[i][k*2+2];
      int first = -1;
      int last = -1;
      for (int n = firsts[slicen]; n<lasts[slicen]; n++) {
        float x3 = vals[slicen][n*2+1];
        float x4 = vals[slicen][n*2+2];
        if (x1<x4 && x2>x3) {
          last = n;
          if  (first == -1) first = n;
          connects[k-firsts[i]][n-firsts[slicen]] = true;
        } else connects[k-firsts[i]][n-firsts[slicen]] = false;
      }
      tfirsts[k-firsts[i]] = first;
      tlasts[k-firsts[i]] = last;
    }
    for (int k = firsts[i]; k<lasts[i]; k++) {
      boolean donext = k+1<lasts[i];
      boolean doprev = k>firsts[i];
      if (tfirsts[k-firsts[i]] != -1) if (!doprev || !connects[k-1-firsts[i]][tfirsts[k-firsts[i]]-firsts[slicen]]) {
        int connect;
        for (connect = k; connect<lasts[i] && connects[connect-firsts[i]][tfirsts[k-firsts[i]]-firsts[slicen]]; connect++);
        connect--;
        hasFace[i][k] = true;
        cons[i][k] = connect; 
        rfirsts[i][k] = tfirsts[k-firsts[i]]*2+2;
        rlasts[i][k] = tlasts[k-firsts[i]]*2+1;
        /*sides.add(new poly(vals[i][k*2+2], ys[i], zs[i], vals[i][connect*2+1], ys[i], zs[i], 
         vals[slicen][tlasts[k-firsts[i]]*2+1], ys[slicen], zs[slicen], vals[slicen][tfirsts[k-firsts[i]]*2+2], ys[slicen], zs[slicen]));*/
      }
    }
  }
  for (int i = 0; i<vals.length-end; i++) {
    int slicen = 0;
    if (i+1<vals.length) slicen = i+1;
    for (int k = 0; k<vals[i].length; k++) {
      if (hasFace[i][k]) {
        int to = (rfirsts[i][k]-2)/2;
        if (hasFace[slicen][to] && slicen<vals.length-end) {
          hasFace[slicen][to] = false;
          int slicen2 = (slicen+1)%vals.length;
          sides.add(new poly(vals[i][k*2+2], ys[i], zs[i], vals[i][cons[i][k]*2+1], ys[i], zs[i], 
            vals[slicen2][rlasts[slicen][to]], ys[slicen2], zs[slicen2], vals[slicen2][rfirsts[slicen][to]], ys[slicen2], zs[slicen2]));
          sides.add(new poly(vals[i][cons[i][k]*2+1], ys[i], zs[i], vals[slicen][rlasts[i][k]], ys[slicen], zs[slicen], 
            vals[slicen2][rlasts[slicen][to]], ys[slicen2], zs[slicen2]));
          sides.add(new poly(vals[i][k*2+2], ys[i], zs[i], vals[slicen][rfirsts[i][k]], ys[slicen], zs[slicen],
            vals[slicen2][rfirsts[slicen][to]], ys[slicen2], zs[slicen2]));
        } else {
          sides.add(new poly(vals[i][k*2+2], ys[i], zs[i], vals[i][cons[i][k]*2+1], ys[i], zs[i], 
            vals[slicen][rlasts[i][k]], ys[slicen], zs[slicen], vals[slicen][rfirsts[i][k]], ys[slicen], zs[slicen]));
        }
      }
    }
  }
}