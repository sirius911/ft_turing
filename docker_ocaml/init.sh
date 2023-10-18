#!/bin/bash
sudo apt-get update && \
sudo apt-get upgrade opam -y && \
opam install dune ocamlfind yojson
sudo apt install python3-pip -y
pip install --break-system-packages -r ./tests/requirements.txt
