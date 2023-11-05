class Graph {
  float xdataMin = 0;
  float xdataMax = 0;
  float ydataMax = 0;
  float ydataMin = 0;
  float xvolumeInterval = 0;
  float yvolumeInterval = 0;
  float xvolumeIntervalMinor = 0;
  float yvolumeIntervalMinor = 0;
  float plotX1 = 0;
  float plotY1 = 0;
  float plotX2 = 0;
  float plotY2 = 0;
  float plotX_W = 0;
  float plotY_W = 0;
  float labelX;
  float labelY;
  String xlabel = "x";
  String ylabel = "y";

  // Constructor
  Graph (float _xdataMin, float _xdataMax, float _ydataMin, float _ydataMax,
    float _xvolumeInterval, float _yvolumeInterval, float _xvolumeIntervalMinor, float _yvolumeIntervalMinor,
    float _plotX1, float _plotY1, float _plotX_W, float _plotY_W) {
    xdataMin = _xdataMin;
    xdataMax = _xdataMax;
    ydataMax = _ydataMax;
    ydataMin = _ydataMin;
    xvolumeInterval = _xvolumeInterval;
    yvolumeInterval = _yvolumeInterval;
    xvolumeIntervalMinor = _xvolumeIntervalMinor;
    yvolumeIntervalMinor = _yvolumeIntervalMinor;
    plotX1 = _plotX1;
    plotY1 = _plotY1;
    plotX2 = _plotX1+_plotX_W;
    plotY2 = _plotY1+_plotY_W;
    plotX_W = _plotX_W;
    plotY_W = _plotX_W;
  }

  void drawPoints(float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;

    float x = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y = map(ydataMin, ydataMin, ydataMax, plotX1, plotX2);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotX1, plotX2);
    float x_pre = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_pre = map(ydataMin, ydataMin, ydataMax, plotX1, plotX2);

    for (int i= 0; i<1024; i++) {
      if (xvalue[i] <= xdataMax) {
        x = map(xvalue[i], xdataMin, xdataMax, plotX1, plotX2);
        y = map(yvalue[i], ydataMin, ydataMax, plotY2, plotY1);
        y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);
        y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
        if (xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
          strokeWeight(1.5);
          stroke(#00ff00);
          if (i >0) {
            //point(x, y);
            line (x_pre, y_pre, x, y);
          }
        }
        if (y > y_min) {
          x_pre = x;
          y_pre = y_min;
        } else if (y < y_max) {
          x_pre = x;
          y_pre = y_max;
        } else if (y >= y_max &&  y <= y_min) {
          x_pre = x;
          y_pre = y;
        }
      }
    }
  }

  void drawPoints_c(float _x[], float _y0[], float _y1[], float _y2[]) {
    float[] xvalue = _x;
    float[] yvalue0 = _y0;
    float[] yvalue1 = _y1;
    float[] yvalue2 = _y2;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);

    float x_mapped = x_min;
    float y0_mapped = y_min;
    float y1_mapped = y_min;
    float y2_mapped = y_min;

    float x_mapped_pre = x_min;
    float y0_mapped_pre = y_min;
    float y1_mapped_pre = y_min;
    float y2_mapped_pre = y_min;

    for (int i= 0; i<94; i++) {

      x_mapped = map(xvalue[i*4+4], xdataMin, xdataMax, plotX1, plotX2);
      y0_mapped = map(yvalue0[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue0[i] <= ydataMax && yvalue0[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#00ff00);
        if (i >0) {
          //point(C_x, C_y);
          line (x_mapped_pre, y0_mapped_pre, x_mapped, y0_mapped);
        }
      }
      if (y0_mapped > y_min) {
        x_mapped_pre = x_mapped;
        y0_mapped_pre = y_min;
      } else if (y0_mapped < y_max) {
        x_mapped_pre = x_mapped;
        y0_mapped_pre = y_max;
      } else if (y0_mapped >= y_max &&  y0_mapped <= y_min) {
        x_mapped_pre = x_mapped;
        y0_mapped_pre = y0_mapped;
      }
    }

    for (int i= 0; i<94; i++) {

      x_mapped = map(xvalue[i*4+4], xdataMin, xdataMax, plotX1, plotX2);
      y1_mapped = map(yvalue1[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue1[i] <= ydataMax && yvalue1[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ffff00);
        if (i >0) {
          //point(C_x, C_y);
          line (x_mapped_pre, y1_mapped_pre, x_mapped, y1_mapped);
        }
      }
      if (y1_mapped > y_min) {
        x_mapped_pre = x_mapped;
        y1_mapped_pre = y_min;
      } else if (y1_mapped < y_max) {
        x_mapped_pre = x_mapped;
        y1_mapped_pre = y_max;
      } else if (y1_mapped >= y_max &&  y1_mapped <= y_min) {
        x_mapped_pre = x_mapped;
        y1_mapped_pre = y1_mapped;
      }
    }

    for (int i= 0; i<94; i++) {
      x_mapped = map(xvalue[i*4+4], xdataMin, xdataMax, plotX1, plotX2);
      y2_mapped = map(yvalue2[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0 && xvalue[i] <= xdataMax && yvalue2[i] <= ydataMax && yvalue2[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ff0000);
        if (i >0) {
          //point(C_x, C_y);
          line (x_mapped_pre, y2_mapped_pre, x_mapped, y2_mapped);
        }
      }
      if (y2_mapped > y_min) {
        x_mapped_pre = x_mapped;
        y2_mapped_pre = y_min;
      } else if (y2_mapped < y_max) {
        x_mapped_pre = x_mapped;
        y2_mapped_pre = y_max;
      } else if (y2_mapped >= y_max &&  y2_mapped <= y_min) {
        x_mapped_pre = x_mapped;
        y2_mapped_pre = y2_mapped;
      }
    }
  }

  void drawPoints_e(float[][] _x, float[][] _y) {
    float[] xvalue0 = _x[0];
    float[] xvalue1 = _x[1];
    float[] xvalue2 = _x[2];
    float[] xvalue3 = _x[3];
    float[] xvalue4 = _x[4];
    float[] xvalue5 = _x[5];

    float[] yvalue0 = _y[0];
    float[] yvalue1 = _y[1];
    float[] yvalue2 = _y[2];
    float[] yvalue3 = _y[3];
    float[] yvalue4 = _y[4];
    float[] yvalue5 = _y[5];

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);

    float x0_mapped = x_min;
    float x1_mapped = x_min;
    float x2_mapped = x_min;
    float x3_mapped = x_min;
    float x4_mapped = x_min;
    float x5_mapped = x_min;

    float y0_mapped = y_min;
    float y1_mapped = y_min;
    float y2_mapped = y_min;
    float y3_mapped = y_min;
    float y4_mapped = y_min;
    float y5_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      x0_mapped = map(xvalue0[i], xdataMin, xdataMax, plotX1, plotX2);
      y0_mapped = map(yvalue0[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue0[i] > 0  && xvalue0[i] <= xdataMax && yvalue0[i] <= ydataMax && yvalue0[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#00ff00);
        if (i >0) {
          point(x0_mapped, y0_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      x1_mapped = map(xvalue1[i], xdataMin, xdataMax, plotX1, plotX2);
      y1_mapped = map(yvalue1[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue1[i] > 0  && xvalue1[i] <= xdataMax && yvalue1[i] <= ydataMax && yvalue1[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ffff00);
        if (i >0) {
          point(x1_mapped, y1_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      x2_mapped = map(xvalue2[i], xdataMin, xdataMax, plotX1, plotX2);
      y2_mapped = map(yvalue2[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue2[i] > 0 && xvalue2[i] <= xdataMax && yvalue2[i] <= ydataMax && yvalue2[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ff0000);
        if (i >0) {
          point(x2_mapped, y2_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      x3_mapped = map(xvalue3[i], xdataMin, xdataMax, plotX1, plotX2);
      y3_mapped = map(yvalue3[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue3[i] > 0 && xvalue3[i] <= xdataMax && yvalue3[i] <= ydataMax && yvalue3[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#00ffff);
        if (i >0) {
          point(x3_mapped, y3_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      x4_mapped = map(xvalue4[i], xdataMin, xdataMax, plotX1, plotX2);
      y4_mapped = map(yvalue4[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue4[i] > 0 && xvalue4[i] <= xdataMax && yvalue4[i] <= ydataMax && yvalue4[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ff00ff);
        if (i >0) {
          point(x4_mapped, y4_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      x5_mapped = map(xvalue5[i], xdataMin, xdataMax, plotX1, plotX2);
      y5_mapped = map(yvalue5[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue5[i] > 0 && xvalue5[i] <= xdataMax && yvalue5[i] <= ydataMax && yvalue5[i] >= ydataMin) {
        strokeWeight(2);
        stroke(#ffffff);
        if (i >0) {
          point(x5_mapped, y5_mapped);
        }
      }
    }
  }

  void drawPoints_f1(float _x0[], float _y0[]) {
    float[] xvalue0 = _x0;
    float[] yvalue0 = _y0;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x0_mapped = x_min;
    float y0_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      //fill(#00ff00);

      x0_mapped = map(xvalue0[i], xdataMin, xdataMax, plotX1, plotX2);
      y0_mapped = map(yvalue0[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue0[i] > 0  && xvalue0[i] <= xdataMax && yvalue0[i] <= ydataMax && yvalue0[i] >= ydataMin) {
        strokeWeight(2.5);
        stroke(floor(128-(int)((log10(y0_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 126);

        if (i >0) {
          point(x0_mapped, y0_mapped);
        }
      }
    }
  }

  void drawPoints_f2(float _x0[], float _y0[], float _x1[], float _y1[]) {
    float[] xvalue0 = _x0;
    float[] yvalue0 = _y0;
    float[] xvalue1 = _x1;
    float[] yvalue1 = _y1;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x0_mapped = x_min;
    float y0_mapped = y_min;
    float x1_mapped = x_min;
    float y1_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      //fill(#00ff00);

      x0_mapped = map(xvalue0[i], xdataMin, xdataMax, plotX1, plotX2);
      y0_mapped = map(yvalue0[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue0[i] > 0  && xvalue0[i] <= xdataMax && yvalue0[i] <= ydataMax && yvalue0[i] >= ydataMin) {
        strokeWeight(2.5);
        stroke(floor(128-(int)((log10(y0_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 126);

        if (i >0) {
          point(x0_mapped, y0_mapped);
        }
      }
    }

    for (int i= 0; i<1024; i++) {
      // fill(#00ff00);

      x1_mapped = map(xvalue1[i], xdataMin, xdataMax, plotX1, plotX2);
      y1_mapped = map(yvalue1[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue1[i] > 0  && xvalue1[i] <= xdataMax && yvalue1[i] <= ydataMax && yvalue1[i] >= ydataMin) {
        strokeWeight(2.5);
        stroke(floor(128-(int)((log10(y1_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 126);

        if (i >0) {
          point(x1_mapped, y1_mapped);
        }
      }
    }
  }

  void drawPoints_g(float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);

    float x_mapped = x_min;
    float y_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      fill(#00ff00);

      x_mapped = map(xvalue[i], xdataMin, xdataMax, plotX1, plotX2);
      y_mapped = map(yvalue[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
        strokeWeight(2.5);
        stroke(#00ffff);
        if (i >0) {
          point(x_mapped, y_mapped);
        }
      }
    }
  }

  void drawPoints_h1(float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x_mapped = x_min;
    float y_mapped = y_min;

    for (int i= 0; i<1024; i++) {

      x_mapped = map(xvalue[i], xdataMin, xdataMax, plotX1, plotX2);
      y_mapped = map(yvalue[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        fill(floor(128-(int)((log10(y_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 64+(int)((log10(y_mapped)-log10(y_min))/(log10(y_max)-log(y_min))*255));
        rect(x_mapped, 400, x_mapped+1, 415);
      }
    }
  }

  void drawPoints_h2(float _x0[], float _y0[], float _x1[], float _y1[]) {
    float[] xvalue0 = _x0;
    float[] yvalue0 = _y0;
    float[] xvalue1 = _x1;
    float[] yvalue1 = _y1;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x0_mapped = x_min;
    float y0_mapped = y_min;
    float x1_mapped = x_min;
    float y1_mapped = y_min;

    for (int i= 0; i<1024; i++) {

      x0_mapped = map(xvalue0[i], xdataMin, xdataMax, plotX1, plotX2);
      y0_mapped = map(yvalue0[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue0[i] > 0  && xvalue0[i] <= xdataMax && yvalue0[i] <= ydataMax && yvalue0[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        fill(floor(128-(int)((log10(y0_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 64+(int)((log10(y0_mapped)-log10(y_min))/(log10(y_max)-log(y_min))*255));
        rect(x0_mapped, 400, x0_mapped+1, 415);
      }
    }

    for (int i= 0; i<1024; i++) {

      x1_mapped = map(xvalue1[i], xdataMin, xdataMax, plotX1, plotX2);
      y1_mapped = map(yvalue1[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue1[i] > 0  && xvalue1[i] <= xdataMax && yvalue1[i] <= ydataMax && yvalue1[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        fill(floor(128-(int)((log10(y1_mapped)-log10(y_min))/(log10(y_max)-log10(y_min))*2048)), 255, 255, 64+(int)((log10(y1_mapped)-log10(y_min))/(log10(y_max)-log(y_min))*255));
        rect(x1_mapped, 400, x1_mapped+1, 415);
      }
    }
  }

  void drawPoints_h3(int _Gf, float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;
    int Gf = _Gf;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x_mapped = x_min;
    float y_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      x_mapped = map(xvalue[i], xdataMin, xdataMax, plotX1, plotX2);
      y_mapped = map(yvalue[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        Freq_adj[9][i] = x_mapped;
        Pw_adj[9][i]   = log10(y_mapped);
        Pw_adj_max[9] = log10(y_max);
        Pw_adj_min[9] = log10(y_min);
      }
    }
  }

  void drawPoints_h3_1(int _Gf1, float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;
    int Gf1 = _Gf1;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x_mapped = x_min;
    float y_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      x_mapped = map(xvalue[i], xdataMin, xdataMax, plotX1, plotX2);
      y_mapped = map(yvalue[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        Freq_adj[Gf1-1][i] = x_mapped;
        Pw_adj[Gf1-1][i]   = log10(y_mapped);
        Pw_adj_max[Gf1-1] = log10(y_max);
        Pw_adj_min[Gf1-1] = log10(y_min);
      }
    }
  }


  void drawPoints_h4(int _Gf1, int _Gf2, float _x1[], float _y1[], float _x2[], float _y2[]) {
    float[] xvalue1 = _x1;
    float[] yvalue1 = _y1;
    float[] xvalue2 = _x2;
    float[] yvalue2 = _y2;
    int Gf1 = _Gf1;
    int Gf2 = _Gf2;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);

    float x1_mapped = x_min;
    float y1_mapped = y_min;
    float x2_mapped = x_min;
    float y2_mapped = y_min;

    for (int i= 0; i<1024; i++) {
      x1_mapped = map(xvalue1[i], xdataMin, xdataMax, plotX1, plotX2);
      y1_mapped = map(yvalue1[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue1[i] > 0  && xvalue1[i] <= xdataMax && yvalue1[i] <= ydataMax && yvalue1[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        Freq_adj[9][2*i] = x1_mapped;
        Pw_adj[9][2*i]   = log10(y1_mapped);
        Pw_adj_max[9] = log10(y_max);
        Pw_adj_min[9] = log10(y_min);
      }
    }

    for (int i= 0; i<1024; i++) {
      x2_mapped = map(xvalue2[i], xdataMin, xdataMax, plotX1, plotX2);
      y2_mapped = map(yvalue2[i], ydataMin, ydataMax, plotY2, plotY1);

      if (xvalue2[i] > 0  && xvalue2[i] <= xdataMax && yvalue2[i] <= ydataMax && yvalue2[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        Freq_adj[9][2*i+1] = x2_mapped;
        Pw_adj[9][2*i+1]   = log10(y2_mapped);
        //Pw_adj_max = log10(y_max);
        //Pw_adj_min = log10(y_min);
      }
    }
  }

  void drawPoints_h5(float _x[], float _y[]) {
    float[] xvalue = _x;
    float[] yvalue = _y;

    float x_min = map(xdataMin, xdataMin, xdataMax, plotX1, plotX2);
    //float y_min = map(ydataMin, ydataMin, ydataMax, plotY2, plotY1);
    //float y_max = map(ydataMax, ydataMin, ydataMax, plotY2, plotY1);
    float y_min = 0;
    float y_max = 256;


    float x_mapped = x_min;
    float y_mapped = y_min;
    //println("y_max=:", y_max);
    //println("y_min=:", y_min);

    for (int i= 0; i<94; i++) {
      x_mapped = map(xvalue[i*4], xdataMin, xdataMax, plotX1, plotX2);
      //y_mapped = map(yvalue[i], 0, 225, 0, 255);
      y_mapped = map(yvalue[i], 60, 100, 0, 128);
      //println("y_mapped=:", y_mapped);
      if (xvalue[i] > 0  && xvalue[i] <= xdataMax && yvalue[i] <= ydataMax && yvalue[i] >= ydataMin) {
        strokeWeight(0.5);
        noStroke();
        Freq_adj[10][i] = x_mapped;
        //Pw_adj[10][i]   = log10(y_mapped);
        //Pw_adj_max[10] = log10(y_max);
        //Pw_adj_min[10] = log10(y_min);
        Pw_adj[10][i]   = y_mapped;
        Pw_adj_max[10] = y_max;
        Pw_adj_min[10] = y_min;
      }
    }
  }


  void xdrawVolumeLabels() {
    fill(0);
    textSize(10);
    textAlign(RIGHT);
    stroke(128);
    strokeWeight(1.0);

    for (float v = xdataMin; v <= xdataMax; v += xvolumeIntervalMinor) {
      if (v % xvolumeIntervalMinor == 0) {     // If a tick mark
        float x = map(v, xdataMax, xdataMin, plotX2, plotX1);
        float textOffset = textAscent()/2;  // Center vertically
        textOffset = 0;                   // Align by the bottom
        textOffset = textAscent();        // Align by the top
        text(floor(v), x + textOffset, plotY2 + 20);
        line(x, plotY2 + 4, x, plotY2);     // Draw major tick
      }
    }
  }

  void ydrawVolumeLabels() {
    fill(0);
    textSize(10);
    textAlign(RIGHT);
    stroke(128);
    strokeWeight(0.5);

    for (float v = ydataMin; v <= ydataMax; v += yvolumeIntervalMinor) {
      if (v % yvolumeIntervalMinor == 0) {     // If a tick mark
        float y = map(v, ydataMin, ydataMax, plotY2, plotY1);
        if (v % yvolumeInterval == 0) {        // If a major tick mark
          float textOffset = textAscent()/2;  // Center vertically
          if (v == ydataMin) {
            textOffset = 0;                   // Align by the bottom
          } else if (v == ydataMax) {
            textOffset = textAscent();        // Align by the top
          }
          text(floor(v), plotX1 - 10, y + textOffset);
          line(plotX1 - 4, y, plotX1, y);     // Draw major tick
        } else {
          line(plotX1 - 2, y, plotX1, y);     // Draw minor tick
        }
      }
    }
  }

  void drawxLabels() {
    fill(0);
    stroke(224);
    strokeWeight(0.5);
    rect(plotX1, plotY1, plotX2, plotY2);
    for (float v = xdataMin; v <= xdataMax; v += xvolumeIntervalMinor) {
      float x = map(v, xdataMax, xdataMin, plotX2, plotX1);
      line(x, plotY1, x, plotY2);     // Draw major tick
    }
  }

  void drawyLabels() {
    fill(0);
    stroke(224);
    strokeWeight(0.5);

    for (float v = ydataMin; v <= ydataMax; v += yvolumeIntervalMinor) {
      if (v % yvolumeIntervalMinor == 0) {     // If a tick mark
        float y = map(v, ydataMin, ydataMax, plotY2, plotY1);
        if (v % yvolumeInterval == 0) {        // If a major tick mark
          line(plotX1, y, plotX2, y);     // Draw major tick
        }
      }
    }
  }

  void drawAxisLabels(String _ylabel, String _xlabel) {
    fill(0);
    noStroke();
    rect(plotX1, plotY1, plotX2, plotY2);
    String xlabel = _xlabel;
    String ylabel = _ylabel;
    labelX = plotX1-60;
    labelY = plotY2+25;

    fill(0);
    textSize(14);
    textLeading(15);
    textAlign(CENTER, CENTER);
    text(xlabel, labelX, (plotY1+plotY2)/2);
    textAlign(CENTER);
    text(ylabel, labelX, plotY1);
  }

  void drawAxisLabels_c(String _ylabel, String _xlabel) {
    noStroke();
    rect(plotX1, plotY1, plotX2, plotY2);
    String xlabel = _xlabel;
    String ylabel = _ylabel;
    labelX = plotX1-60;
    labelY = plotY2+40;

    fill(0);
    textSize(14);
    textLeading(15);
    textAlign(CENTER, CENTER);
    text(xlabel, labelX, (plotY1+plotY2)/2);
    textAlign(CENTER);
    text(ylabel, (plotX1+plotX2)/2, labelY);
  }
}
