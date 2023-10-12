# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    gen_palindrome.py                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/10/12 15:13:56 by clorin            #+#    #+#              #
#    Updated: 2023/10/12 17:51:15 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


def st(read, to_state, write, action):
    return dict(read=read, to_state=to_state, write=write, action=action)

liste_caracteres = [chr(lettre) for lettre in range(ord('a'), ord('z') + 1)]

for c in liste_caracteres:
    print(f'"check{c}": [')
    for caractere in liste_caracteres:
        print (f'\t{{ "read" : "{caractere}", "to_state" : "erase{c}", "write" : "{caractere}", "action" : "RIGHT" }},')
    print('\t{ "read" : ".", "to_state" : "print_y", "write": ".", "action": "RIGHT" }\n],')