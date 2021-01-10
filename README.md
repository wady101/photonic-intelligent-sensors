# Photonic Intelligent Sensors

Research archive for a 2020–2021 FPGA signal-processing pipeline for photonic sensor data. The repository explores ADC capture, FFT and peak extraction, and a small fully connected neural network for pressure classification.

> **Research artifact:** this is a historical development snapshot, not a maintained or turnkey sensor platform. It includes generated Vivado/Vivado HLS output, machine-specific paths, and experimental scripts from the original environment.

## Pipeline

The prototype was organized around the following stages:

1. Capture digitized sensor samples through the ADC design.
2. Transform the time-domain samples with an FPGA FFT pipeline.
3. Extract spectral peaks for use as model features.
4. Classify pressure ranges with a fully connected neural network.

## Repository layout

| Path | Contents |
| --- | --- |
| `ADC/` | Zynq/Vivado ADC integration sources, constraints, block-design output, and generated IP. |
| `FFT-Verilog/` | FFT RTL experiments and `FFTPeaks_sim.py`, a NumPy/SciPy reference for peak extraction. |
| `HLS FFT/peak detector/` | Vivado HLS top level, testbench, parameters, and neural-network helper code for the combined experiment. |
| `Training/` | PyTorch pressure-classification experiment, MATLAB conversion utilities, HLS C++, parameters, and generated RTL. |

## Software exploration

`FFT-Verilog/FFTPeaks_sim.py` expects a directory of newline-separated sample files named by the original acquisition convention. Its principal dependencies are NumPy, pandas, SciPy, and Matplotlib:

```bash
python3 FFT-Verilog/FFTPeaks_sim.py \
  --root_dir /path/to/sample-files \
  --pressure 0
```

`Training/main.py` preserves the PyTorch classifier experiment. It contains paths and CUDA assumptions from the original workstation, so update the dataset directory and device handling before running it on a new system. MATLAB scripts under `Training/` convert captured or simulated data into the CSV/decimal formats used by the experiment.

## FPGA sources

- The ADC design targets the Xilinx Zynq ecosystem and includes generated vendor IP under `ADC/sources_1/`.
- FFT variants and their testbenches are retained under `FFT-Verilog/hw/`.
- HLS neural-network sources are available under `Training/FPGA/` and `HLS FFT/peak detector/`.
- Generated RTL is included for inspection; rebuilding it requires a compatible legacy Xilinx Vivado/Vivado HLS installation.

No single scripted build spans the complete repository. Treat each directory as a preserved experiment and review its top-level/testbench source before opening it in the matching vendor tool version.

## Maintainer

- wady101 — system integration, FFT/ADC experiments, and training work

## Contact

wady101 — [omegangregovitch@gmail.com](mailto:omegangregovitch@gmail.com)

## Reuse

This archive does not currently include a repository-wide license. Generated Xilinx assets and other third-party components may carry their own terms; review those terms before redistribution or reuse.
