
# LFP Analysis Toolbox

## Overview
The `LFP_data_analysis.m` script is a MATLAB-based tool designed for the preprocessing, analysis, and visualization of Local Field Potential (LFP) recordings. It leverages the FieldTrip toolbox to process multi-channel LFP data and provides interactive visualization features to facilitate neuroscience research.

## Features
- **Data Loading and Synchronization**:
  - Loads LFP data from `.mat` files.
  - Ensures channel length consistency by truncating longer signals.

- **FieldTrip Integration**:
  - Converts raw LFP data into FieldTrip-compatible format.
  - Includes segmentation, filtering, and baseline correction steps.

- **Time-Frequency Analysis**:
  - Computes time-frequency representations using multi-taper methods.
  - Incorporates spectral smoothing and bandstop filtering.

- **Interactive Visualization**:
  - Plots raw LFP signals and spectrograms for each channel.
  - Allows interactive adjustment of visualization scales.
  - Tracks analysis progress and displays annotations.

## Requirements
- MATLAB (R2017b or newer recommended).
- FieldTrip toolbox (version 2017-06-18 or compatible).

## How to Use
1. Place the script and the required `.mat` files in the same directory.
2. Update the following parameters in the script as needed:
   - `secs_to_plot`: Number of seconds to display per segment.
   - `clim1`, `clim2`, `clim3`, `clim4`: Color limits for raw and frequency plots.
   - `lg`: Set to 1 to use logarithmic scaling for spectrograms.
3. Add the FieldTrip toolbox to the MATLAB path.
4. Run the script in MATLAB.
5. Follow the prompts to:
   - Navigate through data segments.
   - Adjust visualization scales interactively.

## Outputs
- **Raw LFP Plots**: Displays microvolt signals over time for each channel.
- **Spectrograms**: Visualizes frequency power over time for both channels.
- **Power Spectral Density (PSD)**: Plots relative power across frequencies.

## Example Data
The script is compatible with `.mat` files containing LFP recordings. Each file should include `values` fields representing the signal data.

## Repository Structure
- `Katarina_clean2_same_scale.m`: Main script for LFP analysis.
- `README.md`: Documentation for the repository.
- `example_data/` (optional): Placeholder for example `.mat` files.

## Contributing
Contributions are welcome! If you encounter issues or have suggestions for improvement:
- Open an issue.
- Submit a pull request with your changes.

## Acknowledgments
This script utilizes the FieldTrip toolbox for LFP analysis. Thanks to the FieldTrip development team for providing tools that enhance neuroscience research.

---
For additional questions or support, please contact the author.
