# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/25 11:25:31 by clorin            #+#    #+#              #
#    Updated: 2023/10/16 16:16:00 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all	:
	dune build
	ln -sf _build/default/srcs/main.exe ft_turing

run : all
	./ft_turing

clean :
	rm -f ./ft_turing

fclean : clean
		rm -rf _build/

re :	fclean all

test : 
	@if [ -f ft_turing ]; then \
		@python3 ./tests/tester.py; \
	else \
		echo "Error: ft_turing not found. Build it using 'make all' first in a docker"; \
	fi
