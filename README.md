# HDVSim - Truck 2030 Longitudinal Dynamics Simulation
  
Stand Alone Version of the longitudinal dynamics, weight and cost model of the Truck2030 project.  
Please also see the project homepage [Truck2030](https://www.truck2030.tum.de/home/) and our [researchgate profile](https://www.researchgate.net/project/Truck2030) to find more information about us and our work.

  
## Steps for running the simulation
1-Open the script called Main_file.m; most of the simulation parameters
  and properties can be accessed there.

2-Choose whether the values after the optimization or custome values to
  be run. This is controlled by the flag "ifOptimized".

3-If optimized values are chosen, assign 1 to ifOptimized and choose
  which vehicle is needed to run by assigning a number from 1 to 16 to
  the variable "DrvTrn".

4-If custom values are needed, assign 0 to ifOptimized. Then choose the
  type of fuel to run by uncommenting the required line in "Fuel type"
  block. After that, assign the custom values to the parameters found in
  Parameterizing().

5-Choose which driving cycle is needed by uncommenting the required line 
  in the "Driving cylce" block.

6-Some simulation properties regarding the results can be adjusted. If
  displaying figures is required, assign 2 to Param.VSim.Display;
  otherwise leave it as 3. If output results in te command window is not
  needed, then assign "True" to the variable Param.VSim.Opt; otherwise
  leave it as "False". This is found in "Simulation properties" block.

7-When everything is set up, click on run. The steps will be shown in the
  command window, and a notification will indicate whether the simulation
  was successful or not. In the case of success, the results will be save
  in the folder "Results".

### Prerequisites

* Matlab
* Curve Fitting Toolbox
* Optimization Toolbox
* Simulink
* Simscape
* Power System Blocks
* Stateflow
* Simscape Electrical
* Simulink Coder
* Parallel Computing
 
## Running the Model/Code
For basic simulation
```
Main_file.m
```

Mährle, Wolff et al. - Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning
```
platooningEvaluationParfor
```

Wolff, Fries, Lienkamp - Techno-Ecological Analysis of Energy Carriers for Long-Haul Transportation
```
addpath('Post-processing\JIE');
Infrastruktur_Fahrzeuge_Auswertung
Auswertung_JounralIndEco
```
  
## Deployment
Built With
  
* [Matlab](https://de.mathworks.com/products/matlab.html) R2018b
  
  
## Contributing and Support
  
If you want to contribute to this project, please contact the correspondance author.
  
## Versioning
V1.0 Consumption Simulation, Weight and Cost Model for Heavy Duty Trucks

  
## Authors
Alexander Süßmann - Consumption Simulation for Diesel Trucks

Michael Fries - Hybrid Drivetrains, CNG, LNG, Dual Fuel, Cost and Weight Model

Sebastian Wolff* - Fuel Cell, Overhead Catenary/Inductive Charging, 3 Truck Platooning, Infrastrucutre Cost Model

*Correspondance Author  
sebastian.wolff[at]tum.de  
Technical University of Munich  
Institute of Automotive Technology

See also the list of contributors who participated in this project.
  
## License
This project is licensed under the LGPL 3.0 License - see the LICENSE.md file for details
 
 
## Sources
### Dissertations

* M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,�? Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.

### Papers

* C. Mährle, S. Wolff, S. Held, G. Wachtmeister - "Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning", 2019
* S. Wolff, M. Fries, M. Lienkamp - "Techno-Ecological Analysis of Energy Carriers for Long-Haul Transportation", 2019.
* M. Fries, M. Sinning, M. Lienkamp, und M. Höpfner - "Virtual Truck - A Method for Customer Oriented Commercial Vehicle Simulation", 2016.
* C. Mährle et al, “Bayerische Kooperation für Transporteffizienz - Truck2030 - Status Report 2016 -,�? 2017.
* M. Fries, M. Kruttschnitt, und M. Lienkamp, “Multi-objective optimization of a long-haul truck hybrid operational strategy and a predictive powertrain control system,�? in Twelfth International Conference on Ecological Vehicles and Renewable Energies (EVER), 2017, S. 1–7.
* M. Fries, S. Wolff, und M. Lienkamp, “Optimization of Hybrid Electric Drive System Components in Long-Haul Vehicles for Evaluation of Transport Efficicency and TCO,�? Technische Universität München, München, 2017.
* M. Fries, M. Lehmeyer, und M. Lienkamp, “Multi-criterion optimization of heavy-duty powertrain design for the evaluation of transport efficiency and costs,�? in IEEE ITSC 2017: 20th International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2017, S. 1–8.
* O. Olsson, “Slide-in Electric Road System: Inductive project report,�? Viktoria Swedish ICT, Göteborg, Okt. 2013. Gefunden am: Nov. 29 2017.
* M. Wietschel und et. al, “Machbarkeitsstudie zur Ermittlung der Potentiale des Hybrid-Oberleitungs-Lkw,�? Fraunhofer Institut für System und, Karlsruhe, 2017.
* M. Fries et al, “An Overview of Costs for Vehicle Components, Fuels, Greenhouse Gas Emissions and Total Cost of Ownership Update 2017,�? 2017.
* L. C. den Boer, Zero Emissions Trucks: An Overview of State-of-the-art Technologies and Their Potential : Report: CE Delft, 2013.
* Jason Marcinkoski, Jacob Spendelow, Adria Wilson, and Dimitrios Papageorgopoulos, U.S. Department of Energy, “DOE Fuel Cell Technologies Office Record: Fuel Cell System Cost,�? Washington DC, USA, 2015. [Online] Verfügbar: https://www.hydrogen.energy.gov/pdfs/15015_fuel_cell_system_cost_2015.pdf. Gefunden am: Feb. 08 2018.
* W. Artl, “Wasserstoff und Speicherung im Schwerlastverkehr: Machbarkeitsstudie,�? Friedrich-Alexander Universität Erlangen-Nürnberg, Erlangen, 2018. [Online] Verfügbar: https://www.tvt.cbi.uni-erlangen.de/LOHC-LKW_Bericht_final.pdf. Gefunden am: Mai. 02 2018.
* The Fuel Cell | Powercell Sweden AB. [Online]: http://www.powercell.se/technology_head/the-fuel-cell. Gefunden am: Feb. 23 2018.
* L. Horlbeck et al, “Description of the modelling style and parameters for electric vehicles in the concept phase,�? Technische Universität München, München, 2014. Gefunden am: Nov. 21 2016.
 






