Listbox blocksList, parametersList, currentsCharts;
SimpleButton addChart, removeChart, scaleXUp, scaleXDown, scaleYUp, scaleYDown;

color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color white = color(255, 255, 255);
color black = color(0, 0, 0);

void setupInterface() {
  Interactive.make(this);
  blocksList=new Listbox(0, 32, 128, 192, 32, Listbox.BLOCKS, "Блоки:"); 
  parametersList=new Listbox(131, 32, 192, 192, 32, Listbox.PARAMETERS, "Параметры:");
  currentsCharts=new Listbox(1, 256, 156, 256, 46, Listbox.CHARTS, "Графики:");

  addChart = new SimpleButton(326, 192, 128, 30, "Добавить", new Runnable() {
    public void run() {
      if (data.currentGraph.chartsList.size()<4) {
        String blockStr = blocksList.select.label;
        String parameter = parametersList.select.label;
        data.currentGraph.addChart(data.getChartList(blockStr, parameter));
      } else
        booster.showInfoDialog("Предельное количество графиков достигнуто");
    }
  }
  );
  scaleXUp = new SimpleButton(763, 256, 32, 32, "X+", new Runnable() {
    public void run() {
      data.currentGraph.scaleX(-1);
    }
  }
  );
  scaleXDown = new SimpleButton(763, 290, 32, 32, "X-", new Runnable() {
    public void run() {
      data.currentGraph.scaleX(1);
    }
  }
  );
  scaleYUp = new SimpleButton(763, 324, 32, 32, "Y+", new Runnable() {
    public void run() {
      data.currentGraph.scaleY(-1);
    }
  }
  );
  scaleYDown = new SimpleButton(763, 358, 32, 32, "Y-", new Runnable() {
    public void run() {
      data.currentGraph.scaleY(1);
    }
  }
  );
  removeChart = new SimpleButton(1, 515, 156, 30, "Исключить", new Runnable() {
    public void run() {
      int select = currentsCharts.getNumberSelect();
      if (select!=-1)
      data.currentGraph.chartsList.remove(constrain(select, 0, data.currentGraph.chartsList.size()-1 ));
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
  float itemHeight;
  int entry=30;
  int listStartAt = 0;
  int hoverItem = -1;
  ListItem select=null;
  float valueY = 0;
  boolean hasSlider = false;
  static final int BLOCKS=0, PARAMETERS=1, CHARTS=2;
  String label;
  color colorSelect, colorBackground, colorText;
  Listbox (float x, float y, float w, float h, float itemHeight, int entry, String label) {
    super(x, y, w, h);
    this.entry=entry;
    valueY =y;
    items = new ArrayList <ListItem> ();
    level=0;
    this.label=label;
    this.itemHeight=itemHeight;
    colorText = white;
    colorSelect = color(200);
    colorBackground =color(20);
  }
  Listbox (float x, float y, float w, float h, float itemHeight, int entry, int level, String label) {
    this(x, y, w, h, itemHeight, entry, label);
    this.level=level;
  }
  class ListItem {

    String label;

    ListItem (String label) {

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
  void load(StringList list) {
    int prev_select = getPrevSelect();  
    for (String part : list) {
      addItem(part);
    }
    setPrevSelect(prev_select);
  }
  void reset() {
    resetScroll();
    select = null;
    items.clear();
  }



  public void addItem (String label) {
    items.add(new ListItem (label));
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
  void draw () { 
    pushMatrix();
    scale(getScaleX(), getScaleY());
    stroke(colorSelect);
    noFill();
    rect(x, y, this.width, this.height);
    if (items!=null) {
      for (int i = 0; i < int(this.height/itemHeight) && i <items.size(); i++) {
        stroke(colorSelect);
        if (i+listStartAt==items.indexOf(select))
          fill(colorSelect);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? colorSelect : colorBackground);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(colorBackground);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? colorBackground : colorSelect);  
        String textLabel = items.get(constrain(i+listStartAt, 0, items.size()-1)).label;
        String textDown ="";
        if (entry==CHARTS) {
          for (ChartList chart : data.currentGraph.chartsList) {
            if (chart.label.equals(textLabel)) {
              int number = data.currentGraph.chartsList.indexOf(chart);

              textDown= str(chart.get(constrain(data.currentGraph.cursorPos, 0, chart.size()-1)).parameter);
              fill(data.currentGraph.colors[number]);
              break;
            }
          }
        }
        int h=5;
        if (data.types.hasKey(textLabel)) {
          if (data.types.get(textLabel).equals("HEX"))
            image(HEX, x+1, y+(i+1)*itemHeight-32);
          else if (data.types.get(textLabel).equals("DEC"))
            image(DEC, x+1, y+(i+1)*itemHeight-32);
          else if (data.types.get(textLabel).equals("BIN"))
            image(BINARY, x+1, y+(i+1)*itemHeight-32);
          h+=32;
        }
        if (data.tags.hasKey(textLabel))
          text(data.tags.get(textLabel)+"\n"+textDown, x+h, y+((i+1)*itemHeight)-itemHeight/2);
        else
          text(textLabel+"\n"+textDown, x+h, y+((i+1)*itemHeight)-itemHeight/2);
      }
    }
    fill(white);
    text(label+" ("+items.size()+")", x+5, y-3);
    if (items.isEmpty())
      hasSlider = false;
    if (hasSlider) {
      stroke(colorSelect);
      fill(colorBackground);
      rect(x+this.width-20, y, 20, this.height);
      fill(colorSelect);
      rect(x+this.width-20, valueY, 20, 20);
    }
    popMatrix();
  }  
  int getNumberSelect() {
    if (select!=null) 
      return items.indexOf(select);

    else return -1;
  }
  void onClick(int entry) {
    if (entry==PARAMETERS) {
    } else    if (entry==BLOCKS) {
      parametersList.select=null;
    } else    if (entry==CHARTS) {
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
