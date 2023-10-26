# ft_turing

### Contributors
[Jérémy Caudal](https://github.com/Lobbyra)

[Cyrille Lorin](https://github.com/sirius911)

### Introduction
The Turing machine is a mathematical model fairly easy to understand and to implement.
A formal definition is available [here](https://plato.stanford.edu/entries/turing-machine/), or [here](https://www.liafa.jussieu.fr/~carton/Enseignement/Complexite/MasterInfo/Cours/turing.html) for instance.
The ft_turing project is functionnal implementation of a single infinite tape Turing machine.

### Objectives
The goal of this project is to write a program able to simulate a single headed, single tape Turing machine from a machine description provided in json.
This project is to be written in functionnal. OCaml is a solution, but any functionnal
language is allowed. If you use another langage, make sure you respect the functionnal
paradigm. It will be a good occasion to experiment clever type designs and a smart
functionnal approach to your program. This will be checked during evaluation
As stated below, you will be free to use any libraries you like. The project is also a
good opportunity to discover famous and widely used libraries like Core or Batteries
to name a few.

## Machines : 

https://github.com/sirius911/ft_turing/blob/main/machines/README.md

## Make commands
- Build a docker image, build the binary and copy it locally to the host

*all*

- Build the binary locally

*build* 

- Clean the binary

*clean*

- Clean the binary, opam build file and docker images if exists

*fclean*

- Start the tester locally (be sure to have the binary)

*test*

- Display the complexity graph (be sure to have the binary)

*complex* 

*** 

**d** prefix means that run is about docker or run the project in docker.

Be sure to run the *dbuild* rule before the other commands

***

dbuildImg : # Rule to build the image

ddev : # Rule to spawn a shell in the container that have all tool installed

dtest: # Rule to run our tests

dbuild : # Rule to build and copy to the host the binary

dclean : # Rule to delete the docker image

## Complex.py
Usage: python3 complex.py

### thks

- https://github.com/RadioPotin
- https://github.com/MikhailPasechnik
