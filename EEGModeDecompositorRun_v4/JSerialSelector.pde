import javax.swing.*;
import java.awt.Dimension;
import java.awt.BorderLayout;
import java.awt.event.*;
import processing.serial.*;
import javax.swing.filechooser.*;

Serial port;

public class JSerialSelector extends JFrame implements ActionListener {
  JFrame frame = new JFrame("Title");
  JComboBox combo1;
  JComboBox combo2;
  JComboBox combo3;
  JComboBox combo4;
  JComboBox combo5;
  JComboBox combo6;
  JComboBox combo7;
  JComboBox combo8;

  //JButton button_start;
  JButton button_stop;
  //JButton file_select;
  JToggleButton btn;
  JLabel label;
  JLabel label2;
  JLabel label3;

  JTextArea textarea2;
  File file;
  String[] portName;

  Serial port;
  String selected_port;
  String selected_mode;
  String selected_imfk ="6";
  String selected_dmode ="EMD";
  String Y_Max1 = "1000";
  String Y_Max2 = "1000";
  String selected_imf1 = "IMF-1";
  String selected_imf2 = "None";

  int selected_mode_flag = 0;
  int start_flag = 0;
  int stop_flag = 0;
  int binary_save_flag = 0;
  int file_select_flag = 0;
  JLabel l1, l2, l3, l4, l42, l5, l6, l7, l8;

  JSerialSelector() {
    //Serial port;
    //String[] startTime = {"08:00","09:00","10:00","11:00", "12:00","13:00",
    //            "14:00","15:00","16:00","17:00","18:00","19:00"};

    String[] dmodes = {"EMD", "VMD", "EWT", "WMD"};
    String[] imfk = {"6", "5", "4", "3", "2"};
    String[] imfs1 = {"IMF-1", "IMF-2", "IMF-3", "IMF-4", "IMF-5", "IMF-6"};
    String[] imfs2 = {"None", "IMF-1", "IMF-2", "IMF-3", "IMF-4", "IMF-5", "IMF-6"};
    String[] y_max1 = {"1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000", "20000"};
    String[] y_max2 = {"1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000", "20000"};

    portName = new String[Serial.list().length];
    for (int i = 0; i< Serial.list().length; i++) {
      portName[i] =  Serial.list()[i];
      println("port["+i+"]=:", portName[i]);
    }

    String[] portNames = {};
    ;
    portNames = (String[])append(portNames, "");
    portNames = concat(portNames, Serial.list());

    String[] ports = portNames;
    String[] modes = {"Clinical", "Demo", "Review"};

    //button_start = new JButton("Start");
    button_stop = new JButton("Exit");
    //file_select = new JButton("file select");

    combo1 = new JComboBox(ports);
    combo1.setPreferredSize(new Dimension(300, 30));

    combo2 = new JComboBox(modes);
    combo2.setPreferredSize(new Dimension(120, 30));

    combo3 = new JComboBox(dmodes);
    combo3.setPreferredSize(new Dimension(120, 30));

    combo4 = new JComboBox(imfk);
    combo4.setPreferredSize(new Dimension(120, 30));

    combo5 = new JComboBox(imfs1);
    combo5.setPreferredSize(new Dimension(120, 30));

    combo6 = new JComboBox(imfs2);
    combo6.setPreferredSize(new Dimension(120, 30));

    combo7 = new JComboBox(y_max1);
    combo7.setPreferredSize(new Dimension(100, 30));

    combo8 = new JComboBox(y_max2);
    combo8.setPreferredSize(new Dimension(100, 30));

    btn = new JToggleButton("Binary Data Save");

    textarea2 = new JTextArea();
    textarea2.setLineWrap(true);

    JScrollPane scrollpane = new JScrollPane(textarea2);
    scrollpane.setPreferredSize(new Dimension(400, 300));


    combo1.addActionListener(this);
    combo2.addActionListener(this);
    combo3.addActionListener(this);
    combo4.addActionListener(this);
    combo5.addActionListener(this);
    combo6.addActionListener(this);
    combo7.addActionListener(this);
    combo8.addActionListener(this);

   // button_start.addActionListener(this);
    button_stop.addActionListener(this);
    //file_select.addActionListener(this);
    btn.addActionListener(this);

    JPanel p = new JPanel();
    l1 = new JLabel("Serial Port");
    l2 = new JLabel("Data Source");
    l3 = new JLabel("D-Mode");
    l4 = new JLabel("N of IMF");
    l42 = new JLabel("--------------------------------------------------");
    l5 = new JLabel("1st-IMF");
    l6 = new JLabel("2nd-IMF");
    l7 = new JLabel("HS1 Y-Max");
    l8 = new JLabel("HS2 Y-Max");

    //p.add(new JLabel("Com Port, Mode, & D-Mode:"));
    p.add(l1);
    p.add(combo1);
    p.add(l2);
    p.add(combo2);
    p.add(l3);
    p.add(combo3);
    p.add(l4);
    p.add(combo4);
    p.add(l42);
    p.add(l5);
    p.add(combo5);
    p.add(l6);
    p.add(combo6);
    p.add(l7);
    p.add(combo7);
    p.add(l8);
    p.add(combo8);

    p.add(btn);
   // p.add(button_start);
    p.add(button_stop);
    //p.add(file_select);
    p.add(scrollpane);

    label = new JLabel();
    JPanel labelPanel = new JPanel();
    labelPanel.add(label);

    getContentPane().add(p, BorderLayout.CENTER);
    getContentPane().add(labelPanel, BorderLayout.PAGE_END);
  }

  public String getPort() {
    return selected_port;
  }

  public String getMode() {
    return selected_mode;
  }

  public Serial getSerial() {
    return port;
  }

  public String getImfK() {
    return selected_imfk;
  }

  public String getdMode() {
    return selected_dmode;
  }

  public String getImf1() {
    return selected_imf1;
  }

  public String getImf2() {
    return selected_imf2;
  }

  public int getMode_Flag() {
    return selected_mode_flag;
  }

  public String get_Y_Max1() {
    return Y_Max1;
  }

  public String get_Y_Max2() {
    return Y_Max2;
  }

  public int getStart_Flag() {
    return start_flag;
  }

  public int getStop_Flag() {
    return stop_flag;
  }

  public int getBinary_Save_Flag() {
    return binary_save_flag;
  }

  public int getFile_Select_Flag() {
    start_flag = 1;
    return file_select_flag;
  }

  public File getFile() {

    return file;
  }

  public void actionPerformed(ActionEvent e) {


    if (e.getSource()==button_stop) {
      println("Stop Button Pushed!");
      stop_flag = 1;
      exit();   
          } else {

      if (e.getSource()==btn) {
        if (btn.isSelected()) {
          btn.setText("Binary Data Save ON");
          binary_save_flag = 1;
        } else {
          btn.setText("Binary Data Save");
          binary_save_flag = 0;
        }
      }
    }
    //--} else if (e.getSource()==button_start) {
      //if (file_select_flag == 1) {
   //--   println("Start Button Pushed!");
    //--  start_flag = 1;
      //} else {
      //  println("Choose Data File!");
      //  JLabel label2 = new JLabel("Please Select Data File!");
      //  label2.setForeground(Color.RED);
      //  JOptionPane.showMessageDialog(this, label2);
      //}
      
    if (e.getSource()== combo3) {
      selected_dmode = (String)combo3.getSelectedItem();
    } else if (e.getSource()==  combo4) {
      selected_imfk = (String)combo4.getSelectedItem();
    } else if (e.getSource()==  combo5) {
      selected_imf1 = (String)combo5.getSelectedItem();
      if (selected_imf1 == "IMF-6" && int(selected_imfk) < 6) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf1 == "IMF-5" && int(selected_imfk) < 5) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf1 == "IMF-4" && int(selected_imfk) < 4) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf1 == "IMF-3" && int(selected_imfk) < 3) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf1 == "IMF-2" && int(selected_imfk) < 2) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
    } else if (e.getSource()==  combo6) {
      selected_imf2 = (String)combo6.getSelectedItem();
      if (selected_imf2 == "IMF-6" && int(selected_imfk) < 6) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf2 == "IMF-5" && int(selected_imfk) < 5) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf2 == "IMF-4" && int(selected_imfk) < 4) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf2 == "IMF-3" && int(selected_imfk) < 3) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
      if (selected_imf2 == "IMF-2" && int(selected_imfk) < 2) {
        JLabel label3 = new JLabel("Selected IMF over n_IMF!");
        label3.setForeground(Color.RED);
        JOptionPane.showMessageDialog(this, label3);
      }
    } else if (e.getSource()==  combo7) {
      Y_Max1 = (String)combo7.getSelectedItem();
    } else if (e.getSource()==  combo8) {
      Y_Max2 = (String)combo8.getSelectedItem();
    } 

      if ( (String)combo2.getSelectedItem() == "Demo") {
        selected_port = (String)combo1.getSelectedItem();
        selected_mode = (String)combo2.getSelectedItem();
        println("Demo Mode Selected!");
        selected_mode_flag = 1;
        SelectedPort = selector.getPort();
        label.setText("Com Port: " + selected_port + "  &  Mode: " + selected_mode );
        start_flag = 1;
        serial_connect();
      }

      if ( (String)combo2.getSelectedItem() == "Clinical") {
        selected_port = (String)combo1.getSelectedItem();
        selected_mode = (String)combo2.getSelectedItem();
        selected_mode_flag = 0;
        SelectedPort = selector.getPort();
        println("Port Selected!");
        label.setText("Com Port: " + selected_port + "  &  Mode: " + selected_mode );
        start_flag = 1;
        serial_connect();
      }

      if ( ( (String)combo2.getSelectedItem() == "Review" ) && (start_flag == 0) ) {
        data_path = dataPath("");
        File dir = new File(data_path + "/../user_data/");
        JFileChooser filechooser = new JFileChooser(dir);
        int read_buffer_size = 3408;
        int loop_cnt2 = 0;
        int selected = filechooser.showOpenDialog(this);

        if (selected == JFileChooser.APPROVE_OPTION) {
          FileFilter filter1 = new FileNameExtensionFilter("datファイル", "dat");
          filechooser.addChoosableFileFilter(filter1);
          file = filechooser.getSelectedFile();
          file_select_flag = 1;
          selected_mode_flag = 2;
        }
        //selected_port = (String)combo1.getSelectedItem();
        selected_mode = (String)combo2.getSelectedItem();
        selected_dmode = (String)combo3.getSelectedItem();
        selected_imfk = (String)combo4.getSelectedItem();
        selected_imf1 = (String)combo5.getSelectedItem();
        selected_imf2 = (String)combo6.getSelectedItem();

        println("Review Mode Selected!");
        selected_mode_flag = 2;
        //SelectedPort = selector.getPort();
        label.setText("Com Port: None &  Mode: " + selected_mode );
        start_flag = 1;
        
        
      }
    //}
  }
}

void serial_connect() {
  port = new Serial(this, SelectedPort, 57600);

  stop_eeg();
  stop_processed_vars();
  port.clear();
  send_processed_vars();
  send_eeg();
}

void send_eeg() {
  //send_eeg
  //BAAB00000E000100040000006F0000000000020080000401
  int[] send_eeg = {0xBA, 0xAB, 0x00, 0x00, 0x0E, 0x00, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x80, 0x00, 0x04, 0x01};
  for (int i=0; i< 24; i=i+1) {
    port.write(send_eeg[i]);
  }
}

void stop_eeg() {
  //stop_eeg
  //BAAB01000C0001000400000070000000010000008300
  int[] stop_eeg = {0xBA, 0xAB, 0x01, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x83, 0x00};
  for (int i=0; i< 22; i=i+1) {
    port.write(stop_eeg[i]);
  }
}

void send_processed_vars() {
  //send_processed_vars
  //BAAB00000D000100040000007300000000000100018700
  int[] send_processed_vars = {0xBA, 0xAB, 0x00, 0x00, 0x0D, 0x00, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x87, 0x00};
  for (int i=0; i< 23; i=i+1) {
    port.write(send_processed_vars[i]);
  }
}

void stop_processed_vars() {
  //stop_processed_vars
  //BAAB01000C0001000400000074000000010000008700
  int[] stop_processed_vars = {0xBA, 0xAB, 0x01, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x74, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x87, 0x00};
  for (int i=0; i< 22; i=i+1) {
    port.write(stop_processed_vars[i]);
  }
}

void exit() {
  super.exit();
}
