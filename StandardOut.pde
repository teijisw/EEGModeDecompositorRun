import java.io.PrintStream;

public class StandardOutTest extends Frame implements ActionListener {
  Label lb1;
  TextField field1;
  StandardStreamPanel outarea;
  Button btn1;

  public StandardOutTest() {
    Panel p = new Panel();
    p.setLayout(new GridLayout(2, 1));
    lb1 = new Label("");
    p.add(lb1);
    field1 = new TextField();
    p.add(field1);
    this.add(p, BorderLayout.NORTH);

    outarea = new StandardStreamPanel();
    this.add(outarea, BorderLayout.CENTER);

    btn1 = new Button("JAVA Information: click");
    btn1.addActionListener(this);
    this.add(btn1, BorderLayout.SOUTH);
    this.setSize(500, 500);
    this.setVisible(true);
    this.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent ev) {
        System.exit(0);
      }
    }
    );
  }

  public void actionPerformed(ActionEvent ev) {
    try {
      int n = Integer.parseInt(field1.getText());
      System.out.print("calc: " + n + "  ");
      n = n * n;
      System.out.println(n);
      lb1.setText("Result: " + n);
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
}

class StandardStreamPanel extends Panel {

  public StandardStreamPanel() {
    super();
    this.setLayout(new GridLayout(2, 1));
    OutputTextArea out = new OutputTextArea();
    out.setToSystemOut();
    this.add(out);
    OutputTextArea err = new OutputTextArea();
    err.setToSystemErr();
    this.add(err);
  }
}

public class OutputTextArea extends TextArea {
  private TextAreaOutputStream out;

  public OutputTextArea() throws HeadlessException {
    super();
    this.setEditable(false);
    out = new TextAreaOutputStream(this);
  }

  public void setToSystemOut() {
    System.setOut(new PrintStream(this.getOut()));
  }

  public void setToSystemErr() {
    System.setErr(new PrintStream(this.getOut()));
  }

  public TextAreaOutputStream getOut() {
    return out;
  }

  public void flush() {
    this.append(out.toString());
    out.reset();
  }
}

class TextAreaOutputStream extends ByteArrayOutputStream {
  private OutputTextArea textarea;

  public TextAreaOutputStream(OutputTextArea textarea) {
    super();
    this.textarea = textarea;
  }

  public synchronized void write(byte[] b, int off, int len) {
    super.write(b, off, len);
    textarea.flush();
  }

  public synchronized void write(int b) {
    super.write(b);
    textarea.flush();
  }

  public void write(byte[] b) throws IOException {
    super.write(b);
    textarea.flush();
  }
}
