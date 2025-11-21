
````markdown
# Variational Bayesian Maximum Correntropy CKF for Li-Ion Battery SOC Estimation

This repository contains MATLAB code for state of charge (SOC) estimation of Li-ion battery cells using the Variational Bayesian Maximum Correntropy Cubature Kalman Filter (VBMCCKF) and related filters (EKF, CKF, VBCKF).

The implementation is based on the paper:

> I. Hafez, A. Wadi, M. F. Abdel-Hafez, and A. A. Hussein,  
> "Variational Bayesian-Based Maximum Correntropy Cubature Kalman Filter Method for State-of-Charge Estimation of Li-Ion Battery Cells,"  
> *IEEE Transactions on Vehicular Technology*, vol. 72, no. 3, pp. 3090-3104, 2023.  
> [https://doi.org/10.1109/TVT.2022.3216337](https://doi.org/10.1109/TVT.2022.3216337)

The PDF of the paper is included in `paper/` for convenience.

---

## Repository structure

```text
src/
  models/        ESC cell model, hysteresis, PSO parameter identification
  filters/       EKF, CKF, VBCKF, VBMCCKF implementations
  utils/         helper functions, plotting, error metrics

data/
  Example datasets and test profiles (HPPC, drive cycles, etc), if available.

results/
  Example figures, logs, and saved results that reproduce selected plots.

paper/
  VBMCCKF_TVT2023.pdf        IEEE TVT paper PDF
````

You can adapt the folder names if you use different ones in your code.

---

## Requirements

* MATLAB (tested with a recent version)
* Optimization Toolbox and any other toolboxes you actually used
* Data files for the tests (HPPC, US06, LA92, HWFET, UDDS, etc), if not included here

Please update this section with the exact MATLAB version and toolboxes you used.

---

## How to run

Typical workflow:

1. Add this repo to the MATLAB path:

   ```matlab
   addpath(genpath('src'));
   ```

2. Prepare or load data:

   ```matlab
   load('data/your_dataset.mat');   % replace with your actual file
   ```

3. Run one of the example scripts:

   ```matlab
   run_example_vbmcckf.m      % main example script (update with your real script name)
   ```

4. Check the figures and logs saved under `results/`.

Since script names and data files depend on how you organized your project, please replace the example names here with your actual `.m` files and `.mat` files.

---

## Reference and citation

If you use this code in academic work, please cite the paper:

```text
I. Hafez, A. Wadi, M. F. Abdel-Hafez, and A. A. Hussein,
"Variational Bayesian-Based Maximum Correntropy Cubature Kalman Filter Method for State-of-Charge Estimation of Li-Ion Battery Cells,"
IEEE Transactions on Vehicular Technology, vol. 72, no. 3, pp. 3090-3104, 2023.
doi: 10.1109/TVT.2022.3216337.
```

You can also link to this GitHub repository.

---

## Code ownership and contact

All MATLAB scripts and functions in this repository are my own work unless explicitly stated otherwise.

* If you detect any bug, mistake, or incorrect implementation, please open an issue on GitHub or contact me directly.
* I am open to collaboration in state estimation and filtering for robotics, battery management systems, and related mechatronic applications.
  If you are interested in collaborating, feel free to contact me.

Contact email: `your.email@domain`
(Replace this with the email you prefer to share.)

---

 
