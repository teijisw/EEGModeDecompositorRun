import java.util.Arrays;
import java.util.Comparator;
import java.util.Random;

//-------------------------------------------------------------------------------
// For Hilbert calculation and Convolution, "JDSP: a library of digital signal processing tools written in Java"
// https://jdsp.dev
// jdsp-0.5.0 was utilized as a jar file.
// jdsp-0.5.0.jar in "code" folder
// https://github.com/psambit9791/jdsp/tree/master
// @software{sambit_paul_2023_7675362,
//  author       = {Sambit Paul and
//                  Sibo Van Gool},
//  title        = {psambit9791/jdsp: v2.0.1 (February 24, 2023)},
//  month        = feb,
//  year         = 2023,
//  publisher    = {Zenodo},
//  version      = {v2.0.1},
//  doi          = {10.5281/zenodo.7675362},
//  url          = {https://doi.org/10.5281/zenodo.7675362}
// }
//-------------------------------------------------------------------------------
import com.github.psambit9791.jdsp.signal.Convolution;
import com.github.psambit9791.jdsp.transform.Hilbert;

// --------------------------------------------------------------
// EMD: Empirical mode decomposition
// --------------------------------------------------------------
// The implementation for Processing using Java package tryout.emd which was build from the following Java code
// https://stackoverflow.com/questions/10230106/is-there-some-empirical-mode-decomposition-library-in-java
// The above code is from C implementation ( https://code.google.com/p/realtime-emd/ ) and translated it to Java.
// --------------------------------------------------------------
import tryout.emd.Emd;
import tryout.emd.EmdDataImpl;

class Emd2 {

  //  signal  - the time domain signal (1D) to be decomposed
  //  K       - the number of modes to be recovered

  double signal2[];
  int K2;


  // Constructor
  Emd2 (double [] _signal, int _K) {
    signal2 = _signal;
    K2 = _K;
  }

  double [][] emd(double [] _signal) {
    signal2 =  _signal;
    Emd emd = new Emd();
    EmdDataImpl emdData = new EmdDataImpl();
    double _imfs[][];

    emd.emdCreate(emdData, signal2.length-15, K2, 20, 0);
    emd.emdDecompose(emdData, signal2);
    _imfs = emd.imfs(emdData);
    //for(int j=0; j<order; j++){
    //    for(int i=0; i<1024; i++){
    //          imfs_float[j][i] = (float) imfs[j][i];
    //    }
    //}
    return _imfs;
  }
}


// --------------------------------------------------------------
// VMD: Variational mode decomposition
// --------------------------------------------------------------
// The implementation for Processing from the following Python code
//  vmdpy: Variational mode decomposition in Python
//  Function for decomposing a signal according to the Variational Mode Decomposition (Dragomiretskiy and Zosso, 2014) method.
//  https://github.com/vrcarva/vmdpy
//  Paper available at: https://doi.org/10.1016/j.bspc.2020.102073
// Vinícius R. Carvalho, Márcio F.D. Moraes, Antônio P. Braga, Eduardo M.A.M. Mendes, Evaluating five different adaptive decomposition methods for EEG signal seizur
// detection and classification, Biomedical Signal Processing and Control, Volume 62, 2020, 102073, ISSN 1746-8094, https://doi.org/10.1016/j.bspc.2020.102073.
// --------------------------------------------------------------

class Vmd {

  //  signal  - the time domain signal (1D) to be decomposed
  //  alpha   - the balancing parameter of the data-fidelity constraint
  //  tau     - time-step of the dual ascent ( pick 0 for noise-slack )
  //  K       - the number of modes to be recovered
  //  DC      - true if the first mode is put and kept at DC (0-freq)
  //  init    - 0 = all omegas start at 0
  //                     1 = all omegas start uniformly distributed
  //                     2 = all omegas initialized randomly
  //  tol     - tolerance of convergence criterion; typically around 1e-6

  double signal2[];
  Complex alpha;
  Complex tau;
  int K;
  int DC;
  int init;
  double tol;
  int N;


  // Constructor
  Vmd (double [] _signal, Complex _alpha, Complex _tau, int _K, int _DC, int _init, double _tol, int _N) {
    signal2 = _signal;
    alpha = _alpha;
    tau = _tau;
    K = _K;
    DC = _DC;
    init = _init;
    tol = _tol;
    N = _N;
  }

  double[][] vmd(double [] _signal) {
    // ---------------------
    //  signal  - the time domain signal (1D) to be decomposed
    //  alpha   - the balancing parameter of the data-fidelity constraint
    //  tau     - time-step of the dual ascent ( pick 0 for noise-slack )
    //  K       - the number of modes to be recovered
    //  DC      - true if the first mode is put and kept at DC (0-freq)
    //  init    - 0 = all omegas start at 0
    //                     1 = all omegas start uniformly distributed
    //                     2 = all omegas initialized randomly
    //  tol     - tolerance of convergence criterion; typically around 1e-6
    //
    //  Output:
    //  -------
    //  u       - the collection of decomposed modes
    //  u_hat   - spectra of the modes
    //  omega   - estimated mode center-frequencies
    //
    // Period and sampling frequency of input signal
    //-----define--------------

    int save_T;
    double fs;
    float T_f;
    int T2_f;
    //Complex alpha= new Complex(2000.0, 0);
    int N2;

    double uDiff = tol + 2.2204e-16; //updata step
    int n=1; //loop counter

    Complex[] freqs_sub;
    Complex[] freqs_square;
    Complex[] freqs_square_sub;
    Complex sum_uk[];
    Complex Alpha[];

    Complex[] f_hat;
    Complex[] f_hat1;
    Complex[] f_hat_plus;
    Complex[] f_hat_plus_sub1;
    Complex[] f_hat_plus_sub2;
    Complex[] f_hat_plus_m1;
    Complex[] f_hat_plus_m2;

    Complex[][] omega;
    Complex[][] omega_plus;
    Complex omega_plus_n2;
    Complex omega_plus_comp;

    Complex[][] lamda_hat;
    Complex[] lamda_hat_n1;
    Complex[] lamda_hat_n2;

    Complex[][] u_hat;
    Complex[][] u_hat2;
    Complex[][] u;
    Complex[][] u_hat_n1;
    Complex[] u_hat_n2;
    Complex[] u_hat_n2_ishift;

    Complex[][][] u_hat_plus;
    Complex[] u_hat_plus_n1;
    Complex[] u_hat_plus_n2;
    Complex[] u_hat_plus_n3;
    Complex[] u_hat_plus_n8;
    Complex[] u_hat_plus_n9;
    Complex[] u_hat_plus_n10;
    Complex[] u_hat_plus_n11;
    Complex[][] u_hat_plus_n17;
    Complex[] u_hat_plus_n18;
    Complex[][] u_hat_plus_n20;
    Complex[] u_hat_plus_conj1;
    Complex[] u_hat_plus_conj2;

    Complex[] u_hat_plus_conj3;
    Complex u_hat_plus_conj4;

    Complex[] fft1_result;
    Complex[][] fft2_result;
    Complex[] fft3_result1;
    Complex[] fft3_result2;
    Complex[] fft3_result3;
    Complex[] fft3_result3_t;

    double f_mirror[];
    double f[];
    double freqs[];

    double freqs_n1[];
    double [][]omega_plus_double;
    double[] u_hat_plus_n4;
    double[] u_hat_plus_n5;
    double u_hat_plus_n6;
    double u_hat_plus_n7;
    double[] u_hat_plus_n12;
    double[] u_hat_plus_n13;
    double[] u_hat_plus_n14;
    double u_hat_plus_n15;
    double u_hat_plus_n16;

    double[][] _u_double;
    double[][] _u_double1;
    double[][] _u_double2;
    double[] u_n1_double;

    //-----memory keep---------
    f_mirror = new double [2*T1];
    //eeg = new double [2*T1];
    f = new double [2*T1];

    freqs = new double [2*T1];
    Alpha = new Complex [K];
    sum_uk = new Complex [2*T1];

    u_hat = new Complex [2*T1][K];
    u_hat2 = new Complex [2*T1][K];
    u_hat_plus = new Complex [N][2*T1][K];
    u_hat_plus_n1 = new Complex [2*T1];
    u_hat_plus_n2 = new Complex [2*T1];
    u_hat_plus_n3 = new Complex [2*T1];
    u_hat_plus_n4 = new double [2*T1];
    u_hat_plus_n5 = new double [2*T1];
    u_hat_plus_n8 = new Complex [2*T1];
    u_hat_plus_n9 = new Complex [2*T1];
    u_hat_plus_n10 = new Complex [2*T1];
    u_hat_plus_n11 = new Complex [2*T1];
    u_hat_plus_n12 = new double [2*T1];
    u_hat_plus_n13 = new double [2*T1];
    u_hat_plus_n14 = new double [2*T1];
    u_hat_plus_n17 = new Complex [2*T1][K];
    u_hat_plus_n18 = new Complex [2*T1];
    u_hat_plus_n20 = new Complex [T1][K];

    f_hat = new Complex [2*T1];
    f_hat1 = new Complex [freqs.length];
    f_hat_plus = new Complex [2*T1];
    f_hat_plus_sub1 = new Complex [2*T1];
    f_hat_plus_sub2 = new Complex [2*T1];
    f_hat_plus_m1 = new Complex [2*T1];
    f_hat_plus_m2 = new Complex [2*T1];

    u = new Complex [K][2*T1];

    _u_double = new double [K][2*T1];
    _u_double1 = new double [K][T1];
    _u_double2 = new double [K][T1];
    u_n1_double = new double [2*T1];
    u_hat_n1 = new Complex [2*T1][K];
    u_hat_n2 = new Complex [2*T1];
    u_hat_n2_ishift = new Complex [2*T1];
    u_hat_plus_conj1 = new Complex [2*T1];
    u_hat_plus_conj2 = new Complex [2*T1];
    u_hat_plus_conj3 = new Complex [2*T1];

    omega = new Complex [N][K];
    omega_plus = new Complex [N][K];
    omega_plus_double = new double [N][K];

    freqs_square_sub = new Complex [2*T1];
    freqs_square = new Complex [2*T1];
    freqs_sub = new Complex [2*T1];
    freqs_n1 =new double [2*T1];

    lamda_hat = new Complex [N][freqs.length];
    lamda_hat_n1 = new Complex [freqs.length];
    lamda_hat_n2 = new Complex [freqs.length];

    fft1_result = new Complex [2*T1];
    fft2_result = new Complex [K][2*T1];
    fft3_result1 = new Complex [2*T1];
    fft3_result2 = new Complex [2*T1];
    fft3_result3 = new Complex [2*T1];
    fft3_result3_t = new Complex [2*T1];

    //---------body--------
    signal2 = _signal;
    save_T = signal2.length; //signal size 1024 to save_T
    fs = 1/(save_T);  //Sampling interval fs is 1/1024

    // extend the signal by mirroring
    // Specifically, the first half of the signal is inverted
    // and added to the beginning of the original signal,
    // and the second half of the signal is inverted and added to the tail of the original signal.
    // Then, signal size is 2048 data points.

    for (int i=0; i<int(T1/2); i++) {
      f_mirror[i] = signal2[int(T1/2)-1-i];
    }
    for (int i=int(T1/2); i<int(3*T1/2); i++) {
      f_mirror[i] = signal2[i-int(T1/2)];
    }
    for (int i=int(3*T1/2); i<int(4*T1/2); i++) {
      f_mirror[i] = signal2[int(T1-1)-(i-int(3*T1/2))];
    }

    //double eeg data: f = f_mirror;
    f = f_mirror;  //Store the mirrored EEG in a new variable f

    // Time Domain 0 to T (of mirrored signal)
    T_f = float(f.length); //Store 2048 mirror extension signal data in T_f

    for (int i=0; i<T_f; i++) {
      t[i] = 1/T_f*(i+1);
    }

    // Spectral Domain discretization freq[]
    for (int i=0; i<T_f; i++) {
      freqs[i] = t[i] - 0.5 - 1/T_f;
    }

    // For future generalizations: individual alpha for each mode
    // penalty factor, balance parameter
    for (int i=0; i<K; i++) {
      Alpha[i] = alpha.multiply(ONE);
    }

    //int N = 500

    // Construct and center f_hat: Fourier transform of the signal
    FastFourierTransformer fft1 = new FastFourierTransformer(DftNormalization.STANDARD);
    fft1_result= fft1.transform(f, TransformType.FORWARD);

    f_hat = fftshift(fft1_result); //Fourier transform result to f_hat with zero frequency component shifted to center of spectrum

    f_hat_plus = f_hat;  //Copy f_hat to f_hat_plus

    for (int i=0; i<int(T_f)/2; i++) {
      f_hat_plus[i] = ZERO;  //Initialize 1-1024 data of f_hat_plus with 0
    }

    // matrix keeping track of every iterant // could be discarded for mem
    for (int i=0; i < N; i++) {
      for (int j=0; j < 2*T1; j++) {
        for (int k=0; k < K; k++) {
          u_hat_plus[i][j][k] = ZERO;  //Create a complex zero array with u_hat_plus.shape:= (500, 2048, 3)
        }
      }
    }

    // Initialization of omega_k
    for (int j = 0; j < N; j++) {
      for (int k = 0; k < K; k++) {
        omega_plus[j][k] = ZERO; //Initialization of frequency variable omega plus
      }
    }

    if (init == 1) {
      for (int i=1; i < K+1; i++) {
        Complex K_comp = new Complex(K, 0);
        Complex i_comp = new Complex(i, 0);
        omega_plus[0][i-1] = (HALF.divide(K_comp)).multiply(i_comp.subtract(ONE));
      }
    } else if (init == 2) {
      for (int k = 0; k < K; k++) {
        Complex random_comp = new Complex(random(1), 0);
        Complex fs_comp = new Complex(fs, 0);
        omega_plus[0][k] = ((fs_comp.log()).exp()).add((HALF.log()).subtract(fs_comp.log()).multiply(random_comp));   //missing sort()
      }
    } else {
      for (int k = 0; k < K; k++) {
        omega_plus[0][k] = ZERO;
      }
    }

    if (DC == 1) {
      omega_plus[0][0] = ZERO;
    }

    // start with empty dual variables  Lagrangian multiplier λ
    for (int i = 0; i < N; i++) {
      for (int j=0; j < freqs.length; j++) {
        lamda_hat[i][j] = ZERO;
      }
    }

    for (int i=0; i<freqs.length; i++) {
      sum_uk[i] = ZERO; //accumulator
    }
    T2_f = int(T_f);

    // ----------- Main loop for iterative updates
    // Update n to minimize u_hat and omega_hat
    // Algorithm 2 Complete optimization of VMD

    while (uDiff > tol && n < N) {
      //Repeat if tolerance of tol convergence criterion is greater than Diff or less than N=2000.
      //if (uDiff > tol) {
      // update first mode accumulator
      int k = 1;

      for (int j=0; j < freqs.length; j++) {
        u_hat_plus_n1[j] = u_hat_plus[n-1][j][K-1];
        u_hat_plus_n2[j] = u_hat_plus[n-1][j][0];
        sum_uk[j] = (u_hat_plus_n1[j].add(sum_uk[j])).subtract(u_hat_plus_n2[j]);
        //update spectrum of first mode through Wiener filter of residuals
        //Wiener filter of residuals 論文の式(27)  u_hat_plus[][][]
        lamda_hat_n1[j] = lamda_hat[n-1][j];
        Complex freqs_comp = new Complex(freqs[j], 0.0);

        //Calculating freqs_square
        freqs_square_sub[j] = freqs_comp.subtract(omega_plus[n-1][k-1]);
        freqs_square[j] = freqs_square_sub[j].multiply(freqs_square_sub[j]);

        //Calculation of u_hat_plus[][][]
        f_hat_plus_sub1[j] =(f_hat_plus[j].subtract(sum_uk[j])).subtract(lamda_hat_n1[j].divide(TWO));
        f_hat_plus_sub2[j] = ONE.add(Alpha[k-1].multiply(freqs_square[j]));
        u_hat_plus[n][j][k-1]=f_hat_plus_sub1[j].divide(f_hat_plus_sub2[j]);
      }

      //update first omega if not held at 0
      //Equation (28) in the paper Substitutes the inner product for the calculation of the integral.

      if (DC == 0) {
        //Computing omega_plus_double[][]
        //np.dot(freqs[T//2:T], (np.square(np.abs(u_hat_plus[n, T//2:T, k-1]))).T)
        //Squared absolute value of u_hat_plus (n=0, last 1024 data, k=0th) and inner product of frequency freqs[T//2:T]
        //np.sum(np.square(np.abs(u_hat_plus[n, T//2:T, k-1])))
        //Sum of squares of absolute values of u_hat_plus(n=0, last 1024 data, k=0th)

        for (int j=0; j < freqs.length/2; j++) {
          freqs_n1[j] = freqs[int(T2_f/2)+j];
          u_hat_plus_n3[j] = u_hat_plus[n][int(T2_f/2)+j][k-1];
          u_hat_plus_n4[j] = ((u_hat_plus_n3[j]).abs())*((u_hat_plus_n3[j]).abs());
        }

        u_hat_plus_n5 = array_transpose_double(u_hat_plus_n4);
        u_hat_plus_n6 = array_sum_double(u_hat_plus_n4);
        u_hat_plus_n7 = array_dot_double(freqs_n1, u_hat_plus_n5);
        omega_plus_double[n][k-1] = u_hat_plus_n7/u_hat_plus_n6;
      }

      for (k=2; k<K+1; k++) {
        //accumulator sum_uk[] calculation
        for (int j=0; j < freqs.length; j++) {
          u_hat_plus_n8[j] = u_hat_plus[n][j][k-2];
          u_hat_plus_n9[j] = u_hat_plus[n-1][j][k-1];

          sum_uk[j] = (u_hat_plus_n8[j].add(sum_uk[j])).subtract(u_hat_plus_n9[j]);

          //mode spectrum //Update u ̂_k for all ω ≥0:
          lamda_hat_n2[j] = lamda_hat[n-1][j];
        }

        omega_plus_n2 = omega_plus[n-1][k-1];

        for (int i=0; i < freqs.length; i++) {
          //double freq =  freqs[i];
          Complex freqs_comp = new Complex(freqs[i], 0.0);
          freqs_sub[i] = freqs_comp.subtract(omega_plus_n2);
          freqs_square[i] = freqs_sub[i].multiply(freqs_sub[i]);
        }

        for (int i=0; i < freqs.length; i++) {
          f_hat1[i] = f_hat_plus[i].subtract(sum_uk[i]);
          f_hat_plus_m1[i] = (f_hat1[i]).subtract(lamda_hat_n2[i].divide(TWO));

          f_hat_plus_m2[i] = (ONE.add(Alpha[k-1].multiply(freqs_square[i])));
          //u_hat_plus k=0, 1, 2 renew
          u_hat_plus[n][i][k-1]= f_hat_plus_m1[i].divide(f_hat_plus_m2[i]);
        }

        //center frequencies Update ω ̂_k:
        for (int j=0; j < freqs.length/2; j++) {
          freqs_n1[j] = freqs[int(T2_f/2)+j];
          u_hat_plus_n10[j] = u_hat_plus[n][int(T2_f/2)+j][k-1];
          u_hat_plus_n11[j] = u_hat_plus[n][int(T2_f/2)+j][k-1];
          u_hat_plus_n12[j] =((u_hat_plus_n10[j]).abs())*(((u_hat_plus_n10[j]).abs()));
        }

        u_hat_plus_n13 = array_transpose_double(u_hat_plus_n12);

        for (int j=0; j < freqs.length/2; j++) {
          u_hat_plus_n14[j] = ((u_hat_plus_n11[j]).abs())*(((u_hat_plus_n11[j]).abs()));
        }

        u_hat_plus_n15 = array_dot_double(freqs_n1, u_hat_plus_n13);
        u_hat_plus_n16 = array_sum_double(u_hat_plus_n14);
        omega_plus_double[n][k-1]=u_hat_plus_n15/u_hat_plus_n16;
        omega_plus[n][k-1] = new Complex(omega_plus_double[n][k-1], 0);

        //Dual ascent
        //Thesis formula (29)

        for (int i=0; i < freqs.length; i++) {
          lamda_hat_n1[i] = lamda_hat[n-1][i];
        }

        for (int i=0; i < freqs.length; i++) {
          for (int j=0; j < K; j++) {
            u_hat_plus_n17[i][j] = u_hat_plus[n][i][j];
          }
          u_hat_plus_n18[i] = ZERO;

          for (int j=0; j < K; j++) {
            u_hat_plus_n18[i] = (u_hat_plus_n18[i]).add(u_hat_plus_n17[i][j]);
          }
          lamda_hat[n][i]=lamda_hat_n1[i].add(tau.multiply(u_hat_plus_n18[i].subtract(f_hat_plus[i])));
        }
      }

      //loop counter Comparison with convergence criteria
      n = n + 1;
      //println("n=:", n);
      //converged yet?
      uDiff = 2.2204e-16;

      for (int i = 1; i < K+1; i++) {
        for (int j = 0; j < freqs.length; j++) {
          u_hat_plus_n1[j] = u_hat_plus[n-1][j][i-1];
          u_hat_plus_n2[j] = u_hat_plus[n-2][j][i-1];
          u_hat_plus_n3[j] = u_hat_plus_n1[j].subtract(u_hat_plus_n2[j]);
          u_hat_plus_conj1[j] = u_hat_plus_n3[j].conjugate();
          u_hat_plus_conj2[j] = u_hat_plus_conj1[j].conjugate();
        }

        u_hat_plus_conj3 = array_transpose(u_hat_plus_conj2);
        u_hat_plus_conj4 = array_dot(u_hat_plus_n3, u_hat_plus_conj3);
        uDiff = uDiff + 1/float(T2_f)* (float)((u_hat_plus_conj4).abs());
      }
      uDiff = abs_double(uDiff);
    }
    println("n=:", n);
    // ------ Postprocessing and cleanup
    // discard empty space if converged early

    N2 = min(N, n);

    for (int i = 0; i < N2; i++) {
      for (int j = 0; j < K; j++) {
        double omega_plus_temp = omega_plus_double[i][j];
        omega_plus_comp = new Complex(omega_plus_temp, 0.0);
        omega_plus[i][j] = omega_plus_comp;
        omega[i][j] = omega_plus[i][j];
      }
    }

    // Signal reconstruction: Calculate IMF from frequency components by inverse Fourier transform
    for (int i=0; i<T2_f; i++) {
      for (int j=0; j<K; j++) {
        u_hat[i][j] = ZERO;
      }
    }

    for (int i=0; i<int(T2_f/2); i++) {
      for (int j=0; j<K; j++) {
        u_hat_plus_n20[i][j]  = u_hat_plus[N2-1][i+ int(T2_f/2)][j];
        u_hat[int(T2_f/2)+i][j]=(u_hat_plus_n20[i][j]);
        u_hat[int(T2_f/2)-i][j]=(u_hat_plus_n20[i][j]).conjugate();
        u_hat_n1[i][j] = u_hat[T2_f-1][j];
        u_hat[0][j]= (u_hat_n1[i][j]).conjugate();
      }
    }

    for (int j=0; j < K; j++) {
      for (int i=0; i< T2_f; i++) {
        u[j][i] = ZERO;
      }
    }

    for (int k=1; k < K+1; k++) {
      for (int i=0; i < T2_f; i++) {
        u_hat_n2[i] = u_hat[i][k-1];
      }

      u_hat_n2_ishift = ifftshift(u_hat_n2);  //reverse shift
      FastFourierTransformer fft2 = new FastFourierTransformer(DftNormalization.STANDARD);
      fft2_result[k-1] = fft2.transform(u_hat_n2_ishift, TransformType.INVERSE);  //inverse Fourier transform

      for (int i=0; i < T2_f; i++) {
        _u_double[k-1][i] = fft2_result[k-1][i].getReal();
        //_u_double[k-1][i] = fft2_result[k-1][i].abs();
      }
    }

    // remove mirror part
    for (int i=0; i<K; i++) {
      for (int j=int(T2_f/4); j<3*int(T2_f/4); j++) {
        _u_double1[i][j-int(T2_f/4)]=_u_double[i][j];
      }
    }

    //recompute spectrum: Obtain the frequency spectrum from the IMF by Fourier transform.　
    for (int i=0; i< int(T2_f); i++) {
      for (int j=0; j<K; j++) {
        u_hat[i][j] = ZERO;
      }
    }

    for (int k=1; k < K+1; k++) {
      for (int i=0; i < int(T2_f); i++) {
        //imfs_float[k-1][i] = (float) _u_double[k-1][i];
        u_n1_double[i] = _u_double[k-1][i];
      }

      FastFourierTransformer fft3 = new FastFourierTransformer(DftNormalization.STANDARD);
      fft3_result1 = fft3.transform(u_n1_double, TransformType.FORWARD);

      fft3_result2 = fftshift(fft3_result1);

      for (int i=0; i< int(T2_f/2); i++) {
        fft3_result3[i] = fft3_result2[i].conjugate();
      }

      fft3_result3_t =array_transpose(fft3_result3);

      for (int i=0; i < int(T2_f/2); i++) {
        u_hat2[i][k-1]= fft3_result3_t[i];
        _u_double2[k-1][i] = u_hat2[i][k-1].abs();
      }
    }

    return _u_double1;
  }
}

public static int[] argsort(final double[] a) {
  return argsort(a, true);
}

public static int[] argsort(double[] a, boolean ascending) {
  Integer[] indexes = new Integer[a.length];
  for (int i = 0; i < indexes.length; i++) {
    indexes[i] = i;
  }
  Arrays.sort(indexes, new Comparator<Integer>() {
    @Override
      public int compare(final Integer i1, final Integer i2) {
      return (ascending ? 1 : -1) * Double.compare(a[i1], a[i2]);
    }
  }
  );
  return asArray(indexes);
}

public static <T extends Number> int[] asArray(final T... a) {
  int[] b = new int[a.length];
  for (int i = 0; i < b.length; i++) {
    b[i] = a[i].intValue();
  }
  return b;
}

float[] array_square(float _array[]) {
  float _array2[];
  _array2 = new float [_array.length];

  for (int i=0; i<_array.length; i++) {
    _array2[i] = _array[i] * _array[i];
  }
  return _array2;
}

Complex[] fftshift(Complex _complex[]) {
  Complex complex2[];
  complex2 = new Complex [_complex.length];
  for (int i=0; i<_complex.length/2; i++) {
    complex2[_complex.length/2+i] = _complex[i];
  }
  for (int i=_complex.length/2; i<_complex.length; i++) {
    complex2[i-_complex.length/2] = _complex[i];
  }
  return complex2;
}

Complex[] ifftshift(Complex _complex[]) {
  Complex complex2[];
  complex2 = new Complex[_complex.length];
  for (int i=0; i<_complex.length/2; i++) {
    complex2[_complex.length/2+i] = _complex[i];
  }
  for (int i=_complex.length/2; i<_complex.length; i++) {
    complex2[i-_complex.length/2] = _complex[i];
  }
  return complex2;
}

double[] fftshift_d(double _double[]) {
  double double2[];
  double2 = new double[_double.length];
  for (int i=0; i<_double.length/2; i++) {
    double2[_double.length/2+i] = _double[i];
  }
  for (int i=_double.length/2; i<_double.length; i++) {
    double2[i-_double.length/2] = _double[i];
  }
  return double2;
}

double[] ifftshift_d(double _double[]) {
  double double2[];
  double2 = new double[_double.length];
  for (int i=0; i<_double.length/2; i++) {
    double2[_double.length/2+i] = _double[i];
  }
  for (int i=_double.length/2; i<_double.length; i++) {
    double2[i-_double.length/2] = _double[i];
  }
  return double2;
}

double[] append_double(double [] array1, double [] array2) {
  double [] array;
  array = new  double [array1.length+array2.length];
  for (int i = 0; i < array1.length; i++) {
    array[i] = array1[i];
  }
  for (int i = 0; i < array2.length; i++) {
    array[i+array1.length] = array2[i];
  }
  return(array);
}

Complex[] array_transpose(Complex _array[]) {
  Complex array2[];
  array2 = new Complex [_array.length];
  for (int j=0; j<_array.length; j++) {
    array2[j]=  _array[j];
  }
  return array2;
}

double[] array_transpose_double(double _array[]) {
  double array2[];
  array2 = new double[_array.length];
  for (int j=0; j<_array.length; j++) {
    array2[j]=  _array[j];
  }
  return array2;
}

Complex array_dot(Complex _array1[], Complex _array2[]) {
  Complex dot_result = new Complex(0, 0);
  for (int i=0; i<_array1.length; i++) {
    dot_result = dot_result.add(_array1[i].multiply(_array2[i]));
  }
  return dot_result;
}

double array_dot_double(double _array1[], double _array2[]) {
  double dot_result = 0;
  for (int i=0; i<_array1.length; i++) {
    dot_result += (_array1[i]*_array2[i]);
  }
  return dot_result;
}

Complex array_sum(Complex _array1[]) {
  Complex sum_result = new Complex(0, 0);
  for (int i=0; i<_array1.length; i++) {
    sum_result = sum_result.add(_array1[i]);
  }
  return sum_result;
}

double array_sum_double(double _array1[]) {
  double sum_result = 0;
  for (int i=0; i<_array1.length; i++) {
    sum_result += _array1[i];
  }
  return sum_result;
}

double abs_double(double _uDiff) {
  double _temp;
  if (_uDiff >= 0) {
    _temp = _uDiff;
  } else {
    _temp = - _uDiff;
  }
  return _temp;
}


// --------------------------------------------------------------
// EWT: Empirical Wavelet Transform
// --------------------------------------------------------------
// The implementation for Processing from the following Python code
//  ewtpy - Empirical wavelet transform in Python
//  https://github.com/vrcarva/ewtpy
//  Paper available at https://doi.org/10.1016/j.bspc.2020.102073.
//  Vinícius R. Carvalho, Márcio F.D. Moraes, Antônio P. Braga, Eduardo M.A.M. Mendes, Evaluating five different adaptive decomposition methods for EEG signal seizure
// detection and classification, Biomedical Signal Processing and Control, Volume 62, 2020, 102073, ISSN 1746-8094, https://doi.org/10.1016/j.bspc.2020.102073.
// --------------------------------------------------------------

//================================================================
// Empirical Wavelet Transformation. EWT_ver01
// Processing Supported with JAVA
//  Aug 21, 2022
//  Teiji Sawa, Anesthesiology, Kyto Prefectural Univ. of Medicine
//  EWT Porting code from Python to Processing
//================================================================
//Empirical Wavelet Transform implementation for 1D signals
//
//@author: Vinícius Rezende Carvalho
//Programa de pós graduação em engenharia elétrica - PPGEE UFMG
//Universidade Federal de Minas Gerais - Belo Horizonte, Brazil
//Núcleo de Neurociências - NNC
//=================================================================

class Ewt {

  //  signal  - the time domain signal (1D) to be decomposed
  //  K       - the number of modes to be recovered

  double signal2[];
  int K;
  int Fs = 128;

  // Constructor
  Ewt (double [] _signal, int _K) {
    signal2 = _signal;
    K = _K;
  }

  double [][] ewt(double [] _signal) {
    signal2 = _signal;
    //Emd emd = new Emd();
    //EmdDataImpl emdData = new EmdDataImpl();

    int data_N = int(signal2.length);
    ewt = EWT1D(signal2, Fs, K);

    //emd.emdCreate(emdData, data.length-15, order, 20, 0);
    //emd.emdDecompose(emdData, data);
    //imfs = emd.imfs(emdData);
    for (int k=0; k<K; k++) {
      for (int i=0; i<data_N; i++) {
        imfs[k][i] = ewt[i][k];
      }
    }
    return imfs;
  }
}


// --------------------------------------------------------------
// WMD: Wavelet Mode Decomposition
// --------------------------------------------------------------
// The implementation for Processing from the following Python code for EWT
// The modification from EWT: boundary frequencies were fixed
//  ewtpy - Empirical wavelet transform in Python
//  https://github.com/vrcarva/ewtpy
//  Paper available at https://doi.org/10.1016/j.bspc.2020.102073.
//  Vinícius R. Carvalho, Márcio F.D. Moraes, Antônio P. Braga, Eduardo M.A.M. Mendes, Evaluating five different adaptive decomposition methods for EEG signal seizure
// detection and classification, Biomedical Signal Processing and Control, Volume 62, 2020, 102073, ISSN 1746-8094, https://doi.org/10.1016/j.bspc.2020.102073.
// --------------------------------------------------------------

class Ewt2 {

  //  signal  - the time domain signal (1D) to be decomposed
  //  K       - the number of modes to be recovered

  double signal2[];
  int K;
  int Fs = 128;

  // Constructor
  Ewt2 (double [] _signal, int _K) {
    signal2 = _signal;
    K = _K;
  }

  double [][] ewt(double [] _signal) {
    signal2 = _signal;
    //Emd emd = new Emd();
    //EmdDataImpl emdData = new EmdDataImpl();

    int data_N = int(signal2.length);
    ewt = EWT1D2(signal2, Fs, K);

    //emd.emdCreate(emdData, data.length-15, order, 20, 0);
    //emd.emdDecompose(emdData, data);
    //imfs = emd.imfs(emdData);
    for (int k=0; k<K; k++) {
      for (int i=0; i<data_N; i++) {
        imfs[k][i] = ewt[i][k];
      }
    }
    return imfs;
  }
}

double[][] EWT1D(double f[], int Fs, int N) {
  // =========================================================================
  //     ewt,  mfb ,boundaries = EWT1D(f, N = 5):
  //     log = 0,detect = "locmax", completion = 0, reg = 'average', lengthFilter = 10,sigmaFilter = 5
  // =========================================================================
  //     Perform the Empirical Wavelet Transform of f over N scales.
  //
  //     Inputs:
  //       -f: the 1D input signal
  //     Optional Inputs:
  //      -log: 0 or 1 to indicate if we want to work with ==> log = 0
  //                    the log spectrum
  //       -method: 'locmax','locmaxmin','locmaxminf'
  //       -reg: 'none','gaussian','average'
  //      -lengthFilter: width of the above filters (Gaussian or average)
  //       -sigmaFilter: standard deviation of the above Gaussian filter
  //       -N: maximum number of supports (modes or signal components)
  //       -completion: 0 or 1 to indicate if we try to complete
  //                           or not the number of modes if the detection
  //                           find a lower number of mode than N
  //     Outputs:
  //       -ewt: contains first the low frequency component and
  //             then the successives frequency subbands
  //       -mfb: contains the filter bank (in the Fourier domain)
  //       -boundaries: vector containing the set of boundaries corresponding
  //                    to the Fourier line segmentation (normalized between
  //                    0 and Pi)
  //     Original MATLAB Version:
  //     Author: Jerome Gilles
  //     Institution: UCLA - Department of Mathematics
  //     Year: 2013
  //     Version: 2.0
  //
  //     Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //     Universidade Federal de Minas Gerais - Brasil
  //     Núcleo de Neurociências
  // =========================================================================

  double f2[];
  Complex f3_pre[];
  Complex f3[];
  double fMirr[];
  double fMirr2[];
  Complex[] ff1;
  double[] ff2;
  Complex[] ffMirr1;
  Complex[] ffMirr2;
  double[] boundaries;
  int ltemp;
  double[][] mfb;
  double[][] ewt;

  FastFourierTransformer fft4 = new FastFourierTransformer(DftNormalization.STANDARD);
  ff1 = fft4.transform(f, TransformType.FORWARD);

  ff2 = new double[int(ceil(ff1.length/2))];
  for (int i=0; i< int(ceil(ff1.length/2)); i++) {
    ff2[i] = ff1[i].abs();
  }

  boundaries = EWT_Boundaries_Detect(ff2, N);
  for (int i=0; i<boundaries.length; i++) {
    //boundaries[i] = boundaries[i] * PI/round(ff2.length);
    //boundaries[i] = boundaries[i] * PI/32;
    boundaries[i] = (boundaries[i]-128/1028) * PI/(Fs/2);
  }

  //Filtering: extend the signal by mirroring to deal with boundaries
  ltemp = int(ceil(f.length/2));

  fMirr = new double[ltemp];
  for (int i=0; i<ltemp; i++) {
    //fMirr[i] = (float) f[ltemp-1-i];
    fMirr[i] = f[ltemp-1-i];
  }

  //for (int i=0; i<f.length ; i++) {
  //fMirr = append(fMirr, (float) f[i]);
  fMirr = append_double(fMirr, f);
  //}

  f2 = new double[ltemp];
  for (int i=0; i<ltemp; i++) {
    f2[i] = f[f.length-2-i];
  }

  //for (int i=0; i<f2.length ; i++) {
  fMirr = append_double(fMirr, f2);
  //}

  fMirr2 = new double[fMirr.length];
  for (int i=0; i<fMirr2.length; i++) {
    fMirr2[i] = fMirr[i];
  }

  FastFourierTransformer fft2 = new FastFourierTransformer(DftNormalization.STANDARD);
  ffMirr1 = fft2.transform(fMirr2, TransformType.FORWARD);

  //build the corresponding filter bank
  mfb = EWT_Meyer_FilterBank(boundaries, ffMirr1.length);

  //filter the signal to extract each subband
  ewt = new double [mfb.length][mfb[0].length];
  for (int i=0; i<mfb.length; i++) {
    for (int j=0; j<mfb[0].length; j++) {
      ewt[i][j]= 0;
    }
  }

  f3_pre = new Complex[mfb.length];
  f3 = new Complex[mfb.length];

  for (int k=0; k<mfb[0].length; k++) {
    for (int i=0; i < mfb.length; i++) {
      f3_pre[i] = Complex.valueOf(mfb[i][k]);
      f3[i] = f3_pre[i].conjugate().multiply(ffMirr1[i]);
    }

    FastFourierTransformer fft3 = new FastFourierTransformer(DftNormalization.STANDARD);
    ffMirr2 = fft3.transform(f3, TransformType.INVERSE);
    for (int i=0; i <mfb.length; i++) {
      ewt[i][k] = ffMirr2[i].getReal();
    }
  }

  for (int k=0; k<ewt[0].length; k++) {
    for (int i=0; i<(mfb.length-ltemp); i++) {
      ewt[i][k] = ewt[ltemp-1+i][k];
      //ewt = ewt[ltemp-1:-ltemp,:]
    }
  }
  //return(ewt, mfb, boundaries);
  return(ewt);
}

double[][] EWT1D2(double f[], int Fs, int N) {
  // =========================================================================
  //     ewt,  mfb ,boundaries = EWT1D(f, N = 5):
  //     log = 0,detect = "locmax", completion = 0, reg = 'average', lengthFilter = 10,sigmaFilter = 5
  // =========================================================================
  //     Perform the Empirical Wavelet Transform of f over N scales.
  //
  //     Inputs:
  //       -f: the 1D input signal
  //     Optional Inputs:
  //      -log: 0 or 1 to indicate if we want to work with ==> log = 0
  //                    the log spectrum
  //       -method: 'locmax','locmaxmin','locmaxminf'
  //       -reg: 'none','gaussian','average'
  //      -lengthFilter: width of the above filters (Gaussian or average)
  //       -sigmaFilter: standard deviation of the above Gaussian filter
  //       -N: maximum number of supports (modes or signal components)
  //       -completion: 0 or 1 to indicate if we try to complete
  //                           or not the number of modes if the detection
  //                           find a lower number of mode than N
  //     Outputs:
  //       -ewt: contains first the low frequency component and
  //             then the successives frequency subbands
  //       -mfb: contains the filter bank (in the Fourier domain)
  //       -boundaries: vector containing the set of boundaries corresponding
  //                    to the Fourier line segmentation (normalized between
  //                    0 and Pi)
  //     Original MATLAB Version:
  //     Author: Jerome Gilles
  //     Institution: UCLA - Department of Mathematics
  //     Year: 2013
  //     Version: 2.0
  //
  //     Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //     Universidade Federal de Minas Gerais - Brasil
  //     Núcleo de Neurociências
  // =========================================================================

  double f2[];
  Complex f3_pre[];
  Complex f3[];
  double fMirr[];
  double fMirr2[];
  Complex[] ff1;
  double[] ff2;
  Complex[] ffMirr1;
  Complex[] ffMirr2;
  double[] boundaries;
  int ltemp;
  double[][] mfb;
  double[][] ewt;

  FastFourierTransformer fft4 = new FastFourierTransformer(DftNormalization.STANDARD);
  ff1 = fft4.transform(f, TransformType.FORWARD);

  ff2 = new double[int(ceil(ff1.length/2))];
  for (int i=0; i< int(ceil(ff1.length/2)); i++) {
    ff2[i] = ff1[i].abs();
  }

  //--FIXED
  boundaries = new double [5];
  //
  //--ORIGINAL
  //boundaries = EWT_Boundaries_Detect(ff2, N);

  //--MODIFIED
  boundaries[0] = 4.0D;
  boundaries[1] = 8.0D;
  boundaries[2] = 14.0D;
  boundaries[3] = 20.0D;
  boundaries[4] = 30.0D;
  //---END


  for (int i=0; i<boundaries.length; i++) {
    //boundaries[i] = boundaries[i] * PI/round(ff2.length);
    //128/1028=0.125
    boundaries[i] = (boundaries[i]-128/1028) * PI/(Fs/2);
  }

  //Filtering: extend the signal by mirroring to deal with boundaries
  ltemp = int(ceil(f.length/2));

  fMirr = new double[ltemp];
  for (int i=0; i<ltemp; i++) {
    //fMirr[i] = (float) f[ltemp-1-i];
    fMirr[i] = f[ltemp-1-i];
  }

  //for (int i=0; i<f.length ; i++) {
  //fMirr = append(fMirr, (float) f[i]);
  fMirr = append_double(fMirr, f);
  //}

  f2 = new double[ltemp];
  for (int i=0; i<ltemp; i++) {
    f2[i] = f[f.length-2-i];
  }

  //for (int i=0; i<f2.length ; i++) {
  fMirr = append_double(fMirr, f2);
  //}

  fMirr2 = new double[fMirr.length];
  for (int i=0; i<fMirr2.length; i++) {
    fMirr2[i] = fMirr[i];
  }

  FastFourierTransformer fft2 = new FastFourierTransformer(DftNormalization.STANDARD);
  ffMirr1 = fft2.transform(fMirr2, TransformType.FORWARD);

  //build the corresponding filter bank
  mfb = EWT_Meyer_FilterBank(boundaries, ffMirr1.length);

  //filter the signal to extract each subband
  ewt = new double [mfb.length][mfb[0].length];
  for (int i=0; i<mfb.length; i++) {
    for (int j=0; j<mfb[0].length; j++) {
      ewt[i][j]= 0;
    }
  }

  f3_pre = new Complex[mfb.length];
  f3 = new Complex[mfb.length];

  for (int k=0; k<mfb[0].length; k++) {
    for (int i=0; i < mfb.length; i++) {
      f3_pre[i] = Complex.valueOf(mfb[i][k]);
      f3[i] = f3_pre[i].conjugate().multiply(ffMirr1[i]);
    }

    FastFourierTransformer fft3 = new FastFourierTransformer(DftNormalization.STANDARD);
    ffMirr2 = fft3.transform(f3, TransformType.INVERSE);
    for (int i=0; i <mfb.length; i++) {
      ewt[i][k] = ffMirr2[i].getReal();
    }
  }

  for (int k=0; k<ewt[0].length; k++) {
    for (int i=0; i<(mfb.length-ltemp); i++) {
      ewt[i][k] = ewt[ltemp-1+i][k];
      //ewt = ewt[ltemp-1:-ltemp,:]
    }
  }
  //return(ewt, mfb, boundaries);
  return(ewt);
}

double[] EWT_Boundaries_Detect(double[] ff, int N) {
  // =========================================================================
  // def EWT_Boundaries_Detect(ff,log,detect, N, reg, lengthFilter,sigmaFilter):
  // log = 0,detect = "locmax", reg = 'average', lengthFilter = 10,sigmaFilter = 5
  // =========================================================================
  // """This function segments f into a certain amount of supports by  using different technics:
  //     - middle point between consecutive local maxima (default),
  //     - lowest minima between consecutive local maxima (locmaxmin),
  //     - lowest minima between consecutive local maxima of original spectrum (locmaxminf),
  //
  //     Regularized version of the spectrum can be obtained by the
  //     following methods:
  //     - Gaussian filtering (its parameters are filter of width
  //       lengthFilter and standard deviation sigmaFilter)scalesp
  //     - Average filtering (its parameters are filter of width
  //       lengthFilter)
  //
  //     Note: the detected boundaries are given in term of indices
  //
  //     Inputs:
  //       -f: the function to segment
  //     Optional parameters:
  //       -log: 0 or 1 to indicate if we want to work with
  //                    the log of the ff
  //       -reg: 'none','gaussian','average'
  //       -lengthFilter: width of the above filters (Gaussian or average)
  //       -sigmaFilter: standard deviation of the above Gaussian filter
  //       -N: maximum number of supports (modes or signal components)
  //       -completion: 0 or 1 to indicate if we try to complete
  //                           or not the number of modes if the detection
  //                           find a lower number of mode than N
  //
  //     Outputs:
  //       -boundaries: list of detected boundaries
  //
  //
  //    Original MATLAB version:
  //    Author: Jerome Gilles + Kathryn Heal
  //    Institution: UCLA - Department of Mathematics
  //    Year: 2013
  //    Version: 2.0
  //
  //    Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //    Universidade Federal de Minas Gerais - Brasil
  //    Núcleo de Neurociências
  //    """

  double [] regFilter;
  double [] boundaries;
  double [] presig;

  regFilter = new double [10];
  //Regularization
  for (int i=0; i<10; i++) {
    regFilter[i] = 1.0/10;
  }

  String mode = "same"; //Can be "valid", "same"
  Convolution con = new Convolution(ff, regFilter);
  presig = con.convolve(mode);

  //Boundaries detection: Mid-point between two consecutive local maxima computed on the regularized spectrum
  boundaries = LocalMax(presig, N);
  for (int i=0; i < boundaries.length; i++) {
    boundaries[i] = boundaries[i] + 0.125;
  }
  return(boundaries);
}

double [] LocalMax(double[] ff, int N) {
  //================================================================
  // def LocalMax(ff, N):
  //================================================================
  //  bound = LocalMax(f,N)
  //
  //    This function segments f into a maximum of N supports by taking
  //    the middle point between the N largest local maxima.
  //    Note: the detected boundaries are given in term of indices
  //
  //    Inputs:
  //      -f: the function to segment
  //      -N: maximal number of bands
  //
  //    Outputs:
  //      -bound: list of detected boundaries
  //
  //    Original MATLAB version:
  //    Author: Jerome Gilles + Kathryn Heal
  //    Institution: UCLA - Department of Mathematics
  //    Year: 2013
  //    Version: 1.0
  //
  //    Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //    Universidade Federal de Minas Gerais - Brasil
  //    Núcleo de Neurociências
  //===============================================================

  //float[] locmax;
  double[] locmax;
  int[] temp;
  int[] temp1;
  int[] maxidxs;
  int a;
  double [] bound;

  N=N-1;
  //locmax = new float [ff.length];
  locmax = new double [ff.length];
  for (int i=0; i<ff.length; i++) {
    locmax[i] = 0.0;
  }

  for (int i =1; i<locmax.length-1; i++) {
    if ((ff[i-1]<ff[i]) && (ff[i]>ff[i+1])) {
      //locmax[i] = (float) ff[i];
      locmax[i] = ff[i];
    }
  }

  N = min(N, locmax.length);
  temp1 = new int [N];

  temp  =  reverse(argsort(locmax));

  for (int i=0; i<N; i++) {
    temp1[i] = temp[i];
  }

  maxidxs = sort(temp1);

  //middle point between consecutive maxima
  bound = new double [N];
  for (int i =0; i <N; i++) {
    bound[i] = 0;
  }

  for (int i =0; i<N; i++) {
    if (i == 0) {
      a = 0;
    } else {
      a = maxidxs[i-1];
    }
    bound[i] = (a + maxidxs[i])/2;
  }
  return(bound);
}

double [][] EWT_Meyer_FilterBank(double [] boundaries, int Nsig) {
  //=========================================================================
  // def EWT_Meyer_FilterBank(boundaries,Nsig):
  //=========================================================================
  //    function mfb=EWT_Meyer_FilterBank(boundaries,Nsig)
  //
  //     This function generate the filter bank (scaling function + wavelets)
  //     corresponding to the provided set of frequency segments
  //
  //     Input parameters:
  //       -boundaries: vector containing the boundaries of frequency segments (0
  //                    and pi must NOT be in this vector)
  //       -Nsig: signal length
  //
  //     Output:
  //       -mfb: cell containing each filter (in the Fourier domain), the scaling
  //             function comes first and then the successive wavelets
  //
  //     Author: Jerome Gilles
  //     Institution: UCLA - Department of Mathematics
  //     Year: 2012
  //     Version: 1.0
  //
  //     Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //     Universidade Federal de Minas Gerais - Brasil
  //     Núcleo de Neurociências
  //=========================================================================

  int Npic;
  double gamma;
  double r;
  int Mi;
  double[] temp1;
  double[] temp2;
  double[] w;
  double [] aw;
  double an;
  double pbn;
  double mbn;
  double[] yms1;
  double [] yms2;
  double[][] mfb;
  double[] mfb_temp1;
  double[] mfb_temp2;

  Npic = boundaries.length;
  //compute gamma
  gamma = 1.0;
  for (int k=0; k <Npic-1; k++) {
    r = (boundaries[k+1]-boundaries[k]) / (boundaries[k+1]+boundaries[k]);
    if (r < gamma) {
      gamma = r;
    }
  }
  r = (PI - boundaries[Npic-1]) / (PI + boundaries[Npic-1]);

  if (r<gamma) {
    gamma = r;
  }
  gamma = (1.0-1.0/Nsig)*gamma;
  //this ensure that gamma is chosen as strictly less than the min

  mfb = new double [Nsig][Npic+1];
  for (int i =0; i <Nsig; i++) {
    for (int j =0; j < Npic+1; j++) {
      mfb[i][j] = 0;
    }
  }

  //EWT_Meyer_Scaling
  Mi=int(floor(Nsig/2));

  //temp1 = new float[Nsig];
  temp1 = new double[Nsig];
  temp2 = new double[Nsig];

  double div = (2*PI-2*PI/Nsig)/(Nsig-1);

  for (int i=0; i<Nsig; i++) {
    temp1[i] = 0 + i * div;
  }


  for (int i=0; i<Nsig; i++) {
    temp2[i] = temp1[i];
  }

  w = fftshift_d(temp2);

  double factor = -2.0 * PI;

  for (int i=0; i<Mi; i++) {
    w[i] = w[i] + factor;
  }

  aw = new double [Nsig];
  for (int i=0; i<Nsig; i++) {
    aw[i] = abs_double(w[i]);
  }

  yms1 = new double [Nsig];

  for (int i=0; i<Nsig; i++) {
    yms1[i] = 0;
  }

  an=1.0/(2*gamma*boundaries[0]);
  pbn=(1.0+gamma)*boundaries[0];
  mbn=(1.0-gamma)*boundaries[0];

  for (int k=0; k<Nsig; k++) {
    if (aw[k]<=mbn) {
      yms1[k]=1;
    } else if ((aw[k]>=mbn) && (aw[k]<=pbn)) {
      yms1[k]=(PI*EWT_beta(an*(aw[k]-mbn))/2);
      yms1[k] = cos((float) yms1[k]);
    }
  }

  yms2 = ifftshift_d(yms1);

  for (int i=0; i<Nsig; i++) {
    mfb[i][0] = abs((float)yms2[i]);
  }

  //generate rest of the wavelets
  for (int k=0; k<Npic-1; k++) {
    for (int i=0; i<mfb.length; i++) {
      mfb_temp1 = EWT_Meyer_Wavelet(boundaries[k], boundaries[k+1], gamma, Nsig);
      mfb[i][k+1] = mfb_temp1[i];
    }
  }

  for (int i=0; i <mfb.length; i++) {
    mfb_temp2 = EWT_Meyer_Wavelet(boundaries[Npic-1], PI, gamma, Nsig);
    mfb[i][Npic] = mfb_temp2[i];
  }
  return(mfb);
}

double EWT_beta(double x) {
  // =================================================================
  // def EWT_beta(x):
  // =================================================================
  //    Beta = EWT_beta(x)
  //    function used in the construction of Meyer's wavelet
  // =================================================================

  double bm;

  if (x<0) {
    bm=0;
  } else if (x>1) {
    bm=1;
  } else {
    bm=(pow((float)x, 4))*(35.0-84.0*x+70.*(pow((float)x, 2))-20.*(pow((float)x, 3)));
  }
  return(bm);
}

double [] EWT_Meyer_Wavelet(double wn, double wm, double gamma, int Nsig) {
  // =========================================================
  // def EWT_Meyer_Wavelet(wn,wm,gamma,Nsig):
  // =========================================================
  //    ymw=EWT_Meyer_Wavelet(wn,wm,gamma,N)
  //
  //    Generate the 1D Meyer wavelet in the Fourier
  //    domain associated to scale segment [wn,wm]
  //    with transition ratio gamma
  //
  //    Input parameters:
  //      -wn : lower boundary
  //      -wm : upper boundary
  //      -gamma : transition ratio
  //      -N : number of point in the vector
  //
  //    Output:
  //      -ymw: Fourier transform of the wavelet on the band [wn,wm]
  //
  //    Author: Jerome Gilles
  //    Institution: UCLA - Department of Mathematics
  //    Year: 2012
  //    Version: 1.0
  //
  //    Python Version: Vinícius Rezende Carvalho - vrcarva@ufmg.br
  //    Universidade Federal de Minas Gerais - Brasil
  //    Núcleo de Neurociências
  //==========================================================
  int Mi;
  double [] temp;
  double [] aw;
  double [] ymw;
  //Complex [] ymw2_comp;
  double [] ymw2;
  //Complex [] ymw_comp;
  double[] w;
  double an;
  double am;
  double pbn;
  double mbn;
  double pbm;
  double mbm;

  Mi=int(floor(Nsig/2));

  temp = new double [Nsig];
  double div = (2*PI-2*PI/Nsig)/(Nsig-1);

  for (int i=0; i<Nsig; i++) {
    temp[i] = 0 + i * div;
  }

  w = fftshift_d(temp);

  double factor = -2.0 * PI;
  for (int i=0; i<Mi; i++) {
    w[i] = w[i] + factor;
  }

  aw = new double [Nsig];
  for (int i=0; i<Nsig; i++) {
    aw[i] =  w[i];
  }
  for (int i=0; i<Mi; i++) {
    aw[i] = abs((float) w[i]);
  }

  ymw = new double [Nsig];
  for (int i=0; i<Nsig; i++) {
    ymw[i] = 0.0;
  }

  an=1.0/(2.0*gamma*wn);
  am=1.0/(2.0*gamma*wm);
  pbn=(1.0+gamma)*wn;
  mbn=(1.0-gamma)*wn;
  pbm=(1.0+gamma)*wm;
  mbm=(1.0-gamma)*wm;

  for (int k=0; k < Nsig; k++) {
    if ((aw[k]>=pbn) && (aw[k]<=mbm)) {
      ymw[k]=1;
    } else if ((aw[k]>=mbm) && (aw[k]<=pbm)) {
      ymw[k] =  cos((float) (PI*EWT_beta(am*(aw[k]-mbm))/2));
    } else if ((aw[k]>=mbn) && (aw[k]<=pbn)) {
      ymw[k] =  sin( (float) (PI*EWT_beta(an*(aw[k]-mbn))/2));
    }
  }

  ymw2 = ifftshift_d(ymw);

  return(ymw2);
}
