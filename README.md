# LOTUS - Long-Haul Truck Simulation

Stand Alone Version of the longitudinal dynamics, weight and cost model of the Truck2030 project (formerly named HDVSim).  
Please also see the project homepage [Truck2030](https://www.mw.tum.de/en/ftm/main-research/vehicle-concepts/truck-2030-bavarian-cooperation-for-transport-efficiency/) and our [researchgate profile](https://www.researchgate.net/project/Truck2030) to find more information about us and our work.


## Steps for running the simulation
1. Open the script called Main_file.m; most of the simulation parameters
  and properties can be accessed there.

2. Choose whether the values after the optimization or custome values to
  be run. This is controlled by the flag "ifOptimized".

3. If optimized values are chosen, assign 1 to ifOptimized and choose
  which vehicle is needed to run by assigning a number from 1 to 16 to
  the variable "DrvTrn".

4. If custom values are needed, assign 0 to ifOptimized. Then choose the
  type of fuel to run by uncommenting the required line in "Fuel type"
  block. After that, assign the custom values to the parameters found in
  Parameterizing().

5. Choose which driving cycle is needed by uncommenting the required line
  in the "Driving cylce" block.

6. Some simulation properties regarding the results can be adjusted. If
  displaying figures is required, assign 2 to Param.VSim.Display;
  otherwise leave it as 3. If output results in te command window is not
  needed, then assign "True" to the variable Param.VSim.Opt; otherwise
  leave it as "False". This is found in "Simulation properties" block.

7. When everything is set up, click on run. The steps will be shown in the
  command window, and a notification will indicate whether the simulation
  was successful or not. In the case of success, the results will be save
  in the folder "Results".

### Prerequisites

* Matlab
* Curve Fitting Toolbox
* Optimization Toolbox
* Simulink
* Simscape
* Powertrain Blockset
* Simscape Electrical (Replaces Simscape Power Systems and Simscape Electronics 2018b and later)
* Simscape Power System (2018a and earlier)
* Simscape Electronics (2018a and earlier)
* Stateflow
* Simulink Coder
* Parallel Computing

## Running the Model/Code
For basic simulation
```
Main_file.m
```

C. Mährle, S. Wolff, S. Held, und G. Wachtmeister, “Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning,” in The 2019 IEEE Intelligent Transportation Systems Conference - ITSC: Auckland, New Zealand, 27-30 October 2019, [Piscataway, New Jersey]: IEEE, 2019, S. 1251–1256.
```
platooningEvaluationParfor
```

S. Wolff, M. Fries, und M. Lienkamp, “Technoecological analysis of energy carriers for long‐haul transportation,” Journal of Industrial Ecology, Bd. 49, Rn. 11, S. 6402, 2019.
```
addpath('Post-processing\JIE');
Infrastruktur_Fahrzeuge_Auswertung
Auswertung_JounralIndEco
```

S. Wolff, S. Kalt, M. Bstieler, und M. Lienkamp, “Influence of Powertrain Topology and Electric Machine Design on Efficiency of Battery Electric Trucks–A Simulative Case-Study,” Energies, Bd. 14, Rn. 2, S. 328, 2021.
```
topologiesMain
```

## Deployment
Built with

* [Matlab](https://de.mathworks.com/products/matlab.html) R2018b

Tested with
* Matlab R2017b
* Matlab R2019b



## Contributing and Support

If you want to contribute to this project, please contact the correspondence author.

## Versioning
V1.0 Consumption simulation, weight and cost model for heavy-duty trucks

V1.1 Powertrain topologies for electric heavy-duty trucks and VECTO driving cycles


## Authors
Alexander Süßmann - Consumption Simulation for Diesel Trucks, Validation

Michael Fries - Hybrid Drivetrains, CNG, LNG, Dual Fuel, Cost and Weight Model

Sebastian Wolff* - Battery Electric, Fuel Cell, Overhead Catenary/Inductive Charging, 3 Truck Platooning, Infrastructure Cost Model, Electric Powertrain Topologies

*Correspondence Author  
sebastian.wolff[at]tum.de  
Technical University of Munich  
Institute of Automotive Technology

## Contributors (chronological order)
The following authors contributed substantial parts to the simulation during their student thesis's.

* Bert Haj Ali
* Stefan Weiß
* Cheng Pan
* Aonan Shen
* Moritz Seidenfus
* Paul Mauk
* Maunel Bstieler
* Niclas Eidkum


## License
This project is licensed under the LGPL 3.0 License - see the LICENSE.md file for details


## Publications
The simulation is featured in the following publications:
### Dissertations

* M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,” Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.

### Articles

* M. Fries, M. Kruttschnitt, und M. Lienkamp, “Multi-objective optimization of a long-haul truck hybrid operational strategy and a predictive powertrain control system,” in Twelfth International Conference on Ecological Vehicles and Renewable Energies (EVER), 2017, S. 1–7.
* M. Fries, M. Lehmeyer, und M. Lienkamp, “Multi-criterion optimization of heavy-duty powertrain design for the evaluation of transport efficiency and costs,” in IEEE ITSC 2017: 20th International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2017, S. 1–8.
* M. Fries, A. Baum, M. Wittmann, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in 2018 21st International Conference on Intelligent Transportation Systems (ITSC): IEEE, 2018, S. 2550–2555.
* S. Wolff, M. Fries, und M. Lienkamp, “Technoecological analysis of energy carriers for long‐haul transportation,” Journal of Industrial Ecology, Bd. 49, Rn. 11, S. 6402, 2019.
* S. Wolff, S. Kalt, M. Bstieler, und M. Lienkamp, “Influence of Powertrain Topology and Electric Machine Design on Efficiency of Battery Electric Trucks–A Simulative Case-Study,” Energies, Bd. 14, Rn. 2, S. 328, 2021.

### Reports
* C. Mährle et al, “Bayerische Kooperation für Transporteffizienz - Truck2030: Status Report 2016,” 2017.
