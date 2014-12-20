import java.util.ArrayList;


public class CONFIG{
  public static String TITLE = "Dance Dance Re-Revolution";
  public static String GRAPH_FILE_NAME = "./graph.txt";
    public static int MAX_DATAPOINTS = 200;
  
  public static float[] MENU_RECTANGLE_DIMENSIONS = {
    (.1666666f),//x coord
    (.125f),//y coord
    (.6666666f),//width
    (.125f)//height
  };
  
  enum KEYBINDS
  {
    NW(103,new int[]{0,100,100,100}), N(104,new int[]{0,100,100,100}), NE(105,new int[]{0,100,100,100}),
    W(100,new int[]{0,100,100,100}), C(101,new int[]{0,100,100,100}), E(102,new int[]{0,100,100,100}),
    SW(97,new int[]{0,100,100,100}), S(98,new int[]{0,100,100,100}), SE(99,new int[]{0,100,100,100});
    
    private int value;
    private int[] colour;
  
    private KEYBINDS(int value, int[] colour) {
      this.value = value;
      this.colour = colour;
    }
    
    public void setValue(int value){
      this.value = value;
    }
    
    public int getValue(){
      return value;
    }
    
    public static KEYBINDS getFromValue(int code){
      for(KEYBINDS e : KEYBINDS.values()){
        if(code == e.value) return e;
      }
      return null;
    }
      
    public void setColour(int[] colour){
      this.colour = colour;
    }
    
    public int[] getColours(){
      return colour;
    }
  };
  
  //paths that osc can pass data through
  enum paths {
    SEND(new ArrayList<String>()), RECIEVE(new ArrayList<String>());

    ArrayList<String> pathVal;

    private paths(ArrayList<String> pathVal) {
      this.pathVal = pathVal;
    }

    public void add(String value) {
      this.pathVal.add(value);
    }

    public void remove(int index) {
      this.pathVal.remove(index);
    }

    public void clear() {
      this.pathVal.clear();
    }

    public ArrayList<String> get() {
      return this.pathVal;
    }

    public String get(int index) {
      return this.pathVal.get(index);
    }
    
    public static paths getFromValue(String code){
      for(paths e : paths.values()){
        if(code.equals(e.pathVal)) return e;
      }
      return null;
    }

    public void set(ArrayList<String> newPaths) {
      this.pathVal = newPaths;
    }

    public void set(int index, String value) {
      this.pathVal.set(index, value);
    }

  };
}
