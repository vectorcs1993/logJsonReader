public class MenuBar {
  JFrame frame;
  JMenuBar menu_bar;
  JMenuItem renameBlock, renameParameter, setType, clearGraph, clear_log, changeColorGraphBackground;


  public MenuBar(PApplet app) {

    frame = (JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas)app.getSurface().getNative()).getFrame();


    menu_bar = new JMenuBar();
    menu_bar.setBackground(Color.WHITE);
    frame.setJMenuBar(menu_bar);

    JMenu import_menu = new JMenu("Лог");
    JMenu block_menu = new JMenu("Блок");
    JMenu parameter_menu = new JMenu("Параметр");
    JMenu graph_menu = new JMenu("График");


    menu_bar.add(import_menu);
    menu_bar.add(block_menu);
    menu_bar.add(parameter_menu);
    menu_bar.add(graph_menu);

    JMenuItem new_file = new JMenuItem("Загрузить лог");
    clear_log = new JMenuItem("Очистить лог");
    JMenuItem action_exit = new JMenuItem("Выход");

    renameBlock = new JMenuItem("Переименовать");

    renameParameter = new JMenuItem("Переименовать");
    setType= new JMenuItem("Изменить");

    clearGraph = new JMenuItem("Очистить");
    changeColorGraphBackground = new JMenuItem("Изменить цвет фона");

    import_menu.add(new_file);
    import_menu.add(clear_log);
    import_menu.addSeparator();
    import_menu.add(action_exit);

    block_menu.add(renameBlock);
    parameter_menu.add(renameParameter);
    parameter_menu.add(setType);

    graph_menu.add(clearGraph);
graph_menu.add(changeColorGraphBackground);
    new_file.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        File log = booster.showFileSelection();
        if (log!=null) 
        data.initData(log);
      }
    }
    );
    clear_log.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        data.clearData();
      }
    }
    );
    action_exit.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        exit();
      }
    }
    );
    renameBlock.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        if (blocksList.select!=null) {
          String label = blocksList.select.label;
          String input = booster.showTextInputDialog("Введите название блока:");
          if (input!=null) {
            data.tags.set(label, input);
            data.saveTagsForJSON();
          }
        }
      }
    }
    );
    renameParameter.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        if (blocksList.select!=null) {
          String label = parametersList.select.label;
          String input = booster.showTextInputDialog("Введите название параметра:");
          if (input!=null) {
            data.tags.set(label, input);
            data.saveTagsForJSON();
          }
        }
      }
    }
    );
    clearGraph.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        data.currentGraph.chartsList.clear();
      }
    }
    );
      changeColorGraphBackground.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        data.currentGraph.colorBackground = booster.showColorPickerAndGetRGB("Выберите цвет:", "Color picking");
      }
    }
    );
    setType.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        String type = booster.showSelectionDialog(
          "Изменение типа данных", 
          "Тип данных", 
          "NONE", "DEC", "BIN", "HEX");
        if (type!=null) {
          String parameter = parametersList.select.label;
          if (type.equals("NONE")) 
          data.types.remove(parameter);
          else 
          data.types.set(parameter, type);
          data.saveTypesForJSON();
        }
      }
    }
    );


    frame.setVisible(true);
  }
  public void update() {
    if (data.log==null) 
      clear_log.setEnabled(false);
    else 
    clear_log.setEnabled(true);

    if (data.currentGraph.chartsList.isEmpty()) {
      clearGraph.setEnabled(false);
      changeColorGraphBackground.setEnabled(false);
    } else {
    clearGraph.setEnabled(true);
    changeColorGraphBackground.setEnabled(true);
    }

    
    if (blocksList.select==null) 
      renameBlock.setEnabled(false);
    else
      renameBlock.setEnabled(true);

    if (parametersList.select==null) {
      renameParameter.setEnabled(false);
      setType.setEnabled(false);
    } else {
      renameParameter.setEnabled(true);
      setType.setEnabled(true);
    }
  }
  public void close() {
    menu_bar.revalidate();
  }
}
