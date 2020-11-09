

class Chart {

  int parameter;
  Date date;
  
  Chart(Date date, int parameter) {
    this.parameter=parameter;
    this.date=date;
  }
}

class ChartList extends ArrayList<Chart> {
  String label, block;
  float min, max;

  ChartList(String block, String label) {
    this.label=label;  
    this.block=block;
    min = max = -1;
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
  ChartGraph(float x, float y, float w, float h) {
    super(x, y, w, h);
    chartsList = new ArrayList <ChartList>();
    cursor = posX = 0;
    scaleX = 1;
    setActive(false);
    dragged=0;
    cursorPos=0;
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
    scale(getScaleX(), getScaleY());
    clip((x-1)*getScaleX(), (y-1)*getScaleY(), (width+2)*getScaleX(), (height+2)*getScaleY());
    if (!chartsList.isEmpty()) {
      cursor=int(constrain((mouseX/getScaleX())-x, 0, width));
      stroke(white);
      fill(color(60));
      rect(x, y, width, height-22);
      float prevX=0, prevY=0;
      for (int i=0; i<chartsList.size(); i++) {  //перебираем все добавленные графики
        ChartList chart = chartsList.get(i); //определяем текущий график для отрисовки
        for (int current = 0; current<constrain(width/scaleX, 0, chart.size()-1); current++) {  //перебираем все замеры
          Chart point = chart.get(constrain(current+posX, 0, chart.size()-1));  //определяем замер
          float point_value=y+height-map(point.parameter, chart.min, chart.max, 30, height-10);
          if (i==0)
            stroke(white);
          else if (i==1)
            stroke(blue);
          else if (i==2)
            stroke(red);
          else if (i==3)
            stroke(green);
          else if (i==4)
            stroke(gray);
          else if (i==5)
            stroke(yellow);
          if (current==0)
            point(x+(current*scaleX), point_value);
          else 
          line(prevX, prevY, x+(current*scaleX), point_value);
          prevX= x+(current*scaleX);
          prevY= point_value;
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
          ellipse(x+cursor, y+height-map(chart.parameter, list.min, list.max, 30, height-10), 5, 5);
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
      stroke(white);
      fill(color(60));
      rect(x+map(posX, 0, chartsList.get(0).size(), 0, width), y+height-20, getWidthScroll(), 20);
      
      
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
        posX=int(constrain(posX, 0, chartsList.get(0).size()-width));
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
    }
  }
  void setPosX() {
    posX=int(constrain(map((mouseX/getScaleX())-getWidthScroll()/2, x, x+width, 0, chartsList.get(0).size()-1), 0, chartsList.get(0).size()-width));
  }
  float getWidthScroll() {
    return constrain(width, 0, chartsList.get(0).size()/width+138);
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
