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
  static final int DECIMAL=0, BINARY=1, HEX=2, NONE=3;
  ChartList(String block, String label) {
    this();
    this.label=label;  
    this.block=block;
  }
  ChartList() {
    label=block="";
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
  float getMax() {      //возвращает максимальное значение параметров из списка
    return getIntList().max();
  }
  float getMin() {      //возвращает минимальное значение параметров из списка
    return getIntList().min();
  }
  float getMiddle() {  //возвращает среднее значение параметров из списка
    float sum=0;
    for (Chart chart : this)
      sum+=chart.parameter;  
    return sum/this.size();
  }
  ChartList getNextPoints(int point, int size) {
    ChartList points = new ChartList();
    point = constrain(point, 0, this.size()-2);
    size = constrain(size, 1, this.size()-point);
    for (int i = point; i<size; i++)
      points.add(this.get(i));
    return points;
  }
}
class ChartGraph extends ScaleActiveObject {
  int cursor, posX, scaleX, cursorPos, scaleY;
  private ArrayList <ChartList> chartsList;
  color colorBackground;
  color [] colors = new color [4];
  ChartGraph(float x, float y, float w, float h) {
    super(x, y, w, h);
    chartsList = new ArrayList <ChartList>();
    cursor = posX = 0;
    scaleX = 1;
    scaleY=1;
    setActive(false);
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
    clip((x-1)*getScaleX(), (y-1)*getScaleY()-32, (width+2)*getScaleX(), (height+2)*getScaleY()+32);
    scale(getScaleX(), getScaleY());
    if (chartsList.size()>0) {
      cursor=int(constrain((mouseX/getScaleX())-x, 0, width));
      stroke(white);
      strokeWeight(1);
      fill(colorBackground);
      noStroke();
      rect(x, y, width, height-22);
      int size = chartsList.size();
      float prevX[] = new float [size];
      float prevY[] = new float [size];
      float prevTimeX = 0;
      prevX[0]=prevY[0]=0;
      pushStyle();
      for (int currentX = 0; currentX<width; currentX++) {                          //перебираем все замеры
        for (int i=0; i<size; i++) {                                                //перебираем все добавленные графики
          ChartList chart = chartsList.get(i);                                       //определяем текущий график для отрисовки
          int n = constrain(int(map(currentX+posX, 0, chart.size()/scaleX, 0, chart.size()-1)), 0, chart.size()-1);  //определяем замер
          Chart point = chart.get(n);                                            //извлекаем замер
          float pointX = x+currentX;                                              //определяем координату по Х
          float pointY=y+height-map(point.parameter, 0, chart.max, 30+scaleY*10, height-10-scaleY*10);        //определяем координату по Y
          strokeWeight(1);                                                         //определяем стандартную толщину
          if (point.date.second==0) {                                                  //каждую секунду отделяем линией
             String time = point.date.getTime();
            float timeX = pointX-textWidth(time)/2;
            if (timeX>=prevTimeX && timeX>=x && timeX+textWidth(time)<x+width) {
            stroke(colorBackground+40);  
            line(pointX, y, pointX, y+height-22);
              fill(white);
              text(time, timeX, y-5);
              prevTimeX=pointX+textWidth(time)/2+5;
            }
          }
          stroke(colors[i]);                                                      //определяем цвет для закрашивания
          if (chartsList.indexOf(chart)==currentsCharts.getNumberSelect())          //проверяем выбран является ли график выбранным, если да, то
            strokeWeight(3);                                                    //определяем для графика усиленную толщину
          if (currentX==0)                                                        //если первый замер
            point(pointX, pointY);                                               //рисуем точку
          else                                                                 //если последующий замер
          line(prevX[i], prevY[i], pointX, pointY);              //соединяем с предыдущим замером линией
          prevX[i] = pointX;                      //обновляем служебную переменную по Х (делаем предшествующую точку текущей)
          prevY[i] = pointY;                      //обновляем служебную переменную по Y (делаем предшествующую точку текущей)
        }
      }
      popStyle();
      if (hover) {
        stroke(black);
        line(x+cursor, y, x+cursor, y+height);
        cursorPos = constrain(int(map(cursor+posX, 0, chartsList.get(0).size()/scaleX, 0, chartsList.get(0).size()-1)), 0, chartsList.get(0).size()-1);    
        for (ChartList list : chartsList) {
          fill(white);
          Chart chart = list.get(constrain(cursorPos, 0, list.size()-1));
          ellipseMode(CENTER);
          ellipse(x+cursor, y+height-map(chart.parameter, 0, list.max, 30+scaleY*10, height-10-scaleY*10), 5, 5);
        }
        fill(black);
        String textCursor = "time: "+chartsList.get(0).get(cursorPos).date.getTime();
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
      noFill();
      stroke(white);
      rect(x, y, width, height-22);
    }
    noClip();
    popStyle();
    popMatrix();
  }
  void  mouseDragged (float mx, float my) {
    if (mouseButton==LEFT) {
      if (mouseX>x*getScaleX() && mouseY>(y+height-20)*getScaleY() && mouseX<(x+width)*getScaleX())
        setPosX();
    }
  }
  void mousePressed() {
    if (mouseButton==LEFT) {
      if (mouseX>x*getScaleX() && mouseY>(y+height-20)*getScaleY() && mouseX<(x+width)*getScaleX())
        setPosX();
    }
  }
  void mouseScrolled (float step) {
    if (hover) {
      posX+=step*50;
      constrainPosX();
    }
  }
  void scaleX(int step) {
    scaleX+=step;
    scaleX=constrain(scaleX, 1, int(chartsList.get(0).size()/width));
    constrainPosX();
  }
  void scaleY(int step) {
    scaleY+=step;
    scaleY=int(constrain(scaleY, 0, (height-40)/30));
  }
  void constrainPosX() {
    posX=int(constrain(posX, 0, (chartsList.get(0).size()-width*scaleX)/scaleX));
  }
  void setPosX() {
    posX = int(map((mouseX/getScaleX())-getWidthScroll()/2, x, x+width, 0, chartsList.get(0).size()-1));
    constrainPosX();
  }
  float getWidthScroll() {
    float widthScale = chartsList.get(0).size()/scaleX; 
    return map(widthScale-width, chartsList.get(0).size(), 0, 0, width);
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
  String getTime() {
    return  isNotZero(hour)+":"+isNotZero(minute)+":"+isNotZero(second);
  }
}
