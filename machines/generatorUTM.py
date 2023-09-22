#! /bin/python3

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    generatorUTM.py                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/18 15:21:11 by clorin            #+#    #+#              #
#    Updated: 2023/09/20 13:56:22 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

import json
import sys
import os

def st(read, to_state, write, action):
    return dict(read=read, to_state=to_state, write=write, action=action)
def filtrer(l, *c):
    return list(filter(lambda v: v not in c, l))
def generator(data):
    tape_symbols = (
    '&'+  # Symbole de début des transitions
    ':'+  # Symbole séparant transition et input appelé null
    '^'+  # Symbole de pointeur
    '{}'+ # Bloc d'état
    '[]'+ # Bloc de règles
    '<>'  # Direction
)
    L = "LEFT"
    R = "RIGHT"
    UTM_blank = " " # blank caractère for UTM
    #generate state name A-Y  (Z fo HALTING States)
    real_states_name = data.get("states", [])
    state_mapping = generate_state_mapping(real_states_name, data.get("finals", []))
    state_list = ''.join([state_mapping[state] for state in real_states_name])
    name = data.get('name',"")
    vblank = data.get("blank", " ") # blank of machine
    halt_state = 'Z'    #reserved
    alpha_machine = data.get("alphabet", []) #alphabet of the Machine
    li =("".join(alpha_machine) + UTM_blank
    )
    alphabets = tape_symbols + state_list + li
    transitions = [
        (   # a chaque Etat on associe un goto-null
            "init", [
                st(state, f"goto-null-{state}", state, R) for state in state_list
            ],
        ),
    ] + [
        (# transitions pour aller chercher ":" (null)
            f"goto-null-{state}", [
                st(c, f"goto-null-{state}", c, R) for c in filtrer(alphabets, ":")
            ] + [st(":", f"goto-state-{state}", ":", R)], #on trouve : -> goto-state
        ) for state in state_list
    ] + [
        (
            f"goto-state-{state}", [
                st(c, f"init-find-{state}:{(c if c != UTM_blank else vblank)}", "^", L) for c in li
            ] if state != halt_state else [
                st(c, "HALT", c, R) for c in li
            ]
        ) for state in state_list
    ] + [
        ( # transitions pour revenir aux début des transitions
            f"init-find-{state}:{input}", [
                st(c, f"init-find-{state}:{input}", c, L) for c in filtrer(alphabets, "&")
            ] + [
                st("&", f"find-state-{state}({input})", "&", R) #On est au début
            ]
        ) for state in state_list for input in li
    ] + [
        (
            f"find-state-{state}({input})", [ #On cherche la transition "CSPH" : x{[]} pour chaque input
                st(c, f"find-state-{state}({input})", c, R) for c in filtrer(li+tape_symbols, ":")
            ] + [
                st(state, f"check-op-{state}({input})", state, R) #On est dans la transition
            ] + [ # on rajoute les transition pour les autres états que state
                st(s, f"find-state-{state}({input})", s, R) for s in filtrer(state_list, state)
            ]
        ) for state in state_list for input in li
    ] + [
        ( # On a trouver l'état -> on Check si on est dans le block de cette état
            f"check-op-{state}({input})", [
                st("{", f"cmp-read-{state}({input})", "{", R) #oui début de block on compare Read et input
            ] + [
                st(c, f"find-state-{state}({input})", c, R) for c in alphabets #non on continue a chercher (find-state)
            ]
        ) for state in state_list for input in li
    ] + [
        ( # on est dans le block
            f"cmp-read-{state}({input})", [
                st("[", f"cmp-read-{state}({input})", "[", R) # on avance
            ] + [
                st(input, f"get-state-{input}", input, R) # On a correspondance (Etat, input) 
            ] + [ # pas de correspondance on cherche la prochaine transition
                st(c, f"to-next-trans-{state}({input})", c, R) for c in filtrer(alphabets, input, "[") #j'ai enlever '}' du filtre
            ]
        ) for state in state_list for input in li
    ] + [
        (# On associe a chaque état un get-dir pour trouver la direction
            f"get-state-{input}", [
                st(s, f"get-dir-{s}", s, R) for s in state_list
            ]
        ) for input in li
    ] + [
        ( # pour chaque état un état transistion pour < et >
            f"get-dir-{state}", [
                st(d, f"get-write-{state}:{d}", d, R) for d in "<>"
            ]
        ) for state in state_list
    ] + [
        (
            f"get-write-{state}:{d}", [
                st(c, f"eval-{d}({c})~{state}", c, R) for c in li
            ]
        ) for state in state_list for d in "<>"
    ] + [
        ( # on cherche a sortir du block
            f"to-next-trans-{state}({input})", [
                st("]", f"cmp-read-{state}({input})", "]", R) #on relance la recherche
            ] + [ #on est pas sortie
                st(c, f"to-next-trans-{state}({input})", c, R) for c in filtrer(alphabets, "}", "]") 
            ]
        ) for state in state_list for input in li
    ] + [
        ( # on cherche  le pointeur ^ pour le remplacer par input
            f"eval-{d}({input})~{state}", [
                st(c, f"eval-{d}({input})~{state}", c, R) for c in filtrer(alphabets, "^")
            ] + [
                st("^", f"goto-state-{state}", input, R if d == ">" else L)
            ]
        ) for state in state_list for d in "<>"  for input in li
    ]
    return dict(
        name = f"UTM_{name}",
        alphabet = list(alphabets),
        blank = UTM_blank,
        states = list(dict(transitions).keys()) + ["HALT"],
        initial = "init",
        finals = ["HALT"],
        transitions = dict(transitions),
    )

def valid(cfg):
    alphabet = cfg['alphabet']
    errors = []

    for state, transitions in cfg['transitions'].items():
        for t in transitions:
            if t['read'] not in alphabet:
                errors.append(f"Error: '{t['read']}' read not in {alphabet}")
            if t['to_state'] not in cfg['states']:
                errors.append(f"Error: '{t['to_state']}' not in {cfg['states']}")
            if t['write'] not in alphabet:
                errors.append(f"Error: '{t['write']}' write not in alphabet")

    if errors:
        for error in errors:
            print(error)
        return None  # ou tout autre code de sortie pour indiquer une configuration invalide
    else:
        return cfg


def print_correspondance(data):
    state_mapping = generate_state_mapping(data.get('states',[]), data.get('finals',[]))
    print("\t*** correspondances (states:UTM_states)***")
    for state, new in state_mapping.items():
        print(f"{state}:{new}, ", end='')
    print("")

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

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage : python3 generator.py file.json")
        sys.exit(1)

    fichier_json = sys.argv[1]
    data = load_json(fichier_json)
    path = os.path.dirname(fichier_json)
    file_name = os.path.splitext(os.path.basename(fichier_json))[0]
    utm_file = os.path.join(path, f"UTM_{file_name}.json")

    result_json = json.dumps(valid(generator(data)), indent=4)
    with open(utm_file, "w") as f:
        print(f"Create '{utm_file}' ... ", end= '')
        f.write(result_json)
        print ("Ok")

    commands = create_commands(data)
    print(f"The alphabet of {fichier_json} is {data.get('alphabet',[])}")
    print_correspondance(data)
    print ("\t***** The transitions codes *****")
    print (commands)
    print ("\t *** Warning dont forget input after the ':' of the transitions code. ***")
    print ("Good luck !")
