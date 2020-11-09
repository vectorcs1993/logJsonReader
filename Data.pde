

class Data extends JSONArray {
  StringList allBlocks;
  static final String KEY_PRIMARY = "NumberBlock", DATE="DateTime";
  ArrayList <ChartList> chartsList;
  StringDict tags;
  ChartGraph currentGraph;
  File log;
  Data() {
    super();
    chartsList = new ArrayList <ChartList>();
    allBlocks = new StringList();
    currentGraph=new ChartGraph (128, 256, 664, 320);
    tags = new StringDict();
    log=null;
  }

  public void clearData() {
    currentGraph.chartsList.clear();
    currentGraph.setActive(false); 
    log=null;
    allBlocks.clear();
    blocksList.items.clear();
    parametersList.items.clear();
    for (int i=this.size()-1; i>0; i--) //удаляет все JSON объекты из собственного списка
      this.remove(i);
  }
  public void initData(File log) {
    this.log=log;
    String [] parse = loadStrings(log);
    for (String str : parse) {
      JSONObject object = parseJSONObject(str);
      this.append(object);  //добавляем к массиву объектов
      if (object.hasKey(KEY_PRIMARY)) {
        String block = str(object.getInt(KEY_PRIMARY));
        if (!allBlocks.hasValue(block))
          allBlocks.append(block);
      }
    }
    allBlocks.sort();
    blocksList.load(allBlocks);
    for (String block : allBlocks) {
      ParamList allParametersForBlock = getListBlocks(int(block));
      for (String parameter : allParametersForBlock.getParameters())
        chartsList.add(allParametersForBlock.createChart(block, parameter));
    }
    JSONObject label= loadJSONObject("data/labels.json");                      //создает словарь тэгов
    for (java.lang.Object s : label.keys()) {
      String keyValue = s.toString();
      this.tags.set(keyValue, label.getString(keyValue));
    }
  }
  public void saveTagsForJSON() {                                              //сохраняет пространство имен в файл data/labels.json
    JSONObject labels = new JSONObject();
    for (String part : tags.keys()) 
      labels.setString(part, tags.get(part));
    saveJSONObject(labels, "data/labels.json");
  }
  ChartList getChartList(String block, String parameter) {                     //возвращает график по блоку и параметру
    for (ChartList charts : chartsList) { 
      if (charts.block==block && charts.label==parameter)
        return charts;
    }
    return null;
  }
  ParamList getListBlocks(int num) {       
    ParamList objects= new ParamList(); 
    for (int i = 0; i < this.size(); i++) {
      JSONObject object = this.getJSONObject(i);
      if (object.getInt(KEY_PRIMARY)==num)
        objects.add(object);
    }
    return objects;
  }
}


class ParamList extends ArrayList <JSONObject> {

  ParamList() {
    super();
  }


  StringList getParameters() {
    StringList parameters = new StringList();
    for (JSONObject object : this) {
      for (java.lang.Object s : object.keys()) { //создает множество хранящее все параметры за исключением даты
        String keyIndex = s.toString();
        if (!keyIndex.equals(Data.DATE) && !keyIndex.equals(Data.KEY_PRIMARY)) {
          if (!parameters.hasValue(keyIndex))
            parameters.append(keyIndex);
        }
      }
    }
    return parameters;
  }
  ChartList createChart(String block, String parameterKey) {
    ChartList chart = new ChartList(block, parameterKey);
    for (JSONObject object : this) {
      int parameterValue = object.getInt(parameterKey);
      String dateStr = object.getString(Data.DATE);
      int day = int(dateStr.substring(0, 2));
      int month = int(dateStr.substring(3, 5));
      int year = int(dateStr.substring(6, 10));
      int hour = int(dateStr.substring(11, 13));
      int min = int(dateStr.substring(14, 16));
      int sec = int(dateStr.substring(17));
      Date date = new Date (sec, min, hour, day, month, year);
      chart.add(new Chart(date, parameterValue));
    }
    chart.update();
    return chart;
  }
}
void logSelected(File selection) {
  if (selection != null) 
    data.initData(selection);
}
