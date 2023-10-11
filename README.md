# ft_turing

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

https://github.com/sirius911/ft_turing/blob/main/machines/machines.md

## Build Docker Image
To build de Docker image : 
in docker_ocaml/
run ./build.sh

## to execute container : 
./ocaml

## Complex.py
Usage: python3 complex.py <Machine name>
        [unary_add]
        [unary_sub]
        [02n]
        [0n1n]
        [0n12n]
        [X+1]
        [palindrome]

### thks

- https://github.com/RadioPotin
- https://github.com/MikhailPasechnik
