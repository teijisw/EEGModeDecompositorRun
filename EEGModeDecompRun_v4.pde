//EEG MODE DECOMPOSITOR RUN v0.42
// By Teiji Sawa, MD, PhD
//Nov 4, 2023;
String subscript_1 = "v0.42 by Teiji SAWA, Nov-4-2023.";
String subscript_2 = "Anesthesiology, Kyoto Prefectural University of Medicine.";

import processing.serial.*;
import org.apache.commons.math3.transform.FastFourierTransformer;
import org.apache.commons.math3.complex.Complex;
import org.apache.commons.math3.transform.TransformType;
import org.apache.commons.math3.stat.Frequency;
import org.apache.commons.math3.transform.DftNormalization;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.text.BadLocationException;

///////////////////////////////////
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
//import java.io.InputStreamReader;
//import java.io.FileReader;


// ---------------------------------------------
//Swing subwindows
// ---------------------------------------------
int saveFrame = 1;
// ---------------------------------------------
// WMD //--Meyer filter bank
//      boundaries[0] = 4.0D;
//      boundaries[1] = 8.0D;
//      boundaries[2] = 14.0D;
//      boundaries[3] = 20.0D;
//      boundaries[4] = 30.0D;
//---END

double Frequency = 128;

// ---------------------------------------------
// Serial port name
String thisPort = "";
// ---------------------------------------------
// Please change to your own!
// for Mac User: "/dev/tty.usbserial-00003014"
//               "/dev/tty.usbserial-00004014"
//               "/dev/tty.usbserial-00005014"
// for Windows User: "COM4"
//                   "COM5"
//                   "COM6"
// ---------------------------------------------
//---SET Filtering Range HERE!!!------------
double fe1 = 0;        // Hi Pass Filter -1 Hz
double fe2 = 47;       // Lo Pass Filter -1 Hz
double delta= 0.25;  // transitional width  Hz
//------------------------------------------
double fs = 128.0d;

//int N2;
double b[];
//-Window Choice----------------------------
// 0: Hanning
// 1: Hamming
// 2: Blackman
//------------------------------------------
int window = 2;
//-------------------------------------------
int trend_point = 3600;
int trend_avg_point = 10;
// ---------------------------------------------
// Power Spectrum Index:
float ps_divisor = 100;
// ---------------------------------------------

StandardOutTest standardOut;
JSerialSelector selector;
JTextArea textarea2;
File file;

byte [] read_buffer;

int color_trend_size = 256;

// Demo Mode: Flag needs to be Mode_Flag = 1, otherwise Mode_Flag = 0;
int Mode_Flag = 0;
int Start_Flag;
int Stop_Flag = 0;
int Binary_Save_Flag = 0;
int Final_Select_Flag = 0;
int read_buffer_size = 3408;
int loop_cnt1 = 0;
int loop_cnt2 = 0;

String D_Mode = "EMD";
String Selected_IMFK;
String Selected_IMF1;
String Selected_IMF2;
int choice=0;
String input_datafile;

double target_freq = 12;
int select_imf;
double select_fq_mean;
double select_fq_stdev;
//--------------------------------------
//Right Graph: Selection for IMF
// Ex)  Gf_R1 = 1, 2, 3, 4, 5, 6, #7(3-4), #8(5-6), 9(all, 1-6), [10(Gf_R1), 11(FFT)], None
int Gf_R1=1;
//int Gf_R1 = 2;
int Gf_R2=1;
//int Gf_R1 = 3;
int dual = 0; //spectrogram: 0:single draw, 1: double draw
//--------------------------------------
//Right Graph: Y-axis MAX
// Ex)  Gf_R1_max = 1000
int Gf_E_max = 1000;
int Gf_R1_max = 1000;
//int Gf_E_max;
//int Gf_R1_max;

float limitter = 30;

Emd2 emd_1;
Vmd vmd_1;
Ewt ewt_1;
Ewt2 ewt_2;

PFont myFont;     // The display font
PFont plotFont;
String SelectedPort;

//Initial Variables---------------------
int N = 2000;
Complex alpha = new Complex(2000.0, 0);
Complex tau = ZERO;
int K = 6;
int DC = 0;
int init = 1;
double tol = 1e-7;

int T1 = 1024;
//INPUT DATA FILE NAME------------------
public static final Complex ZERO = new Complex(0, 0);
public static final Complex ONE = new Complex(1, 0);
public static final Complex TWO = new Complex(2, 0);
public static final Complex HALF = new Complex(0.5, 0);

FastFourierTransformer fft;
FastFourierTransformer fft1;
FastFourierTransformer fft2;
FastFourierTransformer fft3;
TransformType forward;
TransformType inverse;

int init_loop_flag = 0;
int loop_cnt_for_sp = 0;
int loop_cnt_for_saveFrame = 0;
int loop_cnt_for_sync = 0;
int syncFastSlow_size = 10;
int trend_loop_cnt = 0;
int packet_cnt = 0;
int eeg_cnt = 0;
int powerSpec_cnt = 0;
int trend_flag = 0;
float t_start;
int binary_cnt = 0;
// ---------------------------------------------

double signal2[];
float t[];
double[][] u_double;

PImage img, img0, img1, img2, img3, img4, img5, img6, img_anesth_kpum;
PImage imgL0, imgL1, imgL2, imgL3, imgL4, imgL5, imgL6;

FloatTable eeg_data;
float his, his_low;
Graph graph_A, graph_B1, graph_B2, graph_B3, graph_B4, graph_B5, graph_B6, graph_B7, graph_B8,
  graph_C, graph_D, graph_E, graph_F, graph_G, graph_H1, graph_H2,
  graph_H2_1, graph_H2_2, graph_H2_3, graph_H2_4, graph_H2_5, graph_H2_6, graph_H2_7,
  graph_J;

Hilbert hilb[];
EmdDataImpl emd;
double [][] ewt;


//Date and Time variables:
String date_now, time_now, time_now2, date, time, start_time;
String binary_save_name;
String data_path;

int year, month, day, hour, min, sec;
String TitleData_fft, TitleData_hht, TitleData_hht_spec;
int rowCount;
int columnCount;
int current_row=0;

//Buffer variables:
byte[] inBuffer;
String inStream;
String[] packet;
int packet_num;
int packet_length;

//Bis Order Sets:
int[] send_eeg;
int[] stop_eeg;
int[] send_processed_vars;
int[] stop_processed_vars;

int Hz_64[];
int Fs;
float data_n[];

//double Hamming[];
double Hanning[];
double Blackman[];
//double x0_Hamming[];
double x0_Hanning[];
double x0_Blackman[];

float x0_Hz[];

double[][][] analytical_signal;
double[][] envelope;
float[][] envelope_float;
double[][] phase;
double[][] frequency;
float[][] frequency_float;
double[][] signal;
float[][] signal_float;
float[][] amp_float;

float [] Freq;
float [] Amp;
float Freq_adj[][];
float Freq_adj2[][][];
float Pw_adj[][];
float Pw_adj2[][][];
float Pw_adj_max[];
float Pw_adj_min[];

float tp_sum;
float tp_sum_low;
float tp[];
float tp_low[];
float fq_mean_avg;
float fq_mean_low_avg;
float fq_mean[];
float fq_mean_low[];
float fq_stdev_avg;
float fq_stdev_low_avg;
float fq_stdev[];
float fq_stdev_low[];
double[] data;

double[][] imfs;
double[][] imfs_temp;
float[][] imfs_float;

PrintWriter output_fft_abs;
PrintWriter output_fft_dB;
PrintWriter output_hht;
PrintWriter output_env;
PrintWriter output_phase;
PrintWriter output_freq;
PrintWriter output_ana_sig;
PrintWriter output_hht_spec_amp;
PrintWriter output_hht_spec_freq;
PrintWriter output1, output2, output3, output4, output5;
String TitleData, TitleData2, TitleData3, TitleData4;

//eeg buffer variables:
float[][] eeg1;
float [] eeg_mem;
float eeg_run;
float maxRange1, maxRange2, maxRange30, maxRange40;

float[] sp1;
float[][] sp_mem;
float sp1_total;
float sp1_total_dB;
float total_power_eeg ;
float x0_data[];
float x0_Hz_avg[];

double x0[];
double x1[];
double x0_r1024[];
double x0_pre[];
double x0_post[];

double x0_filtered_0[];

// double Blackman[];
float x0_filtered_0_float[];

Complex y[][];

double y_abs[][];
double y_abs_Hz[][];
double y_dB_Hz[][];
double y_dB_Hz_adj[][][];
double y_dB_Hz_adj2[][][];

float y_abs_Hz_float[][];
float y_abs_Hz_float_adj[][];
float y_dB_Hz_float[][];
float y_dB_Hz_float_adj[][];

double y_dB_sq[][];
float y_dB_sq_float_adj[][];

float total_power_x0_filtered;

//float total_power_x0_filtered_trend[];

//float total_power_x0_filtered_trend_avg[];

//BIS data buffer variables:
long dsc_gain_num, dsc_gain_divisor, dsc_offset_num, dsc_offset_divisor;
float dsc_gain, dsc_offset;
int[] burst_suppress_ratio;
float[] spectral_edge_95;
int[] bis_bits;
float[] bispectral_index;
int[] bispectral_alternate_index;
int[] bispectral_alternate2_index;
int[] total_power;
int[] emg_low;
long[] bis_signal_quality;
long[] second_artifact;

//Poincare variables:
float x0_avg[];
float d0_x0[];
float d0_x0_avg;
float x0_float[];
float x0_post_float[];

float y_sef95_self;

Complex tripleProduct[][];
double tripleProduct_abs[][];
double tripleProduct_total_005_47, tripleProduct_total_40_47;
//double syncFastSlow[];
double sFS;
float sFS_float;

float relativeBetaRatio;

float time_mem;

float sef95[];

//multitaper
double y_abs_Hz_mt[];
double y_dB_Hz_mt[];
float y_dB_Hz_float_mt[];
double y_dB_Hz_adj_mt[][];
double y_dB_Hz_adj2_mt[][];
float maxRange40_mt;

double y_dB_sq_mt[];
float y_dB_sq_float_adj_mt[];

Complex y_taper_1[];
Complex y_taper_2[];
Complex y_taper_3[];
Complex y_taper_4[];
Complex y_taper_5[];
Complex y_mt[];
double y_abs_mt[];

double taper_1[];
double taper_2[];
double taper_3[];
double taper_4[];
double taper_5[];

double x0_taper_1[];
double x0_taper_2[];
double x0_taper_3[];
double x0_taper_4[];
double x0_taper_5[];
//multitaper_end


void setup() {

  //size(1400, 800, P3D);
  size(1600, 900);
  //smooth();
  loadImages();
  surface.setResizable(true);
  surface.setSize(1600, 900);

  color_trend_size = 256;

  smooth();
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  frameRate(1);

  //BEGIN: Java Stanard Out
  standardOut = new StandardOutTest();
  standardOut.setTitle("Console");
  //END: Java Stanard Out

  selector = new JSerialSelector();
  selector.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
  selector.setBounds(10, 10, 400, 500);
  selector.setTitle("Serial Port & Mode");
  selector.setVisible(true);

  new MyFrame().setVisible(true);

  default_set();
  
  //Write out the data
  //year = year();
  //month = month();
  //day = day();
  //hour = hour();
  //min = minute();
  //sec = second();

  //date_now = year + "_" + nf(month, 2) + "_" + nf(day, 2) + "_" + hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
  //time_now = hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
  //start_time = hour + ":" + nf(min, 2) + ":" + nf(sec, 2);

  Mode_Flag = selector.getMode_Flag();

  if (Mode_Flag == 2) {
    Final_Select_Flag = selector.getFile_Select_Flag();
  }
    data_writer_1();
}

void default_set() {

  emd_1 = new Emd2(x1, K);
  vmd_1 = new Vmd(x0, alpha, tau, K, DC, init, tol, N);
  ewt_1 = new Ewt(x0, K);
  ewt_2 = new Ewt2(x0, K);

  println("READ DEFAULT_SET");
  Freq_adj = new float [11][2048];
  Freq_adj2 = new float [11][color_trend_size][2048];
  Pw_adj = new float [11][2048];
  Pw_adj2 = new float [11][color_trend_size][2048];


  Pw_adj_max = new float [11];
  Pw_adj_min = new float [11];

  data_n = new float [1024];
  Freq = new float [1024];
  Amp = new  float [1024];

  imfs = new double [6][2*T1];
  imfs_temp = new double [6][2*T1];

  x0 = new double [1024];
  x0_r1024 = new double [1024];
  x0_float = new float [1024];
  x0_Hz = new float [1024];

  //Hamming = new double [1024];
  Hanning = new double [1024];
  Blackman = new double [1024];
  //x0_Hamming = new double [1024];
  x0_Hanning = new double [1024];
  x0_Blackman = new double [1024];

  y = new Complex [3][1024];
  y_abs = new double [3][1024];
  y_abs_Hz = new double [3][256];
  y_dB_Hz = new double [3][256];
  y_abs_Hz_float = new float [3][256];
  y_dB_Hz_float = new float [3][256];

  hilb = new Hilbert[9];
  analytical_signal = new double[9][1024][2];
  frequency = new double [9][1024];
  frequency_float = new float [9][1024];
  phase = new double [9][1024];
  envelope = new double [9][1024];
  envelope_float = new float [9][1024];
  signal = new double [9][1024];

  signal_float = new float [9][1024];
  amp_float = new float [9][1024];
  fq_mean = new float [9];
  fq_mean_low = new float [9];
  fq_stdev = new float [9];
  fq_stdev_low = new float [9];
  tp = new float [9];
  tp_low = new float [9];

  array_init_2d_double(signal);
  array_init_2d_float(signal_float);

  data = new double [1024];
  Hz_64 = new int[64];

  imfs_float = new float[7][1024];

  t = new float [2*T1];

  for (int i = 0; i < T1; i++) {
    t[i] = (1/float(T1) * (i + 1));
  }

  for (int i=0; i<64; i++) {
    Hz_64[i] = i;
  }

  inBuffer = new byte[3408];

  eeg1 = new float[66][16];
  eeg_mem = new float[1040];

  x0_Hz = new float [1024];
  x0_data = new float [1024];
  x0_Hz_avg = new float [256];

  x0 = new double [1024];
  x1 = new double [1040];
  x0_filtered_0 = new double [1024];

  x0_pre = new double [1024];
  x0_post = new double [1024];
  x0_float = new float [1024];
  x0_post_float = new float [1024];
  x0_filtered_0_float = new float [1024];

  y = new Complex [3][1024];
  y_abs = new double [3][1024];
  y_abs_Hz = new double [3][256];
  y_abs_Hz_float = new float [3][256];
  y_abs_Hz_float_adj = new float [3][256];

  y_dB_Hz = new double [3][256];
  y_dB_Hz_float = new float [3][256];
  y_dB_Hz_float_adj = new float[3][256];
  y_dB_Hz_adj = new double [3][color_trend_size][200];

  y_dB_sq = new double [3][256];
  y_dB_sq_float_adj = new float [3][256];

  y_dB_Hz_adj2 = new double [3][color_trend_size][200];


  //multitaper
  y_abs_Hz_mt = new double [256];
  y_dB_sq_mt = new double [256];
  y_dB_Hz_float_mt = new float [256];
  y_dB_Hz_adj_mt = new double [color_trend_size][200];
  y_dB_sq_float_adj_mt = new float [256];
  y_dB_Hz_adj2_mt = new double [color_trend_size][200];

  y_taper_1 = new Complex [1024];
  y_taper_2 = new Complex [1024];
  y_taper_3 = new Complex [1024];
  y_taper_4 = new Complex [1024];
  y_taper_5 = new Complex [1024];

  y_mt = new Complex [1024];
  y_abs_mt = new double [1024];

  y_abs_Hz_mt = new double [256];
  y_dB_Hz_mt = new double [256];
  taper_1 = new double [1024];
  taper_2 = new double [1024];
  taper_3 = new double [1024];
  taper_4 = new double [1024];
  taper_5 = new double [1024];

  x0_taper_1 = new double [1024];
  x0_taper_2 = new double [1024];
  x0_taper_3 = new double [1024];
  x0_taper_4 = new double [1024];
  x0_taper_5 = new double [1024];

  taper_1 = dpss_1_1024();
  taper_2 = dpss_2_1024();
  taper_3 = dpss_3_1024();
  taper_4 = dpss_4_1024();
  taper_5 = dpss_5_1024();
  println("taper_1:=", taper_1[0]);

  //multitaper end

  d0_x0 = new float [960];

  tripleProduct = new Complex[188][188];
  tripleProduct_abs = new double[188][188];
  //syncFastSlow = new double[syncFastSlow_size];

  sp1 = new float[60];
  sp_mem = new float[color_trend_size][60];

  burst_suppress_ratio =new int[2];
  spectral_edge_95 =new float[2];
  bis_bits =new int[2];
  bispectral_index = new float[2];
  bispectral_alternate_index =new int[2];
  bispectral_alternate2_index =new int[2];
  total_power =new int[2];
  emg_low =new int[2];
  bis_signal_quality =new long[2];
  second_artifact =new long[2];

  array_init_2d_double(tripleProduct_abs);
  //array_init_float(x0_avg);

  array_init_2d_float(sp_mem);

  array_init_2d_double(y_dB_Hz_adj2[0]);
  array_init_2d_double(y_dB_Hz_adj2[1]);
  array_init_2d_double(y_dB_Hz_adj2[2]);
  //multitaper
  array_init_2d_double(y_dB_Hz_adj2_mt);
  //end
  
  array_init_float(Freq_adj[Gf_R1-1]);
  array_init_2d_float(Freq_adj2[Gf_R1-1]);
  array_init_float(Pw_adj[Gf_R1-1]);
  array_init_2d_float(Pw_adj2[Gf_R1-1]);

}

void serialEvent(Serial port) {
   try {
    Mode_Flag = selector.getMode_Flag();
    Start_Flag = selector.getStart_Flag();
    Binary_Save_Flag = selector.getBinary_Save_Flag();

    println("Start_Flag=", Start_Flag);
    if (Start_Flag == 1) {
      choice = 1;
    }

    if ( port.available() > 0 ) {
        port.buffer(3408);
        
      if (Binary_Save_Flag == 1) {
        if (binary_cnt == 0) {
          //year = year();
          //month = month();
          //day = day();
          hour = hour();
          min = minute();
          sec = second();
        
          //inBuffer = _port.readBytes();
          //date_now = year + "_" + nf(month, 2) + "_" + nf(day, 2) + "_" + hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
          time_now2 = hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
          data_path = dataPath("");
          binary_save_name = data_path + "/../user_data/" + date_now  +  "/eeg_binary_"+  time_now2 +".dat"; 
          binary_cnt += 1;
         } 
           write_binary(inBuffer, binary_save_name);
            println("Save binary file!");
      } else {
        binary_cnt = 0;
      } 

      inBuffer = port.readBytes();
      
      packet();
      
      port.clear();
   
    }  //available
  }   //try
  catch(RuntimeException e) {
  }
} 

void packet() {
  inStream = "";
  selector.textarea2.setText("");

  if (packet_cnt < 64) {
    for (int i=0; i<3408; i++) {
      inStream += hex(inBuffer[i]);
    }
    //selector.textarea2.insert(inStream,0);
    if (loop_cnt2 == 0) {
      selector.textarea2.append(inStream);
    } else {
      try {
        int start = selector.textarea2.getLineStartOffset(0);
        int line_num = selector.textarea2.getRows();
        int end = selector.textarea2.getLineEndOffset(line_num);

        selector.textarea2.replaceRange(inStream, start, end);
        //println("loop_cnt2-2=:", loop_cnt2);
      }
      catch(BadLocationException e) {
        System.out.println("Bad Location Error!");
      }
    }
    loop_cnt2 += 1 ;
  }
  packet = split(inStream, "BAAB");
  packet_num = packet.length;
  //println("packet=:", packet[0]);
  for (int i = 0; i < packet_num; i++) {
    packet_length = packet[i].length();

    if (packet_length == 768) {
      spectral_packet(packet[i]);
    }

    if (packet_length == 176) {
      packet_cnt = eeg_packet(packet_cnt, packet[i]);
    }

    // data_println();
  }
  //write();
  write_sp();
  write_sp_FFT();
  write_FFT();
  write_HHT();
}

void draw() {
  try {

    background(224);
    colorMode(HSB);
    fill(0);
    rectMode(CORNERS);
    noStroke();

    Stop_Flag = selector.getStop_Flag();
    Start_Flag = selector.getStart_Flag();
    Mode_Flag = selector.getMode_Flag();
    D_Mode = selector.getdMode();
    Selected_IMFK = selector.getImfK();
    K = int(Selected_IMFK);
    Selected_IMF1 = selector.getImf1();
    Selected_IMF2 = selector.getImf2();
    selected_imf1();
    selected_imf2();
    Gf_E_max = int(selector.get_Y_Max1());
    Gf_R1_max = int(selector.get_Y_Max2());

    if (Stop_Flag == 1) {
      exit();
    } else {
      
      //println("Start_Flag=", Start_Flag);
      if (Start_Flag == 1) {
        choice = 1;
        //data_writer_1();
      }
      //println("Mode_Flag=", Mode_Flag);

      if (choice == 1) {

        if (Mode_Flag == 2) {
          if (loop_cnt1 == 0) {

            //  Final_Select_Flag = selector.getFile_Select_Flag();
            file = selector.getFile();
            //selector.textarea2.setText("");

            read_buffer = new byte[(int)file.length()];
            read_buffer = loadBytes(file);
            //println("file size=:", (int)file.length());

            limitter = floor((int)file.length()/read_buffer_size);
            loop_cnt1 = 1;
          }
          //println("loop_cnt2=:", loop_cnt2);
          //println("limitter=:", limitter);
          if (loop_cnt2 < limitter) {
            for (int i=0; i< read_buffer_size; i++) {
              inBuffer[i] = read_buffer[i+read_buffer_size*loop_cnt2];
            }
            packet();
          } else {
            stop();
          }
        }       
       
          //println("OK draw!");

          get_eegData();

          //println("x0.length=:", x0.length);
          
          //println("D_Mode=", D_Mode);

          switch(D_Mode) {
          case "EMD" :
            imfs_temp = emd_1.emd(x1);
            break;
          case "VMD" :
            imfs_temp = vmd_1.vmd(x0);
            break;
          case "EWT" :
            imfs_temp = ewt_1.ewt(x0_r1024);
            break;
          case "WMD" :
            imfs_temp = ewt_2.ewt(x0_r1024);
            break;
          default:
            imfs_temp = emd_1.emd(x0);
            break;
          }
          
          //println("imfs_temp[0].length=:", imfs_temp[0].length);
          
          imfs_temp(imfs_temp);
                 
          //println("imfs[0]=:", imfs[0][0]);
          imfs(imfs);
          //println("imfs_float[0]=:", imfs_float[0][0]);
                             
          hht(imfs);

          draw_graphs();
          //power_spectrum_mt(11, 410);
          power_spectrum1(11, 410);
          power_spectrum2(10, 410);

          switch(K) {
          case 1 :
            power_spectrum3(1, 730);
            power_spectrum3(9, 730);
            break;
          case 2 :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(9, 730);
            break;
          case 3 :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(3, 730);
            power_spectrum3(9, 730);
            break;
          case 4 :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(3, 730);
            power_spectrum3(4, 730);
            power_spectrum3(9, 730);
            break;
          case 5 :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(3, 730);
            power_spectrum3(4, 730);
            power_spectrum3(5, 730);
            power_spectrum3(9, 730);
            break;
          case 6 :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(3, 730);
            power_spectrum3(4, 730);
            power_spectrum3(5, 730);
            power_spectrum3(6, 730);
            power_spectrum3(9, 730);
            break;
          default :
            power_spectrum3(1, 730);
            power_spectrum3(2, 730);
            power_spectrum3(3, 730);
            power_spectrum3(4, 730);
            power_spectrum3(5, 730);
            power_spectrum3(6, 730);
            power_spectrum3(9, 730);
            break;
          }

          bispectral_analysis();

          y_sef95_self = sef95(y_abs_Hz[0]);

          trend_graph();

          labels_2();

          saveFrame("user_data/" + date_now + "/frames/########.png");

      } else if (choice == 0) {
        title_show();
        //if (Start_Flag == 1) {
          
        //  choice = 1;
          
  //array_init_float(Freq_adj[Gf_R1-1]);
  //array_init_2d_float(Freq_adj2[Gf_R1-1]);
  //array_init_float(Pw_adj[Gf_R1-1]);
  //array_init_2d_float(Pw_adj2[Gf_R1-1]);

          //Console 2
          //println("Decomposition_Mode=: ", D_Mode);
          //Console 3
          //Console 4
          //println("Input Datafile=: ", input_datafile);
          //println("SATARTED");
          //println("Dual Mode=: ", dual);
    //  }
      }
    }
  }   //try
  catch(RuntimeException e) {
  }
}

void imfs_temp(double [][] _imfs) {
  for (int k=1; k < K+1; k++) {
    for (int i=0; i < int(T1); i++) {
      imfs[k-1][i] = _imfs[k-1][i];
      //u_n1_double[i] = u_double[k-1][i];
    }
  }
}

void imfs(double [][] _imfs) {
  for (int k=1; k < K+1; k++) {
    for (int i=0; i < int(T1); i++) {
      imfs_float[k-1][i] = (float) _imfs[k-1][i];
      //u_n1_double[i] = u_double[k-1][i];
    }
  }
}


void spectral_packet(String _packet) {

  String packet = _packet;
  dsc_gain_num = unhex(packet.substring(58, 60))*256*256*256 + unhex(packet.substring(56, 58))*256*256
    + unhex(packet.substring(54, 56))*256 + unhex(packet.substring(52, 54));
  if (dsc_gain_num > 2147483648L) {
    dsc_gain_num = - (2147483648L - (dsc_gain_num - 2147483648L));
  }

  dsc_gain_divisor = unhex(packet.substring(66, 68))*256*256*256 + unhex(packet.substring(64, 66))*256*256
    + unhex(packet.substring(62, 64))*256 + unhex(packet.substring(60, 62));

  if (dsc_gain_divisor > 2147483648L) {
    dsc_gain_divisor = - (2147483648L - (dsc_gain_divisor - 2147483648L));
  }

  dsc_offset_num = unhex(packet.substring(74, 76))*256*256*256 + unhex(packet.substring(72, 74))*256*256
    + unhex(packet.substring(70, 72))*256 + unhex(packet.substring(68, 70));

  if (dsc_offset_num > 2147483648L) {
    dsc_offset_num = - (2147483648L - (dsc_offset_num - 2147483648L));
  }

  dsc_offset_divisor = unhex(packet.substring(82, 84))*256*256*256 + unhex(packet.substring(80, 82))*256*256
    + unhex(packet.substring(78, 80))*256 + unhex(packet.substring(76, 78));

  if (dsc_offset_divisor > 2147483648L) {
    dsc_offset_divisor = - (2147483648L - (dsc_offset_divisor - 2147483648L));
  }

  dsc_gain = ((float)dsc_gain_num)/((float)dsc_gain_divisor);
  dsc_offset =(float)(dsc_offset_num/dsc_offset_divisor) ;

  //type signed = 16 bits
  burst_suppress_ratio[0] = unhex(packet.substring(134, 136))*256 + unhex(packet.substring(132, 134));
  if (burst_suppress_ratio[0] > 32768) {
    burst_suppress_ratio[0] = - (32768 - (burst_suppress_ratio[0]-32768));
  }

  burst_suppress_ratio[1] = unhex(packet.substring(182, 184))*256 + unhex(packet.substring(180, 182));
  if (burst_suppress_ratio[1] > 32768) {
    burst_suppress_ratio[1] = - (32768 - (burst_suppress_ratio[1]-32768));
  }

  spectral_edge_95[0] = unhex(packet.substring(138, 140))*256 + unhex(packet.substring(136, 138));
  if (spectral_edge_95[0] > 32768) {
    spectral_edge_95[0] = - (32768 - (spectral_edge_95[0]-32768));
  }

  spectral_edge_95[1] = unhex(packet.substring(186, 188))*256 + unhex(packet.substring(184, 186));
  if (spectral_edge_95[1] > 32768) {
    spectral_edge_95[1] = - (32768 - (spectral_edge_95[1]-32768));
  }

  bis_bits[0] = unhex(packet.substring(142, 144))*256 + unhex(packet.substring(140, 142));
  if (bis_bits[0] > 32768) {
    bis_bits[0] = - (32768 - (bis_bits[0]-32768));
  }

  bis_bits[1] = unhex(packet.substring(190, 192))*256 + unhex(packet.substring(188, 190));
  if (bis_bits[1] > 32768) {
    bis_bits[1] = - (32768 - (bis_bits[1]-32768));
  }

  bispectral_index[0] = unhex(packet.substring(146, 148))*256 + unhex(packet.substring(144, 146));
  if (bispectral_index[0] > 32768) {
    bispectral_index[0] = - (32768 - (bispectral_index[0]-32768));
  }

  bispectral_index[1] = unhex(packet.substring(194, 196))*256 + unhex(packet.substring(192, 194));
  if (bispectral_index[1] > 32768) {
    bispectral_index[1] = - (32768 - (bispectral_index[1]-32768));
  }

  bispectral_alternate_index[0] = unhex(packet.substring(150, 152))*256 + unhex(packet.substring(148, 150));
  if (bispectral_alternate_index[0] > 32768) {
    bispectral_alternate_index[0] = - (32768 - (bispectral_alternate_index[0]-32768));
  }

  bispectral_alternate_index[1] = unhex(packet.substring(198, 200))*256 + unhex(packet.substring(196, 198));
  if (bispectral_alternate_index[1] > 32768) {
    bispectral_alternate_index[1] = - (32768 - (bispectral_alternate_index[1]-32768));
  }

  bispectral_alternate2_index[0] = unhex(packet.substring(154, 156))*256 + unhex(packet.substring(152, 154));
  if (bispectral_alternate2_index[0] > 32768) {
    bispectral_alternate2_index[0] = - (32768 - (bispectral_alternate2_index[0]-32768));
  }

  bispectral_alternate2_index[1] = unhex(packet.substring(202, 204))*256 + unhex(packet.substring(200, 202));
  if (bispectral_alternate2_index[1] > 32768) {
    bispectral_alternate2_index[1] = - (32768 - (bispectral_alternate2_index[1]-32768));
  }

  total_power[0] = unhex(packet.substring(158, 160))*256 + unhex(packet.substring(156, 158));
  if (total_power[0] > 32768) {
    total_power[0] = - (32768 - (total_power[0]-32768));
  }

  total_power[1] = unhex(packet.substring(206, 208))*256 + unhex(packet.substring(204, 206));
  if (total_power[1] > 32768) {
    total_power[1] = - (32768 - (total_power[1]-32768));
  }

  emg_low[0] = unhex(packet.substring(162, 164))*256 + unhex(packet.substring(160, 162));
  if (emg_low[0] > 32768) {
    emg_low[0] = - (32768 - (emg_low[0]-32768));
  }

  emg_low[1] = unhex(packet.substring(210, 212))*256 + unhex(packet.substring(208, 210));
  if (emg_low[1] > 32768) {
    emg_low[1] = - (32768 - (emg_low[1]-32768));
  }

  //type long = 32 bits
  bis_signal_quality[0] = unhex(packet.substring(170, 172))*256*256*256 + unhex(packet.substring(168, 170))*256*256
    + unhex(packet.substring(166, 168))*256 + unhex(packet.substring(164, 166));
  if (bis_signal_quality[0] > 2147483648L) {
    bis_signal_quality[0] = - (2147483648L - (bis_signal_quality[0]-2147483648L));
  }

  bis_signal_quality[1] = unhex(packet.substring(218, 220))*256*256*256 + unhex(packet.substring(216, 218))*256*256
    + unhex(packet.substring(214, 216))*256 + unhex(packet.substring(212, 214));
  if (bis_signal_quality[1] > 2147483648L) {
    bis_signal_quality[1] = - (2147483648L - (bis_signal_quality[1]-2147483648L));
  }

  second_artifact[0] = unhex(packet.substring(178, 180))*256*256*256 + unhex(packet.substring(176, 178))*256*256
    + unhex(packet.substring(174, 176))*256 + unhex(packet.substring(172, 174));
  if (second_artifact[0] > 2147483648L ) {
    second_artifact[0] = - (2147483648L  - (bis_signal_quality[0]-2147483648L));
  }

  second_artifact[1] = unhex(packet.substring(226, 228))*256*256*256 + unhex(packet.substring(224, 226))*256*256
    + unhex(packet.substring(222, 224))*256 + unhex(packet.substring(220, 222));
  if (second_artifact[1] > 2147483648L ) {
    second_artifact[1] = - (2147483648L  - (second_artifact[1]-2147483648L));
  }

  for (int i=0; i<60; i++) {
    sp1[i] = unhex(packet.substring(286+i*4, 288+i*4))*256 + unhex(packet.substring(284+i*4, 286+i*4));

    if (sp1[i] > 32768) {
      sp1[i] = - (32768 - (sp1[i]-32768));
    }

    sp1[i] = float(round(sp1[i]*pow(10, 2)))/pow(10, 2)/ps_divisor;

    maxRange2 = 1;
    for (int z = 0; z < 60; z++) {
      maxRange2 = (abs(sp1[z]) > maxRange2 ? abs(sp1[z]) : maxRange2);
    }
  }

  if (trend_flag == 0) {
    if (powerSpec_cnt >=1) {
      for (int j=0; j<powerSpec_cnt; j++) {
        for (int i=0; i<60; i++) {
          sp_mem[powerSpec_cnt-j][i] = sp_mem[powerSpec_cnt-1-j][i] ;
          sp_mem[0][i] = sp1[i] ;
        }
      }
    }

    sp1_total = array_sum_float(sp1);
    sp1_total_dB = (20*log10(sp1_total/0.01))/2;
  }
  if (trend_flag == 1) {
    if (powerSpec_cnt >=1) {
      array_shift_2d_float(sp_mem, sp1);
    }
    sp1_total = array_sum_float(sp1);
    sp1_total_dB = (20*log10(sp1_total/0.01))/2;
  }
  powerSpec_cnt = powerSpec_cnt + 1;

  if (powerSpec_cnt == color_trend_size) {
    powerSpec_cnt = 0;
    trend_flag = 1;
  }
}

int eeg_packet(int _packet_cnt, String _packet) {
  int packet_cnt = _packet_cnt;
  String packet = _packet;
  for (int p=0; p < 16; p++) {
    eeg1[packet_cnt][p]  = unhex(packet.substring(46+p*8, 48+p*8))*256 + unhex(packet.substring(44+p*8, 46+p*8));

    if (eeg1[packet_cnt][p] > 32768) {
      eeg1[packet_cnt][p] = - (32768 - (eeg1[packet_cnt][p]-32768));
    }

    //!!!!CLINICAL MODE!!!!!!!
    eeg1[packet_cnt][p] = ((eeg1[packet_cnt][p] - dsc_offset)* dsc_gain);

    //!!!!DEMO MODE!!!!!!!
    if (Mode_Flag == 1) {
      if (eeg1[packet_cnt][p]>16) {
        eeg1[packet_cnt][p] = ( eeg1[packet_cnt][p] / dsc_gain ) + dsc_offset;
      }
    }

    eeg1[packet_cnt][p] = float(round(eeg1[packet_cnt][p]*pow(10, 2)))/pow(10, 2);
  }

  write();

  packet_cnt = packet_cnt + 1;

  if (packet_cnt == 64) {
    packet_cnt = 0;
    for (int q=0; q<64; q++) {
      for (int r=0; r<16; r++) {
        eeg_mem[q*16+r] = eeg1[q][r];
      }
    }

    maxRange1 = 1;
    for (int z = 0; z < 1024; z++) {
      maxRange1 = (abs(eeg_mem[z]) > maxRange1 ? abs(eeg_mem[z]) : maxRange1);
    }

    total_power_eeg = 10*log10(array_sq_sum_float(eeg_mem)/0.01);
  }

  return packet_cnt;
}

void power_spectrum1(int Gf, int yaxis) {
  for (int cnt = 0; cnt < color_trend_size; cnt++) {
    for (int i = 0; i < 94; i++) {
      strokeWeight(1);
      noStroke();

      //println("Pw_adj2[Gf-1][cnt][i]=:", Pw_adj2[Gf-1][cnt][i]);

      if (Freq_adj2[Gf-1][cnt][i] <= 0) {
        fill(0, 0, 0);
      } else {
        //fill(floor(128-(int)((Pw_adj2[Gf-1][cnt][i]-Pw_adj_min[Gf-1])/(Pw_adj_max[Gf-1]-Pw_adj_min[Gf-1])*2048)), 255, 255, 255);
        fill(128-(int)Pw_adj2[Gf-1][cnt][i], 255, 255, 200);
        //println("color_value=:", (int)Pw_adj2[Gf-1][cnt][i]);

        rect(Freq_adj2[Gf-1][cnt][i]-1.8, yaxis+cnt, Freq_adj2[Gf-1][cnt][i]+1.8, yaxis+cnt+1.1);
      }
    }
  }
}


void power_spectrum2(int Gf, int yaxis) {
  for (int cnt = 0; cnt < color_trend_size; cnt++) {
    for (int i = 0; i < 2048; i++) {
      strokeWeight(1);
      noStroke();

      if (Freq_adj2[Gf-1][cnt][i] <= 0) {
        fill(0, 0, 0);
      } else {
        fill(floor(128-(int)((Pw_adj2[Gf-1][cnt][i]-Pw_adj_min[Gf-1])/(Pw_adj_max[Gf-1]-Pw_adj_min[Gf-1])*2048)), 255, 255, 50);

        //30min adjestment
        rect(Freq_adj2[Gf-1][cnt][i], yaxis+cnt, Freq_adj2[Gf-1][cnt][i]+1, yaxis+cnt+1);
      }
    }
  }
}

void power_spectrum3(int Gf, int yaxis) {
  for (int cnt = 0; cnt < color_trend_size; cnt++) {
    for (int i = 0; i < 2048; i++) {
      strokeWeight(1);
      noStroke();

      if (Freq_adj2[Gf-1][cnt][i] <= 0) {
        fill(0, 0, 0);
      } else {
        fill(floor(128-(int)((Pw_adj2[Gf-1][cnt][i]-Pw_adj_min[Gf-1])/(Pw_adj_max[Gf-1]-Pw_adj_min[Gf-1])*2048)), 255, 255, 50);

        //30min adjestment
        rect(Freq_adj2[Gf-1][cnt][i], yaxis+cnt/2, Freq_adj2[Gf-1][cnt][i]+1, yaxis+cnt/2+0.5);
      }
    }
  }
}

void power_spectrum_mt() {

  for (int cnt = 0; cnt < color_trend_size; cnt++) {
    for (int i=0; i<128; i++) {

      strokeWeight(1);
      noStroke();
      if (y_dB_Hz_adj2_mt[cnt][i]+7 <= 0) {
        fill(0, 0, 0);
      } else {
        if (floor(255-(int)((y_dB_Hz_adj2_mt[cnt][i]+7)/12*255))== 255) {
          fill(0, 0, 0);
        } else {
          fill(floor(255-(int)((y_dB_Hz_adj2_mt[cnt][i]+7)/12*255)), 200, 200);
        }
      }
      rect(60+3.5*i*128/128, 655+cnt, 63.5+3.5*i*128/128, 656+cnt);
    }
  }
}


void hht(double [][]_imfs) {
  for (int j =0; j<6; j++) {
    //signal[j] = u_double[j];
    signal[j] = _imfs[j];
  }
  //signal[6] = sumArray(signal[2], signal[3]);
  //signal[7] = sumArray(signal[3], signal[4]);
  //signal[7] = sumArray(signal[4], signal[5]);
  //signal[7] = sumArray(sumArray(sumArray(signal[1], signal[2]), signal[3]), signal[4]);

  switch(K) {
  case 1 :
    //signal[1] = signal[0];
    //signal[2] = signal[0];
    //signal[3] = signal[0];
    //signal[4] = signal[0];
    //signal[5] = signal[0];
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = signal[0];
    break;
  case 2 :
    //signal[2] = signal[0];
    //signal[3] = signal[0];
    //signal[4] = signal[0];
    //signal[5] = signal[0];
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(signal[0], signal[1]);
    break;
  case 3 :
    //signal[3] = signal[0];
    //signal[4] = signal[0];
    //signal[5] = signal[0];
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(sumArray(signal[0], signal[1]), signal[2]);
    break;
  case 4 :
    //signal[4] = signal[0];
    //signal[5] = signal[0];
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(sumArray(sumArray(signal[0], signal[1]), signal[2]), signal[3]);
    break;
  case 5 :
    //signal[5] = signal[0];
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(sumArray(sumArray(sumArray(signal[0], signal[1]), signal[2]), signal[3]), signal[4]);
    break;
  case 6 :
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(sumArray(sumArray(sumArray(sumArray(signal[0], signal[1]), signal[2]), signal[3]), signal[4]), signal[5]);
    break;
  default:
    signal[6] = signal[0];
    signal[7] = signal[0];
    signal[8] = sumArray(sumArray(sumArray(sumArray(sumArray(signal[0], signal[1]), signal[2]), signal[3]), signal[4]), signal[5]);
    break;
  }

  for (int j =0; j<9; j++) {
    for (int i=0; i<1024; i++) {
      signal_float[j][i] =  (float) signal[j][i];
    }
  }

  Fs = 128; //Sampling Frequency of the original signal

  for (int j =0; j<9; j++) {
    hilb[j] = new Hilbert(signal[j]);
    hilb[j].hilbertTransform();
    analytical_signal[j] = hilb[j].getOutput();
    envelope[j] = hilb[j].getAmplitudeEnvelope();
    phase[j] = hilb[j].getInstantaneousPhase();
    frequency[j] = hilb[j].getInstantaneousFrequency(Fs);
    for (int i=0; i<1024; i++) {
      envelope_float[j][i] =  (float) envelope[j][i];
      frequency_float[j][i] = (float) frequency[j][i];
    }
    for (int i=0; i<1024; i++) {
      amp_float[j][i] =   envelope_float[j][i] * envelope_float[j][i];
    }

    tp[j] =  arrSqSum(envelope_float[j]);
    tp_low[j] = arrSqSum_low(limitter, frequency_float[j], envelope_float[j]);
    fq_mean[j] = arrAvg(frequency_float[j]);
    fq_mean_low[j] = arrAvg_low(frequency_float[j], limitter);
    fq_stdev_low[j] = arrStd_low(frequency_float[j], limitter, fq_mean_low[j]);
    fq_stdev[j] = arrStdev(frequency_float[j]);
  }

  //select_imf = Gf_R1;

  select_fq_mean = fq_mean[Gf_R1-1];
  select_fq_stdev = fq_stdev[Gf_R1-1];

  if (tp[Gf_R1 -1]/1000 >= 200) {
    //select_imf=1;
    image(img6, 100, 2);
    image(imgL6, 1380, 130);
  } else if (tp[Gf_R1-1]/1000 >= 100) {
    //select_imf=2;
    image(img5, 100, 2);
    image(imgL5, 1380, 130);
  } else if (tp[Gf_R1-1]/1000 >= 50) {
    //select_imf=3;
    image(img4, 100, 2);
    image(imgL4, 1380, 130);
  } else if (tp[Gf_R1-1]/1000 >= 25) {
    //select_imf=4;
    image(img3, 100, 2);
    image(imgL3, 1380, 130);
  } else if (tp[Gf_R1-1]/1000 >= 10) {
    //select_imf=5;
    image(img2, 100, 2);
    image(imgL2, 1380, 130);
  } else {
    //select_imf=6;
    image(img1, 100, 2);
    image(imgL1, 1380, 130);
  }
}

void write() {
  year = year();
  month = month();
  day = day();
  sec = second();
  min = minute();
  hour = hour();
  date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
  time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

  if (inBuffer !=null) {
    output1.println("ch1:" + TAB + time + TAB + eeg1[packet_cnt][0] + TAB + eeg1[packet_cnt][1] + TAB + eeg1[packet_cnt][2] + TAB + eeg1[packet_cnt][3] + TAB + eeg1[packet_cnt][4]
      + TAB + eeg1[packet_cnt][5] + TAB + eeg1[packet_cnt][6] + TAB + eeg1[packet_cnt][7] + TAB + eeg1[packet_cnt][8] + TAB + eeg1[packet_cnt][9] + TAB + eeg1[packet_cnt][10] + TAB + eeg1[packet_cnt][11]
      + TAB + eeg1[packet_cnt][12] + TAB + eeg1[packet_cnt][13] + TAB + eeg1[packet_cnt][14] + TAB + eeg1[packet_cnt][15]);
  } else {
  }
  output1.flush();
}

void write_sp() {
  year = year();
  month = month();
  day = day();
  sec = second();
  min = minute();
  hour = hour();
  date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
  time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

  if (inBuffer !=null) {
    output2.println("ch1:" + TAB + time + TAB + dsc_gain + TAB + dsc_offset  +  TAB + spectral_edge_95[0]/100
      + TAB + float(round(bispectral_index[0]/10*pow(10, 1)))/pow(10, 1)
      + TAB + burst_suppress_ratio[0] + TAB + total_power[0] + TAB + emg_low[0] + TAB + bis_signal_quality[0]
      + TAB + sp1[0] + TAB + sp1[1] + TAB + sp1[2] + TAB + sp1[3] + TAB + sp1[4]
      + TAB + sp1[5] + TAB + sp1[6] + TAB + sp1[7] + TAB + sp1[8] + TAB + sp1[9] + TAB + sp1[10] + TAB + sp1[11]
      + TAB + sp1[12] + TAB + sp1[13] + TAB + sp1[14] + TAB + sp1[15] + TAB + sp1[16] + TAB + sp1[17] + TAB + sp1[18]
      + TAB + sp1[19] + TAB + sp1[20] + TAB + sp1[21] + TAB + sp1[22] + TAB + sp1[23] + TAB + sp1[24] + TAB + sp1[25]
      + TAB + sp1[26] + TAB + sp1[27] + TAB + sp1[28] + TAB + sp1[29] + TAB + sp1[30] + TAB + sp1[31] + TAB + sp1[32]
      + TAB + sp1[33] + TAB + sp1[34] + TAB + sp1[35] + TAB + sp1[36] + TAB + sp1[37] + TAB + sp1[38] + TAB + sp1[39]
      + TAB + sp1[40] + TAB + sp1[41] + TAB + sp1[42] + TAB + sp1[43] + TAB + sp1[44] + TAB + sp1[45] + TAB + sp1[46]
      + TAB + sp1[47] + TAB + sp1[48] + TAB + sp1[49] + TAB + sp1[50] + TAB + sp1[51] + TAB + sp1[52] + TAB + sp1[53]
      + TAB + sp1[54] + TAB + sp1[55] + TAB + sp1[56] + TAB + sp1[57] + TAB + sp1[58] + TAB + sp1[59]);
  } else {
  }
  output2.flush();
}

void write_FFT() {
  year = year();
  month = month();
  day = day();
  sec = second();
  min = minute();
  hour = hour();
  date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
  time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

  output_fft_abs.print("ch1:" + TAB + time);
  for (int i=0; i < 128; i++) {
    output_fft_abs.print(TAB);
    output_fft_abs.print(y_abs_Hz[2][i]);
  }
  output_fft_abs.println("");
  output_fft_abs.flush();

  output_fft_dB.print("ch1:" + TAB + time);
  for (int i=0; i < 128; i++) {
    output_fft_dB.print(TAB);
    output_fft_dB.print(y_dB_Hz[2][i]);
  }
  output_fft_dB.println("");
  output_fft_dB.flush();
}

void write_HHT() {
  year = year();
  month = month();
  day = day();
  sec = second();
  min = minute();
  hour = hour();
  date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
  time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

  switch(Gf_R1) {
  case 1 :
    Freq = frequency_float[0];
    Amp  = envelope_float[0];
    tp_sum = tp[0];
    tp_sum_low = tp_low[0];
    fq_mean_avg = fq_mean[0];
    fq_stdev_avg = fq_stdev[0];
    fq_mean_low_avg = fq_mean_low[0];
    fq_stdev_low_avg = fq_stdev_low[0];
    break;
  case 2 :
    Freq = frequency_float[1];
    Amp  = envelope_float[1];
    tp_sum = tp[1];
    tp_sum_low = tp_low[1];
    fq_mean_avg = fq_mean[1];
    fq_stdev_avg = fq_stdev[1];
    fq_mean_low_avg = fq_mean_low[1];
    fq_stdev_low_avg = fq_stdev_low[1];
    break;
  case 3 :
    Freq = frequency_float[2];
    Amp  = envelope_float[2];
    tp_sum = tp[2];
    tp_sum_low = tp_low[2];
    fq_mean_avg = fq_mean[2];
    fq_stdev_avg = fq_stdev[2];
    fq_mean_low_avg = fq_mean_low[2];
    fq_stdev_low_avg = fq_stdev_low[2];
    break;
  case 4 :
    Freq = frequency_float[3];
    Amp  = envelope_float[3];
    tp_sum = tp[3];
    tp_sum_low = tp_low[3];
    fq_mean_avg = fq_mean[3];
    fq_stdev_avg = fq_stdev[3];
    fq_mean_low_avg = fq_mean_low[3];
    fq_stdev_low_avg = fq_stdev_low[3];
    break;
  case 5 :
    Freq = frequency_float[4];
    Amp  = envelope_float[4];
    tp_sum = tp[4];
    tp_sum_low = tp_low[4];
    fq_mean_avg = fq_mean[4];
    fq_stdev_avg = fq_stdev[4];
    fq_mean_low_avg = fq_mean_low[4];
    fq_stdev_low_avg = fq_stdev_low[4];
    break;
  case 6 :
    Freq = frequency_float[5];
    Amp  = envelope_float[5];
    tp_sum = tp[5];
    tp_sum_low = tp_low[5];
    fq_mean_avg = fq_mean[5];
    fq_stdev_avg = fq_stdev[5];
    fq_mean_low_avg = fq_mean_low[5];
    fq_stdev_low_avg = fq_stdev_low[5];
    break;

  case 9 :
    Freq = frequency_float[8];
    Amp  = envelope_float[8];
    tp_sum = tp[8];
    tp_sum_low = tp_low[8];
    fq_mean_avg = fq_mean[8];
    fq_stdev_avg = fq_stdev[8];
    fq_mean_low_avg = fq_mean_low[8];
    fq_stdev_low_avg = fq_stdev_low[8];
    break;

  default:
    Freq = frequency_float[0];
    Amp  = envelope_float[0];
    tp_sum = tp[0];
    tp_sum_low = tp_low[0];
    fq_mean_avg = fq_mean[0];
    fq_stdev_avg = fq_stdev[0];
    fq_mean_low_avg = fq_mean_low[0];
    fq_stdev_low_avg = fq_stdev_low[0];

    break;
  }

  his = 2.8061*(float)fq_mean_avg+15.589;
  his_low = 2.8061*(float)fq_mean_low_avg+15.589;

  output_hht_spec_freq.print("ch1:" + TAB + time);
  for (int i=0; i < 1024; i++) {
    output_hht_spec_freq.print(TAB);
    output_hht_spec_freq.print(Freq[i]);
  }
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean_avg);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[0]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[1]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[2]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[3]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[4]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean[5]);

  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_mean_low_avg);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(his);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(his_low);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_stdev_avg);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(fq_stdev_low_avg);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp_sum);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[0]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[1]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[2]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[3]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[4]);
  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp[5]);

  output_hht_spec_freq.print(TAB);
  output_hht_spec_freq.print(tp_sum_low);
  output_hht_spec_freq.println();
  output_hht_spec_freq.flush();

  output_hht_spec_amp.print("ch1:" + TAB + time);
  for (int i=0; i < 1024; i++) {
    output_hht_spec_amp.print(TAB);
    output_hht_spec_amp.print(Amp[i]);
  }
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean_avg);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[0]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[1]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[2]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[3]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[4]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean[5]);

  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_mean_low_avg);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(his);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(his_low);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_stdev_avg);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(fq_stdev_low_avg);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp_sum);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[0]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[1]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[2]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[3]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[4]);
  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp[5]);

  output_hht_spec_amp.print(TAB);
  output_hht_spec_amp.print(tp_sum_low);
  output_hht_spec_amp.println();
  output_hht_spec_amp.flush();
}

void write_sp_FFT() {
  year = year();
  month = month();
  day = day();
  sec = second();
  min = minute();
  hour = hour();
  date =  year + ":" + nf(month, 2) + ":" + nf(day, 2);
  time = nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2);

  if (inBuffer !=null) {
    output3.println("ch1:" + TAB + time +
      + TAB + y_dB_sq_mt[0] + TAB + y_dB_sq_mt[1] + TAB + y_dB_sq_mt[2] + TAB + y_dB_sq_mt[3] + TAB + y_dB_sq_mt[4]
      + TAB + y_dB_sq_mt[5] + TAB + y_dB_sq_mt[6] + TAB + y_dB_sq_mt[7] + TAB + y_dB_sq_mt[8] + TAB + y_dB_sq_mt[9]
      + TAB + y_dB_sq_mt[10] + TAB + y_dB_sq_mt[11] + TAB + y_dB_sq_mt[12] + TAB + y_dB_sq_mt[13] + TAB + y_dB_sq_mt[14]
      + TAB + y_dB_sq_mt[15] + TAB + y_dB_sq_mt[16] + TAB + y_dB_sq_mt[17] + TAB + y_dB_sq_mt[18] + TAB + y_dB_sq_mt[19]
      + TAB + y_dB_sq_mt[20] + TAB + y_dB_sq_mt[21] + TAB + y_dB_sq_mt[22] + TAB + y_dB_sq_mt[23] + TAB + y_dB_sq_mt[24]
      + TAB + y_dB_sq_mt[25] + TAB + y_dB_sq_mt[26] + TAB + y_dB_sq_mt[27] + TAB + y_dB_sq_mt[28] + TAB + y_dB_sq_mt[29]
      + TAB + y_dB_sq_mt[30] + TAB + y_dB_sq_mt[31] + TAB + y_dB_sq_mt[32] + TAB + y_dB_sq_mt[33] + TAB + y_dB_sq_mt[34]
      + TAB + y_dB_sq_mt[35] + TAB + y_dB_sq_mt[36] + TAB + y_dB_sq_mt[37] + TAB + y_dB_sq_mt[38] + TAB + y_dB_sq_mt[39]
      + TAB + y_dB_sq_mt[40] + TAB + y_dB_sq_mt[41] + TAB + y_dB_sq_mt[42] + TAB + y_dB_sq_mt[43] + TAB + y_dB_sq_mt[44]
      + TAB + y_dB_sq_mt[45] + TAB + y_dB_sq_mt[46] + TAB + y_dB_sq_mt[47] + TAB + y_dB_sq_mt[48] + TAB + y_dB_sq_mt[49]
      + TAB + y_dB_sq_mt[50] + TAB + y_dB_sq_mt[51] + TAB + y_dB_sq_mt[52] + TAB + y_dB_sq_mt[53] + TAB + y_dB_sq_mt[54]
      + TAB + y_dB_sq_mt[55] + TAB + y_dB_sq_mt[56] + TAB + y_dB_sq_mt[57] + TAB + y_dB_sq_mt[58] + TAB + y_dB_sq_mt[59]
      + TAB + y_dB_sq_mt[60] + TAB + y_dB_sq_mt[61] + TAB + y_dB_sq_mt[62] + TAB + y_dB_sq_mt[63] + TAB + y_dB_sq_mt[64]
      + TAB + y_dB_sq_mt[65] + TAB + y_dB_sq_mt[66] + TAB + y_dB_sq_mt[67] + TAB + y_dB_sq_mt[68] + TAB + y_dB_sq_mt[69]
      + TAB + y_dB_sq_mt[70] + TAB + y_dB_sq_mt[71] + TAB + y_dB_sq_mt[72] + TAB + y_dB_sq_mt[73] + TAB + y_dB_sq_mt[74]
      + TAB + y_dB_sq_mt[75] + TAB + y_dB_sq_mt[76] + TAB + y_dB_sq_mt[77] + TAB + y_dB_sq_mt[78] + TAB + y_dB_sq_mt[79]
      + TAB + y_dB_sq_mt[80] + TAB + y_dB_sq_mt[81] + TAB + y_dB_sq_mt[82] + TAB + y_dB_sq_mt[83] + TAB + y_dB_sq_mt[84]
      + TAB + y_dB_sq_mt[85] + TAB + y_dB_sq_mt[86] + TAB + y_dB_sq_mt[87] + TAB + y_dB_sq_mt[88] + TAB + y_dB_sq_mt[89]
      + TAB + y_dB_sq_mt[90] + TAB + y_dB_sq_mt[91] + TAB + y_dB_sq_mt[92] + TAB + y_dB_sq_mt[93] + TAB + y_dB_sq_mt[94]
      + TAB + y_dB_sq_mt[95] + TAB + y_dB_sq_mt[96] + TAB + y_dB_sq_mt[97] + TAB + y_dB_sq_mt[98] + TAB + y_dB_sq_mt[99]
      + TAB + y_dB_sq_mt[100] + TAB + y_dB_sq_mt[101] + TAB + y_dB_sq_mt[102] + TAB + y_dB_sq_mt[103] + TAB + y_dB_sq_mt[104]
      + TAB + y_dB_sq_mt[105] + TAB + y_dB_sq_mt[106] + TAB + y_dB_sq_mt[107] + TAB + y_dB_sq_mt[108] + TAB + y_dB_sq_mt[109]
      + TAB + y_dB_sq_mt[110] + TAB + y_dB_sq_mt[111] + TAB + y_dB_sq_mt[112] + TAB + y_dB_sq_mt[113] + TAB + y_dB_sq_mt[114]
      + TAB + y_dB_sq_mt[115] + TAB + y_dB_sq_mt[116] + TAB + y_dB_sq_mt[117] + TAB + y_dB_sq_mt[118] + TAB + y_dB_sq_mt[119]
      + TAB + y_dB_sq_mt[120] + TAB + y_dB_sq_mt[121] + TAB + y_dB_sq_mt[122] + TAB + y_dB_sq_mt[123] + TAB + y_dB_sq_mt[124]
      + TAB + y_dB_sq_mt[125] + TAB + y_dB_sq_mt[126] + TAB + y_dB_sq_mt[127]);
  } else {
  }
  output3.flush();
}

void write_binary(byte[] aInput, String aOutputFileName) {
  println("Writing binary file...");
  try {
    OutputStream output = null;
    try {
      output = new BufferedOutputStream(new FileOutputStream(aOutputFileName, true));
      output.write(aInput);
    }
    finally {
      output.close();
    }
  }
  catch(FileNotFoundException ex) {
    println("File not found.");
  }
  catch(IOException ex) {
    println(ex);
  }
}


byte[] read_binary(String aInputFileName) {
  println("Reading in binary file named : " + aInputFileName);
  File file = new File(aInputFileName);
  println("File size: " + file.length());
  byte[] result = new byte[(int)file.length()];
  try {
    InputStream input = null;
    try {
      int totalBytesRead = 0;
      input = new BufferedInputStream(new FileInputStream(file));
      while (totalBytesRead < result.length) {
        int bytesRemaining = result.length - totalBytesRead;
        //input.read() returns -1, 0, or more :
        int bytesRead = input.read(result, totalBytesRead, bytesRemaining);
        if (bytesRead > 0) {
          totalBytesRead = totalBytesRead + bytesRead;
        }
      }
      /*
         the above style is a bit tricky: it places bytes into the 'result' array;
       'result' is an output parameter;
       the while loop usually has a single iteration only.
       */
      println("Num bytes read: " + totalBytesRead);
    }
    finally {
      println("Closing input stream.");
      input.close();
    }
  }
  catch (FileNotFoundException ex) {
    println("File not found.");
  }
  catch (IOException ex) {
    println(ex);
  }
  return result;
}

void stop() {
  output1.close();
  output2.close();
  output3.close();
  output_fft_abs.close();
  output_fft_dB.close();
  output_hht_spec_freq.close();
  output_hht_spec_amp.close();
  output4.close();
  //fstream.close();
  super.stop();
}

void draw_eegGraph(int _k) {
  float xdataMax, xdataMin;
  float xvolumeInterval, xvolumeIntervalMinor;
  float plotX1, plotY1, plotX2, plotY2;
  float labelX, labelY;
  int k = _k;

  xdataMax = 384;
  xdataMin = 0;

  plotX1 = 100;
  plotX2 = width - plotX1-550;
  plotY1 = 150;
  plotY2 = height - plotY1-295;
  labelX = 20;
  labelY = height - 463;
  xvolumeInterval = 128;
  xvolumeIntervalMinor = 48;

  //eegGraph.graphDraw(eeg_run);
  //eeg_run=eeg_mem[k];

  noStroke();
  fill(0);
  stroke(224);
  strokeWeight(0.25);

  for (float v = xdataMin; v <= xdataMax; v += xvolumeIntervalMinor) {
    float x = map(v, xdataMax, xdataMin, plotX2, plotX1);
    line(x, plotY1, x, plotY2);     // Draw major tick
  }

  fill(0);
  textSize(13);
  textLeading(15);
  textAlign(LEFT, CENTER);
  text("uV", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Raw EEG", (plotX1+plotX2)/2, labelY);
}


void get_eegData() {

  for (int i=0; i<1024; i++) {
    data_n[i] = (float) i;
    x0_Hz[i] = 0.125 + 0.125*i;
    x0[i] = (double) eeg_mem[i];  //x1[data_n] = raw EEG
    x0_r1024[i] = x0[i];
    x0_float[i] = (float) x0[i];
    Hanning[i] = 0.5-0.5*cos(2*PI*i/1023);
    x0_Hanning[i] = Hanning[i] * x0[i];
    Blackman[i] = 0.42+0.5*cos(2*PI*i/1023)+ 0.08*cos(4*PI*i/1023);
    x0_Blackman[i] = Blackman[i] * x0[i];
  }
  
  for (int i=0; i<1040; i++) {
    x1[i] = (double) eeg_mem[i]; 
  }
  
  //for (int i=0; i<1040; i++) {
  //   x0[i] = (double) eeg_mem[i];  //x1[data_n] = raw EEG
  //}
  
  for (int i=0; i<256; i++) {
    x0_Hz_avg[i] = 0.5 + 0.5 * i;
  }

  for (int i=0; i<1024; i++) {
    //x0_Hz[i] = 0.125*i;
    //x0_pre[i] = (double) eeg_mem[i];
    x0_post[i] = (double) eeg_mem[i];
  }

  for (int i=0; i<1024; i++) {
    x0_float[i] = (float) x0[i];   // raw EEG
    x0_post_float[i] = (float) x0_post[i]; //Input data sets for FFT and poincare
  }

  // FIR filter sets
  //x0_filtered_0 = x0_post;
  x0_filtered_0 = high_pass_filter(low_pass_filter(x0_post, fe2, fs, delta), fe1, fs, delta);


  //FFT sets
  FastFourierTransformer fft = new FastFourierTransformer(DftNormalization.STANDARD);
  y[0] = fft.transform(x0, TransformType.FORWARD);
  y[1] = fft.transform(x0_Hanning, TransformType.FORWARD);
  y[2] = fft.transform(x0_Blackman, TransformType.FORWARD);

  for (int j=0; j<3; j++) {
    for (int i=0; i<1024; i++) {
      y_abs[j][i] = y[j][i].abs();
    }
    for (int i=0; i<255; i++) {
      y_abs_Hz[j][i] = (y_abs[j][4*i] +  y_abs[j][4*i+1]  +  y_abs[j][4*i+2] +  y_abs[j][4*i+3]);
      y_dB_Hz[j][i] = 20*log(((float) y_abs_Hz[j][i]/0.1))/log(10);
      y_abs_Hz_float[j][i] = (float) y_abs_Hz[j][i];
      y_dB_Hz_float[j][i] = (float) y_dB_Hz[j][i];
    }
  }


  //multitaper
  for (int i=0; i<1024; i++) {
    x0_taper_1[i] = x0[i] * taper_1[i];
  }
  for (int i=0; i<1024; i++) {
    x0_taper_2[i] = x0[i] * taper_2[i];
  }
  for (int i=0; i<1024; i++) {
    x0_taper_3[i] = x0[i] * taper_3[i];
  }
  for (int i=0; i<1024; i++) {
    x0_taper_4[i] = x0[i] * taper_4[i];
  }
  for (int i=0; i<1024; i++) {
    x0_taper_5[i] = x0[i] * taper_5[i];
  }

  y_taper_1 = fft.transform(x0_taper_1, TransformType.FORWARD);
  y_taper_2 = fft.transform(x0_taper_2, TransformType.FORWARD);
  y_taper_3 = fft.transform(x0_taper_3, TransformType.FORWARD);
  y_taper_4 = fft.transform(x0_taper_4, TransformType.FORWARD);
  y_taper_5 = fft.transform(x0_taper_5, TransformType.FORWARD);

  for (int i=0; i<1024; i++) {
    //y0_mt[i] = ((((y0_taper_1[i].add(y0_taper_2[i])).add(y0_taper_2[i])).add(y0_taper_3[i])).add(y0_taper_4[i])).add(y0_taper_5[i]);
    y_abs_mt[i] = 0.2 *(y_taper_1[i].abs() + y_taper_2[i].abs() + y_taper_3[i].abs() + y_taper_4[i].abs() + y_taper_5[i].abs());
  }

  //for (int i=0; i<data_n; i++) {
  //  y0_abs_mt[i] = (y0_mt[i].abs())/5;
  //}

  for (int i=0; i<256; i++) {
    y_abs_Hz_mt[i] = sqrt((float)(y_abs_mt[4*i]*y_abs_mt[4*i] +  y_abs_mt[4*i+1]*y_abs_mt[4*i+1] +  y_abs_mt[4*i+2]*y_abs_mt[4*i+2] +  y_abs_mt[4*i+3]*y_abs_mt[4*i+3])/4);
    //println(y1_abs_Hz[i]);
  }

  for (int i=0; i<255; i++) {
    y_dB_Hz_mt[i] = 20*log(((float) y_abs_Hz_mt[i]))/log(10);
    //     println("y1(dB_Hz)=:", y0_dB_Hz_mt[i]);
  }

  for (int i=0; i<255; i++) {
    y_dB_Hz_float_mt[i] = (float) y_dB_Hz_mt[i];
  }
  // multitaper END

  //poincare plot data set 0
  for (int i=0; i<1024; i++) {
    x0_filtered_0_float[i] = (float) x0_filtered_0[i];
  }

  total_power_x0_filtered = 10*log10(array_sq_sum_float2(x0_float)/0.01);

  for (int j=0; j<3; j++) {
    for (int i=0; i<1024; i++) {
      y_abs[j][i] = y[j][i].abs();
    }
    for (int i=0; i<255; i++) {
      y_abs_Hz[j][i] = (y_abs[j][4*i] +  y_abs[j][4*i+1]  +  y_abs[j][4*i+2] +  y_abs[j][4*i+3]);
      y_dB_Hz[j][i] = 20*log(((float) y_abs_Hz[j][i]/0.1))/log(10);
      y_abs_Hz_float[j][i] = (float) y_abs_Hz[j][i];
      y_dB_Hz_float[j][i] = (float) y_dB_Hz[j][i];
    }
  }

  maxRange30 = 1;
  maxRange40 = 1;

  for (int z = 0; z < 128; z++) {
    //maxRange30 = (abs((float)y_abs_Hz[j][z]) > maxRange30 ? abs((float)y_abs_Hz[j][z]) : maxRange30);

    //multitaper
    maxRange40_mt = (abs((float)y_dB_sq_mt[z]) > maxRange40_mt ? abs((float)y_dB_sq_mt[z]) : maxRange40_mt);
    //end
    //maxRange40 = (abs((float)y_dB_sq[j][z]) > maxRange40 ? abs((float)y_dB_sq[j][z]) : maxRange40);
  }

  for (int i=0; i<128; i++) {
    //y_abs_Hz_float_adj[j][i] = y_abs_Hz_float[j][i]*12/maxRange30;

    //multitaper
    y_dB_sq_float_adj_mt[i] = (float)y_dB_sq_mt[i]*12/maxRange40-1;
    //end
    //y_dB_sq_float_adj[j][i] = (float)y_dB_sq[j][i]*12/maxRange40-1;
  }
}

void bispectral_analysis() {
  //Bispectral Analysis
  for (int j=5; j<94; j++) {
    for (int i=4; i<j; i++) {
      tripleProduct[j][i] = (y[0][j].multiply(y[0][i])).multiply(y[0][i+j].conjugate());
      tripleProduct_abs[j][i] = tripleProduct[j][i].abs();
    }
  }

  for (int j=94; j<188; j++) {
    for (int i=4; i<188-j; i++) {
      tripleProduct[j][i] = (y[0][j].multiply(y[0][i])).multiply(y[0][i+j].conjugate());
      tripleProduct_abs[j][i] = tripleProduct[j][i].abs();
    }
  }

  tripleProduct_total_005_47 = 0;

  for (int j=5; j<94; j++) {
    for (int i=4; i<j; i++) {
      tripleProduct_total_005_47 += tripleProduct_abs[j][i];
    }
  }

  for (int j=94; j<188; j++) {
    for (int i=4; i<188-j; i++) {
      tripleProduct_total_005_47 += tripleProduct_abs[j][i];
    }
  }

  tripleProduct_total_40_47 = 0;

  for (int j=160; j<188; j++) {
    for (int i=4; i<188-j; i++) {
      tripleProduct_total_40_47 += tripleProduct_abs[j][i];
    }
  }

  sFS_float = (float) (log10((float)(tripleProduct_total_40_47 / tripleProduct_total_005_47)));

  //End Bispectral
}

float sef95(double[] _spectral) {
  float spectral_total = 0;
  float sef95_total=0;
  int sef95 = 0;
  for (int i=0; i<60; i++) {
    spectral_total += (float) _spectral[i] * (float) _spectral[i];
  }

  while (sef95_total < spectral_total*0.95) {
    sef95_total +=(float) _spectral[sef95] * (float) _spectral[sef95];

    sef95++;
  }

  return sef95/2;
}

float relativeBetaRatio(double[] _spectral) {
  float spectral_30_47 = 0;
  float spectral_11_20 =0;
  float _relativeBetaRatio = 0;

  for (int i=120; i<188; i++) {
    spectral_30_47 += (float)_spectral[i] * (float)_spectral[i];
    spectral_30_47 = sqrt(spectral_30_47);
  }

  for (int i=44; i<80; i++) {
    spectral_11_20 += (float)_spectral[i] *(float) _spectral[i];
    spectral_11_20 = sqrt(spectral_11_20);
  }

  _relativeBetaRatio = log10(spectral_30_47/spectral_11_20);

  return _relativeBetaRatio;
}

void trend_graph() {
  for (int i = 0; i < 11; i++) {
    array_shift_2d(Freq_adj2[i], Freq_adj[i]);
    array_shift_2d(Pw_adj2[i], Pw_adj[i]);
  }
}

void draw_graphs() {
  //graph_A = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 50, 1050, 30);
  graph_A = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 50, 1050, 30);
  graph_A.drawAxisLabels("EEG [ms]", "uV");
  graph_A.xdrawVolumeLabels();
  graph_A.ydrawVolumeLabels();
  graph_A.drawxLabels();
  graph_A.drawyLabels();
  graph_A.drawPoints(data_n, x0_float);

  graph_B1 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 90, 1050, 30);
  graph_B1.drawAxisLabels("", "IMF-1");
  graph_B1.xdrawVolumeLabels();
  graph_B1.ydrawVolumeLabels();
  graph_B1.drawxLabels();
  graph_B1.drawyLabels();
  graph_B1.drawPoints(data_n, imfs_float[0]);

  graph_B2 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 130, 1050, 30);
  if (K>1) {
    graph_B2.drawAxisLabels("", "IMF-2");
  }
  graph_B2.xdrawVolumeLabels();
  graph_B2.ydrawVolumeLabels();
  graph_B2.drawxLabels();
  graph_B2.drawyLabels();
  graph_B2.drawPoints(data_n, imfs_float[1]);

  graph_B3 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 170, 1050, 30);
  if (K>2) {
    graph_B3.drawAxisLabels("", "IMF-3");
  }
  graph_B3.xdrawVolumeLabels();
  graph_B3.ydrawVolumeLabels();
  graph_B3.drawxLabels();
  graph_B3.drawyLabels();
  graph_B3.drawPoints(data_n, imfs_float[2]);

  graph_B4 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 210, 1050, 30);
  if (K>3) {
    graph_B4.drawAxisLabels("", "IMF-4");
  }
  graph_B4.xdrawVolumeLabels();
  graph_B4.ydrawVolumeLabels();
  graph_B4.drawxLabels();
  graph_B4.drawyLabels();
  graph_B4.drawPoints(data_n, imfs_float[3]);

  graph_B5 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 250, 1050, 30);
  if (K>4) {
    graph_B5.drawAxisLabels("", "IMF-5");
  }
  graph_B5.xdrawVolumeLabels();
  graph_B5.ydrawVolumeLabels();
  graph_B5.drawxLabels();
  graph_B5.drawyLabels();
  graph_B5.drawPoints(data_n, imfs_float[4]);

  graph_B6 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 290, 1050, 30);
  if (K>5) {
    graph_B6.drawAxisLabels("", "IMF-6");
  }
  graph_B6.xdrawVolumeLabels();
  graph_B6.ydrawVolumeLabels();
  graph_B6.drawxLabels();
  graph_B6.drawyLabels();
  graph_B6.drawPoints(data_n, imfs_float[5]);

  //graph_B6 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 330, 850, 30);
  //graph_B6.drawAxisLabels("", "IMF-3-4");
  //graph_B6.xdrawVolumeLabels();
  //graph_B6.ydrawVolumeLabels();
  //graph_B6.drawxLabels();
  //graph_B6.drawyLabels();
  //graph_B6.drawPoints(data_n, signal_float[6]);

  //graph_B7 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 370, 850, 30);
  graph_B7 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 330, 1050, 30);
  graph_B7.drawAxisLabels("", "Σ IMF");
  graph_B7.xdrawVolumeLabels();
  graph_B7.ydrawVolumeLabels();
  graph_B7.drawxLabels();
  graph_B7.drawyLabels();
  graph_B7.drawPoints(data_n, signal_float[8]);

  //graph_B8 = new Graph(0, 1023, -100, 100, 128, 100, 64, 50, 100, 410, 850, 30);
  //graph_B8.drawAxisLabels("", "HHT-"+Gf_R1);
  //graph_B8.xdrawVolumeLabels();
  //graph_B8.ydrawVolumeLabels();
  //graph_B8.drawxLabels();
  //graph_B8.drawyLabels();
  //graph_B8.drawPoints(data_n, frequency_float[Gf_R1-1]);

  //graph_C = new Graph(0, 47, 0, 20000, 10, 4000, 5, 2000, 100, 650, 300, 80);
  graph_C = new Graph(0, 47, 0, 20000, 10, 4000, 5, 2000, 100, 570, 300, 100);
  graph_C.drawAxisLabels_c("Power Spectrum [Hz]", "uV^2");
  graph_C.xdrawVolumeLabels();
  graph_C.ydrawVolumeLabels();
  graph_C.drawxLabels();
  graph_C.drawyLabels();
  graph_C.drawPoints_c(x0_Hz, y_abs_Hz_float[0], y_abs_Hz_float[1], y_abs_Hz_float[2]);

  //graph_D = new Graph(0, 47, 0, 192, 10, 50, 5, 10, 480, 650, 300, 100);
  graph_D = new Graph(0, 47, 0, 192, 10, 50, 5, 10, 480, 570, 300, 100);
  graph_D.drawAxisLabels_c("Power Spectrum [Hz]", "dB");
  graph_D.xdrawVolumeLabels();
  graph_D.ydrawVolumeLabels();
  graph_D.drawxLabels();
  graph_D.drawyLabels();
  graph_D.drawPoints_c(x0_Hz, y_dB_Hz_float[0], y_dB_Hz_float[1], y_dB_Hz_float[2]);

  //graph_E = new Graph(0, 47, 0, Gf_E_max, 10, int(Gf_E_max/5), 5, int(Gf_E_max/10), 100, 500, 300, 100);
  graph_E = new Graph(0, 47, 0, Gf_E_max, 10, int(Gf_E_max/5), 5, int(Gf_E_max/10), 100, 420, 300, 100);
  graph_E.drawAxisLabels_c("", "Pw1");
  graph_E.xdrawVolumeLabels();
  graph_E.ydrawVolumeLabels();
  graph_E.drawxLabels();
  graph_E.drawyLabels();
  graph_E.drawPoints_e(frequency_float, amp_float);

  //graph_F = new Graph(0, 47, 0, Gf_R1_max, 10, int(Gf_R1_max/5), 5, int(Gf_R1_max/10), 480, 500, 300, 100);
  graph_F = new Graph(0, 47, 0, Gf_R1_max, 10, int(Gf_R1_max/5), 5, int(Gf_R1_max/10), 480, 420, 300, 100);
  graph_F.drawAxisLabels_c("", "Pw2");
  graph_F.xdrawVolumeLabels();
  graph_F.ydrawVolumeLabels();
  graph_F.drawxLabels();
  graph_F.drawyLabels();
  if (dual == 0) {
    graph_F.drawPoints_f1(frequency_float[Gf_R1-1], amp_float[Gf_R1-1]);
  } else {
    graph_F.drawPoints_f2(frequency_float[Gf_R1-1], amp_float[Gf_R1-1], frequency_float[Gf_R2-1], amp_float[Gf_R2-1]);
  }

  //graph_G = new Graph(0, 47, 0, Gf_E_max, 10, int(Gf_E_max/4), 5, int(Gf_R1_max), 100, 480, 300, 15);
  graph_G = new Graph(0, 47, 0, Gf_E_max, 10, int(Gf_E_max/4), 5, int(Gf_R1_max), 100, 400, 300, 15);
  graph_G.drawxLabels();
  graph_G.drawyLabels();
  graph_G.drawPoints_g(frequency_float[8], amp_float[8]);

  //graph_H1: Line hilbert spectrum
  //graph_H1 = new Graph(0, 64, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 480, 480, 300, 15);
  graph_H1 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 480, 400, 300, 15);
  graph_H1.drawxLabels();
  graph_H1.drawyLabels();
  if (dual ==0) {
    graph_H1.drawPoints_h1(frequency_float[Gf_R1-1], amp_float[Gf_R1-1]);
  } else {
    graph_H1.drawPoints_h2(frequency_float[Gf_R1-1], amp_float[Gf_R1-1], frequency_float[Gf_R2-1], amp_float[Gf_R2-1]);
  }

  //graph_H1: hilbert spectrogram
  //graph_H2 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 820, 490, 320, 256);
  graph_H2 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 1220, 410, 320, 256);
  graph_H2.xdrawVolumeLabels();
  graph_H2.drawxLabels();
  graph_H2.drawyLabels();

  if (dual == 1) {
    graph_H2.drawPoints_h4(Gf_R1, Gf_R2, frequency_float[Gf_R1-1], amp_float[Gf_R1-1], frequency_float[Gf_R2-1], amp_float[Gf_R2-1]);
  } else {
    graph_H2.drawPoints_h3(Gf_R1, frequency_float[Gf_R1-1], amp_float[Gf_R1-1]);
  }

  //FFT Spectrogram
  graph_J = new Graph(0, 47, 0, 150, 10, 200, 5, 200, 820, 410, 320, 256);
  graph_J.xdrawVolumeLabels();
  graph_J.drawxLabels();
  graph_J.drawyLabels();
  graph_J.drawPoints_h5(x0_Hz, y_dB_Hz_float[2]);
  //graph_J.drawPoints_h5(x0_Hz, y_dB_Hz_float_mt);


  //HSPG IMF-1
  graph_H2_1 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 100, 730, 160, 128);
  graph_H2_1.xdrawVolumeLabels();
  graph_H2_1.drawxLabels();
  graph_H2_1.drawyLabels();
  graph_H2_1.drawPoints_h3_1(1, frequency_float[0], amp_float[0]);

  //HSPG IMF-2
  graph_H2_2 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 300, 730, 160, 128);
  graph_H2_2.xdrawVolumeLabels();
  graph_H2_2.drawxLabels();
  graph_H2_2.drawyLabels();
  graph_H2_2.drawPoints_h3_1(2, frequency_float[1], amp_float[1]);

  //HSPG IMF-3
  graph_H2_3 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 500, 730, 160, 128);
  graph_H2_3.xdrawVolumeLabels();
  graph_H2_3.drawxLabels();
  graph_H2_3.drawyLabels();
  graph_H2_3.drawPoints_h3_1(3, frequency_float[2], amp_float[2]);

  //HSPG IMF-4
  graph_H2_4 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 700, 730, 160, 128);
  graph_H2_4.xdrawVolumeLabels();
  graph_H2_4.drawxLabels();
  graph_H2_4.drawyLabels();
  graph_H2_4.drawPoints_h3_1(4, frequency_float[3], amp_float[3]);

  //HSPG IMF-5
  graph_H2_5 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 900, 730, 160, 128);
  graph_H2_5.xdrawVolumeLabels();
  graph_H2_5.drawxLabels();
  graph_H2_5.drawyLabels();
  graph_H2_5.drawPoints_h3_1(5, frequency_float[4], amp_float[4]);

  //HSPG IMF-6
  graph_H2_6 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 1100, 730, 160, 128);
  graph_H2_6.xdrawVolumeLabels();
  graph_H2_6.drawxLabels();
  graph_H2_6.drawyLabels();
  graph_H2_6.drawPoints_h3_1(6, frequency_float[5], amp_float[5]);

  //HSPG IMF-all
  graph_H2_7 = new Graph(0, 47, 0, Gf_R1_max, 10, Gf_R1_max, 5, Gf_R1_max, 1300, 730, 160, 128);
  graph_H2_7.xdrawVolumeLabels();
  graph_H2_7.drawxLabels();
  graph_H2_7.drawyLabels();
  graph_H2_7.drawPoints_h3_1(9, frequency_float[8], amp_float[8]);
}



void data_writer_1() {

  year = year();
  month = month();
  day = day();
  hour = hour();
  min = minute();
  sec = second();

  date_now = year + "_" + nf(month, 2) + "_" + nf(day, 2) + "_" + hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
  time_now = hour + "-" + nf(min, 2) + "-" + nf(sec, 2);
  start_time = hour + ":" + nf(min, 2) + ":" + nf(sec, 2);

  output_fft_abs = createWriter("user_data/" + date_now + "/output_fft_abs.tsv");
  output_fft_dB = createWriter("user_data/" + date_now + "/output_fft_dB.tsv");
  output_hht_spec_amp= createWriter("user_data/" + date_now + "/output_hht_spec_amp.tsv");
  output_hht_spec_freq= createWriter("user_data/" + date_now + "/output_hht_spec_freq.tsv");

  TitleData_fft = "Ch" + TAB + "Time";
  for (int i =0; i< 128; i++) {
    TitleData_fft += (TAB +"sp[" + i + "]");
  }

  output_fft_abs.println(TitleData_fft);
  output_fft_abs.flush();

  output_fft_dB.println(TitleData_fft);
  output_fft_dB.flush();

  TitleData_hht_spec = "Ch" + TAB + "Time";
  for (int i =0; i< 1024; i++) {
    TitleData_hht_spec += (TAB +"sp[" + i + "]");
  }
  TitleData_hht_spec += (TAB +"freq_mean_selected");
  TitleData_hht_spec += (TAB +"freq_mean_1");
  TitleData_hht_spec += (TAB +"freq_mean_2");
  TitleData_hht_spec += (TAB +"freq_mean_3");
  TitleData_hht_spec += (TAB +"freq_mean_4");
  TitleData_hht_spec += (TAB +"freq_mean_5");
  TitleData_hht_spec += (TAB +"freq_mean_6");
  TitleData_hht_spec += (TAB +"freq_mean_low");
  TitleData_hht_spec += (TAB +"HIS");
  TitleData_hht_spec += (TAB +"HIS_low");
  TitleData_hht_spec += (TAB +"freq_stdev");
  TitleData_hht_spec += (TAB +"freq_stdev_low");
  TitleData_hht_spec += (TAB +"tp_selected");
  TitleData_hht_spec += (TAB +"tp_1");
  TitleData_hht_spec += (TAB +"tp_2");
  TitleData_hht_spec += (TAB +"tp_3");
  TitleData_hht_spec += (TAB +"tp_4");
  TitleData_hht_spec += (TAB +"tp_5");
  TitleData_hht_spec += (TAB +"tp_6");
  TitleData_hht_spec += (TAB +"tp_low");

  output_hht_spec_freq.println(TitleData_hht_spec);
  output_hht_spec_freq.flush();

  output_hht_spec_amp.println(TitleData_hht_spec);
  output_hht_spec_amp.flush();


  output1 = createWriter("user_data/" + date_now + "/eeg_bis.tsv");

  TitleData = "Ch" + TAB + "Time" + TAB + "ch[0]" + TAB + "ch[1]"+ TAB + "ch[2]" + TAB + "ch[3]" + TAB + "ch[4]" + TAB + "ch[5]" + TAB + "ch[6]"
    + TAB + "ch[7]" + TAB + "ch[8]" + TAB + "ch[9]" + TAB + "ch[10]" + TAB + "ch[11]" + TAB + "ch[12]" + TAB + "ch[13]"
    + TAB + "ch[14]" + TAB + "ch[15]";

  output1.println(TitleData);
  output1.flush();

  output2 = createWriter("user_data/" + date_now + "/pw_spectrum.tsv");
  TitleData2 = "Ch" + TAB + "Time" + TAB + "dsc_gain" + TAB + "dsc_offset" + TAB + "SEF95" + TAB + "BIS" + TAB + "SR" + TAB + "Total_Power" + TAB + "EMG_low" + TAB + "SQ"
    + TAB + "sp[0]" + TAB + "sp[1]" + TAB + "sp[2]" + TAB + "sp[3]" + TAB + "sp[4]" + TAB + "sp[5]" + TAB + "sp[6]"
    + TAB + "sp[7]" + TAB + "sp[8]" + TAB + "sp[9]" + TAB + "sp[10]" + TAB + "sp[11]" + TAB + "sp[12]" + TAB + "sp[13]"
    + TAB + "sp[14]" + TAB + "sp[15]" + TAB + "sp[16]" + TAB + "sp[17]" + TAB + "sp[18]" + TAB + "sp[19]" + TAB + "sp[20]"
    + TAB + "sp[21]" + TAB + "sp[22]" + TAB + "sp[23]" + TAB + "sp[24]" + TAB + "sp[25]" + TAB + "sp[26]" + TAB + "sp[27]"
    + TAB + "sp[28]" + TAB + "sp[29]" + TAB + "sp[30]" + TAB + "sp[31]" + TAB + "sp[32]" + TAB + "sp[33]" + TAB + "sp[34]"
    + TAB + "sp[35]" + TAB + "sp[36]" + TAB + "sp[37]" + TAB + "sp[38]" + TAB + "sp[39]" + TAB + "sp[40]" + TAB + "sp[41]"
    + TAB + "sp[42]" + TAB + "sp[43]" + TAB + "sp[44]" + TAB + "sp[45]" + TAB + "sp[46]" + TAB + "sp[47]" + TAB + "sp[48]"
    + TAB + "sp[49]" + TAB + "sp[50]" + TAB + "sp[51]" + TAB + "sp[52]" + TAB + "sp[53]" + TAB + "sp[54]" + TAB + "sp[55]"
    + TAB + "sp[56]" + TAB + "sp[57]" + TAB + "sp[58]" + TAB + "sp[59]";

  //String TitleData = "Time:" + date_now;
  output2.println(TitleData2);
  output2.flush();

  output3 = createWriter("user_data/" + date_now + "/pw_spectrum_FFT.tsv");
  TitleData3 = "Ch" + TAB + "Time" + TAB + "sp[0]" + TAB + "sp[1]" + TAB + "sp[2]" + TAB + "sp[3]" + TAB + "sp[4]" + TAB + "sp[5]" + TAB + "sp[6]"
    + TAB + "sp[7]" + TAB + "sp[8]" + TAB + "sp[9]" + TAB + "sp[10]" + TAB + "sp[11]" + TAB + "sp[12]" + TAB + "sp[13]"
    + TAB + "sp[14]" + TAB + "sp[15]" + TAB + "sp[16]" + TAB + "sp[17]" + TAB + "sp[18]" + TAB + "sp[19]" + TAB + "sp[20]"
    + TAB + "sp[21]" + TAB + "sp[22]" + TAB + "sp[23]" + TAB + "sp[24]" + TAB + "sp[25]" + TAB + "sp[26]" + TAB + "sp[27]"
    + TAB + "sp[28]" + TAB + "sp[29]" + TAB + "sp[30]" + TAB + "sp[31]" + TAB + "sp[32]" + TAB + "sp[33]" + TAB + "sp[34]"
    + TAB + "sp[35]" + TAB + "sp[36]" + TAB + "sp[37]" + TAB + "sp[38]" + TAB + "sp[39]" + TAB + "sp[40]" + TAB + "sp[41]"
    + TAB + "sp[42]" + TAB + "sp[43]" + TAB + "sp[44]" + TAB + "sp[45]" + TAB + "sp[46]" + TAB + "sp[47]" + TAB + "sp[48]"
    + TAB + "sp[49]" + TAB + "sp[50]" + TAB + "sp[51]" + TAB + "sp[52]" + TAB + "sp[53]" + TAB + "sp[54]" + TAB + "sp[55]"
    + TAB + "sp[56]" + TAB + "sp[57]" + TAB + "sp[58]" + TAB + "sp[59]" + TAB + "sp[60]" + TAB + "sp[61]" + TAB + "sp[62]"
    + TAB + "sp[63]" + TAB + "sp[64]" + TAB + "sp[65]" + TAB + "sp[66]" + TAB + "sp[67]" + TAB + "sp[68]" + TAB + "sp[69]"
    + TAB + "sp[70]" + TAB + "sp[71]" + TAB + "sp[72]" + TAB + "sp[73]" + TAB + "sp[74]" + TAB + "sp[75]" + TAB + "sp[76]"
    + TAB + "sp[77]" + TAB + "sp[78]" + TAB + "sp[79]" + TAB + "sp[80]" + TAB + "sp[81]" + TAB + "sp[82]" + TAB + "sp[83]"
    + TAB + "sp[84]" + TAB + "sp[85]" + TAB + "sp[86]" + TAB + "sp[87]" + TAB + "sp[88]" + TAB + "sp[89]" + TAB + "sp[90]"
    + TAB + "sp[91]" + TAB + "sp[92]" + TAB + "sp[93]" + TAB + "sp[94]" + TAB + "sp[95]" + TAB + "sp[96]" + TAB + "sp[97]"
    + TAB + "sp[98]" + TAB + "sp[99]"
    + TAB + "sp[100]" + TAB + "sp[101]" + TAB + "sp[102]" + TAB + "sp[103]" + TAB + "sp[104]" + TAB + "sp[105]" + TAB + "sp[106]"
    + TAB + "sp[107]" + TAB + "sp[108]" + TAB + "sp[109]" + TAB + "sp[110]" + TAB + "sp[111]" + TAB + "sp[112]" + TAB + "sp[113]"
    + TAB + "sp[114]" + TAB + "sp[115]" + TAB + "sp[116]" + TAB + "sp[117]" + TAB + "sp[118]" + TAB + "sp[119]" + TAB + "sp[120]"
    + TAB + "sp[121]" + TAB + "sp[122]" + TAB + "sp[123]" + TAB + "sp[124]" + TAB + "sp[125]" + TAB + "sp[126]" + TAB + "sp[127]"
    ;

  output3.println(TitleData3);
  output3.flush();

  //data_path = dataPath("");

  //binary_save_name = data_path + "/../user_data/" + date_now + "/" + time_now + "eeg_binary.dat";
  //binary_save_name = data_path;
}

void labels_1() {
  textSize(12);
  textAlign(LEFT, CENTER);
  text(subscript_1, 200, 10);
  textAlign(LEFT, CENTER);
  text(subscript_2, 200, 25);

  fill(0);
  textLeading(15);
  textSize(25);
  textAlign(LEFT, CENTER);
  text("EEG Analyzer", 550, 12);

  textSize(12);
  textAlign(LEFT, CENTER);
  text(date_now, 10, 10);

  textSize(12);
  textAlign(LEFT, CENTER);
  text("Port: " + selector.getPort(), 10, 25);

  textSize(20);
  textAlign(CENTER, CENTER);
  text("BIS", 35, 55);
  fill(0);
  textSize(48);
  if (bispectral_index[0]>1000) {
    text("N", 55, 90);
  } else {
    text(int(bispectral_index[0]/10), 55, 90);
  }

  textSize(10);
  textAlign(RIGHT, CENTER);
  text(floor(maxRange30), 55, 290);
  text(0, 55, 400);

  textSize(10);
  textAlign(RIGHT, CENTER);
  text(floor(maxRange40), 55, 475);
  text(0, 55, 565);

  textAlign(LEFT, CENTER);
  fill(0);
  textSize(12);
  text("SR", 80, 135);
  fill(0);
  textSize(24);
  if (burst_suppress_ratio[0] > 10000) {
    text("N", 80, 160);
  } else {
    text(int(burst_suppress_ratio[0]), 80, 155);
  }

  fill(0);
  textSize(12);
  text("Total Power", 120, 135);
  textSize(24);
  text(int(total_power[0]/100), 120, 155);

  fill(0);
  textSize(12);
  text("EMG Low", 200, 135);
  textSize(24);
  text(int(emg_low[0]/100), 200, 155);

  fill(0);
  textSize(12);
  text("SQ", 270, 135);
  textSize(24);
  text(int(bis_signal_quality[0]/100), 270, 155);

  fill(0);
  textSize(10);
  text("TP BIS", 20, 650);
  textSize(14);
  text((int)total_power_eeg, 20, 665);

  fill(0);
  textSize(10);
  text("TP FFT", 20, 690);
  textSize(14);
  text((int)total_power_x0_filtered, 20, 705);

  fill(#ff0000);
  textSize(12);
  //text("Blackman-W", 460, 278);
  switch (window) {
  case 0:
    text("Hanning", 460, 278);
    break;
  case 1:
    text("Hamming", 460, 278);
    break;
  case 2:
    text("Blackman", 460, 278);
    break;
  }
  fill(#ff0000);
  textSize(12);
  //text("Blackman-W", 460, 460);
  switch (window) {
  case 0:
    text("Hanning", 460, 460);
    break;
  case 1:
    text("Hamming", 460, 460);
    break;
  case 2:
    text("Blackman", 460, 460);
    break;
  }


  fill(#FF0000);
  textSize(15);
  text("Start: " + start_time, 750, 15);

  hour = hour();
  min = minute();
  sec = second();
  time_now = hour + ":" + nf(min, 2) + ":" + nf(sec, 2);

  fill(#006400);
  textSize(15);
  text("Now: " + time_now, 915, 15);


  //end total power

  textAlign(CENTER, CENTER);
  fill(0);
  textSize(24);

  textAlign(CENTER, CENTER);
  fill(0);
  textSize(18);
  if (bispectral_index[0]>1000) {
    text("N", 925, 300);
  } else {
    text(int(bispectral_index[0]/10), 550, 300);
  }

  fill(#000000);
  textSize(14);
  text(nf(spectral_edge_95[0]/100, 2, 1), 550, 360);
  //}

  textAlign(CENTER, CENTER);
  fill(0);
  textSize(18);
  if (bispectral_index[0]>1000) {
    text("N", 550, 450);
  } else {
    text(int(bispectral_index[0]/10), 550, 450);
  }

  textSize(13);
  fill(0);
  textAlign(LEFT, CENTER);
  text("Colored 2D-Map of Power Spectrum from Raw EEG", 140, 785);
}

void labels_2() {
  fill(0);
  textLeading(15);
  textSize(18);
  textAlign(LEFT, CENTER);
  switch(D_Mode) {
  case "EMD" :
    text("Empirical Mode Decomposition:", 155, 12);
    break;
  case "VMD" :
    text("Variational Mode Decomposition:", 155, 12);
    break;
  case "EWT" :
    text("Empirical Wavelet Transform:", 155, 12);
    break;
  case "WMD" :
    text("Wavelet Mode Decomposition:", 155, 12);
    break;
  default:
    text("Empirical Mode Decomposition:", 155, 12);
    break;
  }

  textAlign(LEFT, CENTER);
  fill(0);
  textSize(15);
  text("HHT", 25, 425);

  fill(0);
  textSize(15);
  text("FFT", 25, 569);

  fill(0);
  textSize(15);

  switch(D_Mode) {
  case "EMD" :
    text("EMD", 25, 780);
    break;
  case "VMD" :
    text("VMD", 25, 780);
    break;
  case "EWT" :
    text("EWT", 25, 780);
    break;
  case "WMD" :
    text("WMD", 25, 780);
    break;
  default:
    text("EMD", 25, 780);
    break;
  }
  text("IMFs", 25, 800);

  fill(0);
  textSize(10);
  text("1024", 1150, 360 + 15);
  stroke(0);
  line(1149, 360, 1149, 360+4);

  fill(#1e90ff);
  textSize(12);
  text("IMF-1~6", 43, 405);

  switch(K) {
  case 1 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    break;

  case 2 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    fill(#ffff00);
    text("IMF-2", 168, 427);
    break;

  case 3 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    fill(#ffff00);
    text("IMF-2", 168, 427);
    fill(#ff0000);
    text("IMF-3", 216, 427);
    break;

  case 4 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    fill(#ffff00);
    text("IMF-2", 168, 427);
    fill(#ff0000);
    text("IMF-3", 216, 427);
    fill(#00ffff);
    text("IMF-4", 264, 427);
    break;

  case 5 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    fill(#ffff00);
    text("IMF-2", 168, 427);
    fill(#ff0000);
    text("IMF-3", 216, 427);
    fill(#00ffff);
    text("IMF-4", 264, 427);
    fill(#ff00ff);
    text("IMF-5", 312, 427);
    break;

  case 6 :
    textSize(12);
    fill(#00ff00);
    text("IMF-1", 120, 427);
    fill(#ffff00);
    text("IMF-2", 168, 427);
    fill(#ff0000);
    text("IMF-3", 216, 427);
    fill(#00ffff);
    text("IMF-4", 264, 427);
    fill(#ff00ff);
    text("IMF-5", 312, 427);
    fill(#ffffff);
    text("IMF-6", 360, 427);
    break;
  }

  fill(#1e90ff);
  textSize(12);
  text("IMF-" + Gf_R1, 443, 405);

  textLeading(15);
  textAlign(LEFT, CENTER);

  fill(#00ff00);
  textSize(12);
  text("Raw", 110, 575);

  fill(#ffff00);
  textSize(12);
  text("Hanning", 180, 575);

  fill(#ff0000);
  textSize(12);
  text("Blackman", 270, 575);

  fill(#00ff00);
  textSize(12);
  text("Raw", 500, 575);

  fill(#ffff00);
  textSize(12);
  text("Hanning", 570, 575);

  fill(#ff0000);
  textSize(12);
  text("Blackman", 660, 575);
  color col1;
  color col2;

  switch(Gf_R1) {
  case 1 :
    col1= #00ff00;
    break;
  case 2 :
    col1= #ffff00;
    break;
  case 3 :
    col1= #ff0000;
    break;
  case 4 :
    col1= #00ffff;
    break;
  case 5 :
    col1= #ff00ff;
    break;
  case 6 :
    col1= #949593;
    break;
  case 7 :
    col1= #ff8c00;
    break;
  case 8 :
    col1= #b22222;
    break;
  case 9 :
    col1= #ff1493;
    break;
  default:
    col1= #00ff00;
    break;
  }

  switch(Gf_R2) {
  case 1 :
    col2= #00ff00;
    break;
  case 2 :
    col2= #ffff00;
    break;
  case 3 :
    col2= #ff0000;
    break;
  case 4 :
    col2= #00ffff;
    break;
  case 5 :
    col2= #ff00ff;
    break;
  case 6 :
    col2= #949593;
    break;
  case 7 :
    col2= #ff8c00;
    break;
  case 8 :
    col2= #b22222;
    break;
  case 9 :
    col2= #ff1493;
    break;
  default:
    col2= #00ff00;
    break;
  }

  if (dual == 1) {
    textSize(14);
    fill(col1);
    text("IMF-" + Gf_R1, 675, 433);
    textSize(14);
    fill(col2);
    text("IMF-" + Gf_R2, 735, 433);
  } else {
    textSize(14);
    fill(col1);
    text("IMF-" + Gf_R1, 735, 433);
  }

  if (dual == 1) {
    textSize(14);
    fill(col1);
    text("IMF-" + Gf_R1, 1440, 398);
    textSize(14);
    fill(col2);
    text("IMF-" + Gf_R2, 1500, 398);
  } else {
    textSize(14);
    fill(col1);
    text("IMF-" + Gf_R1, 1500, 398);
  }

  // Head indicator
  fill(0);
  textSize(20);
  text(D_Mode, 1460, 255);

  if (dual == 1) {
    textSize(20);
    fill(col1);
    text("IMF-" + Gf_R1, 1460, 280);
    textSize(20);
    fill(col2);
    text("IMF-" + Gf_R2, 1460, 300);
  } else {
    textSize(20);
    fill(col1);
    text("IMF-" + Gf_R1, 1460, 280);
  }
  //--------

  fill(#ff0000);
  textSize(12);
  text("Blackman Window", 820, 398);

  fill(0);
  textLeading(15);
  textSize(14);
  textAlign(LEFT, CENTER);
  text("Hilbert Spectrogram:", 1270, 398);

  if (dual == 1) {
    textSize(20);
    text( "Dual IMF Mode in HSG", 917, 35);
  } else {
    text( "Single IMF Mode in HSG", 917, 35);
  }

  textSize(15);
  text( "Central Freq-" + Gf_R1 + " : "  + nfc((float) select_fq_mean, 1) + " ± " + nfc((float) select_fq_stdev, 1), 1340, 15);

  textSize(15);
  text("Total Power-"+ Gf_R1 + " : "  + ((int) tp_sum/1000) + " x 10^3", 1340, 35);
  //text("Total Power-"+ Gf_R1 + " : "  + ((int) 10*log(tp_sum)) + " dB", 1320, 35);


  //textSize(15);
  //text( "± " + nfc((float) select_fq_stdev, 1), 1070, 35);

  //textSize(15);
  //text("Target Freq: " + target_freq + " Hz: IMF-"+ select_imf, 1147, 15);

  fill(0);
  stroke(40);
  strokeWeight(1);

  textAlign(RIGHT, CENTER);
  textSize(12);
  text("min", 810, 390);
  text("0", 811, 410);
  text("5", 811, 450);
  text("10", 811, 490);
  text("15", 811, 530);
  text("20", 811, 570);
  text("25", 811, 610);
  text("30", 811, 650);

  stroke(0);
  line(818, 410, 818, 666);

  line(816, 410, 818, 410);
  line(816, 450, 818, 450);
  line(816, 490, 818, 490);
  line(816, 530, 818, 530);
  line(816, 570, 818, 570);
  line(816, 610, 818, 610);
  line(816, 650, 818, 650);

  stroke(#6e6e6e, 150);
  line(818, 450, 1140, 450);
  line(818, 490, 1140, 490);
  line(818, 530, 1140, 530);
  line(818, 570, 1140, 570);
  line(818, 610, 1140, 610);
  line(818, 650, 1140, 650);

  //-------HHT Spectrogram
  textAlign(RIGHT, CENTER);
  textSize(12);
  text("min", 1210, 390);
  text("0", 1211, 410);
  text("5", 1211, 450);
  text("10", 1211, 490);
  text("15", 1211, 530);
  text("20", 1211, 570);
  text("25", 1211, 610);
  text("30", 1211, 650);

  stroke(0);
  line(1218, 410, 1218, 666);

  line(1216, 410, 1218, 410);
  line(1216, 450, 1218, 450);
  line(1216, 490, 1218, 490);
  line(1216, 530, 1218, 530);
  line(1216, 570, 1218, 570);
  line(1216, 610, 1218, 610);
  line(1216, 650, 1218, 650);

  stroke(#6e6e6e, 150);
  line(1218, 450, 1540, 450);
  line(1218, 490, 1540, 490);
  line(1218, 530, 1540, 530);
  line(1218, 570, 1540, 570);
  line(1218, 610, 1540, 610);
  line(1218, 650, 1540, 650);
  //----------------------------
  textSize(15);
  textAlign(LEFT, CENTER);
  text("Power Spectrogram [Hz]", 900, 700);

  textSize(15);
  textAlign(LEFT, CENTER);
  text("Hilbert Spectrogram [Hz]", 1300, 700);


  switch(K) {
  case 1 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("Σ IMF", 1304, 720);
    break;
  case 2 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("Σ IMF", 1304, 720);
    break;
  case 3 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("IMF-3", 504, 720);
    text("Σ IMF", 1304, 720);
    break;
  case 4 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("IMF-3", 504, 720);
    text("IMF-4", 704, 720);
    text("Σ IMF", 1304, 720);
    break;
  case 5 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("IMF-3", 504, 720);
    text("IMF-4", 704, 720);
    text("IMF-5", 904, 720);
    text("Σ IMF", 1304, 720);
    break;
  case 6 :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("IMF-3", 504, 720);
    text("IMF-4", 704, 720);
    text("IMF-5", 904, 720);
    text("IMF-6", 1104, 720);
    text("Σ IMF", 1304, 720);
    break;
  default :
    textSize(12);
    text("IMF-1", 104, 720);
    text("IMF-2", 304, 720);
    text("IMF-3", 504, 720);
    text("IMF-4", 704, 720);
    text("IMF-5", 904, 720);
    text("IMF-6", 1104, 720);
    text("Σ IMF", 1304, 720);
    break;
  }

  if (D_Mode == "WMD") {
    text("δ [0.5-4Hz]", 154, 720);
    text("θ [4-8Hz]", 354, 720);
    text("α [8-14Hz]", 554, 720);
    text("lo-β [14-20Hz]", 754, 720);
    text("hi-β [20-30Hz]", 954, 720);
    text("γ [30-64Hz]", 1154, 720);
    text("  [0.5-64Hz]", 1354, 720);
  }

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 90, 720);
  text("0", 95, 732);
  text("10", 95, 772);
  text("20", 95, 812);
  text("30", 95, 852);

  stroke(0);
  line(99, 730, 99, 854);
  line(97, 730, 99, 730);
  line(97, 770, 99, 770);
  line(97, 810, 99, 810);
  line(97, 850, 99, 850);

  stroke(#6e6e6e, 150);
  line(100, 770, 260, 770);
  line(100, 810, 260, 810);
  line(100, 850, 260, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 290, 720);
  text("0", 295, 732);
  text("10", 295, 772);
  text("20", 295, 812);
  text("30", 295, 852);

  stroke(0);
  line(299, 730, 299, 854);
  line(297, 730, 299, 730);
  line(297, 770, 299, 770);
  line(297, 810, 299, 810);
  line(297, 850, 299, 850);

  stroke(#6e6e6e, 150);
  line(300, 770, 460, 770);
  line(300, 810, 460, 810);
  line(300, 850, 460, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 490, 720);
  text("0", 495, 732);
  text("10", 495, 772);
  text("20", 495, 812);
  text("30", 495, 852);

  stroke(0);
  line(499, 730, 499, 854);
  line(497, 730, 499, 730);
  line(497, 770, 499, 770);
  line(497, 810, 499, 810);
  line(497, 850, 499, 850);

  stroke(#6e6e6e, 150);
  line(500, 770, 660, 770);
  line(500, 810, 660, 810);
  line(500, 850, 660, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 690, 720);
  text("0", 695, 732);
  text("10", 695, 772);
  text("20", 695, 812);
  text("30", 695, 852);

  stroke(0);
  line(699, 730, 699, 854);
  line(697, 730, 699, 730);
  line(697, 770, 699, 770);
  line(697, 810, 699, 810);
  line(697, 850, 699, 850);

  stroke(#6e6e6e, 150);
  line(700, 770, 860, 770);
  line(700, 810, 860, 810);
  line(700, 850, 860, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 890, 720);
  text("0", 895, 732);
  text("10", 895, 772);
  text("20", 895, 812);
  text("30", 895, 852);

  stroke(0);
  line(899, 730, 899, 854);
  line(897, 730, 899, 730);
  line(897, 770, 899, 770);
  line(897, 810, 899, 810);
  line(897, 850, 899, 850);

  stroke(#6e6e6e, 150);
  line(900, 770, 1060, 770);
  line(900, 810, 1060, 810);
  line(900, 850, 1060, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 1090, 720);
  text("0", 1095, 732);
  text("10", 1095, 772);
  text("20", 1095, 812);
  text("30", 1095, 852);

  stroke(0);
  line(1099, 730, 1099, 854);
  line(1097, 730, 1099, 730);
  line(1097, 770, 1099, 770);
  line(1097, 810, 1099, 810);
  line(1097, 850, 1099, 850);

  stroke(#6e6e6e, 150);
  line(1100, 770, 1260, 770);
  line(1100, 810, 1260, 810);
  line(1100, 850, 1260, 850);

  textAlign(RIGHT, CENTER);
  textSize(10);
  text("min", 1290, 720);
  text("0", 1295, 732);
  text("10", 1295, 772);
  text("20", 1295, 812);
  text("30", 1295, 852);

  stroke(0);
  line(1299, 730, 1299, 854);
  line(1297, 730, 1299, 730);
  line(1297, 770, 1299, 770);
  line(1297, 810, 1299, 810);
  line(1297, 850, 1299, 850);

  stroke(#6e6e6e, 150);
  line(1300, 770, 1460, 770);
  line(1300, 810, 1460, 810);
  line(1300, 850, 1460, 850);

  textSize(26);
  textAlign(LEFT, CENTER);
  text("N_of_IMFs=:" + K, 1380, 80);

  textSize(12);
  textAlign(LEFT, CENTER);
  text("Hilbert Spectrogram [Hz]", 720, 890);

  textSize(15);
  textAlign(LEFT, CENTER);
  text(subscript_1, 155, 35);
  text(subscript_2, 440, 35);
  text("Data: " + file, 460, 15);

  fill(#006eb0);
  textSize(30);
  textAlign(LEFT, CENTER);
  text("BIS:", 1170, 85);
  textSize(40);
  textAlign(RIGHT, CENTER);
  if (bispectral_index[0]>1000) {
    text("N", 1320, 85);
  } else {
    text(int(bispectral_index[0]/10), 1320, 85);
  }

  fill(#008000);
  textAlign(LEFT, CENTER);
  textSize(24);
  text("SR:", 1170, 140);
  textSize(24);
  textAlign(RIGHT, CENTER);
  if (burst_suppress_ratio[0] > 10000) {
    text("N", 1320, 140);
  } else {
    text(int(burst_suppress_ratio[0]), 1320, 140);
  }

  fill(#FF7F50);
  textSize(24);
  textAlign(LEFT, CENTER);
  text("TP:", 1170, 180);
  textSize(24);
  textAlign(RIGHT, CENTER);
  text(int(total_power[0]/100), 1320, 180);

  fill(#B22222);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("EMG Low:", 1170, 220);
  textSize(24);
  textAlign(RIGHT, CENTER);
  text(int(emg_low[0]/100), 1320, 220);

  fill(#6A5ACD);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("SQ:", 1170, 260);
  textSize(24);
  textAlign(RIGHT, CENTER);
  text(int(bis_signal_quality[0]/100), 1320, 260);

  fill(#C71585);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("TP-BIS:", 1170, 300);
  textSize(24);
  textAlign(RIGHT, CENTER);
  text((int)total_power_eeg, 1320, 300);

  fill(#BA55D3);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("SEF95:", 1170, 340);
  textSize(24);
  textAlign(RIGHT, CENTER);
  text(nfc(spectral_edge_95[0]/100,1), 1320, 340);

  //fill(#BA55D3);
  //textSize(20);
  //textAlign(LEFT, CENTER);
  //text("TP-FFT:", 1170, 340);
  //textSize(24);
  //textAlign(RIGHT, CENTER);
  //if ((int)total_power_x0_filtered < 0) {
  //  text("N", 1320, 340);
  //} else {
  //  text((int)total_power_x0_filtered, 1320, 340);
  //}
}


void loadImages() {
  img0 = loadImage("./image/Brain_Sig_IMF0.png");
  img1 = loadImage("./image/Brain_Sig_IMF1.png");
  img2 = loadImage("./image/Brain_Sig_IMF2.png");
  img3 = loadImage("./image/Brain_Sig_IMF3.png");
  img4 = loadImage("./image/Brain_Sig_IMF4.png");
  img5 = loadImage("./image/Brain_Sig_IMF5.png");
  img6 = loadImage("./image/Brain_Sig_IMF6.png");
  imgL0 = loadImage("./image/Brain_Sig_L_IMF0.png");
  imgL1 = loadImage("./image/Brain_Sig_L_IMF1.png");
  imgL2 = loadImage("./image/Brain_Sig_L_IMF2.png");
  imgL3 = loadImage("./image/Brain_Sig_L_IMF3.png");
  imgL4 = loadImage("./image/Brain_Sig_L_IMF4.png");
  imgL5 = loadImage("./image/Brain_Sig_L_IMF5.png");
  imgL6 = loadImage("./image/Brain_Sig_L_IMF6.png");
  img = loadImage("./image/Brain_Sig_IMF.png");
  img_anesth_kpum = loadImage("./image/Anesth-KPUM-logo.png");
}

float array_sum_float(float[] _array) {
  float _array_sum = 0;

  for (int i=0; i<_array.length; i++) {
    _array_sum += _array[i];
  }
  return _array_sum;
}

float array_sq_sum_float(float[] _array) {
  float _array_sum = 0;

  for (int i=0; i<_array.length; i++) {
    _array_sum += _array[i] * _array[i];
  }
  return _array_sum;
}

float array_sq_sum_float2(float[] _array) {
  float _array_sum = 0;

  for (int i=0; i<_array.length; i++) {
    _array_sum += _array[i] * _array[i];
  }
  return _array_sum;
}

double array_avg_double(double[] _array) {
  double _array_avg = 0;

  for (int i=0; i<_array.length; i++) {
    _array_avg += _array[i];
  }
  _array_avg =  _array_avg / (double) _array.length;

  return _array_avg;
}

float array_avg_float(float[] _array) {
  float _array_avg = 0;

  for (int i=0; i<_array.length; i++) {
    _array_avg += _array[i];
  }
  _array_avg =  _array_avg / (float)_array.length;

  return _array_avg;
}


float array_avg_float_cnt(float[] _array, float _cnt) {
  float _array_avg = 0;

  for (int i=0; i<_cnt; i++) {
    _array_avg += _array[i];
  }
  _array_avg =  _array_avg / (float) _cnt;

  return _array_avg;
}


float array_rms_double(double[] _array) {
  float _array_rms = 0;

  for (int i=0; i<_array.length; i++) {
    _array_rms += (float)_array[i] * (float)_array[i];
  }
  _array_rms =  sqrt(_array_rms / (float) _array.length);

  return _array_rms;
}

float array_rms_float(float[] _array) {
  float _array_rms = 0;

  for (int i=0; i<_array.length; i++) {
    _array_rms += _array[i] * _array[i];
  }
  _array_rms =  sqrt(_array_rms / (float) _array.length);

  return _array_rms;
}

void array_shift_2d_double(double[][] _array1, double[] _array2) {
  for (int j = 1; j<_array1.length; j++) {
    for (int i = 0; i<_array1[j].length; i++) {
      _array1[_array1.length-j][i] = _array1[_array1.length-j-1][i];
      _array1[0][i] = _array2[i];
    }
  }
}

void array_shift_2d_double2(double[][] _array1, float[] _array2) {
  for (int j = 1; j<_array1.length; j++) {
    for (int i = 0; i<_array1[j].length; i++) {
      _array1[_array1.length-j][i] = _array1[_array1.length-j-1][i];
      _array1[0][i] = (double) _array2[i];
    }
  }
}

void array_shift_double(double[] _array, double _value) {
  for (int j = 1; j<_array.length; j++) {
    _array[_array.length-j] = _array[_array.length-j-1];
  }
  _array[0] = _value;
}

void array_shift_float(float[] _array, float _value) {
  for (int j = 1; j<_array.length; j++) {
    _array[_array.length-j] = _array[_array.length-j-1];
  }
  _array[0] = _value;
}

void array_shift_2d_float(float[][] _array1, float[] _array2) {
  for (int j = 1; j<_array1.length; j++) {
    for (int i = 0; i<_array1[j].length; i++) {
      _array1[_array1.length-j][i] = _array1[_array1.length-j-1][i];
      _array1[0][i] = _array2[i];
    }
  }
}

void array_shift_2d(float[][] _array1, float[] _array2) {
  for (int j = 1; j<_array1.length; j++) {
    for (int i = 0; i<_array1[j].length; i++) {
      _array1[_array1.length-j][i] = _array1[_array1.length-j-1][i];
      _array1[0][i] = _array2[i];
    }
  }
}


void array_shift_float2(float[] _array) {
  for (int j = 1; j<_array.length; j++) {
    _array[_array.length-j] = _array[_array.length-j-1];
  }
  //_array[0] = _value;
}

void array_shift_float3(float[] _array, float _value) {
  for (int j = 1; j<_array.length; j++) {
    _array[_array.length-j] = _array[_array.length-1-j];
  }
  _array[0] = _value;
}

float[][] array_add(float[][] _array1, float[][] _array2) {
  float _array3[][];
  _array3 = new float[_array1.length][_array1[1].length];

  for (int j = 1; j<_array1.length; j++) {
    for (int i = 0; i<_array1[j].length; i++) {
      _array3[j][i] = _array1[j][i] + _array2[j][i];
    }
  }
  return (_array3);
}

void array_init_float(float[] _array) {
  for (int i=0; i<_array.length; i++) {
    _array[i] = 0;
  }
}

void array_init_double(double[] _array) {
  for (int i=0; i<_array.length; i++) {
    _array[i] = 0;
  }
}

void array_init_2d_float(float[][] _array) {
  for (int j=0; j<_array.length; j++) {
    for (int i=0; i<_array[j].length; i++) {
      _array[j][i] = 0;
    }
  }
}

void array_init_2d_double(double[][] _array) {
  for (int j=0; j<_array.length; j++) {
    for (int i=0; i<_array[j].length; i++) {
      _array[j][i] = 0;
    }
  }
}

float arrAvg_low(float[] _array, float limitter) {
  float array_sum = 0;
  int counter = 0;
  for (int i=0; i<_array.length; i++)
  {
    if (_array[i]<= limitter) {
      array_sum += _array[i];
      counter += 1;
    }
  }
  return (array_sum /counter);
}

float arrStd_low(float[] _array, float limitter, float fq_mean_avg) {
  float std_sum = 0;
  int counter = 0;
  for (int i=0; i<_array.length; i++)
  {
    if (_array[i]<= limitter) {
      std_sum += ((_array[i] - fq_mean_avg)  * (_array[i] - fq_mean_avg));
      counter += 1;
    }
  }
  return (sqrt(std_sum) /sqrt(counter));
}

static final float arrSqSum(float... arr) {
  float sum = 0.0;
  for (final float f : arr)  sum += f * f;
  return sum;
}

static final float arrSqSum_low(float limitter, float[] _frequency_float, float... arr) {
  float sum = 0.0;
  for (int i=0; i< arr.length; i++) {
    if (_frequency_float[i] <= limitter) {
      sum += arr[i] * arr[i];
    }
  }
  return sum;
}

static final float arrAvg(float... arr) {
  float average = 0.0;
  for (final float f : arr)  average += f;
  average /= (float)(arr.length);
  return average;
}

static final float arrStdev(float... arr) {
  float average = 0.0;
  float stdev = 0.0;
  for (final float f : arr)  average += f;
  average /= (float)(arr.length);

  for (final float f : arr)  stdev += (f - average)*(f - average);
  stdev = sqrt(stdev/(float)(arr.length));
  return stdev;
}

public static float[] sumArray_float(float[] _array1, float[] _array2) {
  float  sum[];
  sum = new float [_array1.length];
  for (int i = 0; i < _array1.length; i++) {
    sum[i] = (float) _array1[i] + (float) _array2[i];
  }
  return sum;
}

public static double[] sumArray(double[] _array1, double[] _array2) {
  double  sum[];
  sum = new double [_array1.length];
  for (int i = 0; i < _array1.length; i++) {
    sum[i] =  _array1[i] +  _array2[i];
  }
  return sum;
}

float log10 (float x) {
  return (log(x) / log(10));
}

void data_println() {
  println("burst_suppress_ratio[0]:", burst_suppress_ratio[0]);
  println("burst_suppress_ratio[1]:", burst_suppress_ratio[1]);
  println("spectral_edge_95[0]:", spectral_edge_95[0]);
  println("spectral_edge_95[1]:", spectral_edge_95[1]);
  println("bis_bits[0]:", bis_bits[0]);
  println("bis_bits[1]:", bis_bits[1]);
  println("bispectral_index[0]:", bispectral_index[0]);
  println("bispectral_index[1]:", bispectral_index[1]);
  println("bispectral_alternate_index[0]:", bispectral_alternate_index[0]);
  println("bispectral_alternate_index[1]:", bispectral_alternate_index[1]);
  println("bispectral_alternate2_index[0]:", bispectral_alternate2_index[0]);
  println("bispectral_alternate2_index[1]:", bispectral_alternate2_index[1]);
  println("total_power[0]:", total_power[0]);
  println("total_power[1]:", total_power[1]);
  println("emg_low[0]:", emg_low[0]);
  println("emg_low[1]:", emg_low[1]);
  println("bis_signal_quality[0]:", bis_signal_quality[0]);
  println("bis_signal_quality[1]:", bis_signal_quality[1]);
  println("second_artifact[0]:", second_artifact[0]);
  println("second_artifact[1]:", second_artifact[1]);
}

double[] low_pass_filter(double[] x, double fe2, double fs, double delta) {
  double _fe2;
  double _fs;
  double _delta;
  double _x_filtered[];
  _x_filtered = new double[1024];

  _fs = fs;
  _fe2 = fe2/ _fs;
  _delta = delta / _fs;

  N = delta_N();
  b = new double[N+1];

  b = createLPF(_fe2, _delta, N);

  _x_filtered = fir(x, b);

  return _x_filtered;
}

double[] high_pass_filter(double[] x, double fe1, double fs, double delta) {
  double _fe1;
  double _fs;
  double _delta;
  double _x_filtered[];
  _x_filtered = new double[1024];

  _fs = fs;
  _fe1 = fe1 / _fs;
  _delta = delta / _fs;

  N = delta_N();
  b = new double[N+1];

  b = createHPF(_fe1, _delta, N);

  _x_filtered = fir(x, b);

  return _x_filtered;
}

double[] band_pass_filter(double[] x, double fe1, double fe2, double fs, double delta) {
  double _fe1;
  double _fe2;
  double _fs;
  double _delta;
  double _x_filtered[];
  _x_filtered = new double[1024];

  _fs = fs;
  _fe1 = fe1 / _fs;
  _fe2 = fe2 / _fs;
  _delta = delta / _fs;

  N = delta_N();
  b = new double[N+1];

  b = createBPF(_fe1, _fe2, _delta, N);

  _x_filtered = fir(x, b);

  return _x_filtered;
}

double sinc(double _x) {
  if (_x == 0.0)
  {
    return 1.0d;
  } else
  {
    return (double)(sin((float)_x) / (float) _x);
  }
}


int delta_N() {

  switch (window) {
  case 0:
    N = round(3.1 / (float) delta) - 1;  //Hanning
    break;
  case 1:
    N = round(3.3 / (float) delta) - 1;  //Hamming
    break;
  case 2:
    N = round(5.5 / (float) delta) - 1;   //Blackman
    break;
  }
  if ((N + 1) % 2 == 0) {
    N += 1;
  }
  N = int(N);

  //println("N=", N);
  return N;
}

double[] createLPF(double fe2, double delta, int N) {
  double b[];
  double s[];
  double Window[];
  Window = new double[N+1];
  b = new double[N+1];
  s = new double[N+1];

  for (int i=-N/2; i < N/2+1; i++) {
    // b[i] = (2.0 * fe * sinc(2.0 * PI * fe * i));
    //b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i);
    b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) ;
    //b[i+N/2] = sinc(PI * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i) ;
    //println("b["+(i+N/2)+"]=:", b[i+N/2]);
  }

  for (int i=0; i<N+1; i++) {
    switch (window) {
    case 0:
      Window [i] = 0.5-0.5*cos(2.0*PI*i/(N+1)); //Hanning
      break;
    case 1:
      Window [i] = 0.54-0.46*cos(2.0*PI*i/(N+1)); //Hamming
      break;
    case 2:
      Window [i] = 0.42-0.5*cos(2.0*PI*i/(N+1)) + 0.08*cos(4.0*PI*i/(N+1));  //Blackman
      break;
    }
  }

  for (int i=0; i < b.length; i++) {
    s[i] = b[i] *  Window[i];
  }

  return s;
}

double[] createHPF(double fe1, double delta, int N) {
  double b[];
  double s[];
  double  Window[];
  Window = new double[N+1];
  b = new double[N+1];
  s = new double[N+1];

  for (int i=-N/2; i < N/2+1; i++) {
    // b[i] = (2.0 * fe * sinc(2.0 * PI * fe * i));
    //b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i);
    //b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) ;
    b[i+N/2] = sinc(PI * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i) ;
    //println("b["+(i+N/2)+"]=:", b[i+N/2]);
  }

  for (int i=0; i<N+1; i++) {
    switch (window) {
    case 0:
      Window [i] = 0.5-0.5*cos(2.0*PI*i/(N+1)); //Hanning
      break;
    case 1:
      Window [i] = 0.54-0.46*cos(2.0*PI*i/(N+1)); //Hamming
      break;
    case 2:
      Window [i] = 0.42-0.5*cos(2.0*PI*i/(N+1)) + 0.08*cos(4.0*PI*i/(N+1));  //Blackman
      break;
    }
  }

  for (int i=0; i < b.length; i++) {
    s[i] = b[i] *  Window[i];
  }

  return s;
}


double[] createBPF(double fe1, double fe2, double delta, int N) {
  double b[];
  double s[];
  double  Window[];
  Window = new double[N+1];
  b = new double[N+1];
  s = new double[N+1];

  for (int i=-N/2; i < N/2+1; i++) {
    // b[i] = (2.0 * fe * sinc(2.0 * PI * fe * i));
    b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i);
    //b[i+N/2] = 2.0 * fe2 * sinc(2.0 * PI * fe2 * i) ;
    //b[i+N/2] = sinc(PI * i) - 2.0 * fe1 * sinc(2.0 * PI * fe1 * i) ;
    //println("b["+(i+N/2)+"]=:", b[i+N/2]);
  }

  for (int i=0; i<N+1; i++) {
    switch (window) {
    case 0:
      Window [i] = 0.5-0.5*cos(2.0*PI*i/(N+1)); //Hanning
      break;
    case 1:
      Window [i] = 0.54-0.46*cos(2.0*PI*i/(N+1)); //Hamming
      break;
    case 2:
      Window [i] = 0.42-0.5*cos(2.0*PI*i/(N+1)) + 0.08*cos(4.0*PI*i/(N+1));  //Blackman
      break;
    }
  }

  for (int i=0; i < b.length; i++) {
    s[i] = b[i] *  Window[i];
  }

  return s;
}

double[] fir(double[] x, double[] b) {
  double _y[];
  _y= new double[x.length];

  for (int i = 0; i < x.length; i++) {
    _y[i] = 0.0d;
  }

  //N = b.length - 1;

  for (int n=0; n< x.length; n++) {
    for (int m=0; m<N+1; m++) {
      if (n - m >= 0) {
        _y[n] += b[m] * x[n - m];
      }
    }
  }
  return _y;
}

void filter_delay(double[] _x) {
  for (int i= 0; i< _x.length-N/2; i++) {
    _x[i] = _x[i+N/2] ;
  }
}


void filter_color() {
  fill(0);
  textSize(14);
  textAlign(LEFT);
  strokeWeight(1);
  stroke(#00ff00);
  line(1345, 664, 1360, 664);
  text("F0:Raw", 1258, 667);
  stroke(#FF00FF);
  line(1345, 684, 1360, 684);
  text("F1:Lo-PF", 1258, 687);
  stroke(#00FFFF);
  line(1345, 704, 1360, 704);
  text("F2:Hi&Lo-PF", 1258, 707);
  stroke(#FFA500);
  line(1345, 724, 1360, 724);
  text("F3:Hi&Lo-PF", 1258, 727);
  stroke(#FFFF00);
  line(1345, 744, 1360, 744);
  text("F4:Hi&Lo-PF", 1258, 747);
  stroke(#FF0800);
  line(1345, 764, 1360, 764);
  text("F5:Hi&Lo-PF", 1258, 767);
  noFill();
  stroke(#000000);
  rect(1250, 650, 1380, 780);
}

void title_show() {

  image(img, 200, 160);
  image(img_anesth_kpum, 390, 650);
  fill(0);
  textLeading(15);
  textSize(78);
  textAlign(LEFT, CENTER);
  text("EEG Mode Decompositor", 330, 200);

  textSize(48);
  textAlign(LEFT, CENTER);
  text("View Four Mode Decompositions", 450, 300);

  textSize(28);
  textAlign(LEFT, LEFT);
  fill(#0000ff);
  text("1-EMD: Empirical Mode Decomposition", 450, 370);
  text("2-VMD: Variational Mode Decomposition", 450, 410);
  text("3-EWT: Empirical Wavelet Transform", 450, 450);
  text("4-WMD: Wavelet Mode Decomposition: Hz-fixed", 450, 490);
  text("The number of IMFs: 2~6", 450, 530);
  text("IMF selection: IMF-1, IMF-2, IMF-3, IMF-4, IMF-5, IMF-6", 450, 570);

  fill(#FF0000);
  text("Select Data File and Click START!!!", 450, 610);
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text(subscript_1, 500, 680);
  textAlign(LEFT, CENTER);
  text(subscript_2, 500, 710);
}

//void mousePressed() {
//  noLoop();
//}

//void mouseReleased() {
//  loop();
//}

void selected_imf1() {
  switch(Selected_IMF1) {
  case "IMF-1" :
    Gf_R1=1;
    break;
  case "IMF-2" :
    Gf_R1=2;
    break;
  case "IMF-3" :
    Gf_R1=3;
    break;
  case "IMF-4" :
    Gf_R1=4;
    break;
  case "IMF-5" :
    Gf_R1=5;
    break;
  case "IMF-6" :
    Gf_R1=6;
    break;
  default:
    Gf_R1=1;
    break;
  }
}

void selected_imf2() {
  println("Selected_IMF2=:", Selected_IMF2);
  switch(Selected_IMF2) {
  case "IMF-1" :
    Gf_R2=1;
    dual = 1;
    break;
  case "IMF-2" :
    Gf_R2=2;
    dual = 1;
    break;
  case "IMF-3" :
    Gf_R2=3;
    dual = 1;
    break;
  case "IMF-4" :
    Gf_R2=4;
    dual = 1;
    break;
  case "IMF-5" :
    Gf_R2=5;
    dual = 1;
    break;
  case "IMF-6" :
    Gf_R2=6;
    dual = 1;
    break;
  case "None" :
    Gf_R2=0;
    dual = 0;
    break;
  default:
    Gf_R2=0;
    dual = 0;
    break;
  }
}

double[] dpss_1_1024() {
  double [] dpss_1 = {
    2.85682581388237e-06, 3.26405522276186e-06, 3.69975823182441e-06, 4.16516519538732e-06, 4.66154297973393e-06, 5.19019510852603e-06, 5.75246209484158e-06, 6.34972163780993e-06, 6.98338905346462e-06, 7.65491765620321e-06, 8.36579913573175e-06, 9.11756401332153e-06, 9.91178216884253e-06, 1.07500633593596e-05, 1.16340577588893e-05, 1.25654564980817e-05, 1.35459922292354e-05, 1.45774397014116e-05, 1.56616163282474e-05, 1.6800382746882e-05, 1.79956433784731e-05, 1.92493469818167e-05, 2.05634871996491e-05, 2.19401030995736e-05, 2.33812797179879e-05, 2.48891486005918e-05, 2.64658883414616e-05, 2.81137251204416e-05, 2.98349332389032e-05, 3.16318356536897e-05, 3.3506804504299e-05, 3.54622616364431e-05, 3.75006791191633e-05, 3.9624579758761e-05, 4.18365376070483e-05, 4.41391784640595e-05, 4.65351803750604e-05, 4.90272741203022e-05, 5.16182436995187e-05, 5.43109268092478e-05, 5.71082153145276e-05, 6.00130557140554e-05, 6.30284495980236e-05, 6.61574540990176e-05, 6.94031823357457e-05, 7.27688038487284e-05, 7.6257545027328e-05, 7.98726895286461e-05, 8.36175786870993e-05, 8.74956119151422e-05, 9.1510247094897e-05, 9.56650009604259e-05, 9.9963449470687e-05, 0.000104409228172404, 0.000109006032552458, 0.000113757618380212, 0.000118667802038657, 0.000123740460844758, 0.000128979533358249, 0.000134389019678805, 0.000139972981731786, 0.000145735543542042, 0.000151680891495257, 0.0001578132745865, 0.000164137004656108, 0.00017065645661225, 0.000177376068640199, 0.000184300342397992, 0.000191433843198305, 0.000198781200176277, 0.000206347106443181, 0.00021413631922533, 0.000222153659988031, 0.000230404014544475, 0.000238892333149065, 0.000247623630575024, 0.00025660298617592, 0.000265835543931007, 0.000275326512474329, 0.000285081165107249, 0.000295104839793963, 0.00030540293913979, 0.000315980930352191, 0.000326844345184258, 0.0003379987798603, 0.000349449894983524, 0.000361203415425488, 0.000373265130197156, 0.000385640892301265, 0.000398336618565728, 0.000411358289457895, 0.000424711948879529, 0.000438403703942221, 0.000452439724723053, 0.000466826244000296, 0.000481569556968936, 0.000496676020935957, 0.000512152054995104, 0.000528004139681017, 0.000544238816602487, 0.000560862688054573, 0.000577882416609574, 0.000595304724686687, 0.00061313639410005, 0.000631384265585104, 0.000650055238303113, 0.000669156269323644, 0.000688694373084959, 0.000708676620832182, 0.000729110140033068, 0.000750002113771292, 0.000771359780117054, 0.000793190431474988, 0.000815501413909196, 0.000838300126445316, 0.00086159402034954, 0.000885390598384566, 0.000909697414042398, 0.000934522070753892, 0.000959872221074985, 0.00098575556584956, 0.00101217985334881, 0.0010391528783871, 0.00106668248141422, 0.00109477654758408, 0.00112344300579971, 0.00115268982773462, 0.00118252502683056, 0.00121295665727154, 0.00124399281293431, 0.00127564162631509, 0.0013079112674326, 0.00134080994270745, 0.00137434589381785, 0.0014085273965317, 0.00144336275951519, 0.00147886032311774, 0.00151502845813351, 0.00155187556453955, 0.0015894100702106, 0.00162764042961063, 0.0016665751224613, 0.00170622265238727, 0.0017465915455385, 0.00178769034918976, 0.00182952763031727, 0.00187211197415282, 0.00191545198271536, 0.0019595562733202, 0.00200443347706606, 0.00205009223729999, 0.00209654120806041, 0.00214378905249836, 0.00219184444127729, 0.00224071605095139, 0.00229041256232283, 0.00234094265877794, 0.0023923150246027, 0.00244453834327757, 0.00249762129575212, 0.00255157255869951, 0.00260640080275111, 0.00266211469071161, 0.0027187228757547, 0.0027762339995998, 0.00283465669066987, 0.00289399956223079, 0.0029542712105125, 0.00301548021281214, 0.00307763512557967, 0.00314074448248609, 0.00320481679247477, 0.00326986053779602, 0.00333588417202545, 0.00340289611806631, 0.00347090476613623, 0.0035399184717387, 0.00360994555361966, 0.0036809942917096, 0.00375307292505147, 0.00382618964971491, 0.00390035261669704, 0.0039755699298104, 0.00405184964355822, 0.00412919976099769, 0.00420762823159146, 0.00428714294904785, 0.00436775174915033, 0.00444946240757652, 0.00453228263770736, 0.00461622008842674, 0.00470128234191226, 0.00478747691141731, 0.00487481123904525, 0.004963292693516, 0.00505292856792546, 0.00514372607749852, 0.00523569235733587, 0.00532883446015532, 0.00542315935402803, 0.0055186739201103, 0.00561538495037134, 0.00571329914531748, 0.00581242311171364, 0.00591276336030233, 0.00601432630352084, 0.0061171182532172, 0.00622114541836538, 0.00632641390278033, 0.00643292970283348, 0.00654069870516917, 0.00664972668442269, 0.00676001930094042, 0.00687158209850278, 0.0069844205020504, 0.00709853981541425, 0.00721394521905027, 0.00733064176777909, 0.00744863438853151, 0.00756792787810016, 0.00768852690089822, 0.00781043598672553, 0.00793365952854297, 0.00805820178025542, 0.00818406685450427, 0.00831125872046978, 0.0084397812016841, 0.00856963797385555, 0.00870083256270476, 0.00883336834181326, 0.0089672485304853, 0.0091024761916233, 0.0092390542296177, 0.00937698538825189, 0.00951627224862267, 0.00965691722707701, 0.00979892257316572, 0.00994229036761464, 0.010087022520314, 0.0102331207683264, 0.0103805866739148, 0.0105294216225896, 0.0106796268211772, 0.0108312032959097, 0.0109841518905363, 0.0111384732644574, 0.0112941678908819, 0.0114512360550086, 0.0116096778522311, 0.0117694931863689, 0.0119306817679234, 0.0120932431123602, 0.0122571765384191, 0.0124224811664502, 0.0125891559167792, 0.012757199508101, 0.0129266104559026, 0.0130973870709156, 0.0132695274575997, 0.0134430295126567, 0.0136178909235765, 0.013794109167215, 0.013971681508405, 0.0141506049986002, 0.0143308764745534, 0.0145124925570287, 0.0146954496495491, 0.0148797439371795, 0.0150653713853456, 0.0152523277386895, 0.0154406085199624, 0.0156302090289553, 0.0158211243414671, 0.0160133493083119, 0.0162068785543652, 0.01640170647765, 0.0165978272484629, 0.0167952348085403, 0.0169939228702664, 0.0171938849159223, 0.0173951141969773, 0.0175976037334223, 0.0178013463131463, 0.0180063344913559, 0.0182125605900389, 0.0184200166974719, 0.0186286946677717, 0.0188385861204924, 0.0190496824402677, 0.019261974776498, 0.0194754540430846, 0.0196901109182094, 0.0199059358441615, 0.020122919027211, 0.0203410504375299, 0.0205603198091606, 0.0207807166400326, 0.0210022301920267, 0.0212248494910887, 0.0214485633273914, 0.0216733602555447, 0.0218992285948569, 0.0221261564296433, 0.0223541316095861, 0.0225831417501436, 0.0228131742330093, 0.0230442162066213, 0.0232762545867229, 0.0235092760569725, 0.0237432670696056, 0.0239782138461466, 0.0242141023781719, 0.0244509184281248, 0.0246886475301805, 0.0249272749911634, 0.0251667858915147, 0.0254071650863126, 0.0256483972063431, 0.0258904666592225, 0.0261333576305719, 0.0263770540852422, 0.026621539768592, 0.0268667982078158, 0.0271128127133239, 0.0273595663801744, 0.027607042089556, 0.0278552225103217, 0.0281040901005747, 0.0283536271093045, 0.0286038155780745, 0.02885463734276, 0.0291060740353375, 0.029358107085724, 0.0296107177236669, 0.0298638869806841, 0.0301175956920541, 0.0303718244988561, 0.0306265538500589, 0.0308817640046602, 0.0311374350338743, 0.0313935468233685, 0.0316500790755487, 0.0319070113118925, 0.0321643228753307, 0.0324219929326765, 0.0326800004771013, 0.0329383243306585, 0.0331969431468529, 0.0334558354132566, 0.0337149794541713, 0.0339743534333353, 0.0342339353566756, 0.0344937030751049, 0.0347536342873629, 0.0350137065429004, 0.0352738972448077, 0.0355341836527849, 0.0357945428861554, 0.03605495192692, 0.0363153876228531, 0.0365758266906394, 0.0368362457190508, 0.0370966211721626, 0.0373569293926093, 0.0376171466048786, 0.0378772489186433, 0.0381372123321304, 0.0383970127355272, 0.0386566259144232, 0.0389160275532874, 0.0391751932389808, 0.0394340984643024, 0.039692718631569, 0.0399510290562282, 0.0402090049705024, 0.0404666215270652, 0.0407238538027485, 0.0409806768022785, 0.0412370654620421, 0.0414929946538812, 0.041748439188915, 0.0420033738213889, 0.0422577732525502, 0.0425116121345489, 0.042764865074363, 0.043017506637748, 0.0432695113532091, 0.0435208537159964, 0.0437715081921202, 0.0440214492223886, 0.0442706512264632, 0.0445190886069349, 0.0447667357534171, 0.0450135670466568, 0.0452595568626611, 0.04550467957684, 0.0457489095681638, 0.0459922212233331, 0.0462345889409634, 0.0464759871357802, 0.0467163902428256, 0.0469557727216751, 0.0471941090606639, 0.0474313737811208, 0.0476675414416098, 0.0479025866421788, 0.0481364840286126, 0.0483692082966915, 0.048600734196453, 0.0488310365364569, 0.049060090188051, 0.0492878700896388, 0.0495143512509466, 0.0497395087572894, 0.0499633177738352, 0.0501857535498656, 0.0504067914230334, 0.0506264068236146, 0.0508445752787552, 0.0510612724167101, 0.0512764739710756, 0.051490155785012, 0.0517022938154577, 0.0519128641373314, 0.0521218429477233, 0.0523292065700743, 0.0525349314583404, 0.0527389942011438, 0.0529413715259081, 0.0531420403029767, 0.0533409775497147, 0.0535381604345922, 0.0537335662812476, 0.0539271725725323, 0.0541189569545328, 0.0543088972405712, 0.0544969714151836, 0.0546831576380731, 0.054867434248039, 0.0550497797668801, 0.0552301729032708, 0.0554085925566103, 0.055585017820843, 0.0557594279882495, 0.0559318025532069, 0.0561021212159193, 0.0562703638861142, 0.056436510686708, 0.0566005419574364, 0.0567624382584505, 0.0569221803738773, 0.0570797493153445, 0.0572351263254668, 0.0573882928812953, 0.0575392306977278, 0.057687921730879, 0.0578343481814106, 0.0579784924978199, 0.0581203373796868, 0.0582598657808772, 0.0583970609127035, 0.0585319062470403, 0.0586643855193951, 0.0587944827319332, 0.0589221821564557, 0.059047468337331, 0.0591703260943771, 0.059290740525696, 0.0594086970104585, 0.0595241812116392, 0.0596371790786999, 0.0597476768502225, 0.0598556610564897, 0.0599611185220126, 0.0600640363680054, 0.0601644020148063, 0.0602622031842436, 0.0603574279019471, 0.0604500644996035, 0.0605401016171562, 0.0606275282049481, 0.0607123335258066, 0.0607945071570724, 0.0608740389925686, 0.0609509192445115, 0.061025138445363, 0.0610966874496222, 0.0611655574355578, 0.0612317399068799, 0.0612952266943503, 0.0613560099573322, 0.0614140821852783, 0.061469436199156, 0.0615220651528114, 0.0615719625342695, 0.0616191221669719, 0.0616635382109517, 0.0617052051639432, 0.0617441178624296, 0.0617802714826251, 0.0618136615413933, 0.061844283897101, 0.0618721347504064, 0.0618972106449838, 0.061919508468181, 0.0619390254516135, 0.0619557591716915, 0.0619697075500823, 0.0619808688541062, 0.0619892416970674, 0.0619948250385181, 0.0619976181844568, 0.0619976207874614, 0.061994832846755, 0.0619892547082061, 0.061980887064263, 0.0619697309538219, 0.0619557877620286, 0.0619390592200146, 0.0619195474045672, 0.0618972547377339, 0.0618721839863604, 0.0618443382615639, 0.0618137210181398, 0.0617803360539043, 0.0617441875089705, 0.0617052798649605, 0.0616636179441518, 0.0616192069085602, 0.0615720522589568, 0.0615221598338224, 0.0614695358082368, 0.061414186692705, 0.0613561193319204, 0.0612953409034639, 0.0612318589164415, 0.0611656812100588, 0.0610968159521333, 0.0610252716375461, 0.0609510570866306, 0.0608741814435022, 0.0607946541743259, 0.060712485065525, 0.0606276842219295, 0.0605402620648654, 0.0604502293301858, 0.0603575970662429, 0.0602623766318035, 0.0601645796939058, 0.060064218225661, 0.0599613045039973, 0.0598558511073498, 0.059747870913294, 0.0596373770961254, 0.0595243831243858, 0.0594089027583352, 0.0592909500473717, 0.0591705393273993, 0.0590476852181446, 0.0589224026204216, 0.0587947067133482, 0.0586646129515115, 0.0585321370620856, 0.0583972950419011, 0.0582601031544668, 0.0581205779269452, 0.0579787361470826, 0.0578345948600928, 0.0576881713654976, 0.0575394832139233, 0.0573885482038541, 0.0572353843783439, 0.0570800100216861, 0.0569224436560438, 0.0567627040380397, 0.0566008101553074, 0.0564367812230044, 0.0562706366802883, 0.0561023961867561, 0.0559320796188487, 0.05575970706622, 0.0555852988280724, 0.0554088754094598, 0.055230457517558, 0.0550500660579041, 0.0548677221306057, 0.0546834470265206, 0.0544972622234079, 0.0543091893820519, 0.0541192503423589, 0.0539274671194283, 0.053733861899599, 0.0535384570364721, 0.0533412750469097, 0.0531423386070129, 0.0529416705480776, 0.0527392938525309, 0.0525352316498476, 0.0523295072124492, 0.0521221439515843, 0.0519131654131946, 0.0517025952737628, 0.0514904573361488, 0.0512767755254101, 0.0510615738846112, 0.0508448765706204, 0.0506267078498962, 0.0504070920942647, 0.050186053776687, 0.0499636174670199, 0.0497398078277693, 0.0495146496098378, 0.0492881676482674, 0.0490603868579784, 0.0488313322295052, 0.0486010288247302, 0.0483695017726162, 0.0481367762649394, 0.0479028775520222, 0.0476678309384694, 0.047431661778905, 0.0471943954737146, 0.046956057464791, 0.0467166732312861, 0.0464762682853693, 0.0462348681679922, 0.0459924984446633, 0.0457491847012305, 0.0455049525396742, 0.0452598275739119, 0.0450138354256137, 0.0447670017200317, 0.0445193520818422, 0.0442709121310034, 0.0440217074786277, 0.0437717637228711, 0.0435211064448391, 0.0432697612045113, 0.0430177535366846, 0.0427651089469361, 0.0425118529076068, 0.0422580108538067, 0.0420036081794419, 0.041748670233265, 0.0414932223149493, 0.0412372896711877, 0.0409808974918168, 0.0407240709059674, 0.0404668349782424, 0.0402092147049214, 0.0399512350101947, 0.0396929207424264, 0.0394342966704469, 0.039175387479877, 0.0389162177694823, 0.0386568120475607, 0.038397194728362, 0.0381373901285415, 0.037877422463647, 0.0376173158446414, 0.0373570942744601, 0.037096781644605, 0.0368364017317745, 0.0365759781945317, 0.0363155345700094, 0.0360550942706547, 0.0357946805810119, 0.0355343166545452, 0.0352740255105016, 0.035013830030815, 0.0347537529570505, 0.0344938168873913, 0.0342340442736678, 0.0339744574184291, 0.0337150784720578, 0.0334559294299288, 0.033197032129612, 0.0329384082481194, 0.0326800792991977, 0.0324220666306661, 0.0321643914217994, 0.0319070746807583, 0.0316501372420654, 0.0313935997641287, 0.0311374827268119, 0.030881806429053, 0.0306265909865301, 0.030371856329376, 0.0301176221999408, 0.0298639081506041, 0.0296107335416354, 0.0293581175391044, 0.0291060791128408, 0.0288546370344437, 0.028603809875341, 0.0283536160048995, 0.0281040735885844, 0.0278552005861706, 0.0276070147500035, 0.0273595336233116, 0.0271127745385693, 0.0268667546159117, 0.0266214907615993, 0.0263769996665356, 0.0261332978048347, 0.0258904014324406, 0.0256483265857989, 0.0254070890805786, 0.0251667045104466, 0.0249271882458927, 0.0246885554331072, 0.0244508209929092, 0.0242139996197265, 0.0239781057806274, 0.0237431537144032, 0.0235091574307024, 0.0232761307092164, 0.0230440870989153, 0.0228130399173359, 0.0225830022499199, 0.0223539869494027, 0.0221260066352538, 0.0218990736931662, 0.0216732002745973, 0.0214483982963591, 0.0212246794402591, 0.0210020551527899, 0.020780536644869, 0.0205601348916278, 0.0203408606322493, 0.0201227243698547, 0.0199057363714383, 0.0196899066678513, 0.0194752450538324, 0.0192617610880871, 0.0190494640934135, 0.0188383631568757, 0.0186284671300235, 0.0184197846291587, 0.018212324035647, 0.0180060934962759, 0.0178011009236579, 0.0175973539966779, 0.0173948601609859, 0.0171936266295336, 0.0169936603831542, 0.0167949681711858, 0.0165975565121382, 0.016401431694401, 0.0162065997769945, 0.0160130665903616, 0.0158208377372014, 0.0156299185933427, 0.0154403143086582, 0.0152520298080177, 0.0150650697922811, 0.0148794387393295, 0.0146951409051352, 0.0145121803248681, 0.0143305608140409, 0.014150285969689, 0.0139713591715884, 0.0137937835835075, 0.0136175621544946, 0.0134426976202004, 0.0132691925042329, 0.0130970491195474, 0.0129262695698677, 0.0127568557511407, 0.0125888093530216, 0.0124221318603911, 0.0122568245549026, 0.0120928885165587, 0.0119303246253186, 0.011769133562732, 0.0116093158136032, 0.0114508716676812, 0.0112938012213775, 0.0111381043795097, 0.010983780857071, 0.0108308301810245, 0.0106792516921227, 0.0105290445467498, 0.0103802077187874, 0.0102327400015037, 0.0100866400094634, 0.00994190618045967, 0.00979853677746642, 0.00965652989061107, 0.00951588343916631, 0.00937659517356087, 0.00923866267740845, 0.00910208336955412, 0.00896685450613768, 0.00883297318267329, 0.00870043633614473, 0.00856924074711567, 0.00843938304185436, 0.008310859694472, 0.00818366702907433, 0.00805780122192555, 0.00793325830362431, 0.00781003416129077, 0.00768812454076442, 0.00756752504881177, 0.00744823115534348, 0.00733023819564029, 0.00721354137258701, 0.00709813575891412, 0.00698401629944617, 0.00687117781335662, 0.00675961499642828, 0.00664932242331888, 0.00654029454983122, 0.00643252571518708, 0.00632601014430463, 0.00622074195007841, 0.00611671513566162, 0.00601392359674983, 0.00591236112386574, 0.00581202140464443, 0.00571289802611836, 0.00561498447700171, 0.00551827414997347, 0.00542276034395872, 0.00532843626640744, 0.00523529503557046, 0.00514332968277204, 0.00505253315467827, 0.00496289831556115, 0.00487441794955751, 0.0047870847629224, 0.00470089138627648, 0.00461583037684675, 0.00453189422070032, 0.00444907533497055, 0.00436736607007522, 0.0042867587119261, 0.00420724548412963, 0.00412881855017802, 0.00405147001563059, 0.00397519193028464, 0.00389997629033555, 0.00382581504052556, 0.00375270007628095, 0.00368062324583696, 0.00360957635235036, 0.00353955115599891, 0.00347053937606756, 0.0034025326930208, 0.00333552275056099, 0.00326950115767203, 0.00320445949064821, 0.00314038929510779, 0.00307728208799088, 0.00301512935954141, 0.00295392257527272, 0.00289365317791663, 0.00283431258935538, 0.00277589221253632, 0.00271838343336906, 0.00266177762260459, 0.00260606613769621, 0.00255124032464197, 0.00249729151980829, 0.00244421105173453, 0.00239199024291817, 0.00234062041158048, 0.00229009287341227, 0.00224039894329956, 0.00219152993702902, 0.00214347717297271, 0.00209623197375219, 0.00204978566788154, 0.00200412959138925, 0.00195925508941866, 0.00191515351780698, 0.0018718162446424, 0.00182923465179942, 0.0017874001364521, 0.00174630411256507, 0.0017059380123622, 0.00166629328777276, 0.00162736141185492, 0.00158913388019649, 0.00155160221229284, 0.00151475795290175, 0.00147859267337522, 0.00144309797296805, 0.00140826548012326, 0.00137408685373417, 0.00134055378438305, 0.00130765799555639, 0.0012753912448366, 0.00124374532507017, 0.00121271206551222, 0.00118228333294751, 0.00115245103278759, 0.00112320711014442, 0.00109454355088017, 0.00106645238263345, 0.00103892567582162, 0.00101195554461968, 0.000985534147915262, 0.000959653690240237, 0.000934306422678628, 0.000909484643750979, 0.000885180700275149, 0.000861386988203675, 0.000838095953437712, 0.000815300092617573, 0.000792991953890023, 0.000771164137652375, 0.000749809297273517, 0.00072892013979187, 0.000708489426590365, 0.000688509974048523, 0.000668974654171827, 0.000649876395198536, 0.000631208182184024, 0.000612963057562685, 0.000595134121687605, 0.000577714533348168, 0.000560697510265746, 0.000544076329567458, 0.000527844328238289, 0.000511994903551702, 0.00049652151347888, 0.000481417677076808, 0.000466676974855229, 0.000452293049122653, 0.000438259604311742, 0.000424570407284207, 0.000411219287615429, 0.000398200137858928, 0.000385506913790825, 0.000373133634634638, 0.000361074383266486, 0.000349323306400871, 0.000337874614757416, 0.000326722583208639, 0.000315861550908953, 0.000305285921405034, 0.000294990162727868, 0.000284968807466687, 0.000275216452825017, 0.000265727760659155, 0.00025649745749935, 0.000247520334553839, 0.000238791247696038, 0.000230305117435069, 0.000222056928869952, 0.000214041731627651, 0.000206254639785292, 0.000198690831776594, 0.000191345550282682, 0.000184214102107696, 0.000177291858039327, 0.000170574252694608, 0.000164056784351246, 0.000157735014764839, 0.000151604568972354, 0.00014566113508194, 0.000139900464049427, 0.00013431836944186, 0.000128910727188398, 0.00012367347531843, 0.000118602613687581, 0.000113694203691482, 0.000108944367967831, 0.000104349290087302, 9.9905214233066e-05, 9.56084448694009e-05, 9.14553463994202e-05, 8.74423428123197e-05, 8.35659173206351e-05, 7.98226119870381e-05, 7.6209027341248e-05, 7.27218219880603e-05, 6.93577122068901e-05, 6.61134715419539e-05, 6.2985930383778e-05, 5.99719755421071e-05, 5.70685498114046e-05, 5.42726515279726e-05, 5.15813341201305e-05, 4.89917056509438e-05, 4.65009283543263e-05, 4.41062181635742e-05, 4.1804844232239e-05, 3.95941284500109e-05, 3.74714449521432e-05, 3.54342196235121e-05, 3.3479929596487e-05, 3.16061027433785e-05, 2.98103171655146e-05, 2.80902006786644e-05, 2.64434302941843e-05, 2.48677316942578e-05, 2.3360878700651e-05, 2.19206927359669e-05, 2.05450422811244e-05, 1.92318423328667e-05, 1.79790538552821e-05, 1.67846832337787e-05, 1.56467817223195e-05, 1.45634448888315e-05, 1.35328120613655e-05, 1.25530657852399e-05, 1.16224312748161e-05, 1.07391758548835e-05, 9.90160839828327e-06, 9.10807875697683e-06, 8.3569771950032e-06, 7.64673380113176e-06, 6.97581785608344e-06, 6.34273719852789e-06, 5.7460376226696e-06, 5.1843023369739e-06, 4.6561515054647e-06, 4.16024173765304e-06, 3.6952658285984e-06, 3.25995215366788e-06, 2.85306234988621e-06};

  return dpss_1;
}

double[] dpss_2_1024() {
  double [] dpss_2 = {
    2.67537469821199e-05, 2.99375626869154e-05, 3.33051041734263e-05, 3.68626929704124e-05, 4.06167749449604e-05, 4.45739209243838e-05, 4.8740827284335e-05, 5.3124316501279e-05, 5.77313376689079e-05, 6.25689669776041e-05, 6.76444081562365e-05, 7.29649928755212e-05, 7.85381811122475e-05, 8.43715614735614e-05, 9.04728514805589e-05, 9.68498978104678e-05, 0.000103510676496663, 0.000110463293085778, 0.000117715982751197, 0.000125277110362211, 0.000133155170508125, 0.000141358787476623, 0.000149896715185695, 0.000158777837068441, 0.000168011165910074, 0.000177605843636465, 0.000187571141053571, 0.000197916457537106, 0.000208651320671814, 0.00021978538583974, 0.000231328435756871, 0.000243290379957553, 0.000255681254226104, 0.000268511219975038, 0.000281790563569349, 0.000295529695596301, 0.000309739150080197, 0.000324429583641597, 0.00033961177460049, 0.000355296622022927, 0.000371495144710634, 0.000388218480133155, 0.000405477883302072, 0.000423284725586881, 0.000441650493472107, 0.000460586787255268, 0.000480105319685313, 0.000500217914541163, 0.000520936505150024, 0.000542273132845149, 0.000564239945362734, 0.000586849195177671, 0.000610113237777884, 0.000634044529877005, 0.000658655627565166, 0.000683959184397677, 0.000709967949421436, 0.000736694765138875, 0.000764152565409307, 0.000792354373287556, 0.000821313298799748, 0.000851042536656199, 0.000881555363901327, 0.000912865137500558, 0.000944985291864209, 0.000977929336308345, 0.00101171085245266, 0.0010463434915554, 0.00108184097178548, 0.00111821707543177, 0.00115548564604977, 0.00119366058554588, 0.00123275585119919, 0.00127278545262129, 0.00131376344865414, 0.00135570394420625, 0.0013986210870275, 0.00144252906442287, 0.00148744209990539, 0.0015333744497887, 0.00158034039971945, 0.00162835426115018, 0.00167743036775284, 0.00172758307177357, 0.00177882674032915, 0.00183117575164563, 0.00188464449123964, 0.00193924734804296, 0.00199499871047091, 0.00205191296243519, 0.00211000447930171, 0.00216928762379421, 0.00222977674184418, 0.00229148615838795, 0.00235443017311153, 0.00241862305614409, 0.00248407904370075, 0.00255081233367559, 0.00261883708118562, 0.00268816739406667, 0.00275881732832196, 0.00283080088352443, 0.00290413199817358, 0.00297882454500796, 0.00305489232627413, 0.00313234906895326, 0.0032112084199463, 0.00329148394121883, 0.00337318910490667, 0.00345633728838334, 0.00354094176929056, 0.0036270157205329, 0.00371457220523777, 0.00380362417168202, 0.00389418444818626, 0.00398626573797833, 0.00407988061402701, 0.00417504151384739, 0.00427176073427925, 0.00437005042623965, 0.00446992258945127, 0.00457138906714777, 0.00467446154075762, 0.00477915152456789, 0.00488547036036933, 0.00499342921208433, 0.00510303906037919, 0.00521431069726224, 0.00532725472066932, 0.00544188152903822, 0.00555820131587357, 0.00567622406430388, 0.0057959595416322, 0.00591741729388216, 0.00604060664034095, 0.00616553666810088, 0.00629221622660127, 0.00642065392217236, 0.00655085811258276, 0.00668283690159249, 0.00681659813351298, 0.00695214938777609, 0.00708949797351367, 0.00722865092414963, 0.0073696149920061, 0.00751239664292569, 0.0076570020509115, 0.00780343709278675, 0.00795170734287588, 0.00810181806770893, 0.00825377422075107, 0.00840758043715907, 0.00856324102856671, 0.00872075997790082, 0.00888014093422997, 0.00904138720764765, 0.00920450176419179, 0.00936948722080257, 0.00953634584032035, 0.00970507952652571, 0.00987568981922342, 0.0100481778893723, 0.0102225445342628, 0.0103987901727443, 0.0105769148405042, 0.0107569181854001, 0.0109387994628476, 0.0111225575312656, 0.0113081908475805, 0.0114956974627918, 0.0116850750176004, 0.0118763207381023, 0.0120694314315481, 0.0122644034821729, 0.0124612328470946, 0.0126599150522866, 0.0128604451886235, 0.0130628179080033, 0.0132670274195479, 0.0134730674858829, 0.0136809314194994, 0.0138906120791991, 0.0141021018666244, 0.0143153927228764, 0.0145304761252205, 0.0147473430838836, 0.0149659841389427, 0.0151863893573087, 0.0154085483298047, 0.0156324501683425, 0.0158580835031984, 0.0160854364803889, 0.01631449675915, 0.0165452515095196, 0.0167776874100259, 0.0170117906454834, 0.0172475469048973, 0.0174849413794781, 0.0177239587607686, 0.017964583238884, 0.0182067985008664, 0.0184505877291565, 0.018695933600182, 0.018942818283066, 0.0191912234384548, 0.0194411302174685, 0.0196925192607742, 0.0199453706977834, 0.0201996641459755, 0.0204553787103476, 0.020712492982993, 0.020970985042808, 0.0212308324553303, 0.0214920122727072, 0.0217545010337979, 0.022018274764408, 0.0222833089776594, 0.0225495786744954, 0.0228170583443219, 0.0230857219657862, 0.0233555430076941, 0.0236264944300654, 0.02389854868533, 0.0241716777196634, 0.0244458529744642, 0.0247210453879736, 0.0249972253970363, 0.0252743629390058, 0.0255524274537926, 0.0258313878860565, 0.0261112126875437, 0.0263918698195691, 0.0266733267556436, 0.0269555504842472, 0.027238507511749, 0.027522163865472, 0.027806485096906, 0.0280914362850657, 0.0283769820399975, 0.0286630865064309, 0.028949713367579, 0.0292368258490846, 0.0295243867231139, 0.0298123583125967, 0.0301007024956131, 0.0303893807099271, 0.0306783539576666, 0.0309675828101485, 0.0312570274128504, 0.0315466474905273, 0.0318364023524728, 0.0321262508979253, 0.0324161516216177, 0.032706062619471, 0.0329959415944297, 0.0332857458624402, 0.0335754323585704, 0.03386495764327, 0.0341542779087702, 0.0344433489856231, 0.0347321263493795, 0.0350205651274025, 0.0353086201058194, 0.0355962457366073, 0.0358833961448136, 0.0361700251359095, 0.0364560862032751, 0.0367415325358158, 0.0370263170257076, 0.037310392276271, 0.037593710609971, 0.0378762240765438, 0.0381578844612461, 0.0384386432932279, 0.0387184518540258, 0.0389972611861758, 0.039275022101944, 0.0395516851921737, 0.039827200835246, 0.0401015192061544, 0.0403745902856894, 0.0406463638697323, 0.0409167895786566, 0.0411858168668342, 0.0414533950322455, 0.0417194732261899, 0.0419840004630971, 0.0422469256304339, 0.0425081974987072, 0.0427677647315597, 0.0430255758959565, 0.0432815794724595, 0.0435357238655889, 0.0437879574142682, 0.0440382284023507, 0.0442864850692257, 0.0445326756205004, 0.0447767482387575, 0.0450186510943836, 0.0452583323564674, 0.0454957402037644, 0.0457308228357261, 0.0459635284835901, 0.04619380542153, 0.0464216019778608, 0.0466468665462981, 0.0468695475972681, 0.0470895936892656, 0.0473069534802567, 0.0475215757391252, 0.0477334093571566, 0.047942403359561, 0.0481485069170278, 0.0483516693573124, 0.0485518401768505, 0.0487489690523975, 0.0489430058526894, 0.0491339006501233, 0.0493216037324537, 0.0495060656145009, 0.0496872370498704, 0.0498650690426787, 0.0500395128592819, 0.0502105200400063, 0.0503780424108753, 0.0505420320953313, 0.050702441525948, 0.050859223456132, 0.0510123309718076, 0.0511617175030846, 0.0513073368359039, 0.0514491431236587, 0.0515870908987875, 0.051721135084336, 0.0518512310054853, 0.0519773344010414, 0.0520994014348854, 0.0522173887073781, 0.0523312532667191, 0.0524409526202541, 0.0525464447457295, 0.0526476881024896, 0.0527446416426144, 0.0528372648219935, 0.052925517611334, 0.0530093605070985, 0.0530887545423709, 0.0531636612976454, 0.0532340429115368, 0.0532998620914085, 0.0533610821239155, 0.0534176668854575, 0.0534695808525419, 0.0535167891120513, 0.0535592573714126, 0.0535969519686665, 0.0536298398824317, 0.0536578887417629, 0.0536810668358984, 0.0536993431238951, 0.0537126872441469, 0.0537210695237847, 0.0537244609879541, 0.0537228333689691, 0.0537161591153373, 0.0537044114006551, 0.0536875641323695, 0.0536655919604042, 0.053638470285646, 0.0536061752682906, 0.0535686838360436, 0.0535259736921745, 0.0534780233234217, 0.0534248120077447, 0.0533663198219219, 0.0533025276489916, 0.0532334171855317, 0.0531589709487795, 0.053079172283585, 0.052994005369198, 0.0529034552258863, 0.0528075077213812, 0.0527061495771501, 0.0525993683744927, 0.052487152560459, 0.0523694914535868, 0.052246375249457, 0.0521177950260647, 0.0519837427490028, 0.0518442112764589, 0.0516991943640202, 0.0515486866692877, 0.0513926837562955, 0.0512311820997356, 0.0510641790889838, 0.0508916730319283, 0.0507136631585968, 0.0505301496245817, 0.0503411335142619, 0.0501466168438197, 0.0499466025640509, 0.0497410945629678, 0.049530097668193, 0.0493136176491433, 0.0490916612190018, 0.0488642360364784, 0.048631350707356, 0.0483930147858235, 0.0481492387755925, 0.0479000341307982, 0.0476454132566832, 0.0473853895100645, 0.0471199771995806, 0.0468491915857209, 0.046573048880635, 0.0462915662477221, 0.0460047618009998, 0.0457126546042524, 0.0454152646699573, 0.0451126129579907, 0.0448047213741115, 0.0444916127682234, 0.0441733109324147, 0.0438498405987775, 0.0435212274370038, 0.0431874980517609, 0.0428486799798449, 0.0425048016871129, 0.0421558925651952, 0.0418019829279855, 0.0414431040079123, 0.04107928795199, 0.0407105678176514, 0.0403369775683615, 0.0399585520690137, 0.039575327081109, 0.039187339257719, 0.0387946261382338, 0.0383972261428953, 0.0379951785671176, 0.0375885235755943, 0.0371773021961954, 0.0367615563136542, 0.0363413286630445, 0.0359166628230518, 0.0354876032090372, 0.0350541950658974, 0.0346164844607209, 0.0341745182752436, 0.0337283441981029, 0.0332780107168949, 0.0328235671100342, 0.0323650634384185, 0.0319025505369013, 0.0314360800055722, 0.0309657042008491, 0.0304914762263824, 0.0300134499237742, 0.0295316798631152, 0.0290462213333396, 0.0285571303324025, 0.02806446355728, 0.0275682783937957, 0.0270686329062759, 0.0265655858270348, 0.0260591965456933, 0.025549525098334, 0.0250366321564935, 0.0245205790159972, 0.024001427585636, 0.0234792403756907, 0.0229540804863051, 0.0224260115957106, 0.0218950979483066, 0.0213614043425972, 0.0208249961189899, 0.0202859391474572, 0.0197442998150646, 0.0192001450133688, 0.0186535421256886, 0.0181045590142515, 0.0175532640072194, 0.0169997258855969, 0.0164440138700249, 0.0158861976074632, 0.015326347157765, 0.0147645329801471, 0.0142008259195592, 0.0136352971929549, 0.0130680183754691, 0.0124990613865038, 0.0119284984757275, 0.0113564022089902, 0.010782845454158, 0.0102079013668718, 0.00963164337623204, 0.0090541451704146, 0.00847548068222049, 0.0078957240745635, 0.00731494972589936, 0.00673323221560005, 0.00615064630927696, 0.00556726694405677, 0.00498316921381357, 0.00439842835436119, 0.00381311972860928, 0.00322731881168716, 0.00264110117603898, 0.0020545424764942, 0.001467718435317, 0.000880704827238553, 0.000293577464475975, -0.00029358781825836, -0.000880715178753172, -0.00146772878229656, -0.00205455281667235, -0.00264111150715079, -0.00322732913146958, -0.00381313003480163, -0.00439843864470561, -0.0049831794860555, -0.0055672771959454, -0.00615065653856575, -0.00673324242004713, -0.00731495990326805, -0.00789573422262273, -0.00847549079874529, -0.00905415525318657, -0.00963165342303977, -0.0102079113755114, -0.0107828554224334, -0.0113564121347139, -0.0119285083567207, -0.0124990712205969, -0.0130680281605024, -0.0136353069267788, -0.0142008356000347, -0.0147645426051463, -0.0153263567251715, -0.0158862071151725, -0.0164440233159449, -0.0169997352676482, -0.0175532733233358, -0.0181045682623805, -0.0186535513037918, -0.0192001541194221, -0.0197443088470589, -0.0202859481033987, -0.0208250049969004, -0.0213614131405146, -0.0218951066642852, -0.0224260202278218, -0.0229540890326372, -0.02347924883435, -0.0240014359547465, -0.0245205872937015, -0.025036640340953, -0.0255495331877289, -0.0260592045382236, -0.0265655937209201, -0.0270686406997562, -0.0275682860851313, -0.0280644711447522, -0.0285571378143138, -0.0290462287080139, -0.0295316871288983, -0.0300134570790342, -0.0304914832695097, -0.030965711130257, -0.031436086819697, -0.0319025572342027, -0.0323650700173799, -0.0328235735691629, -0.0332780170547226, -0.0337283504131855, -0.034174524366162, -0.034616490426081, -0.0350542009043302, -0.0354876089191995, -0.035916668403626, -0.036341334112739, -0.0367615616312036, -0.0371773073803609, -0.0375885286251636, -0.0379951834809053, -0.0383972309197432, -0.0387946307770108, -0.0391873437573215, -0.0395753314404612, -0.0399585562870675, -0.0403369816440967, -0.040710571750076, -0.0410792917401403, -0.0414431076508532, -0.0418019864248104, -0.0421558959150261, -0.0425048048891008, -0.0428486830331696, -0.0431875009556315, -0.0435212301906584, -0.0438498432014836, -0.0441733133834692, -0.0444916150669526, -0.0448047235198714, -0.0451126149501666, -0.0454152665079645, -0.0457126562875359, -0.0460047633290342, -0.0462915676200119, -0.0465730500967147, -0.0468491926451549, -0.0471199781019631, -0.0473853902550197, -0.0476454138438652, -0.0479000345598911, -0.0481492390463104, -0.0483930148979103, -0.0486313506605855, -0.0488642358306543, -0.0490916608539579, -0.0493136171247428, -0.0495300969843292, -0.0497410937195634, -0.0499466015610585, -0.0501466156812215, -0.0503411321920695, -0.0505301481428361, -0.0507136615173684, -0.0508916712313167, -0.0510641771291178, -0.0512311799807731, -0.0513926814784232, -0.051548684232721, -0.0516991917690034, -0.0518442085232647, -0.0519837398379324, -0.0521177919574474, -0.0522463720236505, -0.0523694880709764, -0.0524871490214581, -0.0525993646795421, -0.0527061457267181, -0.0528075037159634, -0.0529034510660053, -0.0529940010554034, -0.053079167816453, -0.0531589663289128, -0.0532334124135593, -0.0533025227255684, -0.0533663147477288, -0.0534248067834879, -0.0534780179498331, -0.053525968170011, -0.0535686781660871, -0.0536061694513475, -0.0536384643225472, -0.0536655858520047, -0.0536875578795482, -0.0537044050043144, -0.0537161525764031, -0.0537228266883903, -0.0537244541667024, -0.0537210625628543, -0.0537126801445543, -0.0536993358866785, -0.0536810594621178, -0.0536578812324995, -0.0536298322387878, -0.0535969441917651, -0.0535592494623971, -0.0535167810720851, -0.0534695726828083, -0.053417658587159, -0.053361073698274, -0.0532998535396645, -0.0532340342349491, -0.0531636524974913, -0.0530887456199452, -0.0530093514637135, -0.052925508448319, -0.0528372555406948, -0.0527446322443943, -0.0526476785887267, -0.052546435117818, -0.0524409428796036, -0.0523312434147541, -0.0522173787455376, -0.0520993913646227, -0.0519773242238239, -0.0518512207227935, -0.0517211246976639, -0.0515870804096416, -0.0514491325335581, -0.0513073261463796, -0.0511617067156792, -0.0510123200880751, -0.0508592124776373, -0.0507024304542664, -0.0505420209320482, -0.0503780311575861, -0.0502105086983155, -0.0500395014308032, -0.0498650575290343, -0.0496872254526909, -0.0495060539354245, -0.0493215919731263, -0.0491338888121978, -0.0489429939378253, -0.0487489570622609, -0.0485518281131132, -0.0483516572216519, -0.0481484947111267, -0.0479423910851068, -0.0477333970158411, -0.0475215633326443, -0.0473069410103101, -0.0470895811575561, -0.0468695350055016, -0.0466468538961828, -0.0464215892711073, -0.0461937926598506, -0.0459635156686986, -0.0457308099693373, -0.0454957272875938, -0.0452583193922307, -0.0450186380837966, -0.0447767351835357, -0.0445326625223583, -0.0442864719298769, -0.0440382152235073, -0.0437879441976403, -0.0435357106128845, -0.0432815661853841, -0.0430255625762127, -0.042767751380847, -0.0425081841187213, -0.0422469122228668, -0.0419839870296364, -0.0417194597685188, -0.0414533815520421, -0.0411858033657716, -0.0409167760584021, -0.0406463503319475, -0.0403745767320297, -0.0401015056382686, -0.0398271872547762, -0.0395516716007547, -0.0392750085012034, -0.0389972475777332, -0.038718438239493, -0.0384386296742082, -0.0381578708393343, -0.0378762104533257, -0.0375936969870233, -0.0373103786551609, -0.0370263034079926, -0.0367415189230433, -0.0364560725969824, -0.0361700115376231, -0.0358833825560495, -0.0355962321588702, -0.0353086065406028, -0.0350205515761884, -0.034732112813638, -0.0344433354668124, -0.034154264408336, -0.0338649441626459, -0.033575418899177, -0.0332857324256852, -0.0329959281817077, -0.0327060492321634, -0.0324161382610921, -0.0321262375655355, -0.0318363890495588, -0.031546634218415, -0.0312570141728512, -0.0309675696035593, -0.0306783407857698, -0.03038936757399, -0.030100689396888, -0.0298123452523209, -0.0295243737025091, -0.0292368128693569, -0.0289497004299191, -0.0286630736120136, -0.0283769691899817, -0.0280914234805942, -0.0278064723391051, -0.0275221511554522, -0.0272384948506039, -0.026955537873054, -0.0266733141954628, -0.0263918573114445, -0.0261112002325021, -0.0258313754851078, -0.0255524151079295, -0.025274350649204, -0.0249972131642541, -0.0247210332131522, -0.0244458408585274, -0.0241716656635172, -0.0238985366898633, -0.0236264824961493, -0.0233555311361821, -0.0230857101575143, -0.0228170466001082, -0.0225495669951404, -0.0222832973639457, -0.0220182632171004, -0.0217544895536434, -0.021492000860435, -0.0212308211116516, -0.0209709737684163, -0.0207124817785637, -0.0204553675765385, -0.0201996530834262, -0.019945359707116, -0.0196925083425925, -0.0194411193723588, -0.0191912126669855, -0.0189428075857876, -0.0186959229776274, -0.0184505771818407, -0.0182067880292868, -0.0179645728435203, -0.017723948442083, -0.0174849311379151, -0.0172475367408839, -0.0170117805594293, -0.0167776774023233, -0.0165452415805435, -0.0163144869092581, -0.0160854267099216, -0.0158580738124791, -0.0156324405576777, -0.0154085387994838, -0.0151863799076044, -0.0149659747701109, -0.0147473337961635, -0.0145304669188348, -0.0143153835980313, -0.0141020928235098, -0.0138906031179886, -0.0136809225403507, -0.0134730586889374, -0.0132670187049311, -0.0130628092758252, -0.0128604366389782, -0.0126599065852529, -0.0124612244627357, -0.0122643951805369, -0.012069423212668, -0.0118763126019958, -0.0116850669642709, -0.0114956894922275, -0.0113081829597553, -0.011122549726139, -0.0109387917403648, -0.0107569105454922, -0.0105769072830884, -0.0103987826977239, -0.0102225371415275, -0.0100481705787985, -0.00987568259067404, -0.00970507237985064, -0.00953633877535648, -0.00936948023737399, -0.00920449486210997, -0.00904138038671161, -0.00888013419422645, -0.00872075331860447, -0.00856323444974025, -0.00840757393855347, -0.00825376780210575, -0.00810181172875191, -0.007951701083324, -0.00780343091234583, -0.00765699594927654, -0.00751239061978103, -0.00736960904702564, -0.007228645056997, -0.00708949218384242, -0.00695214367522989, -0.0068165924977258, -0.00668283134218879, -0.0065508526291777, -0.00642064851437196, -0.00629221089400265, -0.00616553141029239, -0.00604060145690244, -0.00591741218438512, -0.00579595450563995, -0.00567621910137181, -0.0055581964255493, -0.0054418767108618, -0.00532724997417343, -0.00521430602197238, -0.00510303445581389, -0.00499342467775532, -0.00488546589578174, -0.00477914712922045, -0.00467445721414287, -0.00457138480875223, -0.00446991839875564, -0.00437004630271899, -0.00427175667740319, -0.00417503752308032, -0.00407987668882824, -0.00398626187780233, -0.0038941806524828, -0.0038036204398964, -0.00371456853681097, -0.00362701211490179, -0.00354093822588807, -0.00345633380663866, -0.00337318568424541, -0.00329148058106323, -0.00321120511971538, -0.00313234582806302, -0.00305488914413772, -0.00297882142103587, -0.00290412893177379, -0.00283079787410259, -0.00275881437528159, -0.0026881644968093, -0.00261883423911097, -0.00255080954618175, -0.00248407631018432, -0.00241862037600037, -0.00235442754573467, -0.00229148358317111, -0.00222977421817971, -0.00216928515107379, -0.00211000205691651, -0.00205191058977603, -0.00199499638692841, -0.00193924507300768, -0.00188464226410226, -0.00183117357179708, -0.00177882460716074, -0.00172758098467717, -0.00167742832612101, -0.00162835226437629, -0.00158033844719784, -0.00153337254091482, -0.00148744023407594, -0.00144252724103591, -0.0013986193054826, -0.00135570220390462, -0.00131376174899875, -0.00127278379301699, -0.00123275423105286, -0.00119365900426654, -0.00115548410304869, -0.00111821557012258, -0.00108183950358432, -0.00104634205988098, -0.00101170945672642, -0.00097792797595454, -0.000944983966310006, -0.000912863846176149, -0.000881554106240027, -0.000851041312094544, -0.00082131210677759, -0.000792353213248155, -0.000764151436799425, -0.00073669366740886, -0.000709966882025314, -0.000683958146793229, -0.000658654619214013, -0.000634043550244687, -0.000610112286333933, -0.000586848271395688, -0.000564239048720457, -0.000542272262824523, -0.00052093566123727, -0.000500217096226839, -0.000480104526464384, -0.00046058601862716, -0.000441649748940771, -0.000423284004660851, -0.000405477185494515, -0.000388217804961926, -0.000371494491698326, -0.000355295990696915, -0.00033961116449298, -0.000324428994289665, -0.00030973858102583, -0.000295529146386434, -0.000281790033755898, -0.00026851070911493, -0.000255680761881305, -0.000243289905695091, -0.00023132797914886, -0.000219784946463402, -0.0002086508981095, -0.000197916051376317, -0.000187570750886981, -0.000177605469061937, -0.000168010806530686, -0.000158777492492499, -0.000149896385026751, -0.000141358471353482, -0.000133154868044856, -0.000125276821188156, -0.000117715706500979, -0.000110463029399314, -0.000103510425019175, -9.68496581924823e-05, -9.04726233779077e-05, -8.43713445473762e-05, -7.85379750289461e-05, -7.29647973067881e-05, -6.76442227790035e-05, -6.25687914740232e-05, -5.77311717263096e-05, -5.31241598121447e-05, -4.8740679546218e-05, -4.45737818397512e-05, -4.0616644220961e-05, -3.68625703185497e-05, -3.33049893090875e-05, -2.99374553287872e-05, -2.67536468507898e-05};

  return dpss_2;
}

double[] dpss_3_1024() {
  double [] dpss_3 = {
    0.000170530529531564, 0.000186999649487835, 0.000204224631072319, 0.000222224489766289, 0.000241018422705729, 0.000260625804998009, 0.000281066185649225, 0.000302359283312594, 0.000324524981886523, 0.00034758332607207, 0.000371554516742966, 0.000396458906221684, 0.000422316993408837, 0.000449149418797259, 0.00047697695934566, 0.000505820523225693, 0.000535701144440387, 0.000566639977303815, 0.000598658290788113, 0.000631777462738765, 0.000666018973956753, 0.000701404402153957, 0.000737955415777711, 0.000775693767708357, 0.000814641288831754, 0.000854819881484958, 0.000896251512778214, 0.000938958207792703, 0.00098296204265629, 0.00102828513749978, 0.00107494964929212, 0.00112297776455744, 0.00117239169197497, 0.00122321365486408, 0.00127546588355573, 0.00132917060765163, 0.00138435004817208, 0.00144102640959435, 0.00149922187178368, 0.00155895858181872, 0.00162025864571345, 0.00168314412003724, 0.00174763700343531, 0.00181375922805165, 0.00188153265085621, 0.00195097904487849, 0.0020221200903504, 0.00209497736576027, 0.00216957233882078, 0.0022459263573532, 0.00232406064009042, 0.00240399626740146, 0.00248575417194019, 0.00256935512922101, 0.00265481974812427, 0.00274216846133405, 0.00283142151571121, 0.00292259896260488, 0.00301572064810525, 0.00311080620324073, 0.00320787503412243, 0.00330694631203933, 0.00340803896350716, 0.00351117166027442, 0.00361636280928874, 0.00372363054262687, 0.0038329927073917, 0.00394446685557983, 0.00405807023392317, 0.00417381977370797, 0.00429173208057508, 0.00441182342430493, 0.00453410972859088, 0.00465860656080455, 0.00478532912175697, 0.00491429223545931, 0.00504551033888689, 0.00517899747175051, 0.0053147672662787, 0.00545283293701515, 0.00559320727063492, 0.00573590261578364, 0.00588093087294351, 0.00602830348433035, 0.00617803142382567, 0.0063301251869478, 0.00648459478086632, 0.00664144971446367, 0.00680069898844833, 0.00696235108552358, 0.00712641396061617, 0.00729289503116902, 0.00746180116750209, 0.00763313868324581, 0.00780691332585115, 0.00798313026718061, 0.0081617940941844, 0.00834290879966609, 0.00852647777314191, 0.00871250379179812, 0.00890098901155056, 0.00909193495821081, 0.00928534251876309, 0.00948121193275627, 0.0096795427838151, 0.00988033399127508, 0.0100835838019451, 0.0102892897820023, 0.0104974488090228, 0.0107080570641531, 0.0109211100244264, 0.0111366024552272, 0.0113545284029095, 0.0115748811875713, 0.0117976533959912, 0.0120228368747298, 0.0122504227234004, 0.0124804012881134, 0.0127127621550976, 0.0129474941445031, 0.0131845853043897, 0.0134240229049043, 0.0136657934326509, 0.0139098825852583, 0.0141562752661478, 0.0144049555795052, 0.0146559068254615, 0.0149091114954845, 0.0151645512679863, 0.0154222070041491, 0.0156820587439737, 0.0159440857025538, 0.0162082662665793, 0.0164745779910717, 0.0167429975963563, 0.0170135009652721, 0.0172860631406251, 0.0175606583228856, 0.0178372598681347, 0.0181158402862613, 0.0183963712394138, 0.0186788235407079, 0.0189631671531949, 0.0192493711890918, 0.0195374039092763, 0.0198272327230492, 0.0201188241881673, 0.0204121440111477, 0.0207071570478469, 0.0210038273043172, 0.0213021179379407, 0.0216019912588458, 0.0219034087316048, 0.0222063309772176, 0.0225107177753814, 0.022816528067048, 0.0231237199572716, 0.0234322507183476, 0.0237420767932442, 0.0240531537993271, 0.0243654365323809, 0.0246788789709253, 0.0249934342808294, 0.0253090548202243, 0.0256256921447145, 0.0259432970128886, 0.0262618193921318, 0.0265812084647375, 0.0269014126343217, 0.0272223795325383, 0.027544056026096, 0.027866388224078, 0.0281893214855626, 0.0285128004275463, 0.0288367689331679, 0.0291611701602347, 0.0294859465500479, 0.0298110398365301, 0.0301363910556507, 0.0304619405551512, 0.0307876280045673, 0.0311133924055492, 0.0314391721024764, 0.0317649047933676, 0.0320905275410839, 0.0324159767848232, 0.0327411883519056, 0.0330660974698464, 0.0333906387787162, 0.0337147463437859, 0.0340383536684543, 0.0343613937074561, 0.0346837988803488, 0.0350055010852755, 0.0353264317130006, 0.0356465216612173, 0.0359657013491232, 0.0362839007322608, 0.0366010493176212, 0.0369170761790071, 0.0372319099726517, 0.0375454789530918, 0.0378577109892895, 0.0381685335810008, 0.0384778738753869, 0.0387856586838643, 0.03909181449919, 0.039396267512779, 0.0396989436322475, 0.0399997684991806, 0.0402986675071184, 0.0405955658197572, 0.0408903883893603, 0.0411830599753753, 0.0414735051632516, 0.0417616483834555, 0.0420474139306755, 0.0423307259832153, 0.0426115086225681, 0.0428896858531673, 0.0431651816223086, 0.0434379198402388, 0.0437078244004041, 0.0439748191998549, 0.0442388281597993, 0.0444997752463014, 0.0447575844911174, 0.0450121800126648, 0.0452634860371176, 0.0455114269196228, 0.0457559271656311, 0.045996911452337, 0.0462343046502199, 0.0464680318446828, 0.0466980183577798, 0.0469241897700275, 0.0471464719422933, 0.0473647910377541, 0.0475790735439188, 0.047789246294708, 0.0479952364925846, 0.0481969717307278, 0.0483943800152442, 0.0485873897874091, 0.048775929945931, 0.048959929869232, 0.0491393194377384, 0.0493140290561723, 0.0494839896758396, 0.0496491328169048, 0.049809390590648, 0.0499646957216942, 0.0501149815702107, 0.0502601821540623, 0.0504002321709191, 0.0505350670203095, 0.0506646228256098, 0.0507888364559643, 0.0509076455481281, 0.0510209885282254, 0.0511288046334154, 0.0512310339334592, 0.0513276173521802, 0.05141849668881, 0.0515036146392128, 0.0515829148169814, 0.0516563417743965, 0.0517238410232426, 0.0517853590554732, 0.0518408433637176, 0.0518902424616219, 0.051933505904017, 0.0519705843069075, 0.0520014293672717, 0.0520259938826681, 0.0520442317706394, 0.0520560980879078, 0.0520615490493543, 0.0520605420467744, 0.0520530356674034, 0.0520389897122056, 0.0520183652139172, 0.0519911244548402, 0.0519572309843766, 0.051916649636299, 0.0518693465457481, 0.0518152891659541, 0.0517544462846706, 0.0516867880403192, 0.0516122859378351, 0.0515309128642078, 0.0514426431037122, 0.0513474523528216, 0.0512453177347981, 0.0511362178139529, 0.0510201326095718, 0.0508970436094986, 0.050766933783372, 0.0506297875955082, 0.0504855910174263, 0.0503343315400074, 0.0501759981852857, 0.0500105815178624, 0.0498380736559406, 0.0496584682819733, 0.0494717606529207, 0.0492779476101118, 0.0490770275887053, 0.048869000626744, 0.0486538683738, 0.0484316340992046, 0.0482023026998591, 0.0479658807076221, 0.047722376296269, 0.0474717992880196, 0.0472141611596306, 0.0469494750480481, 0.0466777557556169, 0.0463990197548437, 0.0461132851927091, 0.0458205718945275, 0.0455209013673495, 0.0452142968029051, 0.0449007830800844, 0.0445803867669538, 0.0442531361223031, 0.0439190610967242, 0.0435781933332159, 0.043230566167315, 0.0428762146267505, 0.0425151754306194, 0.0421474869880826, 0.0417731893965788, 0.0413923244395554, 0.0410049355837153, 0.0406110679757784, 0.040210768438756, 0.039804085467739, 0.0393910692251979, 0.0389717715357948, 0.0385462458807067, 0.0381145473914598, 0.0376767328432764, 0.0372328606479317, 0.0367829908461237, 0.0363271850993548, 0.0358655066813262, 0.0353980204688472, 0.0349247929322577, 0.034445892125368, 0.0339613876749146, 0.0334713507695358, 0.0329758541482665, 0.032474972088556, 0.0319687803938088, 0.0314573563804523, 0.0309407788645326, 0.0304191281478406, 0.0298924860035721, 0.0293609356615238, 0.0288245617928278, 0.0282834504942291, 0.027737689271907, 0.0271873670248466, 0.0266325740277617, 0.0260734019135732, 0.0255099436554479, 0.0249422935484009, 0.0243705471904653, 0.0237948014634343, 0.0232151545131804, 0.0226317057295549, 0.0220445557258741, 0.0214538063179955, 0.0208595605029912, 0.0202619224374206, 0.0196609974152113, 0.0190568918451505, 0.0184497132279945, 0.0178395701332013, 0.0172265721752926, 0.0166108299898506, 0.015992455209156, 0.0153715604374743, 0.0147482592259951, 0.0141226660474332, 0.0134948962702957, 0.0128650661328243, 0.0122332927166177, 0.0115996939199423, 0.0109643884307386, 0.0103274956993292, 0.00968913591083717, 0.00904942995732188, 0.00840849940963938, 0.00776646648903581, 0.00712345403848123, 0.00647958549375179, 0.00583498485426855, 0.00518977665370072, 0.0045440859303418, 0.0038980381972668, 0.00325175941227896, 0.00260537594765448, 0.00195901455969383, 0.00131280235808819, 0.000666866775109923, 2.13355346357422e-05, -0.000623663378988537, -0.00126800175223265, -0.00191155117380696, -0.00255418306621898, -0.00319576871745196, -0.00383617931275667, -0.00447528596654689, -0.00511295975438934, -0.00574907174507878, -0.0063834930327889, -0.00701609476928941, -0.00764674819622001, -0.0082753246774117, -0.00890169573124574, -0.00952573306304097, -0.0101473085974596, -0.0107662945109218, -0.0113825632640202, -0.0119959876339233, -0.0126064407467592, -0.0132137961099697, -0.0138179276446251, -0.0144187097176891, -0.0150160171742261, -0.0156097253695393, -0.0161997102012302, -0.0167858481411715, -0.0173680162673811, -0.0179460922957895, -0.018519954611891, -0.0190894823022672, -0.0196545551859752, -0.0202150538457906, -0.0207708596592943, -0.0213218548297959, -0.0218679224170822, -0.0224089463679826, -0.0229448115467418, -0.0234754037651899, -0.024000609812702, -0.024520317485936, -0.0250344156183416, -0.0255427941094305, -0.0260453439537978, -0.0265419572698876, -0.0270325273284925, -0.0275169485809785, -0.0279951166872268, -0.0284669285432836, -0.02893228230871, -0.0293910774336215, -0.0298432146854122, -0.0302885961751513, -0.0307271253836473, -0.0311587071871695, -0.0315832478828193, -0.0320006552135444, -0.0324108383927864, -0.0328137081287554, -0.0332091766483242, -0.0335971577205327, -0.0339775666796977, -0.0343503204481192, -0.0347153375583765, -0.0350725381752071, -0.035421844116962, -0.0357631788766298, -0.0360964676424236, -0.0364216373179243, -0.0367386165417737, -0.0370473357069108, -0.0373477269793466, -0.0376397243164698, -0.0379232634848789, -0.0381982820777344, -0.0384647195316264, -0.0387225171429507, -0.0389716180837904, -0.039211967417296, -0.0394435121125606, -0.0396662010589849, -0.0398799850801268, -0.0400848169470325, -0.0402806513910446, -0.0404674451160818, -0.0406451568103884, -0.0408137471577481, -0.0409731788481596, -0.0411234165879705, -0.0412644271094657, -0.0413961791799079, -0.041518643610027, -0.0416317932619557, -0.0417356030566095, -0.0418300499805072, -0.0419151130920315, -0.0419907735271265, -0.0420570145044307, -0.0421138213298443, -0.0421611814005282, -0.0421990842083349, -0.0422275213426688, -0.0422464864927765, -0.0422559754494643, -0.042255986106245, -0.0422465184599109, -0.0422275746105358, -0.0421991587609021, -0.0421612772153575, -0.0421139383780985, -0.0420571527508824, -0.0419909329301689, -0.0419152936036915, -0.0418302515464598, -0.0417358256161947, -0.0416320367481973, -0.041518907949653, -0.0413964642933733, -0.0412647329109767, -0.0411237429855113, -0.0409735257435205, -0.0408141144465558, -0.0406455443821382, -0.0404678528541715, -0.0402810791728105, -0.0400852646437872, -0.0398804525571987, -0.0396666881757597, -0.0394440187225246, -0.039212493368081, -0.0389721632172207, -0.0387230812950918, -0.038465302532835, -0.038198883752711, -0.0379238836527212, -0.0376403627907286, -0.0373483835680829, -0.0370480102127545, -0.0367393087619843, -0.0364223470444531, -0.0360971946619771, -0.0357639229707356, -0.0354226050620353, -0.035073315742619, -0.0347161315145241, -0.0343511305544969, -0.0339783926929702, -0.0335979993926091, -0.0332100337264338, -0.0328145803555247, -0.0324117255063173, -0.0320015569474946, -0.0315841639664826, -0.0311596373455585, -0.0307280693375771, -0.0302895536413239, -0.0298441853765028, -0.0293920610583658, -0.0289332785719917, -0.0284679371462248, -0.0279961373272776, -0.027517980952009, -0.027033571120885, -0.0265430121706303, -0.0260464096465789, -0.025543870274734, -0.025035501933543, -0.0245214136253998, -0.0240017154478794, -0.0234765185647175, -0.0229459351765409, -0.0224100784913597, -0.0218690626948296, -0.0213230029202932, -0.0207720152186106, -0.0202162165277873, -0.019655724642409, -0.0190906581828942, -0.0185211365645708, -0.01794727996659, -0.0173692093006835, -0.0167870461797762, -0.0162009128864623, -0.0156109323413548, -0.0150172280713188, -0.0144199241775968, -0.0138191453038369, -0.013215016604033, -0.0126076637103865, -0.0119972127011004, -0.0113837900681128, -0.0107675226847833, -0.0101485377735385, -0.00952696287348843, -0.00890292580802251, -0.00827655465239562, -0.00764797770131303, -0.00701732343652444, -0.00638472049443653, -0.0057502976337537, -0.00511418370315648, -0.00447650760902728, -0.00383739828323287, -0.00319698465097316, -0.00255539559870572, -0.00191275994215529, -0.00126920639441787, -0.000624863534168436, 2.01402260182502e-05, 0.000665676671224699, 0.0013116178156164, 0.00195783593372715, 0.00260420359159492, 0.00325059367773944, 0.0038968794339725, 0.00454293448603221, 0.00518863287403255, 0.00583384908271945, 0.00647845807152495, 0.00712233530441088, 0.00776535677949362, 0.0084073990584418, 0.00904833929563855, 0.00968805526710021, 0.0103264253991436, 0.0109633287967939, 0.0115986452719247, 0.0122322553711242, 0.0128640404032772, 0.0134938824668588, 0.0141216644769287, 0.0147472701918225, 0.0153705842395295, 0.0159914921437527, 0.016609880349642, 0.0172256362491953, 0.01783864820632, 0.0184488055815482, 0.0190559987564003, 0.0196601191573888, 0.0202610592796586, 0.0208587127102556, 0.0214529741510185, 0.0220437394410886, 0.0226309055790311, 0.0232143707445631, 0.0237940343198825, 0.0243697969105925, 0.024941560366218, 0.0255092278003064, 0.026072703610111, 0.0266318934958502, 0.0271867044795391, 0.027737044923389, 0.0282828245477704, 0.0288239544487358, 0.0293603471150986, 0.0298919164450635, 0.0304185777624066, 0.0309402478321994, 0.0314568448760764, 0.0319682885870403, 0.0324745001438041, 0.0329754022246663, 0.033470919020917, 0.033960976249772, 0.0344455011668335, 0.0349244225780743, 0.0353976708513445, 0.0358651779273977, 0.0363268773304369, 0.036782704178177, 0.0372325951914227, 0.0376764887031624, 0.0381143246671748, 0.038546044666149, 0.0389715919193166, 0.0393909112895964, 0.0398039492902496, 0.0402106540910467, 0.0406109755239464, 0.0410048650882851, 0.0413922759554784, 0.0417731629732352, 0.0421474826692844, 0.0425151932546155, 0.042876254626233, 0.043230628369428, 0.043578277759565, 0.0439191677633884, 0.044253265039848, 0.0445805379404466, 0.0449009565091105, 0.045214492481586, 0.0455211192843631, 0.0458208120331293, 0.046113547530755, 0.0463993042648148, 0.0466780624046456, 0.0469498037979454, 0.0472145119669159, 0.0474721721039508, 0.0477227710668752, 0.0479662973737368, 0.0482027411971556, 0.0484320943582323, 0.0486543503200229, 0.0488695041805795, 0.0490775526655652, 0.0492784941204445, 0.0494723285022545, 0.0496590573709614, 0.0498386838804072, 0.0500112127688498, 0.0501766503491032, 0.0503350044982814, 0.0504862846471511, 0.0506305017690986, 0.0507676683687168, 0.0508977984700154, 0.0510209076042625, 0.0511370127974612, 0.0512461325574671, 0.0513482868607532, 0.0514434971388272, 0.0515317862643073, 0.0516131785366625, 0.0516876996676234, 0.0517553767662702, 0.0518162383238026, 0.0518703141979995, 0.0519176355973747, 0.0519582350650334, 0.0519921464622381, 0.0520194049516893, 0.0520400469805277, 0.052054110263065, 0.0520616337632497, 0.0520626576768749, 0.0520572234135347, 0.0520453735783368, 0.0520271519533776, 0.0520026034789862, 0.0519717742347466, 0.0519347114203024, 0.0518914633359535, 0.0518420793630501, 0.0517866099441925, 0.0517251065632436, 0.0516576217251607, 0.0515842089356547, 0.051504922680684, 0.0514198184057892, 0.0513289524952782, 0.0512323822512662, 0.0511301658725806, 0.0510223624335367, 0.0509090318625916, 0.0507902349208842, 0.0506660331806685, 0.0505364890036476, 0.0504016655192155, 0.0502616266026142, 0.0501164368530141, 0.0499661615715234, 0.0498108667391359, 0.0496506189946232, 0.0494854856123783, 0.0493155344802193, 0.0491408340771589, 0.0489614534511481, 0.0487774621968005, 0.0485889304331043, 0.0483959287811304, 0.0481985283417414, 0.0479968006733112, 0.0477908177694598, 0.0475806520368119, 0.047366376272785, 0.0471480636434154, 0.046925787661227, 0.0466996221631512, 0.0464696412885037, 0.0462359194570257, 0.0459985313469942, 0.0457575518734113, 0.0455130561662749, 0.0452651195489403, 0.0450138175165781, 0.0447592257147334, 0.0445014199179946, 0.0442404760087767, 0.0439764699562242, 0.0437094777952424, 0.0434395756056601, 0.0431668394915305, 0.0428913455605769, 0.0426131699037876, 0.0423323885751662, 0.0420490775716422, 0.0417633128131482, 0.0414751701228685, 0.0411847252076633, 0.0408920536386759, 0.0405972308321253, 0.0403003320302913, 0.0400014322826953, 0.0397006064274828, 0.039397929073011, 0.0390934745796472, 0.0387873170417812, 0.0384795302700578, 0.0381701877738309, 0.0378593627438466, 0.0375471280351559, 0.0372335561502643, 0.0369187192225191, 0.0366026889997398, 0.0362855368280954, 0.0359673336362304, 0.0356481499196444, 0.0353280557253283, 0.0350071206366597, 0.0346854137585607, 0.0343630037029219, 0.0340399585742934, 0.033716345955848, 0.0333922328956174, 0.0330676858930043, 0.032742770885573, 0.0324175532361209, 0.0320920977200323, 0.0317664685129174, 0.0314407291785374, 0.0311149426570188, 0.0307891712533574, 0.030463476626214, 0.0301379197770038, 0.0298125610392793, 0.0294874600684101, 0.0291626758315589, 0.0288382665979552, 0.0285142899294684, 0.02819080267148, 0.0278678609440561, 0.0275455201334204, 0.0272238348837292, 0.0269028590891468, 0.026582645886224, 0.026263247646577, 0.0259447159698699, 0.0256271016770974, 0.0253104548041701, 0.0249948245958013, 0.0246802594996938, 0.0243668071610277, 0.024054514417248, 0.0237434272931511, 0.0234335909962696, 0.0231250499125543, 0.0228178476023529, 0.0225120267966832, 0.0222076293938008, 0.0219046964560594, 0.0216032682070623, 0.0213033840291035, 0.0210050824608969, 0.0207084011955928, 0.0204133770790776, 0.0201200461085581, 0.019828443431425, 0.0195386033443968, 0.0192505592929391, 0.0189643438709597, 0.0186799888207746, 0.0183975250333452, 0.018116982548782, 0.0178383905571136, 0.0175617773993183, 0.0172871705686146, 0.0170145967120092, 0.0167440816320989, 0.0164756502891238, 0.0162093268032687, 0.0159451344572092, 0.0156830956989011, 0.0154232321446073, 0.0151655645821618, 0.0149101129744656, 0.0146568964632114, 0.0144059333728348, 0.0141572412146875, 0.013910836691429, 0.0136667357016345, 0.0134249533446133, 0.0131855039254366, 0.0129484009601683, 0.0127136571812975, 0.0124812845433675, 0.0122512942287975, 0.012023696653894, 0.0117985014750471, 0.0115757175951087, 0.0113553531699474, 0.0111374156151773, 0.0109219116130561, 0.0107088471195481, 0.0104982273715491, 0.0102900568942679, 0.0100843395087609, 0.00988107833961597, 0.00968027582278029, 0.00948193371352936, 0.00928605309457185, 0.00909263438428668, 0.00890167734508791, 0.00871318109191313, 0.0085271441008313, 0.00834356421776559, 0.00816243866732711, 0.00798376406175513, 0.0078075364099596, 0.00763375112666174, 0.00746240304162828, 0.00729348640899527, 0.00712699491667704, 0.00696292169585614, 0.00680125933055, 0.00664199986725001, 0.0064851348246289, 0.00633065520331221, 0.00617855149570956, 0.00602881369590156, 0.00588143130957822, 0.00573639336402465, 0.00559368841814998, 0.00545330457255547, 0.00531522947963759, 0.00517945035372214, 0.00504595398122524, 0.00491472673083733, 0.00478575456372611, 0.00465902304375453, 0.00453451734771002, 0.0044122222755408, 0.00429212226059564, 0.00417420137986305, 0.00405844336420637, 0.00394483160859073, 0.00383334918229846, 0.00372397883912911, 0.00361670302758047, 0.00351150390100734, 0.00340836332775427, 0.00330726290125883, 0.00320818395012181, 0.00311110754814109, 0.00301601452430581, 0.00292288547274753, 0.00283170076264517, 0.00274244054808048, 0.00265508477784104, 0.00256961320516744, 0.00248600539744195, 0.00240424074581543, 0.00232429847476965, 0.00224615765161235, 0.00216979719590176, 0.00209519588879822, 0.00202233238233982, 0.00195118520863972, 0.00188173278900219, 0.00181395344295526, 0.00174782539719726, 0.00168332679445463, 0.00162043570224888, 0.00155913012157038, 0.00149938799545657, 0.00144118721747263, 0.00138450564009229, 0.00132932108297671, 0.0012756113411495, 0.00122335419306611, 0.00117252740857603, 0.00112310875677614, 0.00107507601375273, 0.00102840697021075, 0.000983079438987702, 0.000939071262450735, 0.000896360319776466, 0.000854924534112323, 0.000814741879618302, 0.000775790388386483, 0.000738048157239103, 0.000701493354402197, 0.000666104226056256, 0.0006318591027599, 0.000598736405749827, 0.000566714653112681, 0.000535772465828126, 0.0005058885736791, 0.000477041821032692, 0.000449211172486597, 0.000422375718392199, 0.000396514680243614, 0.000371607415924036, 0.000347633424800168, 0.000324572352684389, 0.000302403996677747, 0.000281108309896815, 0.000260665406067916, 0.000241055564008215, 0.000222259231989128, 0.000204257032042673, 0.000187029763809451, 0.000170558407871601 };

  return dpss_3;
}

double[] dpss_4_1024() {
  double [] dpss_4 = {
    0.000848103672987477, 0.000912007028590408, 0.000978108113269016, 0.00104644043177421, 0.00111703722640186, 0.00118993149117766, 0.00126515596180556, 0.00134274310027819, 0.00142272507675994, 0.00150513375331608, 0.00159000066630987, 0.00167735700977021, 0.00176723361777411, 0.00185966094705107, 0.00195466905932057, 0.00205228760357799, 0.00215254579825811, 0.00225547241349585, 0.00236109575343905, 0.00246944363833007, 0.00258054338654027, 0.00269442179655514, 0.00281110512898277, 0.00293061908860288, 0.00305298880638726, 0.00317823882147502, 0.00330639306314648, 0.00343747483288303, 0.00357150678649453, 0.00370851091633357, 0.00384850853356019, 0.00399152025044146, 0.00413756596271831, 0.00428666483205929, 0.00443883526861133, 0.00459409491367697, 0.00475246062249429, 0.00491394844712185, 0.00507857361946485, 0.00524635053444385, 0.00541729273332376, 0.00559141288720786, 0.00576872278069952, 0.00594923329573357, 0.00613295439557735, 0.00631989510902808, 0.00651006351480405, 0.00670346672614094, 0.00690011087560748, 0.00710000110013321, 0.00730314152626058, 0.0075095352556331, 0.00771918435072603, 0.00793208982083115, 0.00814825160830699, 0.00836766857510666, 0.00859033848958339, 0.00881625801358319, 0.0090454226898333, 0.0092778269296316, 0.00951346400084504, 0.00975232601623247, 0.00999440392209917, 0.0102396874872849, 0.0104881652924971, 0.0107398247199984, 0.0109946519436514, 0.0112526319193294, 0.0115137483756997, 0.0117779838053905, 0.0120453194565429, 0.0123157353247544, 0.012589210145423, 0.0128657213864978, 0.013145245241643, 0.0134277566238197, 0.0137132291592954, 0.0140016351820883, 0.0142929457288503, 0.0145871305341938, 0.0148841580264696, 0.015183995324, 0.0154866082317737, 0.0157919612386072, 0.0161000175147762, 0.0164107389101252, 0.0167240859526578, 0.0170400178476144, 0.0173584924770428, 0.0176794663998645, 0.0180028948524421, 0.0183287317496502, 0.0186569296864549, 0.018987439940004, 0.0193202124722343, 0.0196551959329986, 0.0199923376637132, 0.0203315837015307, 0.0206728787840384, 0.0210161663544888, 0.021361388567562, 0.0217084862956627, 0.0220573991357548, 0.0224080654167326, 0.0227604222073319, 0.023114405324582, 0.023469949342799, 0.0238269876031225, 0.0241854522235951, 0.0245452741097859, 0.0249063829659591, 0.0252687073067857, 0.0256321744696002, 0.0259967106271998, 0.0263622408011877, 0.0267286888758563, 0.0270959776126125, 0.0274640286649421, 0.0278327625939121, 0.0282020988842091, 0.0285719559607116, 0.0289422512055952, 0.0293129009759668, 0.0296838206220254, 0.0300549245057463, 0.0304261260200853, 0.0307973376087, 0.0311684707861842, 0.0315394361588119, 0.0319101434457872, 0.0322805015009938, 0.032650418335242, 0.0330198011390061, 0.0333885563056485, 0.033756589455125, 0.034123805458166, 0.0344901084609273, 0.0348554019101054, 0.0352195885785109, 0.0355825705910939, 0.0359442494514134, 0.0363045260685455, 0.0366633007844223, 0.0370204734015945, 0.0373759432114115, 0.0377296090226089, 0.0380813691902962, 0.0384311216453383, 0.0387787639241201, 0.0391241931986876, 0.0394673063072552, 0.0398079997850711, 0.0401461698956307, 0.0404817126622294, 0.0408145238998452, 0.0411444992473415, 0.0414715341999792, 0.0417955241422293, 0.0421163643808743, 0.0424339501783897, 0.0427481767865928, 0.0430589394805502, 0.0433661335927317, 0.043669654547399, 0.0439693978952195, 0.0442652593480923, 0.0445571348141758, 0.0448449204331044, 0.0451285126113826, 0.0454078080579442, 0.0456827038198654, 0.0459530973182181, 0.0462188863840519, 0.0464799692944922, 0.0467362448089404, 0.0469876122053648, 0.0472339713166691, 0.0474752225671255, 0.0477112670088573, 0.0479420063583618, 0.0481673430330555, 0.0483871801878316, 0.0486014217516145, 0.0488099724638989, 0.0490127379112585, 0.0492096245638129, 0.0494005398116361, 0.0495853920010949, 0.0497640904711025, 0.0499365455892727, 0.050102668787963, 0.0502623726001895, 0.0504155706954025, 0.0505621779151063, 0.0507021103083112, 0.0508352851668023, 0.0509616210602116, 0.0510810378708789, 0.0511934568284883, 0.0512988005444642, 0.051396993046116, 0.051487959810514, 0.051571627798085, 0.0516479254859125, 0.051716782900728, 0.0517781316515791, 0.0518319049621607, 0.0518780377027966, 0.0519164664220553, 0.0519471293779889, 0.0519699665689802, 0.0519849197641848, 0.0519919325335546, 0.0519909502774298, 0.0519819202556854, 0.0519647916164208, 0.0519395154241767, 0.0519060446876696, 0.0518643343870283, 0.0518143415005224, 0.0517560250307676, 0.0516893460303974, 0.0516142676271882, 0.0515307550486254, 0.0514387756458994, 0.0513382989173188, 0.0512292965311292, 0.0511117423477277, 0.0509856124412593, 0.0508508851205862, 0.0507075409496185, 0.0505555627669945, 0.0503949357051023, 0.0502256472084303, 0.0500476870512376, 0.0498610473545343, 0.0496657226023616, 0.0494617096573624, 0.0492490077756331, 0.0490276186208476, 0.0487975462776451, 0.0485587972642719, 0.0483113805444702, 0.0480553075386059, 0.0477905921340253, 0.0475172506946371, 0.0472353020697081, 0.0469447676018694, 0.0466456711343238, 0.0463380390172483, 0.0460219001133871, 0.0456972858028262, 0.0453642299869476, 0.0450227690915539, 0.0446729420691612, 0.0443147904004546, 0.0439483580949007, 0.0435736916905145, 0.0431908402527756, 0.0427998553726915, 0.0424007911640025, 0.0419937042595275, 0.0415786538066465, 0.0411557014619183, 0.0407249113848312, 0.040286350230684, 0.0398400871425971, 0.0393861937426523, 0.0389247441221602, 0.0384558148310545, 0.0379794848664147, 0.0374958356601153, 0.0370049510656034, 0.0365069173438049, 0.0360018231481615, 0.0354897595087984, 0.0349708198158258, 0.0344450998017757, 0.0339126975231771, 0.0333737133412712, 0.0328282499018716, 0.0322764121143713, 0.0317183071299017, 0.0311540443186465, 0.0305837352463161, 0.0300074936497868, 0.0294254354119097, 0.028837678535495, 0.0282443431164783, 0.0276455513162735, 0.0270414273333199, 0.0264320973738305, 0.0258176896217473, 0.0251983342079125, 0.0245741631784622, 0.0239453104624511, 0.023311911838717, 0.0226741049019929, 0.0220320290282768, 0.0213858253394677, 0.0207356366672774, 0.0200816075164285, 0.0194238840271488, 0.0187626139369722, 0.0180979465418568, 0.0174300326566327, 0.0167590245747883, 0.0160850760276099, 0.0154083421426842, 0.0147289794017763, 0.0140471455980973, 0.0133629997929721, 0.0126767022719217, 0.0119884145001736, 0.011298299077612, 0.0106065196931842, 0.00991324107877523, 0.00921862896256594, 0.00852285002188876, 0.00782607183559592, 0.00712846283595532, 0.00643019226008887, 0.00573143010096921, 0.00503234705799011, 0.0043331144871266, 0.00363390435070077, 0.0029348891667695, 0.00223624195815059, 0.00153813620110388, 0.000840745773684015, 0.000144244903781944, -0.000551191883127715, -0.00124538981651619, -0.00193817393358946, -0.002629369132319, -0.00331880022469658, -0.00400629199019529, -0.00469166922941871, -0.00537475681792032, -0.00605537976017449, -0.00673336324368117, -0.00740853269318536, -0.00808071382499328, -0.00874973270136626, -0.00941541578497395, -0.0100775899933879, -0.0107360827535963, -0.0113907220565221, -0.0120413365115238, -0.0126877554008614, -0.0133298087341079, -0.0139673273024872, -0.0146001427331189, -0.0152280875431522, -0.0158509951937682, -0.0164687001440325, -0.0170810379045784, -0.0176878450911018, -0.0182889594776494, -0.0188842200496796, -0.0194734670568781, -0.0200565420657096, -0.0206332880116849, -0.0212035492513269, -0.0217671716138146, -0.0223240024522871, -0.0228738906947897, -0.0234166868948419, -0.0239522432816102, -0.0244804138096662, -0.025001054208313, -0.02551402203046, -0.0260191767010299, -0.0265163795648782, -0.0270054939342088, -0.0274863851354674, -0.027958920555695, -0.0284229696883248, -0.0288784041784049, -0.0293250978672294, -0.0297629268363623, -0.0301917694510361, -0.0306115064029098, -0.0310220207521688, -0.0314231979689525, -0.0318149259740913, -0.0321970951791398, -0.0325695985256888, -0.0329323315239422, -0.0332851922905432, -0.0336280815856358, -0.0339609028491457, -0.0342835622362685, -0.0345959686521493, -0.0348980337857408, -0.0351896721428272, -0.0354708010781995, -0.0357413408269699, -0.0360012145350126, -0.0362503482885201, -0.0364886711426596, -0.0367161151493226, -0.0369326153839517, -0.0371381099714372, -0.0373325401110705, -0.0375158501005447, -0.0376879873589924, -0.0378489024490508, -0.0379985490979444, -0.038136884217577, -0.0382638679236232, -0.038379463553612, -0.0384836376839942, -0.0385763601461852, -0.0386576040415772, -0.0387273457555127, -0.0387855649702132, -0.038832244676657, -0.0388673711853994, -0.0388909341363315, -0.0389029265073704, -0.0389033446220777, -0.0388921881562012, -0.0388694601431358, -0.0388351669783006, -0.0387893184224287, -0.0387319276037659, -0.0386630110191783, -0.038582588534164, -0.0384906833817689, -0.0383873221604051, -0.0382725348305708, -0.0381463547104714, -0.0380088184705416, -0.0378599661268694, -0.0376998410335216, -0.0375284898737733, -0.0373459626502419, -0.037152312673928, -0.0369475965521656, -0.0367318741754845, -0.0365052087033864, -0.0362676665490415, -0.0360193173629056, -0.035760234015265, -0.0354904925777128, -0.0352101723035613, -0.0349193556071966, -0.034618128042381, -0.0343065782795097, -0.0339847980818279, -0.0336528822806159, -0.033310928749349, -0.0329590383768406, -0.0325973150393761, -0.032225865571847, -0.0318447997378925, -0.031454230199059, -0.0310542724829879, -0.0306450449506394, -0.0302266687625645, -0.0297992678442355, -0.029362968850445, -0.0289179011287869, -0.0284641966822283, -0.0280019901307868, -0.0275314186723244, -0.0270526220424709, -0.0265657424736894, -0.0260709246534989, -0.0255683156818651, -0.0250580650277754, -0.0245403244850119, -0.0240152481271366, -0.0234829922617032, -0.0229437153837123, -0.0223975781283238, -0.021844743222843, -0.0212853754379959, -0.0207196415385108, -0.0201477102330218, -0.0195697521233114, -0.0189859396529092, -0.0183964470550637, -0.0178014503001053, -0.0172011270422174, -0.0165956565656346, -0.0159852197302843, -0.0153699989168929, -0.0147501779715719, -0.0141259421499055, -0.0134974780605567, -0.0128649736084117, -0.012228617937282, -0.0115886013721838, -0.0109451153612133, -0.0102983524170394, -0.00964850605803219, -0.00899577074904794, -0.00834034184189068, -0.0076824155154706, -0.00702218871567975, -0.00635985909500535, -0.00569562495190167, -0.00502968516994084, -0.00436223915676357, -0.00369348678285065, -0.00302362832013606, -0.00235286438048275, -0.00168139585404217, -0.00100942384751858, -0.000337149622359211, 0.000335225467108428, 0.00100750003557111, 0.001679472728635, 0.00235094228472017, 0.00302170759692337, 0.00369156777482782, 0.00436032220623892, 0.00502777061882469, 0.00569371314164002, 0.00635795036651348, 0.00702028340927596, 0.00768051397081, 0.00833844439789909, 0.00899387774385604, 0.00964661782890978, 0.0102964693003299, 0.0109432376922686, 0.0115867294852989, 0.0122267521656305, 0.0128631142839809, 0.0134956255140834, 0.0141240967108117, 0.0147483399679008, 0.015368168675245, 0.0159833975757536, 0.0165938428217454, 0.0171993220308613, 0.0177996543414783, 0.0183946604676044, 0.0189841627532364, 0.0195679852261628, 0.0201459536511927, 0.0207178955827933, 0.0212836404171185, 0.0218430194434103, 0.022395865894757, 0.0229420149981899, 0.0234813040241023, 0.0240135723349744, 0.024538661433388, 0.0250564150093143, 0.0255666789866599, 0.0260693015690552, 0.0265641332848699, 0.0270510270314409, 0.0275298381184982, 0.028000424310774, 0.0284626458697819, 0.0289163655947512, 0.0293614488627046, 0.0297977636676648, 0.0302251806589782, 0.0306435731787429, 0.0310528172983294, 0.0314527918539815, 0.0318433784814869, 0.0322244616499056, 0.0325959286943464, 0.0329576698477802, 0.0333095782718809, 0.0336515500868838, 0.0339834844004525, 0.0343052833355455, 0.0346168520572737, 0.0349180987987407, 0.0352089348858583, 0.0354892747611298, 0.0357590360063942, 0.036018139364524, 0.0362665087600713, 0.0365040713188558, 0.0367307573864889, 0.0369465005458301, 0.0371512376333692, 0.0373449087545313, 0.0375274572979005, 0.0376988299483586, 0.0378589766991349, 0.0380078508627663, 0.0381454090809632, 0.0382716113333816, 0.0383864209452967, 0.038489804594181, 0.038581732315182, 0.0386621775055021, 0.0387311169276793, 0.0387885307117698, 0.038834402356433, 0.03886871872892, 0.0388914700639679, 0.0389026499616011, 0.0389022553838428, 0.0388902866503389, 0.0388667474328977, 0.0388316447489491, 0.038784988953927, 0.0387267937325798, 0.038657076089213, 0.0385758563368698, 0.0384831580854544, 0.0383790082288046, 0.038263436930719, 0.0381364776099468, 0.0379981669241451, 0.0378485447528132, 0.0376876541792102, 0.037515541471264, 0.0373322560614808, 0.0371378505258632, 0.0369323805618465, 0.0367159049652613, 0.0364884856063347, 0.0362501874047376, 0.0360010783036897, 0.0357412292431332, 0.0354707141319854, 0.0351896098194821, 0.0348979960656235, 0.0345959555107343, 0.0342835736441501, 0.0339609387720434, 0.0336281419844015, 0.0332852771211694, 0.032932440737571, 0.0325697320686232, 0.0321972529928555, 0.0318151079952504, 0.0314234041294183, 0.0310222509790223, 0.0306117606184671, 0.0301920475728679, 0.0297632287773142, 0.0293254235354439, 0.0288787534773448, 0.0284233425167983, 0.0279593168078814, 0.0274868047009449, 0.0270059366979837, 0.0265168454074146, 0.026019665498282, 0.0255145336539044, 0.0250015885249832, 0.024480970682188, 0.0239528225682384, 0.0234172884494984, 0.0228745143671029, 0.0223246480876327, 0.0217678390533574, 0.0212042383320647, 0.0206339985664926, 0.0200572739233856, 0.0194742200421916, 0.018884993983419, 0.0182897541766727, 0.0176886603683873, 0.0170818735692776, 0.0164695560015236, 0.0158518710457107, 0.0152289831875429, 0.0146010579643493, 0.0139682619114011, 0.0133307625080606, 0.0126887281237792, 0.0120423279639655, 0.0113917320157402, 0.0107371109936003, 0.0100786362850076, 0.00941647989592445, 0.00875081439631312, 0.00808181286561887, 0.00740964883825576, 0.0067344962491138, 0.00605652937910654, 0.00537592280077758, 0.00469285132398504, 0.00400748994168235, 0.00332001377581417, 0.00263059802334559, 0.00193941790244334, 0.00124664859882688, 0.000552465212307697, -0.000142957296465243, -0.000839444159035952, -0.00153682085193015, -0.00223491314918459, -0.00293354717459953, -0.0036325494536971, -0.00433174696536837, -0.00503096719319219, -0.00573003817640897, -0.00642878856053292, -0.00712704764758603, -0.00782464544593791, -0.00852141271973509, -0.00921718103790435, -0.00991178282271409, -0.0106050513978785, -0.0112968210361894, -0.0119869270066598, -0.0126752056211666, -0.0133614942805755, -0.0140456315203348, -0.0147274570555249, -0.0154068118253479, -0.0160835380370455, -0.0167574792092308, -0.017428480214621, -0.0180963873221587, -0.0187610482385096, -0.0194223121489228, -0.020080029757444, -0.020734053326468, -0.0213842367156203, -0.0220304354199558, -0.0226725066074652, -0.0233103091558764, -0.0239437036887429, -0.024572552610808, -0.025196720142635, -0.025816072354495, -0.0264304771995027, -0.027039804545992, -0.0276439262091219, -0.0282427159817064, -0.0288360496642586, -0.0294238050942435, -0.030005862174531, -0.030582102901043, -0.0311524113895878, -0.0317166739018764, -0.0322747788707134, -0.032826616924359, -0.0333720809100548, -0.0339110659167109, -0.0344434692967479, -0.0349691906870898, -0.0354881320293053, -0.0360001975888932, -0.0365052939737075, -0.0370033301515219, -0.0374942174667289, -0.0379778696561729, -0.0384542028641141, -0.0389231356563232, -0.0393845890333042, -0.039838486442646, -0.0402847537905005, -0.0407233194521886, -0.041154114281933, -0.041577071621719, -0.0419921273092842, -0.0423992196852373, -0.0427982895993083, -0.043189280415732, -0.0435721380177653, -0.0439468108113435, -0.0443132497278748, -0.0446714082261792, -0.0450212422935724, -0.0453627104461005, -0.0456957737279275, -0.046020395709882, -0.0463365424871648, -0.0466441826762251, -0.046943287410808, -0.0472338303371804, -0.0475157876085409, -0.0477891378786172, -0.0480538622944613, -0.0483099444884449, -0.0485573705694646, -0.0487961291133626, -0.0490262111525707, -0.0492476101649845, -0.0494603220620771, -0.0496643451762586, -0.0498596802474903, -0.0500463304091634, -0.0502243011732483, -0.0503936004147263, -0.0505542383553109, -0.0507062275464698, -0.0508495828517559, -0.0509843214284583, -0.0511104627085833, -0.0512280283791742, -0.0513370423619832, -0.0514375307925034, -0.051529521998374, -0.0516130464771675, -0.051688136873573, -0.0517548279559841, -0.0518131565925052, -0.0518631617263864, -0.0519048843509002, -0.0519383674836713, -0.0519636561404724, -0.0519807973084971, -0.0519898399191251, -0.0519908348201895, -0.0519838347477606, -0.0519688942974583, -0.0519460698953071, -0.0519154197681452, -0.0518770039136036, -0.0518308840696645, -0.0517771236838167, -0.0517157878818178, -0.051646943436079, -0.0515706587336858, -0.0514870037440669, -0.0513960499863275, -0.0512978704962588, -0.0511925397930382, -0.0510801338456349, -0.0509607300389341, -0.0508344071395935, -0.050701245261647, -0.0505613258318698, -0.0504147315549177, -0.0502615463782558, -0.0501018554568908, -0.0499357451179197, -0.0497633028249105, -0.0495846171421278, -0.0493997776986183, -0.0492088751521695, -0.0490120011531556, -0.0488092483082858, -0.0486007101442658, -0.0483864810713907, -0.048166656347079, -0.0479413320393644, -0.0477106049903575, -0.0474745727796921, -0.0472333336879686, -0.0469869866602091, -0.0467356312693371, -0.0464793676796951, -0.0462182966106131, -0.0459525193000423, -0.045682137468265, -0.0454072532816957, -0.0451279693167844, -0.0448443885240355, -0.044556614192155, -0.0442647499123383, -0.0439688995427114, -0.0436691671729369, -0.0433656570889977, -0.0430584737381696, -0.0427477216941951, -0.0424335056226702, -0.0421159302466555, -0.0417951003125221, -0.0414711205560456, -0.0411440956687564, -0.0408141302645598, -0.0404813288466345, -0.040145795774621, -0.0398076352321104, -0.0394669511944425, -0.0391238473968254, -0.0387784273027833, -0.0384307940729443, -0.0380810505341767, -0.037729299149082, -0.0373756419858555, -0.0370201806885216, -0.0366630164475541, -0.0363042499708878, -0.0359439814553323, -0.0355823105583923, -0.0352193363705051, -0.034855157387702, -0.034489871484699, -0.0341235758884269, -0.0337563671520047, -0.0333883411291657, -0.0330195929491408, -0.0326502169920067, -0.0322803068645035, -0.0319099553763288, -0.0315392545169114, -0.0311682954326725, -0.0307971684047772, -0.0304259628273832, -0.0300547671863891, -0.0296836690386889, -0.0293127549919356, -0.0289421106848188, -0.0285718207678583, -0.0282019688847185, -0.0278326376540467, -0.0274639086518386, -0.0270958623943331, -0.0267285783214384, -0.0263621347806921, -0.0259966090117559, -0.0256320771314493, -0.0252686141193223, -0.0249062938037705, -0.0245451888486907, -0.0241853707406804, -0.0238269097767801, -0.0234698750527597, -0.0231143344519488, -0.0227603546346124, -0.02240800102787, -0.0220573378161585, -0.0217084279322385, -0.0213613330487414, -0.0210161135702589, -0.020672828625972, -0.0203315360628174, -0.0199922924391899, -0.0196551530191797, -0.019320171767342, -0.0189874013439966, -0.0186568931010531, -0.0183286970783601, -0.0180028620005752, -0.0176794352745531, -0.0173584629872492, -0.0170399899041335, -0.0167240594681137, -0.0164107137989622, -0.0160999936932441, -0.0157919386247402, -0.0154865867453635, -0.015183974886562, -0.0148841385612056, -0.0145871119659513, -0.0142929279840804, -0.0140016181888028, -0.0137132128470246, -0.0134277409235742, -0.0131452300858759, -0.0128657067090688, -0.0125891958815649, -0.0123157214110397, -0.0120453058308488, -0.0117779704068644, -0.0115137351447245, -0.0112526187974874, -0.0109946388736849, -0.0107398116457711, -0.0104881521589584, -0.010239674240432, -0.00999439050893755, -0.00975231238473661, -0.0095134500999208, -0.00927781270907894, -0.0090454081003044, -0.00881624300653716, -0.00859032301723725, -0.00836765259038323, -0.00814823506478099, -0.00793207267267685, -0.00771916655266947, -0.00750951676290788, -0.00730312229456691, -0.00709998108559194, -0.00690009003470575, -0.00670344501567445, -0.00651004089182517, -0.00631987153080846, -0.00613292981959028, -0.00594920767966256, -0.0057686960824685, -0.0055913850650454, -0.00541726374586811, -0.00524632034088067, -0.00507854217970238, -0.00491391572199875, -0.0047524265740126, -0.00459405950525699, -0.00443879846536137, -0.00428662660105154, -0.00413752627326042, -0.00399147907434039, -0.00384846584540481, -0.00370846669376386, -0.00357146101042775, -0.00343742748771557, -0.00330634413696253, -0.00317818830632705, -0.00305293669866934, -0.00293056538952799, -0.00281104984515715, -0.00269436494058525, -0.0025804849776592, -0.00246938370313898, -0.00236103432676229, -0.00225540953925672, -0.00215248153035042, -0.00205222200671754, -0.00195460220995711, -0.00185959293466734, -0.00176716454626127, -0.00167728699883704, -0.00158992985301097, -0.00150506229387845, -0.00142265314860226, -0.00134267090417137, -0.0012650837253752, -0.00118985947102634, -0.00111696570908969, -0.00104636973035358, -0.00097803856680994, -0.000911939017269967, -0.000848037697387819};

  return dpss_4;
}

double[] dpss_5_1024() {
  double [] dpss_5 = {
    0.00345260126582403, 0.00364412166751947, 0.00384004909358614, 0.00404039657855438, 0.0042451755527743, 0.00445439581939298, 0.00466806553162162, 0.00488619117040295, 0.00510877752255535, 0.00533582765949109, 0.00556734291649212, 0.00580332287256852, 0.00604376533091442, 0.00628866629998062, 0.00653801997515756, 0.00679181872108958, 0.00705005305463586, 0.00731271162849757, 0.00757978121551595, 0.00785124669365868, 0.00812709103170428, 0.00840729527563536, 0.00869183853575341, 0.00898069797452703, 0.00927384879518362, 0.00957126423105393, 0.00987291553568272, 0.0101787719737151, 0.010488800812568, 0.0108029673148982, 0.011121234731875, 0.0114435642972677, 0.0117699152223582, 0.0121002446916848, 0.0124345078596281, 0.0127726578478445, 0.0131146457435566, 0.0134604205987064, 0.0138099294299794, 0.0141631172197046, 0.0145199269176387, 0.0148802994436388, 0.0152441736912297, 0.0156114865320703, 0.0159821728213253, 0.0163561654039443, 0.016733395121854, 0.0171137908220666, 0.0174972793657068, 0.0178837856379615, 0.0182732325589532, 0.0186655410955401, 0.0190606302740427, 0.0194584171939011, 0.0198588170422595, 0.0202617431094829, 0.020667106805601, 0.0210748176776832, 0.0214847834281405, 0.0218969099339544, 0.0223111012668308, 0.0227272597142766, 0.0231452858015957, 0.0235650783148025, 0.0239865343244483, 0.0244095492103566, 0.0248340166872637, 0.0252598288313586, 0.0256868761077179, 0.0261150473986289, 0.0265442300327956, 0.0269743098154211, 0.0274051710591575, 0.0278366966159188, 0.0282687679095466, 0.0287012649693207, 0.0291340664643069, 0.0295670497385309, 0.030000090846971, 0.0304330645923571, 0.0308658445627675, 0.0312983031700112, 0.0317303116887854, 0.0321617402965956, 0.0325924581144273, 0.033022333248155, 0.0334512328306781, 0.0338790230647673, 0.0343055692666106, 0.0347307359100431, 0.0351543866714459, 0.0355763844753008, 0.0359965915403839, 0.036414869426583, 0.0368310790823235, 0.037245080892585, 0.0376567347274933, 0.0380658999914696, 0.0384724356729203, 0.0388762003944493, 0.039277052463574, 0.0396748499239286, 0.0400694506069331, 0.0404607121839117, 0.0408484922186396, 0.0412326482202986, 0.0416130376968225, 0.0419895182086117, 0.0423619474225955, 0.0427301831666229, 0.04309408348416, 0.0434535066892727, 0.0438083114218735, 0.0441583567032105, 0.0445035019915768, 0.0448436072382175, 0.0451785329434131, 0.0455081402127151, 0.045832290813313, 0.0461508472305076, 0.0464636727242689, 0.0467706313858554, 0.0470715881944701, 0.047366409073931, 0.0476549609493313, 0.0479371118036669, 0.0482127307344049, 0.0484816880099717, 0.0487438551261352, 0.0489991048622563, 0.0492473113373867, 0.0494883500661884, 0.0497220980146495, 0.0499484336555732, 0.0501672370238146, 0.0503783897712415, 0.0505817752213937, 0.0507772784238184, 0.0509647862080542, 0.0511441872372423, 0.0513153720613385, 0.0514782331699027, 0.0516326650444407, 0.0517785642102754, 0.0519158292879221, 0.0520443610439442, 0.052164062441266, 0.0522748386889175, 0.0523765972911894, 0.0524692480961725, 0.0525527033436602, 0.0526268777123892, 0.0526916883665969, 0.052747055001871, 0.0527928998902702, 0.0528291479246919, 0.0528557266624664, 0.0528725663681541, 0.0528796000555244, 0.0528767635286951, 0.0528639954224108, 0.0528412372414386, 0.0528084333990614, 0.0527655312546481, 0.0527124811502795, 0.0526492364464116, 0.052575753556556, 0.0524919919809576, 0.052397914339252, 0.0522934864020833, 0.0521786771216642, 0.0520534586612607, 0.0519178064235841, 0.0517716990780734, 0.0516151185870505, 0.0514480502307338, 0.0512704826310926, 0.0510824077745279, 0.0508838210333639, 0.0506747211861376, 0.0504551104366689, 0.0502249944319017, 0.0499843822784996, 0.0497332865581851, 0.0494717233418101, 0.0491997122021451, 0.0489172762253767, 0.0486244420213026, 0.0483212397322134, 0.0480077030404517, 0.0476838691746396, 0.0473497789145657, 0.0470054765947234, 0.0466510101064931, 0.0462864308989608, 0.0459117939783676, 0.0455271579061826, 0.0451325847957952, 0.0447281403078216, 0.0443138936440203, 0.0438899175398143, 0.0434562882554159, 0.0430130855655519, 0.0425603927477871, 0.0420982965694446, 0.0416268872731228, 0.0411462585608076, 0.0406565075765812, 0.0401577348879284, 0.0396500444656412, 0.0391335436623245, 0.0386083431895056, 0.0380745570933506, 0.0375323027289917, 0.0369817007334701, 0.0364228749972993, 0.035855952634655, 0.0352810639521975, 0.0346983424165339, 0.0341079246203269, 0.0335099502470597, 0.032904562034464, 0.0322919057366219, 0.0316721300847509, 0.031045386746682, 0.0304118302850432, 0.0297716181141591, 0.0291249104556792, 0.0284718702929476, 0.0278126633241275, 0.0271474579140943, 0.0264764250451127, 0.0257997382663114, 0.0251175736419721, 0.0244301096986487, 0.0237375273711338, 0.0230400099472889, 0.0223377430117569, 0.021630914388575, 0.0209197140827066, 0.0202043342205126, 0.0194849689891797, 0.0187618145751297, 0.0180350691014266, 0.0173049325642063, 0.0165716067681484, 0.0158352952610144, 0.0150962032672727, 0.0143545376208369, 0.0136105066969371, 0.0128643203431523, 0.012116189809626, 0.0113663276784899, 0.0106149477925236, 0.00986226518307266, 0.00910849599725386, 0.00835385742447336, 0.00759856762228429, 0.00684284564161179, 0.00608691135137273, 0.00533098536251835, 0.00457528895152807, 0.00382004398338309, 0.00306547283404882, 0.00231179831249546, 0.00155924358228605, 0.000808032082762051, 5.83874498564503e-05, -0.000689466563435362, -0.00143530616689626, -0.00217890761320887, -0.0029200472783269, -0.00365850174206503, -0.00439404786887607, -0.00512646288878384, -0.00585552447843993, -0.00658101084227263, -0.00730270079369595, -0.00802037383634666, -0.00873381024531707, -0.0094427911483513, -0.0101470986069726, -0.0108465156975094, -0.0115408265919871, -0.0122298166388538, -0.0129132724435071, -0.0135909819485884, -0.014262734514014, -0.0149283209967091, -0.015587533830012, -0.0162401671027173, -0.0168860166377238, -0.0175248800702572, -0.0181565569256323, -0.0187808486965252, -0.019397558919722, -0.0200064932523123, -0.0206074595472962, -0.021200267928572, -0.0217847308652748, -0.0223606632454331, -0.0229278824489135, -0.0234862084196216, -0.0240354637369294, -0.0245754736862981, -0.0251060663290666, -0.0256270725713754, -0.0261383262321963, -0.0266396641104388, -0.0271309260511046, -0.0276119550104598, -0.0280825971201988, -0.0285427017505697, -0.0289921215724349, -0.0294307126182393, -0.0298583343418582, -0.0302748496772999, -0.030680125096236, -0.0310740306643334, -0.0314564400963632, -0.0318272308100617, -0.0321862839787192, -0.0325334845824713, -0.0328687214582717, -0.0331918873485213, -0.033502878948332, -0.0338015969514034, -0.0340879460944912, -0.0343618352004446, -0.0346231772197949, -0.0348718892708739, -0.0351078926784422, -0.0353311130108109, -0.0355414801154361, -0.0357389281529705, -0.0359233956297538, -0.0360948254287268, -0.0362531648387517, -0.036398365582326, -0.0365303838416723, -0.0366491802831933, -0.0367547200802764, -0.0368469729344363, -0.0369259130947838, -0.036991519375809, -0.0370437751734683, -0.0370826684795663, -0.0371081918944211, -0.0371203426378075, -0.0371191225581667, -0.0371045381400785, -0.0370766005099874, -0.0370353254401774, -0.0369807333509906, -0.0369128493112849, -0.0368317030371274, -0.0367373288887198, -0.0366297658655551, -0.0365090575998014, -0.0363752523479154, -0.0362284029804819, -0.0360685669702831, -0.0358958063785967, -0.0357101878397259, -0.0355117825437645, -0.035300666217599, -0.0350769191041544, -0.0348406259398857, -0.0345918759305233, -0.0343307627250777, -0.0340573843881102, -0.033771843370278, -0.0334742464771624, -0.0331647048363892, -0.0328433338630503, -0.0325102532234396, -0.0321655867971115, -0.0318094626372769, -0.0314420129295478, -0.0310633739490444, -0.030673686015879, -0.030273093449032, -0.0298617445186342, -0.0294397913966734, -0.0290073901061405, -0.0285647004686338, -0.0281118860504395, -0.0276491141071066, -0.0271765555265364, -0.0266943847706062, -0.0262027798153489, -0.0257019220897082, -0.0251919964128934, -0.0246731909303542, -0.0241456970484009, -0.0236097093674922, -0.023065425614215, -0.0225130465719823, -0.0219527760104733, -0.0213848206138425, -0.0208093899077242, -0.0202266961850589, -0.0196369544307702, -0.0190403822453196, -0.0184371997671676, -0.017827629594171, -0.0172118967039451, -0.0165902283732209, -0.0159628540962286, -0.0153300055021368, -0.0146919162715803, -0.0140488220523068, -0.0134009603739755, -0.0127485705621398, -0.0120918936514469, -0.0114311722980873, -0.010766650691529, -0.0100985744655676, -0.00942719060873002, -0.00875274737406326, -0.00807549418834492, -0.00739568156074963, -0.00671356099100706, -0.006029384877087, -0.00534340642244731, -0.00465587954288076, -0.00396705877299701, -0.00327719917237611, -0.00258655623143009, -0.00189538577700938, -0.00120394387779093, -0.000512486749485118, 0.000178729340101669, 0.000869448166111288, 0.00155941364174787, 0.00224836991342418, 0.00293606145590289, 0.00362223316739543, 0.00430663046458083, 0.00498899937750729, 0.00566908664433886, 0.00634663980590993, 0.00702140730005016, 0.00769313855564255, 0.00836158408637737, 0.00902649558416496, 0.00968762601217019, 0.0103447296974319, 0.0109975624230303, 0.011645881519766, 0.0122894459573142, 0.0129280164348173, 0.0135613554708807, 0.0141892274929355, 0.0148113989259321, 0.0154276382803305, 0.0160377162393508, 0.0166414057454501, 0.0172384820859907, 0.0178287229780664, 0.0184119086524508, 0.0189878219366365, 0.0195562483369307, 0.0201169761195744, 0.0206697963908526, 0.0212145031761642, 0.0217508934980188, 0.0222787674529302, 0.0227979282871746, 0.0233081824713843, 0.023809339773946, 0.0243012133331746, 0.0247836197282336, 0.0252563790487736, 0.0257193149632602, 0.0261722547859649, 0.0266150295425916, 0.0270474740345115, 0.0274694269015821, 0.0278807306835236, 0.0282812318798286, 0.0286707810081809, 0.02904923266136, 0.0294164455626077, 0.0297722826194355, 0.0301166109758501, 0.0304493020629766, 0.0307702316480586, 0.0310792798818156, 0.0313763313441383, 0.0316612750881044, 0.0319340046822947, 0.0321944182513958, 0.0324424185150697, 0.0326779128250773, 0.0329008132006382, 0.0331110363620153, 0.0333085037623081, 0.0334931416174435, 0.0336648809343513, 0.0338236575373128, 0.0339694120924727, 0.0341020901305031, 0.0342216420674122, 0.0343280232234867, 0.0344211938403637, 0.0345011190962215, 0.0345677691190856, 0.0346211189982446, 0.0346611487937691, 0.0346878435441322, 0.0347011932719278, 0.0347011929876832, 0.0346878426917663, 0.0346611473743851, 0.0346211170136803, 0.0345677665719124, 0.0345011159897426, 0.0344211901786125, 0.0343280190112236, 0.0342216373101222, 0.0341020848343923, 0.0339694062644642, 0.0338236511850428, 0.0336648740661638, 0.0334931342423858, 0.0333084958901245, 0.0331110280031415, 0.0329008043661948, 0.0326779035268625, 0.0324424087655523, 0.0321944080637073, 0.0319339940702211, 0.0316612640660777, 0.0313763199272275, 0.0310792680857169, 0.0307702194890862, 0.0304492895580521, 0.0301165981424917, 0.0297722694757476, 0.029416432127269, 0.0290492189536119, 0.0286707670478156, 0.0282812176871763, 0.0278807162794398, 0.0274694123074346, 0.0270474592721665, 0.0266150146344004, 0.0261722397547492, 0.0257192998322979, 0.0252563638417839, 0.024783604469362, 0.0243011980469773, 0.0238093244853744, 0.0233081672057691, 0.0227979130702092, 0.0222787523106547, 0.021750878456803, 0.0212144882626905, 0.020669781632099, 0.020116961542797, 0.0195562339696461, 0.0189878078066038, 0.0184118947876536, 0.0178287094066947, 0.0172384688364224, 0.0166413928462322, 0.0160377037191812, 0.0154276261680386, 0.0148113872504601, 0.0141892162833191, 0.0135613447562299, 0.0129280062442969, 0.0122894363201246, 0.0116458724651233, 0.0109975539801468, 0.0103447218954965, 0.00968761888032845, 0.00902648915149927, 0.00836157838188718, 0.00769313360822443, 0.00702140313847789, 0.00634663645881457, 0.00566908414018887, 0.00498899774458858, 0.00430662973097688, 0.00362223336096747, 0.00293606260427007, 0.0022483720439438, 0.00155941678149574, 0.000869452341862075, 0.000178734578309387, -0.000512480422706546, -0.001203936436687, -0.00189537719620422, -0.00258654648594555, -0.0032771882376507, -0.00396704662490473, -0.00465586615774976, -0.00534339177707839, -0.00602936894877194, -0.00671354375754675, -0.00739566300047207, -0.00807547428012297, -0.00875272609733218, -0.00942716794350482, -0.0100985503924602, -0.0107666251917649, -0.0114311453535225, -0.012091865244584, -0.0127485406761444, -0.0134009289926916, -0.0140487891602727, -0.0146918818540438, -0.01532996954507, -0.0159628165863427, -0.0165901892979804, -0.017211856051582, -0.0178275873536982, -0.0184371559283924, -0.0190403367988567, -0.0196369073680544, -0.020226647498357, -0.0208093395901473, -0.0213847686593572, -0.021952722413913, -0.0225129913290579, -0.0230653687215252, -0.0236096508225335, -0.0241456368495769, -0.0246731290769849, -0.0251919329052239, -0.0257018569289169, -0.026202713003555, -0.0266943163108778, -0.0271764854228967, -0.0276490423645407, -0.0281118126749005, -0.028564625467048, -0.0290073134864131, -0.0294397131676925, -0.0298616646902754, -0.0302730120321618, -0.0306736030223583, -0.0310632893917309, -0.0314419268222986, -0.03180937499495, -0.0321654976355671, -0.0325101625595411, -0.0328432417146644, -0.0331646112223855, -0.0334741514174133, -0.0337717468856567, -0.0340572865004897, -0.0343306634573282, -0.0345917753065096, -0.034840523984464, -0.035076815843169, -0.0353005616778775, -0.0355116767531135, -0.0357100808269262, -0.035895698173397, -0.0360684576033943, -0.0362282924835704, -0.0363751407535959, -0.0365089449416298, -0.0366296521780197, -0.0367372142072334, -0.036831587398018, -0.0369127327517863, -0.0369806159092324, -0.0370352071551745, -0.0370764814216294, -0.037104418289118, -0.0371190019862079, -0.0371202213872935, -0.0371080700086217, -0.0370825460025644, -0.0370436521501466, -0.036991395851836, -0.0369257891165994, -0.0368468485492368, -0.0367545953359995, -0.0366490552285022, -0.0365302585259398, -0.0363982400556182, -0.0362530391518109, -0.0360946996329543, -0.0359232697771928, -0.0357388022962875, -0.0355413543079032, -0.0353309873062867, -0.0351077671313532, -0.0348717639361948, -0.0346230521530294, -0.0343617104576049, -0.0340878217320784, -0.0338014730263864, -0.0335027555181267, -0.0331917644709698, -0.0328685991916206, -0.0325333629853501, -0.0321861631101184, -0.0318271107293106, -0.0314563208631073, -0.0310739123385122, -0.0306800077380599, -0.0302747333472268, -0.0298582191005708, -0.0294305985266214, -0.0289920086915477, -0.0285425901416279, -0.0280824868445471, -0.0276118461295483, -0.0271308186264648, -0.0266395582036592, -0.026138221904898, -0.0256269698851874, -0.0251059653456014, -0.0245753744671265, -0.0240353663435563, -0.0234861129134607, -0.0229277888912626, -0.0223605716974491, -0.0217846413879486, -0.0212001805827039, -0.0206073743934707, -0.0200064103508731, -0.0193974783307471, -0.0187807704798021, -0.0181564811406331, -0.0175248067761138, -0.0168859458932033, -0.0162400989661971, -0.0155874683594557, -0.0149282582496418, -0.0142626745474981, -0.0135909248191992, -0.0129132182073093, -0.0122297653513771, -0.0115407783082027, -0.0108464704718067, -0.0101470564931354, -0.00944275219953507, -0.00873377451402575, -0.00802034137441005, -0.0073026716522472, -0.00658098507172594, -0.0058555021284686, -0.00512644400829846, -0.00439403250600304, -0.00365848994412533, -0.00292003909181519, -0.00217890308377281, -0.00143530533931617, -0.000689469481604241, 5.83807429526807e-05, 0.000808021545063893, 0.00155922917267947, 0.00231177999083061, 0.00306545056115834, 0.00382001772110009, 0.00457525866270378, 0.00533095101103929, 0.00608687290217759, 0.00684280306070789, 0.00759852087676359, 0.00835380648252811, 0.00910844082819184, 0.00986220575733191, 0.0106148840816869, 0.0113662596552984, 0.0121161174479929, 0.012864243618176, 0.0136104255849134, 0.0143544520992713, 0.0150961133148922, 0.0158352008577781, 0.0165715078952589, 0.0173048292041193, 0.0180349612378609, 0.0187617021930762, 0.0194848520749103, 0.0202042127615881, 0.0209195880679849, 0.0216307838082175, 0.022337607857236, 0.0230398702113934, 0.0237373830479749, 0.024429960783665, 0.0251174201319342, 0.025799580159326, 0.0264762623406258, 0.0271472906128944, 0.027812491428348, 0.0284716938060688, 0.0291247293825293, 0.0297714324609152, 0.0304116400592317, 0.031045191957178, 0.0316719307417775, 0.032291701851749, 0.0329043536206059, 0.0335097373184733, 0.0341077071926083, 0.0346981205066149, 0.0352808375783414, 0.0358557218164521, 0.0364226397556619, 0.0369814610906265, 0.03753205870848, 0.038074308720012, 0.0386080904894772, 0.0391332866630312, 0.0396497831957877, 0.0401574693774901, 0.0406562378567949, 0.0411459846641618, 0.0416266092333473, 0.0420980144214996, 0.0425601065278518, 0.043012795311013, 0.043455994004855, 0.0438896193329952, 0.0443135915218758, 0.0447278343124397, 0.0451322749704051, 0.0455268442951397, 0.0459114766271388, 0.0462861098541087, 0.0466506854156601, 0.0470051483066153, 0.0473494470789348, 0.0476835338422677, 0.0480073642631323, 0.0483208975627337, 0.048624096513425, 0.0489169274338202, 0.049199360182566, 0.0494713681507828, 0.049732928253182, 0.0499840209178709, 0.0502246300748553, 0.0504547431432492, 0.0506743510172046, 0.0508834480505719, 0.0510820320403034, 0.0512701042086131, 0.0514476691839048, 0.0516147349804836, 0.0517713129770633, 0.0519174178940859, 0.0520530677698663, 0.0521782839355793, 0.0522930909891037, 0.0523975167677398, 0.052491592319817, 0.0525753518752095, 0.0526488328147753, 0.0527120756387386, 0.0527651239340323, 0.0528080243406202, 0.0528408265168159, 0.0528635831036203, 0.0528763496880946, 0.0528791847657906, 0.0528721497022573, 0.0528553086936448, 0.0528287287264259, 0.0527924795362567, 0.0527466335659978, 0.0526912659229165, 0.0526264543350934, 0.0525522791070536, 0.052468823074647, 0.052376171559198, 0.0522744123209485, 0.0521636355118171, 0.0520439336274966, 0.0519154014589145, 0.0517781360430785, 0.0516322366133311, 0.0514778045490376, 0.0513149433247299, 0.0511437584587315, 0.0509643574612866, 0.0507768497822182, 0.0505813467581389, 0.0503779615592386, 0.0501668091356743, 0.0499480061635856, 0.0497216709907596, 0.049487923581972, 0.0492468854640263, 0.0489986796705174, 0.0487434306863427, 0.0484812643919867, 0.0482123080076016, 0.0479366900369102, 0.0476545402109541, 0.0473659894317122, 0.0470711697156133, 0.0467702141369669, 0.0464632567713369, 0.0461504326388814, 0.0458318776476828, 0.0455077285370916, 0.0451781228211079, 0.044843198731824, 0.0445030951629507, 0.0441579516134518, 0.0438079081313079, 0.0434531052574338, 0.0430936839697722, 0.0427297856275839, 0.04236155191596, 0.0419891247905752, 0.0416126464227052, 0.0412322591445302, 0.0408481053947446, 0.0404603276644945, 0.0400690684436639, 0.03967447016753, 0.0392766751638077, 0.0388758256001032, 0.0384720634317963, 0.0380655303503714, 0.0376563677322154, 0.0372447165879016, 0.0368307175119776, 0.036414510633277, 0.0359962355657695, 0.0355760313599707, 0.0351540364549246, 0.0347303886307797, 0.0343052249619712, 0.0338786817710282, 0.0334508945830197, 0.0330219980806562, 0.03259212606006, 0.0321614113872209, 0.0317299859551487, 0.0312979806417395, 0.0308655252683661, 0.0304327485592074, 0.0299997781013284, 0.0295667403055233, 0.0291337603679339, 0.0287009622324528, 0.0282684685539253, 0.0278364006621574, 0.0274048785267419, 0.0269740207227116, 0.0265439443970288, 0.02611476523592, 0.025686597433064, 0.0252595536586414, 0.0248337450292534, 0.0244092810787158, 0.0239862697297365, 0.023564817266481, 0.0231450283080325, 0.0227270057827528, 0.0223108509035461, 0.021896663144034, 0.0214845402156415, 0.0210745780456016, 0.0206668707558785, 0.0202615106430137, 0.0198585881588976, 0.0194581918924663, 0.019060408552328, 0.0186653229503179, 0.0182730179859825, 0.0178835746319945, 0.0174970719204963, 0.0171135869303737, 0.0167331947754558, 0.0163559685936419, 0.0159819795369526, 0.0156112967625023, 0.0152439874243912, 0.0148801166665135, 0.0145197476162779, 0.0141629413792368, 0.0138097570346197, 0.0134602516317659, 0.0131144801874519, 0.0127724956841081, 0.012434349068918, 0.0121000892537953, 0.0117697631162309, 0.0114434155010037, 0.0111210892227471, 0.0108028250693635, 0.0104886618062801, 0.0101786361815366, 0.00987278293169668, 0.00957113478857461, 0.0092737224867672, 0.00898057477198171, 0.00869171841014929, 0.00840717819731535, 0.00812697697029414, 0.00785113561807855, 0.00757967309399167, 0.00731260642857176, 0.00704995074317922, 0.00679171926431504, 0.00653792333863728, 0.00628857244866329, 0.00604367422914129, 0.00580323448407928, 0.00556725720441997, 0.00533574458635749, 0.00510869705026902, 0.0048861132602643, 0.0046679901443228, 0.00445432291499673, 0.00424510509063218, 0.0040403285171, 0.00383998339005341, 0.00364405827764899, 0.0034525401433104};

  return dpss_5;
}
