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

- Copy all files from this repo directory to a local directory, in particular 
  - `sns_tokenomics_analyzer.py`, which contains the code for the tool. 
  - `sns_init.yaml` which is an example input file.      
- Python installation is required.
- Additional Python libraries are also required and are listed at the beginning of the `sns_tokenomics_analyzer.py` file. In order to install these you have the following options
  - **Manual Installation**: Manually install the required Python libraries listed in the `sns_tokenomics_analyzer.py` file.
  - **Nix Installation**: Alternatively, install Nix and run `nix develop` in the directory where you plan to execute the code.


## Running the Tool

1. Adjust or replace the input `sns_init.yaml` in current directory. 
2. Execute `python ./sns_tokenomics_analyzer.py` in your terminal. 
2. Open `http://127.0.0.1:8051/` in your local web browser to use the tool. 
