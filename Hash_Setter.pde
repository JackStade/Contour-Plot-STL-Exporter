HashMap<String, returner> hm = new HashMap<String, returner>();
HashMap<String, dreturner> dm = new HashMap<String, dreturner>();
HashMap<String, dreturner> im = new HashMap<String, dreturner>();
//sets some hashmaps used for evaluating functions and for differentiation rules
void setHash() {
  //hm is used to evaluate operators during function evaluation
  //they take an array of the values that that operator acts on
  hm.put("+", new returner() {
    public float val(float[] args) {
      return args[0]+args[1];
    }
  }
  );
  hm.put("-", new returner() {
    public float val(float[] args) {
      return args[0]-args[1];
    }
  }
  );
  hm.put("*", new returner() {
    public float val(float[] args) {
      if (args[0] == 0 || args[1] == 0) {
        return 0;
      }
      return args[0]*args[1];
    }
  }
  );
  hm.put("/", new returner() {
    public float val(float[] args) {
      return args[0]/args[1];
    }
  }
  );
  hm.put("^", new returner() {
    public float val(float[] args) {
      return pow(args[0], args[1]);
    }
  }
  );
  hm.put("sin", new returner() {
    public float val(float[] args) {
      return sin(args[0]);
    }
  }
  );
  hm.put("cos", new returner() {
    public float val(float[] args) {
      return cos(args[0]);
    }
  }
  );
  hm.put("tan", new returner() {
    public float val(float[] args) {
      return tan(args[0]);
    }
  }
  );
  hm.put("asin", new returner() {
    public float val(float[] args) {
      return asin(args[0]);
    }
  }
  );
  hm.put("acos", new returner() {
    public float val(float[] args) {
      return acos(args[0]);
    }
  }
  );
  hm.put("atan", new returner() {
    public float val(float[] args) {
      return atan(args[0]);
    }
  }
  );
  hm.put("sqrt", new returner() {
    public float val(float[] args) {
      return sqrt(args[0]);
    }
  }
  );
  hm.put("ln", new returner() {
    public float val(float[] args) {
      return log(args[0]);
    }
  }
  );
  //"eval" is a function that does nothing
  hm.put("eval", new returner() {
    public float val(float[] args) {
      return args[0];
    }
  }
  );
  //dm stores the differentiation rules. It has a class that takes the two arguments to the operator and their derivatives and gives the derivative
  dm.put("+", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      //args[2] and args[3] are the positions of the derivatives of the functions in the final array
      return new fpart[]{new fpart("+", args[2], args[3])};
    }
  }
  );
  dm.put("-", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("-", args[2], args[3])};
    }
  }
  );
  dm.put("*", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      //the argument pos is pased to tell what the location of the first part will be in the final array. This is used for more complicated rules.
      //product rule: d/dx a*b = a*db/dx+b*da/dx
      //first part multiplies a with the derivative of b
      //second part mulitplies b with the derivative of a
      //third part adds together the first two
      return new fpart[]{new fpart("*", args[0], args[3]), new fpart("*", args[1], args[2]), new fpart("+", pos, pos+1)};
    }
  }
  );
  dm.put("/", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[1], args[2]), new fpart("*", args[0], args[3]), new fpart("-", pos, pos+1), new fpart("*", args[1], args[1]), 
        new fpart("/", pos+2, pos+3)};
    }
  }
  );
  //note that we have to use a weird rule for power functions, since they are in the for f(x)^g(x)
  dm.put("^", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("^", args[0], args[1]), new fpart("ln", args[0]), new fpart("*", args[3], pos+1), new fpart("/", args[2], args[0]), 
        new fpart("*", pos+3, args[1]), new fpart("+", pos+2, pos+4), new fpart("*", pos, pos+5)};
    }
  }
  );
  dm.put("sin", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      //single argument functions get args[0], the argument, and args[1], its derivative
      return new fpart[]{new fpart("cos", args[0]), new fpart("*", args[1], pos)};
    }
  }
  );
  dm.put("cos", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("sin", args[0]), new fpart("*", args[1], pos), new fpart("VAL", -1), new fpart("*", pos+1, pos+2)};
    }
  }
  );
  dm.put("tan", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("cos", args[0]), new fpart("VAL", 1), new fpart("/", pos+1, pos), new fpart("VAL", 2), new fpart("^", pos+2, pos+3), 
        new fpart("*", pos+4, args[1])};
    }
  }
  );
  dm.put("asin", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("-", pos+1, pos), new fpart("sqrt", pos+2), 
        new fpart("/", pos+1, pos+3), new fpart("*", pos+4, args[1])};
    }
  }
  );
  dm.put("acos", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("-", pos+1, pos), new fpart("sqrt", pos+2), 
        new fpart("/", pos+1, pos+3), new fpart("*", pos+4, args[1]), new fpart("VAL", -1), new fpart("*", pos+5, pos+6)};
    }
  }
  );
  dm.put("atan", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("+", pos+1, pos), new fpart("/", pos+1, pos+2), 
        new fpart("*", pos+3, args[1])};
    }
  }
  );
  dm.put("sqrt", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("sqrt", args[0]), new fpart("VAL", 2), new fpart("*", pos, pos+1), new fpart("VAL", 1), new fpart("/", pos+3, pos+2), 
        new fpart("*", pos+4, args[1])};
    }
  }
  );
  dm.put("ln", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("VAL", 1), new fpart("/", pos, args[0]), new fpart("*", pos+1, args[1])};
    }
  }
  );
  dm.put("eval", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("eval", args[1])};
    }
  }
  );
  //similar to dm, but for implicit differetiation rules, but it needs to seperate the derivatives into the part multiplied by dy/dx and the part that isn't
  im.put("+", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      //the arguments are given as a+b*(dy/dx)
      //the last part is the part multiplied by dy/dx (or whatever variables are being used)
      //second to last part is multiplied by dx/dx, or 1.
      //the arguments are given as:
      //[0] - first argument
      //[1] - second argument
      //[2] - x part of the first argument
      //[4] - x part of the second argument
      //[3] - y part of the first argument
      //[5] - y part of the second argument
      return new fpart[]{new fpart("+", args[2], args[3]), new fpart("+", args[4], args[5])};
    }
  }
  );
  im.put("-", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("-", args[2], args[3]), new fpart("-", args[4], args[5])};
    }
  }
  );
  im.put("*", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[3]), new fpart("*", args[1], args[2]), new fpart("*", args[0], args[5]), new fpart("*", args[1], args[4]), 
        new fpart("+", pos, pos+1), new fpart("+", pos+2, pos+3)}; 
    }
  }
  );
  im.put("/", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[3]), new fpart("*", args[1], args[2]), new fpart("*", args[0], args[5]), new fpart("*", args[1], args[4]), 
        new fpart("-", pos, pos+1), new fpart("-", pos+2, pos+3), new fpart("*", args[1], args[1]), new fpart("/", pos+4, pos+6), new fpart("/", pos+5, pos+6)};
    }
  }
  );
  im.put("^", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("^", args[0], args[1]), new fpart("/", args[1], args[0]), new fpart("*", pos+1, pos+2), new fpart("ln", args[0]), 
        new fpart("*", pos+2, args[2]), new fpart("*", pos+2, args[4]), new fpart("*", pos+3, args[3]), new fpart("*", pos+3, args[5]), 
        new fpart("+", pos+4, pos+5), new fpart("+", pos+6, pos+7)};
    }
  }
  );
  im.put("sin", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      //singe variable operators take:
      //[0] - argument
      //[1] - x part of argument
      //[2] - y part of argument
      return new fpart[]{new fpart("cos", args[0]), new fpart("*", args[1], pos), new fpart("*", args[2], pos)};
    }
  }
  );
  im.put("cos", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("sin", args[0]), new fpart("VAL", -1), new fpart("*", pos, pos+1), new fpart("*", args[1], pos+2), 
        new fpart("*", args[2], pos+2)};
    }
  }
  );
  im.put("tan", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("cos", args[0]), new fpart("VAL", 1), new fpart("/", pos+1, pos), new fpart("VAL", 2), new fpart("^", pos+2, pos+3), 
        new fpart("*", pos+4, args[1]), new fpart("*", pos+4, args[2])};
    }
  }
  );
  im.put("asin", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("-", pos+1, pos), new fpart("sqrt", pos+2), 
        new fpart("/", pos+1, pos+3), new fpart("*", pos+4, args[1]), new fpart("*", pos+4, args[2])};
    }
  }
  );
  im.put("acos", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("-", pos+1, pos), new fpart("sqrt", pos+2), 
        new fpart("/", pos+1, pos+3), new fpart("VAL", -1), new fpart("*", pos+4, pos+5), new fpart("*", args[1], pos+6), new fpart("*", args[2], pos+6)};
    }
  }
  );
  im.put("atan", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("*", args[0], args[0]), new fpart("VAL", 1), new fpart("+", pos+1, pos), new fpart("/", pos+1, pos+2), 
        new fpart("*", pos+3, args[1]), new fpart("*", pos+3, args[2])};
    }
  }
  );
  im.put("sqrt", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("sqrt", args[0]), new fpart("VAL", 2), new fpart("*", pos, pos+1), new fpart("VAL", 1), new fpart("/", pos+3, pos+2), 
        new fpart("*", pos+4, args[1]), new fpart("*", pos+4, args[2])};
    }
  }
  );
  im.put("ln", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("VAL", 1), new fpart("/", pos, args[0]), new fpart("*", pos+1, args[1]), new fpart("*", pos+1, args[2])};
    }
  }
  );
  im.put("eval", new dreturner() {
    public fpart[] vals(float[] args, int pos) {
      return new fpart[]{new fpart("eval", args[1]), new fpart("eval", args[2])};
    }
  }
  );
}
//class used to return arrays
class dreturner {
  fpart[] vals(float[] args, int pos) {
    return new fpart[0];
  }
}
//class used to return values
class returner {
  float val(float[] args) {
    return 0;
  }
}