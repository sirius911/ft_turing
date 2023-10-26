# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/25 11:25:31 by clorin            #+#    #+#              #
#    Updated: 2023/10/18 15:46:16 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Build a docker image, build the binary and copy it locally to the host
all : dbuildImg dbuild

# Build the binary locally
build :
	dune build
	ln -sf _build/default/srcs/main.exe ft_turing

# Clean the binary
clean :
	rm -f ./ft_turing

# Clean the binary, opam build file and docker images if exists
fclean : clean dclean
	rm -rf _build/

# Clean all and build the binary with docker
re : fclean all

# Start the tester locally (be sure to have the binary)
test :
	@python3 ./tests/tester.py;

# Display the complexity graph (be sure to have the binary)
complex :
	@python3 complex.py 

######################################################################
# d prefix means that run is about docker or run the project in docker
# Be sure to run the *dbuild* rule before the other commands
#####
dbuildImg : # Rule to build the image
	docker build -f docker_ocaml/dockerfile_run -t ft_turing_run .

ddev : # Rule to spawn a shell in the container that have all tool installed
	docker run -it --rm --name turing ft_turing_run /bin/bash

dtest: # Rule to run our tests
	docker run -it --rm ft_turing_run /bin/sh -c "make build && make test"

dbuild : # Rule to build and copy to the host the binary
	docker run --rm --name turing ft_turing_run /bin/sh -c "make build && tail -f" &
	@echo "Waiting for the container to start"
	sleep 10
	docker cp turing:/home/opam/ft_turing/_build/default/srcs/main.exe ft_turing
	docker kill turing

dclean : # Rule to delete the docker image
	docker rmi -f ft_turing_run
