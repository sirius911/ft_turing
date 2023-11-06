#! /bin/python3

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    generator_cmd.py                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/20 16:12:53 by clorin            #+#    #+#              #
#    Updated: 2023/09/20 16:14:55 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

import sys
import json

def generate_state_mapping(states, finals):
    state_mapping = {}
    current_letter = 'A'

    for state in states:
        if state in finals:
            state_mapping[state] = 'Z'
        else:
            state_mapping[state] = current_letter
            current_letter = chr(ord(current_letter) + 1)
    return state_mapping

def print_correspondance(data):
    state_mapping = generate_state_mapping(data.get('states',[]), data.get('finals',[]))
    print("\t*** correspondances (states:UTM_states)***")
    for state, new in state_mapping.items():
        print(f"{state}:{new}, ", end='')
    print("")

def create_commands(data):

    if data != None:
        states = data.get("states", [])
        initial = data.get("initial", "")
        finals = data.get("finals", [])
        transitions = data.get("transitions", {})
        state_mapping = generate_state_mapping(states, finals)
        command_str = f"{state_mapping[initial]}&"
        for state in states:
            if state not in finals:
                newn = state_mapping[state]
                command_str += newn + '{'
                for t in transitions.get(state,[]):
                    read = t.get('read',"")
                    to_state = t.get('to_state','')
                    write = t.get('write','')
                    action = '<' if t.get('action','') == 'LEFT' else '>'
                    command_str += f"[{read}{state_mapping[to_state]}{action}{write}]"
                command_str += '}'
        command_str += ":"
        return command_str
    else:
        return "No commands for None data !"

def load_json(nom_fichier):
    """
    Load nom_fichier and return an Object Json or None
    """
    try:
        with open(nom_fichier, 'r') as fichier:
            data = json.load(fichier)
        return data
    except FileNotFoundError:
        print(f"Fichier {nom_fichier} introuvable.")
        return None
    except json.JSONDecodeError:
        print(f"Erreur lors de la lecture du fichier JSON {nom_fichier}.")
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage : python3 generator.py file.json")
        sys.exit(1)

    fichier_json = sys.argv[1]
    data = load_json(fichier_json)

    commands = create_commands(data)
    print(f"The alphabet of {fichier_json} is {data.get('alphabet',[])}")
    print_correspondance(data)
    print ("\t***** The transitions codes *****")
    print (commands)
    print ("\t *** Warning dont forget input after the ':' of the transitions code. ***")
    print ("Good luck !")