 
## Variational Bayesian Maximum Correntropy CKF for Li Ion Battery SOC Estimation

This repository contains MATLAB code for state of charge (SOC) estimation of Li ion battery cells using the Variational Bayesian Maximum Correntropy Cubature Kalman Filter (VBMCCKF) and related filters.

The implementation is based on the paper

> I. Hafez, A. Wadi, M. F. Abdel Hafez, and A. A. Hussein,  
> "Variational Bayesian Based Maximum Correntropy Cubature Kalman Filter Method for State of Charge Estimation of Li Ion Battery Cells,"  
> IEEE Transactions on Vehicular Technology, vol. 72, no. 3, pp. 3090 to 3104, 2023.  
> doi: 10.1109/TVT.2022.3216337

A PDF of the paper is included in the `paper` folder.

---

## Repository contents

```text
src/
  models/      Battery models, OCV model, hysteresis model, parameter identification
  filters/     EKF, CKF, VBCKF, VBMCCKF and other filter implementations
  utils/       Helper functions, plotting, error metrics, data handling

data/
  Example datasets and profiles used for SOC estimation tests

results/
  Example figures, logs, and saved estimation results

paper/
  VBMCCKF_TVT2023.pdf    PDF of the published IEEE TVT paper

README.md
````

---

## Requirements

The code is written in MATLAB.

Minimum setup:

* MATLAB (any reasonably recent version that supports the scripts)
* Any MATLAB toolboxes that were used in the original work, for example

  * Optimization Toolbox
  * Statistics and Machine Learning Toolbox

The code is intended for research and academic use.

---

## How to use

1. Open the repository folder in MATLAB.

2. Add the `src` folder and its subfolders to the MATLAB path:

   ```matlab
   addpath(genpath('src'));
   ```

3. Make sure the required data files are available in the `data` folder.

4. Run one of the main scripts, for example:

   ```matlab
   % Example: VBMCCKF SOC estimation
   main_vbmcckf_soc;

   % Example: comparison between filters
   % main_compare_filters;
   ```

Replace the script names above with the actual names of your main `.m` files that run the estimators and generate the results.

---

## Reproducing results

The repository is structured to reproduce the main results of the paper, including

* SOC estimation under different drive cycles
* Comparison between EKF, CKF, VBCKF, and VBMCCKF
* Error statistics and robustness to noise and outliers

Each main script in `src` contains comments that explain which data set it uses and which figures or tables in the paper it is related to.

---

## Citation

If you use this repository, the code, or ideas from this work in your research, please cite the paper:

```text
I. Hafez, A. Wadi, M. F. Abdel Hafez, and A. A. Hussein,
"Variational Bayesian Based Maximum Correntropy Cubature Kalman Filter Method for State of Charge Estimation of Li Ion Battery Cells,"
IEEE Transactions on Vehicular Technology, vol. 72, no. 3, pp. 3090 to 3104, 2023.
doi: 10.1109/TVT.2022.3216337.
```

You may also include a link to this GitHub repository.

---

## Code ownership and contact

All MATLAB scripting, implementation, and repository organization in this project are completely my own work, unless a specific file header clearly states otherwise.

If you detect any mistake, bug, or inconsistency in the implementation, please contact me directly or open an issue in this repository.

I am open to collaboration in state estimation and filtering for robotics, UAVs, Li ion batteries, and related mechatronic and control applications. If you are interested in collaboration in these areas, feel free to contact me.

Contact email:

```text
ishaq.hmk@gmail.com
```

---

## License and reuse

The code and material in this repository are provided for research and educational use.

* All rights are reserved by the author.
* If you would like to reuse the code in a commercial project or redistribute a modified version, please contact me to discuss permission and possible collaboration.
* The author does not provide any warranty. Use this code at your own risk and always validate it for your specific application.

```
