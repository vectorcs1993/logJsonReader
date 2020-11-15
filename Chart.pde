

class Chart {

  int parameter;
  Date date;


  Chart(Date date, int parameter) {
    this.parameter=parameter;
    this.date=date;
  }
}

class ChartList extends ArrayList<Chart> {
  String label, block, type;
  float min, max;
  float prevX, prevY;  //служебные
  static final int DECIMAL=0, BINARY=1, HEX=2, NONE=3;

  ChartList(String block, String label) {
    this.label=label;  
    this.block=block;
    min = max = -1;
    type="NONE";
  }
  void update() {
    min = getMin();
    max = getMax();
  }

  IntList getIntList() {
    IntList list = new IntList();
    for (Chart chart : this)
      list.append(chart.parameter);
    return list;
  }
  float getMax() {
    return getIntList().max();
  }
  float getMin() {
    return getIntList().min();
  }
}

class ChartGraph extends ScaleActiveObject {
  float dragged;
  int cursor, posX, scaleX, cursorPos;
  private ArrayList <ChartList> chartsList;

  color colorBackground;
  color [] colors = new color [4];

  ChartGraph(float x, float y, float w, float h) {
    super(x, y, w, h);
    chartsList = new ArrayList <ChartList>();
    cursor = posX = 0;
    scaleX = 1;
    setActive(false);
    dragged=0;
    cursorPos=0;
    colorBackground= color(60);
    colors[0]=white;
    colors[1]=blue;
    colors[2]=red;
    colors[3]=green;
  }

  StringList getChartStringList() {
    StringList charts = new StringList();
    for (ChartList list : chartsList) 
      charts.append(list.label);
    return charts;
  }

  void addChart(ChartList chart) {
    boolean add=true;
    for (int i = chartsList.size()-1; i>=0; i--) {
      ChartList list = chartsList.get(i);
      if (list.block.equals(chart.block) && list.label.equals(chart.label))
        add=false;
    }
    if (add)
      chartsList.add(chart);
  }


  void removeChart(String block, String parameter) {
    for (int i = chartsList.size()-1; i>=0; i--) {
      ChartList list = chartsList.get(i);
      if (list.block.equals(block) && list.label.equals(parameter))
        chartsList.remove(list);
    }
  }



  void draw() { 
    pushMatrix();
    pushStyle();
    clip((x-1)*getScaleX(), (y-1)*getScaleY(), (width+2)*getScaleX(), (height+2)*getScaleY());
    scale(getScaleX(), getScaleY());
    if (chartsList.size()>0) {
      cursor=int(constrain((mouseX/getScaleX())-x, 0, width));
      stroke(white);
      fill(colorBackground);
      rect(x, y, width, height-22);
      for (ChartList chart : chartsList) { 
        chart.prevX=0;
        chart.prevY=0;
      }
      for (int current = 0; current<width; current++) {  //перебираем все замеры
        for (int i=0; i<chartsList.size(); i++) {  //перебираем все добавленные графики
          ChartList chart = chartsList.get(i); //определяем текущий график для отрисовки
          Chart point = chart.get(constrain(current+posX, 0, chart.size()-1));  //определяем замер
          float point_value=y+height-map(point.parameter, 0, chart.max, 30, height-10);

          stroke(colors[i]);
          if (chartsList.indexOf(chart)==currentsCharts.getNumberSelect())
            strokeWeight(3);
          if (current==0)
            point(x+(current*scaleX), point_value);
          else 
          line(chart.prevX, chart.prevY, x+(current*scaleX), point_value);
          strokeWeight(1);
          chart.prevX= x+(current*scaleX);
          chart.prevY= point_value;
        }
      }
      if (hover) {
        stroke(black);
        line(x+cursor, y, x+cursor, y+height);
        cursorPos = constrain(posX+cursor/scaleX, 0, chartsList.get(0).size()-1);
        for (ChartList list : chartsList) {
          fill(white);
          Chart chart = list.get(constrain(cursorPos, 0, list.size()-1));
          ellipseMode(CENTER);
          ellipse(x+cursor, y+height-map(chart.parameter, 0, list.max, 30, height-10), 5, 5);
        }
        fill(black);
        String textCursor = "time: "+chartsList.get(0).get(cursorPos).date.getDate();
        float posText = x+cursor+5;
        if (x+cursor>x+width-textWidth(textCursor))
          posText-=textWidth(textCursor)+10;
        fill(white);
        stroke(black);
        rect(posText-3, y+constrain((mouseY/getScaleY())-y+32, 20, height-55)-16, textWidth(textCursor)+6, 20);
        fill(black);
        text(textCursor, posText, y+constrain((mouseY/getScaleY())-y+32, 20, height-55));
      }
      if (!chartsList.isEmpty()) {
        if (!chartsList.get(0).isEmpty()) {
          stroke(white);
          fill(color(60));
          rect(x+map(posX, 0, chartsList.get(0).size()-1, 0, width), y+height-20, getWidthScroll(), 20);
        }
      }
    }
    noClip();
    popStyle();
    popMatrix();
  }
  void  mouseDragged (float mx, float my) {
    if ((mouseY/getScaleY())<y+height-20) {
      if (mouseButton==RIGHT) {
        if (mx>dragged)
          posX-=2;
        else
          posX+=2;
        constrainPosX();
        dragged=mx;
      }
    } else {
      if (mouseButton==LEFT) 
        setPosX();
    }
  }
  void mousePressed() {
    if (mouseButton==RIGHT) {
      if (mouseY<y+height-20)
        dragged=mouseX;
    } else if (mouseButton==LEFT) {
      if (mouseX>x*getScaleX() && mouseY>(y+height-20)*getScaleY() && mouseX<(x+width)*getScaleX())
        setPosX();
    }
  }
  void mouseScrolled (float step) {
    if (hover) {
      scaleX+=-step;
      scaleX=constrain(scaleX, 1, 10);
      constrainPosX();
    }
  }
  void constrainPosX() {
    posX=int(constrain(posX, 0, chartsList.get(0).size()-(width/scaleX)));
  }
  void setPosX() {
   posX = int(map((mouseX/getScaleX())-getWidthScroll()/2, x, x+width, 0, chartsList.get(0).size()-1));
   constrainPosX();
  }
  float getWidthScroll() {
    float widthScale = chartsList.get(0).size()*scaleX;
    return width/constrain(widthScale/width, 0, widthScale);
  }
}
class Date {
  int second, minute, hour, day, month, year;
  Date (int second, int minute, int hour, int day, int month, int year) {
    this.second=second;
    this.minute=minute;
    this.hour=hour;
    this.day=day;
    this.month=month;
    this.year=year;
  }
  String isNotZero(int num) {
    if (num<10)
      return "0"+str(num);
    else
      return str(num);
  }
  String getDateNotTime() {
    return  isNotZero(day)+"."+isNotZero(month)+"."+year;
  }
  String getDate() {
    return  isNotZero(hour)+":"+isNotZero(minute)+":"+isNotZero(second)+" "+isNotZero(day)+"."+isNotZero(month)+"."+year;
  }
}
