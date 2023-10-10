#!/bin/bash
sudo pat-get update
sudo apt-get upgrade opam -y
opam install dune
opam install ocamlfind
opam install yojson