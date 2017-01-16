import java.util.*;
//class used to store a function
//is uses a recursive descent parser to save the function as a tree
class function {
  //parts store the tree
  //a part can store a number, a variable, or an operator of previous parts
  fpart[] parts;
  //stores the variables that the function is defined in
  String[] vars;
  //store the position of each variable in the var array
  HashMap<String, Integer> varNums = new HashMap<String, Integer>();
  //turns the function back into a readable string
  String getText() {
    //method for external access
    return getText(parts.length-1);
  }
  String getText(int pos) {
    //method for internal access, this takes the last part of the function, finds the things it is defined by, and then shows that function
    fpart on = parts[pos];
    //here the three types of part are shown, each is a case that behaves differently
    //"VAL" is for a number, like 5.3
    if (on.s.equals("VAL")) {
      return "("+on.v[0]+")";
    } else if (on.s.equals("VAR")) {
      //"VAR" is a number, if the functions vars are x, y, z, then 2 would be z
      return "("+vars[(int) on.v[0]]+")";
    } else {
      //All others are operators that act on a position in the array
      String mid = ""+getText((int) on.v[0]);
      for (int i = 1;i<on.v.length;i++) {
        mid+=", "+getText((int) on.v[i]);
      }
      return on.s+"("+mid+")";
    }
  }
  //substitutes one variable for a number
  function substitute(String var, float val) {
    int vNum = varNums.get(var);
    fpart[] newParts = parts.clone();
    //copy all the arrays so the original is not affected
    for (int i = 0; i<newParts.length; i++) {
      newParts[i] = newParts[i].copy();
    }
    for (int i = 0; i<parts.length; i++) {
      //whenever that variable appears, replace it with the values
      if (parts[i].s.equals("VAR") && parts[i].v[0] == vNum) {
        newParts[i] = new fpart("VAL", val);
      }
    }
    //make a copy of this function with the edited parts
    function ret = new function(newParts, vars.clone(), (HashMap<String, Integer>) varNums.clone());
    //remove the variable from vars and varnums
    ret.rvar(var);
    return ret;
  }
  //substitutes one variable for a function
  function substitute(String var, function val) {
    int vNum = varNums.get(var);
    int pos = val.parts.length-1;
    String[] nvars = vars.clone();
    boolean remove = true;
    HashMap<String, Integer> nvarNums = (HashMap<String, Integer>) varNums.clone();
    //the variable should be removed only if the function val is not defined in that variable
    for (int i = 0; i<val.vars.length; i++) {
      if (varNums.get(val.vars[i]) == null) {
        nvars = concat(vars, new String[]{val.vars[i]});
        nvarNums.put(val.vars[i], nvars.length-1);
      }
      if (val.vars[i] == var) {
        remove = false;
      }
    }
    //copy the parts of this function and of val
    fpart[] newParts = val.parts.clone();
    fpart[] partsCopy = parts.clone();
    for (int i = 0; i<newParts.length; i++) {
      newParts[i] = newParts[i].copy();
    }
    for (int i = 0; i<partsCopy.length; i++) {
      partsCopy[i] = partsCopy[i].copy();
    }
    //reset the variables in the function to substitute to match the numbers of those variables in this function
    for (int i = 0; i<newParts.length; i++) {
      if (newParts[i].s.equals("VAR")) {
        int vpos = (int) newParts[i].v[0];
        int npos = nvarNums.get(val.vars[vpos]);
        newParts[i].v[0] = npos;
      }
    }
    //go throught this function's parts
    //the changed variable needs to be replaced with the evaluation of the new function
    //also, the numbers of operators need to be changed since everything is moved forward to make room for the new function
    for (int i = 0; i<partsCopy.length; i++) {
      if (partsCopy[i].s.equals("VAL")) {
      } else if (partsCopy[i].s.equals("VAR")) {
        if (partsCopy[i].v[0] == vNum) {
          partsCopy[i] = new fpart("eval", pos);
        }
      } else {
        for (int k = 0; k<partsCopy[i].v.length; k++) {
          partsCopy[i].v[k]+=pos+1;
        }
      }
    }
    //create a new function
    function ret = new function((fpart[]) concat(newParts, partsCopy), nvars, nvarNums);
    if (remove) {
      //remove the variable if neccessary
      ret.rvar(var);
    }
    return ret;
  }
  void rvar(String var) {
    //this removes a variable
    //reset varnumes
    int vNum = varNums.get(var);
    varNums.remove(vNum);
    for (int i = vNum; i<vars.length; i++) {
      varNums.put(vars[i], varNums.get(vars[i])-1);
    }
    //remove the last element of vars
    String[] store = vars;
    vars = new String[vars.length-1];
    arrayCopy(store, 0, vars, 0, vNum);
    arrayCopy(store, vNum+1, vars, vNum, vars.length-vNum);
    //variables coming after that var in the array need to be adjusted
    for (int i = 0; i<parts.length; i++) {
      if (parts[i].s.equals("VAR")) {
        if (parts[i].v[0]>vNum) {
          parts[i].v[0]--;
        }
      }
    }
  }
  //takes the implicit derivative
  function iderive(String var, String var2) {
    //this works with any two variables, and will return dvar2/dvar2
    //I will use var = x and var2 = y to explain, and assume the function = z (so z=f(x, y), find dy/dx)
    //get the numbers of the derivatives
    int vNum = varNums.get(var);
    int v2Num = varNums.get(var2);
    //copy this function
    fpart[] newParts = parts.clone();
    //array to store the parts
    ArrayList<fpart> dparts = new ArrayList<fpart>();
    //positions of the derivatives
    int[] dposes = new int[parts.length];
    //number to add to all the parts
    //the original function is kept, with the differentiating stuff added on the end
    int add = parts.length;
    //finish copying
    for (int i = 0; i<newParts.length; i++) {
      newParts[i] = newParts[i].copy();
    }
    for (int i = 0; i<newParts.length; i++) {
      //go through the parts, apply the implicit differentiator to each
      //save the string for the part
      String f = newParts[i].s;
      if (f.equals("VAL")) {
        //values turn into 0+0*dy/dx
        dparts.add(new fpart("VAL", 0));
        dparts.add(new fpart("VAL", 0));
        dposes[i] = dparts.size()-1+add;
      } else if (f.equals("VAR")) {
        if (newParts[i].v[0] == vNum) {
          //if the variable is the first one, it is 1+0*dy/dx
          dparts.add(new fpart("VAL", 1));
          dparts.add(new fpart("VAL", 0));
          dposes[i] = dparts.size()-1+add;
        } else if (newParts[i].v[0] == v2Num) {
          //if the variable is the second one, it is 0+1*dy/dx
          dparts.add(new fpart("VAL", 0));
          dparts.add(new fpart("VAL", 1));
          dposes[i] = dparts.size()-1+add;
        } else {
          //other variables are just 0
          dparts.add(new fpart("VAL", 0));
          dparts.add(new fpart("VAL", 0));
          dposes[i] = dparts.size()-1+add;
        }
      } else {
        //operators are more difficult
        //get the returner for this operator
        dreturner ret = im.get(f);
        //these store the sets of first and second derivatives
        //this allows for arbitrarily large numbers of arguments
        //and makes one and two argument operators get handeled in the same way
        float[] dvals = new float[newParts[i].v.length];
        float[] dvals2 = new float[newParts[i].v.length];
        //set the arguments
        for (int k = 0; k<dvals.length; k++) dvals[k] = dposes[(int) parts[i].v[k]]-1;
        for (int k = 0; k<dvals2.length; k++) dvals2[k] = dposes[(int) parts[i].v[k]];
        //create the set of parts to add
        fpart[] toAdd = ret.vals(concat(newParts[i].v, concat(dvals, dvals2)), add+dparts.size());
        //go through these parts and add them to the set
        for (int k = 0; k<toAdd.length; k++) {
          dparts.add(toAdd[k]);
        }
        //set the possition
        dposes[i] = dparts.size()-1+add;
      }
    }
    //turn the arraylist into an array
    fpart[] nparts = new fpart[dparts.size()];
    for (int i = 0; i<nparts.length; i++) {
      nparts[i] = dparts.get(i);
    }
    //this is the position of the last part
    int pos = add+nparts.length-1;
    //add a part at the end that solves for dy/dx in 0 = a+b*dy/dx
    fpart[] lastPart = {new fpart("/", pos-1, pos), new fpart("VAL", -1), new fpart("*", pos+1, pos+2)};
    //return all the things set together
    return new function((fpart[]) concat(newParts, concat(nparts, lastPart)), vars, varNums);
  }
  //derives with respect to one variable
  function derive(String var) {
    return derive(new mapper(var, new function("1")));
  }
  //derives with the derivatives of each variable being set as a function
  //variables not defined will have derivatives set to zero
  function derive(mapper... derivs) {
    //copy the parts
    fpart[] newParts = parts.clone();
    //create a new arraylist for the parts
    ArrayList<fpart> dparts = new ArrayList<fpart>();
    //create an array of positions of derivatives of each part
    int[] dposes = new int[parts.length];
    //this is added to the positions of the array, since the main function parts are copied and put at the start of the final array
    int add = parts.length;
    //this is the number of variables at the start
    int vnums = vars.length;
    //clone varnums
    HashMap<String, Integer> nvarNums = (HashMap<String, Integer>) varNums.clone();
    //clone vars
    String[] nvars = vars.clone();
    //go through the vars and add the derivative of each variable, will be substituted in later
    for (int i = 0; i<vnums; i++) {
      nvarNums.put("DERIV"+nvars[i], vnums+i);
      String[] store = nvars;
      nvars = new String[nvars.length+1];
      arrayCopy(store, nvars, store.length);
      nvars[vnums+i] = "DERIV"+nvars[i];
    }
    //finish copying
    for (int i = 0; i<newParts.length; i++) {
      newParts[i] = newParts[i].copy();
    }
    //go through each part
    for (int i = 0; i<newParts.length; i++) {
      //this is the string for that part
      String f = newParts[i].s;
      if (f.equals("VAL")) {
        //the derivative of a value is 0
        dparts.add(new fpart("VAL", 0));
        dposes[i] = dparts.size()-1+add;
      } else if (f.equals("VAR")) {
        //the derivative of a variable is saved as the derivative of that variable, and then substituted later
        dparts.add(new fpart("VAR", newParts[i].v[0]+vnums));
        dposes[i] = dparts.size()-1+add;
      } else {
        //for an operator, find the derivative rule for it
        dreturner ret = dm.get(f);
        //create an array and fill it with the derivative of the variables in that operator
        float[] dvals = new float[newParts[i].v.length];
        for (int k = 0; k<dvals.length; k++) dvals[k] = dposes[(int) parts[i].v[k]];
        //get the vals from the returner
        fpart[] toAdd = ret.vals(concat(newParts[i].v, dvals), add+dparts.size());
        //add each element in the array to the arraylist
        for (int k = 0; k<toAdd.length; k++) {
          dparts.add(toAdd[k]);
        }
        //set the position
        dposes[i] = dparts.size()-1+add;
      }
    }
    //turn dparts into an array
    fpart[] nparts = new fpart[dparts.size()];
    for (int i = 0; i<nparts.length; i++) {
      nparts[i] = dparts.get(i);
    }
    //create a function with the concatenated parts and the nvars and varnumes
    function toReturn =  new function((fpart[]) concat(newParts, nparts), nvars, nvarNums);
    //look for a mapper that has each variable. If one exists, substitute that variables's derivative with the function in the mapper
    //otherwise set it to zero
    for (int i = vnums; i<nvars.length; i++) {
      function toSub = new function("0");
      for (int k = 0;k<derivs.length;k++) {
        if (derivs[k].v.equals(vars[i-vnums])) {
          toSub = derivs[k].f;
        }
      }
      toReturn = toReturn.substitute(nvars[i], toSub);
    }
    //return it
    return toReturn;
  }
  //evaluates the function with certain variables
  float eval(float... args) {
    float[] vals = new float[parts.length]; 
    for (int i = 0; i<parts.length; i++) {
      String f = parts[i].s; 
      if (f.equals("VAL")) {
        vals[i] = parts[i].v[0];
      } else if (f.equals("VAR")) {
        vals[i] = args[(int) parts[i].v[0]];
      } else {
        returner ret = hm.get(f); 
        float[] v = new float[parts[i].v.length]; 
        for (int k = 0; k<v.length; k++) {
          v[k] = vals[(int) parts[i].v[k]];
        }
        vals[i] = ret.val(v);
      }
    }
    return vals[vals.length-1];
  }
  //this is how the function is built
  fpart[] getParts(String start, int used) {
    //first paren
    int paren = start.indexOf('('); 
    //used to find which operators are inside parens
    int pars = 0; 
    int p = 0;
    boolean[] inPars = new boolean[start.length()]; 
    //extra is if a function has an extra set of parens, like (x^2)
    boolean extra = true; 
    //find which characters are inside parens
    while (p<inPars.length) {
      if (start.charAt(p) == '(') {
        pars++;
      } else if (start.charAt(p) == ')') {
        pars--;
      }
      if (pars == 0) {
        inPars[p] = false; 
        if (p+1<inPars.length) {
          extra = false;
        }
      } else {
        inPars[p] = true;
      }
      p++;
    }
    //if there is an extra, remove the extra parens
    if (extra && start.length()>2) {
      start = start.substring(1, start.length()-1); 
      return getParts(start, used);
    } else {
      //the character of the operator to find
      char chUse = ','; 
      int pos = 0; 
      boolean loop = true; 
      boolean ret = false;
      //the types of operators
      //the order in the arrays determins order of operations
      char[] type1s = {'+', '*', '^'}; 
      char[] type2s = {'-', '/', '^'}; 
      //for each operator...
      for (int n = 0; n<type1s.length && loop; n++) {
        //start at the end so that 3-4+5=4, not -6
        for (int i = start.length()-1; i>0 && loop; i--) {
          //a couple of things need to be checked so that numbers like 5E-7 are counted as one number
          //only find the operator if it is outside the parens
          if (!inPars[i] && (i == 0 || start.charAt(i-1) != 'E')) {
            //the character to use
            char ch = start.charAt(i); 
            //println(ch, type1s[i]);
            //if it is the character being tested for
            if (ch == type1s[n] || ch == type2s[n]) {
              //stop looping and set that as the character to use
              chUse = ch; 
              loop = false; 
              ret = true; 
              pos = i;
            }
          }
        }
      }
      //if there is an operator like + or *, otherwise there is a function like sin (or an error)
      if (ret) {
        //get two sets of parts
        //the ends specify what the end of that string is, so that the operator can reference it
        fpart[] h1 = getParts(start.substring(0, pos), used); 
        int end1 = h1.length-1+used; 
        //used shows how many parts are actually used
        used+=h1.length; 
        fpart[] h2 = getParts(start.substring(pos+1), used); 
        int end2 = h2.length-1+used; 
        //return the two halves, and then the operator
        return (fpart[]) concat(h1, concat(h2, new fpart[]{new fpart(""+chUse, end1, end2)}));
      } else {
        if (paren == 0) println("Error-Illegal Paretheses"); 
        if (paren>0) {
          //in a function like sin(x+y), this will find paren=3, so front = sin, which is the function
          String front = start.substring(0, paren); 
          String end = start.substring(paren, start.length()); 
          //h1 is the stuff inside the function
          fpart[] h1 = getParts(end, used); 
          int val = h1.length-1+used; 
          //array for the inside, then the function
          return (fpart[]) concat(h1, new fpart[]{new fpart(front, val)});
        } else {
          //otherwise, the remaining thing is a variable or a number
          String s = "VAL"; 
          float v = 0; 
          try {
            //if it is parseable as a number, then it makes it a val
            v = Float.valueOf(start);
          } 
          catch (NumberFormatException e) {
            //otherwise, it is a variable
            v = varNums.get(start); 
            s = "VAR";
          }
          //return it
          return new fpart[]{new fpart(s, v)};
        }
      }
    }
  }
  //constructors for functions
  //this is user-used constructor
  function(String val, String... vars) {
    //set up vars and varnums
    this.vars = vars; 
    for (int i = 0; i<vars.length; i++) {
      varNums.put(vars[i], i);
    }
    parts = getParts(val, 0);
  }
  //this is for differentiating methods and such to create a function directly
  function(fpart[] parts, String[] vars, HashMap<String, Integer> varNums) {
    //just sets everything to the values specified
    this.varNums = varNums; 
    this.parts = parts; 
    this.vars = vars;
  }
}
//class that maps a variable and a function, for specifying derivatives to derive
class mapper {
  //stores a string and function
  String v; 
  function f; 
  mapper(String var, function f) {
    v = var; 
    this.f = f;
  }
}
//part of a function, either a variable, operator, or value
class fpart {
  //s is the string, either VAL, VAR, or an operator like + or sin
  String s; 
  //the array of values, the value in VAL, the variable number in VAR, and the positions of the arguments for operators
  float[] v; 
  fpart(String s, float... v) {
    this.s = s; 
    this.v = v;
  }
  //method to copy it
  fpart copy() {
    return new fpart(s, v.clone());
  }
}