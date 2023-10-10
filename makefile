# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/25 11:25:31 by clorin            #+#    #+#              #
#    Updated: 2023/10/10 19:54:18 by clorin           ###   ########.fr        #
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
