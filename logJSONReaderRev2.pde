import de.bezier.guido.*;
import java.util.Iterator;
Data data;
PApplet context = this;
int _sizeX=800;
int _sizeY=600;

void settings() {
  size(_sizeX, _sizeY, P2D);
  smooth(0);
  PJOGL.setIcon("data/icon.png");
}

void setup() {
  surface.setResizable(true);
  setupInterface();
  data = new Data ();
  //  selectInput("Select a file is JSON data:", "logSelected");
}

void draw() {
  background(black);
  clearChart.setActive(false);
  addChart.setActive(false);
  removeChart.setActive(false);
  data.currentGraph.setActive(false); 
  parametersList.setActive(false);
  blocksList.setActive(false);
  if (data.log!=null) {
    blocksList.setActive(true);
    parametersList.setActive(true);

    if (blocksList.select!=null) {
      String blockStr = blocksList.select.label;
      ParamList allParametersForBlock = data.getListBlocks(int(blockStr));
      StringList list = allParametersForBlock.getParameters();
      list.sort();
      parametersList.loadHelpMessages(list);
      if (parametersList.select!=null) {
        data.currentGraph.setActive(true);
        clearChart.setActive(true);
        addChart.setActive(true);
        removeChart.setActive(true);

        if (!data.currentGraph.chartsList.isEmpty()) {
          float y = 280; 
          for (ChartList chart : data.currentGraph.chartsList) {
            int number = data.currentGraph.chartsList.indexOf(chart);
            color fill = 0;
            if (number==0)
              fill=white;
            else if (number==1)
              fill=blue;
            else if (number==2)
              fill=red;
            else if (number==3)
              fill=green;
            else if (number==4)
              fill=gray;
            showScaleText(chart.label+":\n"+str(chart.get(data.currentGraph.cursorPos).parameter), 15, y+(number*32), fill);
          }
        } else 
        showScaleText("Добавьте параметр в график", width/2-100, height/2);
      } else
        showScaleText("Выберите параметр", width/2-100, height/2);
    } else {
      parametersList.items.clear();
      showScaleText("Выберите блок", width/2-100, height/2);
    }
  } else
    showScaleText("Загрузите лог для просмотра графика", width/2-100, height/2);
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
    +"mouse X: "+mouseX+"\n"+"mouse Y: "+mouseY, 649, 96);
}
