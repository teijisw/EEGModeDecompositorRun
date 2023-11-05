public class MyFrame extends javax.swing.JFrame implements ActionListener {

  private final JSplitPane splitPane;  // split the window in top and bottom
  private final JPanel topPanel;       // container panel for the top
  private final JPanel bottomPanel;    // container panel for the bottom
  private final JScrollPane scrollPane; // makes the text scrollable
  private final JTextArea textArea;     // the text
  private final JPanel inputPanel;      // under the text a container for all the input elements
  private final JTextField textField;   // a textField for the text the user inputs
  private final JButton button1;         // and a "send" button
  private final JButton button2;         // and a "send" button
  String data_info;
  public MyFrame() {


    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice defaultScreen = ge.getDefaultScreenDevice();
    Rectangle rect = defaultScreen.getDefaultConfiguration().getBounds();
    int x = (int) rect.getMaxX() - this.getWidth()-400;
    int y = 0;
    this.setLocation(x, y);
    this.setVisible(true);

    splitPane = new JSplitPane();

    topPanel = new JPanel();         // our top component
    bottomPanel = new JPanel();      // our bottom component

    scrollPane = new JScrollPane();  // this scrollPane is used to make the text area scrollable
    textArea = new JTextArea();      // this text area will be put inside the scrollPane

    // the input components will be put in a separate panel
    inputPanel = new JPanel();
    textField = new JTextField();    // first the input field where the user can type his text
    button1 = new JButton("save");    // and a button at the right, to send the text
    button2= new JButton("Time Stamp");    // and a button at the right, to send the text

    setPreferredSize(new Dimension(400, 400));     // let's open the window with a default size of 400x400 pixels
    getContentPane().setLayout(new GridLayout());  // the default GridLayout is like a grid with 1 column and 1 row,
    getContentPane().add(splitPane);               // due to the GridLayout, our splitPane will now fill the whole window

    splitPane.setOrientation(JSplitPane.VERTICAL_SPLIT);  // we want it to split the window verticaly
    splitPane.setDividerLocation(50);                    // the initial position of the divider is 200 (our window is 400 pixels high)
    splitPane.setTopComponent(topPanel);                  // at the top we want our "topPanel"
    splitPane.setBottomComponent(bottomPanel);            // and at the bottom we want our "bottomPanel"

    bottomPanel.setLayout(new BoxLayout(bottomPanel, BoxLayout.Y_AXIS)); // BoxLayout.Y_AXIS will arrange the content vertically

    bottomPanel.add(scrollPane);                // first we add the scrollPane to the bottomPanel, so it is at the top
    scrollPane.setViewportView(textArea);       // the scrollPane should make the textArea scrollable, so we define the viewport
    bottomPanel.add(inputPanel);                // then we add the inputPanel to the bottomPanel, so it under the scrollPane / textArea

    inputPanel.setMaximumSize(new Dimension(Integer.MAX_VALUE, 75));     // we set the max height to 75 and the max width to (almost) unlimited
    inputPanel.setLayout(new BoxLayout(inputPanel, BoxLayout.X_AXIS));   // X_Axis will arrange the content horizontally

    inputPanel.add(button1);           // and right the "send" button
    inputPanel.add(button2);           // and right the "send" button
    button1.addActionListener(this);
    button2.addActionListener(this);
    pack();   // calling pack() at the end, will ensure that every layout and size we just defined gets applied before the stuff becomes visible
  }

  public void actionPerformed(ActionEvent e) {
    if (e.getSource()==button1) {
      data_info = textArea.getText();
      println("data_info=", data_info);
      save_input_text(data_info);
    }

    if (e.getSource()==button2) {
      year = year();
      month = month();
      day = day();
      sec = second();
      min = minute();
      hour = hour();
      date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
      time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);
      println("time stamp:= @"+date+": "+time+":");
      textArea.append("@"+date+": "+time+":");
    }
  }

  public void save_input_text(String _data_info) {
    year = year();
    month = month();
    day = day();
    sec = second();
    min = minute();
    hour = hour();
    date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
    time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

    output5 = createWriter("user_data/" + date_now + "/data_info.txt");                           
    output5.println("saved: @ "+date + ": "+time);
    output5.println(_data_info);
    println("data_info=", _data_info);
    output5.flush();
    textArea.append("Saved @"+date+": "+time+":");
  }
}
