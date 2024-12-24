# ldimpact

Study of a high speed impact of two flexible rings inside a third larger ring.

This work aims to study the large deformation aspects of this problem through
the use of [Metafor](http://metafor.ltas.ulg.ac.be/dokuwiki/start),
a finite-element code developed by the research group of Prof. J.-P. Ponthot.

This repository holds all the code written for the project carried out as part
of the Large Deformations of Solids course (MECA0464-1), academic year 2024-2025.

## Usage

The top-level directory of the project is considered to be the one where this
README lies.

The code contains a Python template for the Metafor input file, which lies in
`src/template.py`. The user can copy this file in a directory called `res/`,
under a name that is relevant to the simulation that he will carry out. For
example, the user can copy the template file as `res/myTemplate.py`, and modify
it to set the simulation parameters as desired. The simulation can then be
performed in Metafor, which will save a bunch of simulation outputs in the
directory `res/workspace/myTemplate`.

In a second time, the user can use Matlab and the post-processing code that is
contained in the directory `src/pprocess`. For that, it is possible to set the
code execution parameters of the program in the file
`src/pprocess/utils/set_running_arguments.m`. The default values and the
explanation of these defaults parameters lies in the file
`src/pprocess/utils/load_defaults.m`. After configuring the program, one can
simply run the main program:
```matlab
run src/pprocess/main.m
```
By default, this will save a bunch of post-processing results into the `out/`
directory. One can load those output results:
```matlab
load out/myTemplate.mat
```
and carry out further post-processing on these data. For that, several functions
are available in the `src/pprocess/` directory. Each function contains a
docstring that explains its usage.

## Project architecture

- `src/`
  - `template.py` Metafor description file template.
  - `pprocess/` Post-processing Matlab code.
    - `main.m` Trigger all the post-processing code.
    - Set of functions that can be used to analyze the simulation results. The
    user can refer to the docstring of each of these functions.
    - `utils` Utilities that does not provide direct post-processing
    functionalities.
      - `load_defaults.m` Default execution parameters used throughout the source code.
      - `set_running_arguments.m` Override the default code execution parameters.
  - `analysis/` Contains several Matlab or Python script that were used to
  derive the results and analysis presented in the report.
- `res/` Resources files. Contains the saved data of the Metafor simulations.
- `out/` Output files. Contains the post-processed data.
