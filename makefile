# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/25 11:25:31 by clorin            #+#    #+#              #
#    Updated: 2023/09/15 13:17:23 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

RESULT = ft_turing

SOURCES = 	srcs/colors.ml \
			srcs/utils.ml  \
			srcs/tape.ml \
			srcs/machine.ml \
			srcs/interactive_mode.ml \
			srcs/main.ml
LIBS = yojson
OCAMLMAKEFILE = OCamlMakefile
include $(OCAMLMAKEFILE)
