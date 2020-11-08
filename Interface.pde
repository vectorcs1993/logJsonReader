Listbox blocksList, parametersList;
SimpleButton loadFile, clear, addChart, removeChart, clearChart;

color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color white = color(255, 255, 255);
color black = color(0, 0, 0);
color gray = color(185, 176, 176);
color yellow = color(100, 255, 0);


void setupInterface() {
  Interactive.make(this);
  blocksList=new Listbox(0, 52, 128, 192, Listbox.BLOCKS, "Блоки:"); 
  parametersList=new Listbox(129, 52, 192, 192, Listbox.PARAMETERS, "Параметры:");
  loadFile = new SimpleButton(1, 1, 160, 30, "Загрузить JSON", new Runnable() {
    public void run() {
       data.clearData();
      selectInput("Select a file is JSON data:", "logSelected");
    }
  }
  );
  clear = new SimpleButton(162, 1, 160, 30, "Очистить JSON", new Runnable() {
    public void run() {
      data.clearData();
    }
  }
  );
   addChart = new SimpleButton(323, 156, 160, 30, "Добавить в график", new Runnable() {
    public void run() {
       String blockStr = blocksList.select.label;
      String parameter = parametersList.select.label;
      data.currentGraph.addChart(data.getChartList(blockStr,parameter));
    }
  }
  );
     removeChart = new SimpleButton(323, 187, 160, 30, "Убрать из графика", new Runnable() {
    public void run() {
       String blockStr = blocksList.select.label;
      String parameter = parametersList.select.label;
      data.currentGraph.removeChart(blockStr, parameter);
    }
  }
  );
     clearChart = new SimpleButton(323, 218, 160, 30, "Очистить график", new Runnable() {
    public void run() {
     //  String blockStr = blocksList.select.label;
      //String parameter = parametersList.select.label;
      
      data.currentGraph.chartsList.clear();
    }
  }
  );
}

class ScaleActiveObject extends ActiveElement {
  int level;

  ScaleActiveObject(float xx, float yy, float ww, float hh) {
    super(xx, yy, ww, hh);
    level = 0;
  }
  ScaleActiveObject(float xx, float yy, float ww, float hh, int level) {
    this(xx, yy, ww, hh);
    this.level = level;
  }
  boolean isActiveSelect() {
    // if (level==world.level)
    return true;
    //else return false;
  }

  boolean isInside(float xx, float yy) {
    if ((xx>x*getScaleX() && xx<x*getScaleX()+width*getScaleX()) &&
      (yy>y*getScaleY() && yy<y*getScaleY()+height*getScaleY()))
      return true;
    else 
    return false;
  }
}

class SimpleButton extends ScaleActiveObject {
  boolean on;
  String text;
  Runnable script;

  SimpleButton (float x, float y, float w, float h, String text, Runnable script, int level) {
    this(x, y, w, h, text, script);
    this.level=level;
  }

  SimpleButton (float x, float y, float w, float h, String text, Runnable script) {
    super(x, y, w, h);
    this.text=text;
    this.script=script;
    level=0;
  }
  void mousePressed () {
    if (isActiveSelect()) {
      if (script!=null)
        script.run();
    }
  }
  void draw () {
    pushMatrix();
    scale(getScaleX(), getScaleY());
    pushStyle();  
    if (hover && isActiveSelect())
      if (mousePressed) 
        stroke(color(90));
      else 
      stroke(white);
    else noStroke();
    if ( on ) fill( white );
    else fill(black);
    rect(x, y, width, height);
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    if ( on ) fill(black);
    else fill(white);
 
    text(text, x+this.width/2, y+this.height/2-textDescent());
    popStyle();
    popMatrix();
  }
}

class Listbox extends ScaleActiveObject {
  ArrayList <ListItem> items;
  float itemHeight = 32;
  int entry=30;
  int listStartAt = 0;
  int hoverItem = -1;
  ListItem select=null;
  float valueY = 0;
  boolean hasSlider = false;
  static final int BLOCKS=0, PARAMETERS=1;
  String label;

  Listbox (float x, float y, float w, float h, int entry, String label) {
    super(x, y, w, h);
    this.entry=entry;
    valueY =y;
    items = new ArrayList <ListItem> ();
    level=0;
    this.label=label;
  }
  Listbox (float x, float y, float w, float h, int entry, int level, String label) {
    this(x, y, w, h, entry, label);
    this.level=level;
  }
  class ListItem {
    String value;
    String label;

    ListItem (String label, String value) {
      this.value=value;
      this.label=label;
    }
  }

  private int getPrevSelect() {

    int prev_select = 0;
    if (items!=null) {
      if (select!=null)
        prev_select=constrain(items.indexOf(select), 0, items.size()-1);
      else 
      prev_select=-1;
      items.clear();
    }

    return prev_select;
  }

  private void setPrevSelect(int prev_select) {
    if (prev_select==-1 || items.isEmpty()) 
      select=null;
    else
      select= items.get(constrain(prev_select, 0, items.size()-1));
    update();
  }

  void loadHelpMessages(StringList list) {
    int prev_select = getPrevSelect();  
    for (String part : list) {
      addItem(part, "");
    }
    setPrevSelect(prev_select);
  }


  public void addItem (String label, String value) {
    items.add(new ListItem (label, value));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }

  public void mouseMoved ( float mx, float my ) {
    if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
    if (hover && isActiveSelect())
      hoverItem = listStartAt + int((my-y*getScaleY()) / (itemHeight*getScaleY()));
  }
  public void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider || !isActiveSelect()) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover && isActiveSelect()) {
      float heightScroll = items.size()*itemHeight-this.height; 
      float hS = heightScroll/itemHeight;
      valueY += constrain(step, -1, 1)*((items.size()*itemHeight)/hS);
      valueY = constrain(valueY, y, y+this.height-itemHeight);
      update();
    }
  }
  void resetScroll() {
    valueY=y;
    update();
  }
  void update () {
    float totalHeight = items.size() * itemHeight;
    float listOffset = (map(valueY, y, y+this.height-itemHeight, 0, totalHeight-this.height));
    listStartAt = int( listOffset / itemHeight );
    listStartAt = constrain(listStartAt, 0, listStartAt);
  }
  public void mousePressed ( float mx, float my ) { 
    if (isActiveSelect()) {
      if (this.items==null) return;
      if (this.items.isEmpty()) return;
      if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
      int pressed=listStartAt + int((my-y*getScaleY())/(itemHeight*getScaleY()));
      if (pressed<this.items.size()) {
        select = items.get(constrain(pressed, 0, items.size()-1));
        onClick(entry);
      } else {
      select=null;
        onClick(entry);
      }  
  }
  }
  boolean hoverNoSlider() {
    if (mouseX<(x+width-20)*getScaleX())
      return true;
    else 
    return false;
  }
  String getSelectInfo() {
    return "no_text";
  }
  void draw () { 
    pushMatrix();
    scale(getScaleX(), getScaleY());
    stroke(white);
    noFill();
    rect(x, y, this.width, this.height);
    if (items!=null) {
      for (int i = 0; i < int(this.height/itemHeight) && i <items.size(); i++) {
        stroke(white);
        if (i+listStartAt==items.indexOf(select))
          fill(white);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? white : black);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(black);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? black : white);
        text(items.get(constrain(i+listStartAt, 0, items.size()-1)).label, x+5, y+(i+1)*itemHeight-5 );
      }
    }
    fill(white);
    text(label+" ("+items.size()+")", x+5, y-3);
    if (items.isEmpty())
      hasSlider = false;
    if (hasSlider) {
      stroke(white);
      fill(black);
      rect(x+this.width-20, y, 20, this.height);
      fill(white);
      rect(x+this.width-20, valueY, 20, 20);
    }
    popMatrix();
  }  
  void onClick(int entry) {
    if (entry==PARAMETERS) {
     

    } else    if (entry==BLOCKS) {
      parametersList.select=null;
      parametersList.select=null;
    }
  }
}

void showScaleText(String text, float x, float y) {
  pushMatrix(); 
  fill(white);
  translate(x*getScaleX(), y*getScaleY());
  scale(getScaleX(), getScaleY());
  text(text, 0, 0);
  popMatrix();
}

void showScaleText(String text, float x, float y, color _color) {
  pushMatrix(); 
  fill(_color);
  translate(x*getScaleX(), y*getScaleY());
  scale(getScaleX(), getScaleY());
  text(text, 0, 0);
  popMatrix();
}
float getScaleX() {
  return (context.width/float(_sizeX));
}
float getScaleY() {
  return (context.height/float(_sizeY));
}
