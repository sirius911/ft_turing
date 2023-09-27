# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/25 11:25:31 by clorin            #+#    #+#              #
#    Updated: 2023/09/27 09:34:30 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

RESULT = ft_turing

SOURCES = 	srcs/types.ml \
			srcs/colors.ml \
			srcs/utils.ml \
			srcs/tape.mli \
			srcs/tape.ml \
			srcs/parsing.ml \
			srcs/machine.mli \
			srcs/machine.ml \
			srcs/interactive_mode.ml \
			srcs/main.ml
LIBS = yojson
OCAMLMAKEFILE = OCamlMakefile
include $(OCAMLMAKEFILE)
