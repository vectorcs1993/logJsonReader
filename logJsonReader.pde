import de.bezier.guido.*;
import java.util.Iterator;
import uibooster.*;
import uibooster.components.*;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JMenuItem;
import java.awt.Color;

MenuBar mainMenu;

UiBooster booster;
WaitingDialog waitingDialog;
Data data;
PApplet context = this;
int _sizeX=800;
int _sizeY=600;
Font font;
PImage DEC, BINARY, HEX;


void settings() {
  size(_sizeX, _sizeY, JAVA2D);
  noSmooth ();
}
void setup() {
  DEC = loadImage("data/decimal.png");
  BINARY = loadImage("data/binary.png");
  HEX = loadImage("data/hex.png");
  mainMenu= new MenuBar(this);
  surface.setIcon(loadImage("data/icon.png"));
  surface.setResizable(true);
  surface.setTitle("logJsonReader");
  booster = new UiBooster();
  setupInterface();
  data = new Data ();
  font = new Font("Verdana", Font.PLAIN, 12);
  textSize(13);
}
void draw() {
  background(black);
  mainMenu.update();
  addChart.setActive(false);
  removeChart.setActive(false);
  data.currentGraph.setActive(false); 
  parametersList.setActive(false);
  blocksList.setActive(false);
  currentsCharts.setActive(false);
    scaleXUp.setActive(false);
      scaleXDown.setActive(false);
  if (data.log!=null) {
    blocksList.setActive(true);
    parametersList.setActive(true);
    if (blocksList.select!=null) {
      String blockStr = blocksList.select.label;
      ParamList allParametersForBlock = data.getListBlocks(int(blockStr));
      StringList list = allParametersForBlock.getParameters();
      list.sort();
      parametersList.load(list);
      if (parametersList.select!=null) {
        if (data.currentGraph.chartsList.isEmpty())
        showScaleText("Для просмотра параметра добавьте его в график", 260, 288);
        if (!data.currentGraph.chartsList.contains(data.getChartList(blockStr, parametersList.select.label)))
          addChart.setActive(true);
      } else 
      showScaleText("Выберите параметр", 260, 288);
    } else {
      parametersList.items.clear();
      showScaleText("Выберите блок", 260, 288);
    }
    data.currentGraph.setActive(true);
    if (!data.currentGraph.chartsList.isEmpty()) {
         scaleXUp.setActive(true);
      scaleXDown.setActive(true);
      currentsCharts.load(data.currentGraph.getChartStringList());
      currentsCharts.setActive(true);
      if (currentsCharts.select!=null)
        removeChart.setActive(true);
    }
  } else
    showScaleText("Загрузите лог для просмотра графика", 260, 288);
  String text="";
  if (data.log!=null && data.chartsList.size()>0) {
    text+="log file: "+data.log.getName()+"\n"+
      "start time: "+data.chartsList.get(0).get(0).date.getDate()+"\n"+
      "finish time: "+data.chartsList.get(0).get(data.chartsList.get(0).size()-1).date.getDate()+"\n"+
      "measures: "+data.chartsList.get(0).size()+"\n";
    if (parametersList.select!=null) 
      text+="parameter: "+parametersList.select.label+"\n"+
        "min: "+data.getChartList(blocksList.select.label, parametersList.select.label).getMin()+"\n"+
        "max: "+data.getChartList(blocksList.select.label, parametersList.select.label).getMax()+"\n";
    showScaleText(text, 330, 48);
  }

  showScaleText("FPS: "+int(frameRate)+"\n"
    +"mouse X: "+mouseX+"\n"+"mouse Y: "+mouseY, 649, 196);
}

void mousePressed() {
  mainMenu.close();
}
