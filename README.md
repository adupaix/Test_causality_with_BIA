# Physiological condition as a cause or consequence of behavior, a chicken-and-egg story

[![License](https://img.shields.io/github/license/adupaix/Test_causality_with_BIA)](https://github.com/adupaix/Test_causality_with_BIA/blob/master/LICENSE)
[![DOI](https://zenodo.org/badge/710848069.svg)](https://zenodo.org/doi/10.5281/zenodo.10711575)
[![Latest Release](https://img.shields.io/github/release/adupaix/Test_causality_with_BIA)](https://github.com/adupaix/Test_causality_with_BIA/releases)

---

Scripts used to generate the results and figures of the following paper:

 Dupaix A, Deneubourg J-L, Forget F, Tolotti MT, Dagorn L, Capello M. (2025) Mechanistic modelling reveals tuna physiological condition is not a driver of floating object association. _Proc. R. Soc. B_ 292: 20250704. [https://doi.org/10.1098/rspb.2025.0704](https://doi.org/10.1098/rspb.2025.0704)

Should you have any question, please contact me: amael.dupaix@ens-lyon.fr

## Running the analysis

Scripts run with the __R 4.3.1__ statistical sofware.
The [conda](https://docs.conda.io/projects/conda/en/latest/) environment to run the model is provided. To create, type in terminal: `conda env create -f r-causality.yml`

To run the analysis:
- prepare a configuration file (template provided in `config/config_template.R`)
- fill in the `config_name` and `BASE_DIR` variables in `launch.R`
- run `launch.R`

## Datasets

The files containing the number of FOBs and that containing BIA data are provided as csv files in the `Outputs` directory.

The Bio-electrical Impedance Analysis (BIA) data, collected by observers onboard French purse seine vessels, as part of the [MANFAD](https://manfad-project.com/en/) project. The csv file is in the `0-Data` folder and is read by the scripts in `BIA_FILE`.

The following IOTC (Indian Ocean Tuna Commission) datasets are used to calculate the number of FOBs:

- [Instrumented buoy data (Jan 2020 - June 2023)](https://iotc.org/documents/instrumented-buoy-data-january-2020-june-2023) (read in `IOTC_3BU_FILE`)
- [Code list for CWP grids](https://iotc.org/WGFAD/03/Data/00-CWP) (codes for 1° cells used, read in `IOTC_CELLREF_FILE`)

Two other datasets, used to calculate a ratio between DFADs and NLOGs, can be obtained through a datacall to the [Ob7](https://www.ob7.ird.fr/en/pages/datacall.html). This data is collected by observers onboard French purse seine vessels:
- One containing all the operation on floating objects (in `OBSERVERS_FOBFILE`)
- One containing all the vessel activities (operations on FOBs but also sets, etc. in `OBSERVERS_ACTIVITYFILE`)

## References

Data from onboard observers (ObServe): Source IRD/Ob7, co-funded by IRD and the EUMAP program for the collection of fisheries data (DCF). https://www.ob7.ird.fr/pages/datacall.html

Data from onboard observers (ObServe) as part of the OCUP program: Source Orthongel, data processing by IRD/Ob7, co-financed by Orthongel and France Filière Pêche (FFP). https://www.ob7.ird.fr/pages/datacall.html

IOTC. (2023). Instrumented buoy data (Jan 2020—June 2023) (IOTC Ad Hoc Working Group on FADs (WGFAD5) IOTC-2023-WGFAD04-DATA04_Rev1). https://iotc.org/documents/instrumented-buoy-data-january-2020-june-2023
