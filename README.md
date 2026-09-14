# Hardware Vision Accelerator: Sobel Edge Detector

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Status: Simulation & Synthesis Ready](https://img.shields.io/badge/Status-Simulation_Ready-brightgreen.svg)
![Language: SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-purple.svg)

This repository contains a zero-warning, fully optimized RTL implementation of a **Real-Time Image Processing Pipeline**, designed to perform hardware-accelerated Sobel Edge Detection on a continuous pixel stream.

This project demonstrates **Hardware/Software Co-Simulation**. The core processing operates at the logic gate level, while Python is used for file I/O (converting images to raw hex streams). We simulate the SystemVerilog datapath in Vivado and reconstruct the output image to visually verify the hardware's mathematical precision.

##  Architecture Overview

The accelerator processes a continuous stream of pixels (e.g., from an AXI-Stream camera) and performs a 2D convolution. 

To achieve a 3x3 convolution window on a streaming 1D pixel bus, the design implements **Synchronous Line Buffers** using FPGA True Dual-Port Block RAM (`RAMB18E1`) to temporarily store rows of the image.

```text
[Input Pixel Stream] 
       │
       ▼
 ┌─────────────┐
 │Line Buffer 1├─────────► (Row N-1) ─────────┐
 └─────────────┘                              │
       │                                      │
       ▼                                      ▼
 ┌─────────────┐                        ┌───────────┐    ┌────────────┐
 │Line Buffer 2├─────────► (Row N-2) ───► 3x3 Window├────► Sobel Math ├──► [Edge Pixel Out]
 └─────────────┘                        │ Formation │    │DSP Pipeline│
                                        └───────────┘    └────────────┘
(Current Row N) ──────────────────────────────┘
```

### Key Modules:
* `line_buffer.sv`: Infers 2-cycle latency Synchronous Block RAM to delay pixels by exactly 1 and 2 row widths, creating a perfectly aligned 3x3 window in the same clock cycle. 
* `sobel_core.sv`: A pipelined DSP datapath that computes the `Gx` and `Gy` gradients simultaneously using fixed-point arithmetic, taking the absolute sum approximation `(|Gx| + |Gy|)` to threshold edges.
* `image_processor_top.sv`: The top-level wrapper that manages valid signals, pipeline alignment, and connects the line buffers to the math core.

##  Quick Start (Co-Simulation)

You do not need a physical FPGA to run this. Follow these steps to simulate the hardware on your PC:

### 1. Prerequisites
* **Xilinx Vivado** (WebPACK / Free version is fine)
* **Python 3** (with `Pillow` library: `pip install pillow`)

### 2. Pre-process the Image (Software -> Hardware)
Convert a standard image into a raw hex stream that the Verilog Testbench can ingest.
```bash
cd scripts
python img2hex.py ../images/professional_test.jpg
```
*This creates `sim/input.hex`.*

### 3. Generate and Run Hardware Simulation
Because professional FPGA repositories version-control source code rather than binary project files, you must generate the Vivado project on your local machine using the provided Tcl script.

**To generate the project:**
1. Open Vivado.
2. At the bottom of the start screen, click **Tcl Console**.
3. Use the `cd` command to navigate to the cloned repository folder (e.g., `cd C:/path/to/Hardware-Vision-Accelerator`).
4. Run the build script: `source scripts/build_project.tcl`

Vivado will automatically build the `Vision_Project.xpr` project, import all RTL and testbenches, and set up the simulation environment. Once the project opens, click **Run Simulation** on the left sidebar.

*The Testbench (`tb_image_processor.sv`) will automatically read the hex file, pump the pixels through the RTL line buffers and math engine, and write the hardware's results to `sim/output.hex`.*

### 4. Post-process the Result (Hardware -> Software)
Reconstruct the hardware's hex output back into a viewable image.
```bash
cd scripts
python hex2img.py
```
Check the `images/` directory. You will see `edge_detected_output.jpg`, perfectly outlining the original image—processed entirely by simulated logic gates!

##  Synthesis & Implementation (Zero Warnings)
This design has been aggressively optimized for Xilinx 7-Series / UltraScale architectures.
* **Timing**: Easily meets 50MHz+ timing requirements with perfectly pipelined paths.
* **Cleanliness**: 0 Synthesis Warnings, 0 Implementation Warnings, 0 DRC Violations.
* **Memory**: Perfectly infers `RAMB18E1` primitives using native 2-stage output registers for optimal Clock-to-Out performance.

##  Future Enhancements
* Wrap the top module in an **AXI4-Stream (AXIS)** interface to plug directly into a Zynq SoC or MicroBlaze processor.
* Add AXI-Lite registers to allow software to dynamically change the Edge Detection threshold on the fly.
