
# LFP Analysis Toolbox

## Overview
The `LFPDataAnalysis` MATLAB class provides functionality to preprocess, analyze, and visualize Local Field Potential (LFP) data. The class supports operations such as segmentation, filtering, spectral analysis, and time-frequency plotting for multiple channels. It leverages the FieldTrip toolbox to process multi-channel LFP data and provides interactive visualization features to facilitate neuroscience research.

## Features
- **Data Preprocessing**:
  - Segments the data into defined lengths.
  - Applies high-pass, low-pass, and band-stop filtering.

- **FieldTrip Integration**:
  - Converts raw LFP data into FieldTrip-compatible format.
  - Includes segmentation, filtering, and baseline correction steps.

- **Time-Frequency Analysis**:
  - Computes time-frequency representations using multi-taper methods.
  - Incorporates spectral smoothing and bandstop filtering.

- **Interactive Visualization**:
  - Plots raw data, time-frequency spectrograms, and relative power for each channel.
  - Includes interactive functionality to adjust scale and navigate through data.

## Requirements
- **MATLAB** (R2017b or newer recommended).
- **FieldTrip toolbox** (version 2017-06-18 or compatible).
- **Input Data**: The class expects `.mat` files containing channel data with fields corresponding to the `signals` property.


## Usage

### 1. Initialization
Create an instance of the `LFPDataAnalysis` class:
```matlab
lfp = LFPDataAnalysis();
```

### 2. Preprocessing Data
Preprocess the data using the preprocessData method:
```matlab
lfp = lfp.preprocessData();
```

### 3. Visualization
Visualize the data using the plotData method:
```matlab
lfp.plotData();
```

## Properties

### Public Properties
- secs_to_plot: Duration of plot in seconds.
- clim1, clim2: Limits for the spectrogram of channel 2.
- clim3, clim4: Limits for the spectrogram of channel 1.
- lg: Boolean to enable or disable logarithmic scaling.
- fieldtrip_path: Path to the FieldTrip toolbox.
- data_source: Path to the .mat files containing LFP data.
- signals: Names of the channels to process.
- fsample_hz: Sampling frequency in Hz.
- freq_hz: Maximum frequency for analysis in Hz.
- channel_names: Names of the channels.
- info: Description of the data.
- segment_length_s: Length of data segments in seconds.
- overlap: Overlap between data segments (fraction).
- hp_cutoff_hz: High-pass filter cutoff frequency in Hz.
- lp_cutoff_hz: Low-pass filter cutoff frequency in Hz.
- bs_freq_hz: Bandstop filter frequency range in Hz.
- spectral_window_s: Spectral analysis window length in seconds.
- smoothing_frequency_hz: Smoothing frequency for spectral analysis in Hz.
- power_frequency_range_hz: Frequency range for power analysis in Hz.
- spectrogram_xlim_low_hz, spectrogram_xlim_high_hz: Limits for x-axis in spectrogram plots.

### Protected Properties
- data: Processed data structure.
- combined_data: Combined data from all channels.
- ch1_data, ch2_data: Data for individual channels.

## Methods

###Public Methods
- LFPDataAnalysis: Constructor to initialize the class and load data.
- preprocessData: Preprocesses the LFP data (segmentation and filtering).
- plotData: Visualizes the LFP data.

### Protected Methods
- loadData: Loads LFP data from .mat files.
- performSpectralPowerAnalysis: Performs spectral analysis for a specific data segment.
- plotChannel: Helper function to plot individual channel data (raw, spectrogram, and relative power).

## Acknowledgments
This script utilizes the FieldTrip toolbox for LFP analysis. Thanks to the FieldTrip development team for providing tools that enhance neuroscience research.

---
For additional questions or support, please contact the author.
