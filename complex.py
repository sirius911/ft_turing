#! /bin/python3

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    complex.py                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: clorin <clorin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/21 10:23:38 by clorin            #+#    #+#              #
#    Updated: 2023/09/21 10:23:38 by clorin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

import subprocess
import matplotlib.pyplot as plt

# Commande à exécuter
# command = "./ft_turing -c machines/unary_add.json 111+1"

# Exécutez la commande et capturez la sortie
# try:
#     result = subprocess.check_output(command, shell=True, text=True)
#     print(result)
# except subprocess.CalledProcessError as e:
#     print(f"Erreur lors de l'exécution de la commande : {e}")

# Définissez une liste d'entrées de test de différentes tailles (X)
input_sizes = ["1+1", "11+11", "111+111", "1111+1111", "11111+11111"]

# Initialisez une liste pour stocker les résultats (X, Y)
results = []

for input_size in input_sizes:
    # Exécutez la machine de Turing avec l'entrée spécifiée
    command = f"./ft_turing -c machines/unary_add.json {input_size}"
    try:
        output = subprocess.check_output(command, shell=True, text=True)
        print(output)
    except subprocess.CalledProcessError as e:
        print(f"Erreur lors de l'exécution de la commande : {e}")
        exit(0)

    # Analysez la sortie pour obtenir le nombre total d'opérations (Y)
    # (Vous devrez extraire cette information de la sortie de votre machine)
    step_counter = int(output.strip())
    
    # Enregistrez (input_size, nombre de pas) dans la liste des résultats
    results.append((len(input_size), step_counter))

# Créez un graphique à partir des résultats
X, Y = zip(*results)
plt.plot(X, Y, marker='o', linestyle='-')
plt.xlabel('Taille de l\'entrée (X)')
plt.ylabel('Nombre total d\'opérations (Y)')
plt.title('Complexité temporelle de l\'algorithme')
plt.grid(True)
plt.show()

