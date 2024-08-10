matGasFlow
----------
matGasFlow is a MATLAB Software for steady-state gas flow calculation in
gas transport and distribution grids. 


System Requirements
-------------------
matGasFlow works for MATLAB > R2019b.


Run matGasFlow
--------------
Take a look at .\Examples\main_example.m


Documentation
-------------
Documentation is being prepared.


License and Terms of Use
------------------------
matGasFlow is distributed as open-source under the BSD 3-Clause License.
See LICENSE file for more information.


Publications and citing matGasFlow
----------------------------------
See CITATION file for more information.


AUTHORS
-------
Primary developer:
- Marcel Kurth

Other Contributors:
- Marie-Sophie Heidi Braun
- Andreas Rhein
- Sarah Nesti
- Paul Maximilian Röhrig
- Andreas Blank


CITATION
--------
We request that publications derived from the use of matGasFlow, or the
included data files, explicitly acknowledge that fact by citing the
software, dissertation, or paper as follows:

### Software
    Marcel Kurth (2024). matGasFlow (Version 1.0) [Software]. Institute for
    High Voltage Equipment and Grids, Digitalization and Energy
    Economics (IAEW), RWTH Aachen University. Available:
    https://github.com/RWTH-IAEW/matGasFlow

### Disseration
    Marcel Kurth, "Blending Hydrogen into Natural Gas Networks - Assessing
    Gas Model Inaccuracies and Improving Steady-State Gas Flow
    Calculation Methods". Doctoral Thesis, RWTH Aachen University, 2024

### Paper
    Kurth, Marcel; Braun, Marie-Sophie Heidi; Ulbig, Andreas: "Impact of
    Substituting Hydrogen for Natural Gas on Compressor Station
    Operation in Gas Networks". In: 2023 IEEE PES Innovative Smart Grid
    Technologies Europe (ISGT Europe). IEEE. 2023

### Recommendation
In the interest of facilitating research reproducibility and thereby
increasing the value of your matGasFlow-related research publications, we
encourage you to publish, whenever possible, the code and data required to
generate the results you are publishing.


References
----------
matGasFlow contains content from GasLib (see comp_model_GasLib.m):
    
    Pfetsch et al. (2012) "Validation of Nominations in Gas Network
    Optimization: Models, Methods, and Solutions", ZIB-Report 12-41

matGasFlow contains an implementation of the AGA8-92DC model, published in:
    
    DIN ISO EN 20765-1:2018 Natural gas - Calculation of thermodynamic
    properties - Part 1: Gas phase properties for transmission and
    distribution applications; German version

matGasFlow contains an example of a pandapipes network (see
    Example_gas_network_pandapipes_v0-1-2.json):
    
    Lohmeier, D.; Cronbach, D.; Drauz, S.R.; Braun, M.; Kneiske, T.M.
    Pandapipes: An Open-Source Piping Grid Calculation Package for
    Multi-Energy Grid Simulations. Sustainability 2020, 12, 9899.

Contributing
------------
Contact Marcel Kurth: marcel.kurth@rwth-aachen.de