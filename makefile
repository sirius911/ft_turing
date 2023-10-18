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

all :
	dune build
	ln -sf _build/default/srcs/main.exe ft_turing

run : all
	./ft_turing

clean :
	rm -f ./ft_turing

fclean : clean
	rm -rf _build/

re : fclean all

test : all
	@python3 ./tests/tester.py;

complex : all
	@python3 complex.py 

######################################################################
# d prefix means that run is about docker or run the project in docker
# Be sure to run the *dbuild* rule before the other commands
#####
dbuild :
	docker build -f docker_ocaml/dockerfile_run -t ft_turing_run .

ddev :
	docker run -it --rm --name turing ft_turing_run /bin/bash 

dtest:
	docker run -it --rm ft_turing_run make test

