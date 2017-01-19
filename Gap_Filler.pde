//takes the gaps in the ranges and finds how to fill them.
void fillGaps(float[][] vals, float[] ys, float[] zs, int[] firsts, int[] lasts) {
  for (int i = 0; i<vals.length; i++) {
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
      if (!doprev || !connects[k-1-firsts[i]][tfirsts[k-firsts[i]]-firsts[slicen]]) if (tfirsts[k-firsts[i]] != -1) {
        int connect;
        for (connect = k; connect<lasts[i] && connects[connect-firsts[i]][tfirsts[k-firsts[i]]-firsts[slicen]]; connect++);
        connect--;
        sides.add(new poly(vals[i][k*2+2], ys[i], zs[i], vals[i][connect*2+1], ys[i], zs[i], 
          vals[slicen][tlasts[k-firsts[i]]*2+1], ys[slicen], zs[slicen], vals[slicen][tfirsts[k-firsts[i]]*2+2], ys[slicen], zs[slicen]));
      }
    }
  }
}