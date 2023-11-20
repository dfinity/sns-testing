# SNS Tokenomics Analyzer

## Purpose

- **What It Is**: A tool designed to simplify the setup and analysis of tokenomics for Service Nervous Systems (SNS) on the Internet Computer (IC).
- **Key Features**: 
  - Parses SNS launch parameters given by SNS init file. 
  - Offers simulation and visualization features
- **Who It's For**: This tool is primarily aimed at SNS project teams and community members who are reviewing NNS proposals for SNS launches.

## Disclaimer

This tool is an initial beta version of the SNS Tokenomics Analyzer. Feedback regarding potential limitations and bugs is highly appreciated.

## Version 
Version 0.9. 

## Installation  

- Copy all files from this repo directory to a local directory. 
- Python installation is required.
- For the required libraries
  - **Manual Installation**: Manually install the required Python libraries listed in `flake.nix` file.
  - **Nix Installation**: Alternatively, install Nix and run `nix develop` in the directory where you plan to execute the code.


## Running the Tool

1. Adjust or replace the input `sns_init.yaml` in current directory. 
2. Execute `python ./app.py` in your terminal.
3. Adjust configuration parameters in config.py if needed 
4. Open `http://127.0.0.1:8051/` in your local web browser to use the tool. 
