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
import numpy as np

# Commande à exécuter
# command = "./ft_turing -c machines/unary_add.json 111+1"

# Exécutez la commande et capturez la sortie
# try:
#     result = subprocess.check_output(command, shell=True, text=True)
#     print(result)
# except subprocess.CalledProcessError as e:
#     print(f"Erreur lors de l'exécution de la commande : {e}")

# Définissez une liste d'entrées de test de différentes tailles (X)
# input_sizes = ["11+1", "11+11", "111+111", "1111+1111", "11111+11111"]


def generate_input_add(max_ones):
    input_sizes = []
    for i in range(1, max_ones + 1):
        input_sizes.append(f"{'1' * i}+{'1' * i}")
    return input_sizes

def generate_input_sub(max_ones):
    input_sizes = []
    for i in range(1, max_ones + 1):
        input_sizes.append(f"{'1' * i}-{'1' * i}=")
    return input_sizes

def generate_input_02n(max_ones):
    input_sizes = []
    for i in range(1, max_ones + 1):
        input_sizes.append(f"{'0' * i}")
    return input_sizes

def generate_input_0n1n(max_ones):
    input_sizes = []
    for i in range(1, max_ones + 1):
        input_sizes.append(f"{'0' * i}{'1' * i}")
    return input_sizes

def generate_input_0n12n(max_ones):
    input_sizes = []
    for i in range(1, max_ones + 1):
        input_sizes.append(f"{'0' * i}{'11' * i}")
    return input_sizes

# Initialisez une liste pour stocker les résultats (X, Y)
results = []
input_sizes = generate_input_0n12n(100)

# mt = "machines/unary_add.json"
# mt = "machines/unary_sub.json"
mt = "0n12n"
for input_size in input_sizes:
    # Exécutez la machine de Turing avec l'entrée spécifiée


    command = f"./ft_turing -c machines/{mt}.json {input_size}"
    try:
        output = subprocess.check_output(command, shell=True, text=True)
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

# Créer des courbes de référence
X_ref = np.linspace(1, 100, 1000)  # Ajustez la plage de X de 0 à 100
Y_ref_1 = np.ones_like(X_ref)  # O(1)
Y_ref_log = np.log2(X_ref)  # O(log n)
Y_ref_linear = X_ref  # O(n)
Y_ref_nlogn = X_ref * np.log2(X_ref)  # O(n log n)
Y_ref_quadratic = X_ref**2  # O(n^2)
Y_ref_exp = 2**X_ref  # O(2^n)

# Calculer le facteur de n! pour chaque valeur dans X_ref
Y_ref_factorial = [np.math.factorial(int(x)) for x in X_ref]  # O(n!)

# Utilisez une échelle logarithmique pour l'axe des Y
# plt.yscale("log")

plt.plot(X, Y, marker='.', linestyle='-', label=mt, color='blue', linewidth=1.5)
plt.plot(X_ref, Y_ref_1, linestyle='-', label='O(1)', color='red', linewidth=1)
plt.plot(X_ref, Y_ref_log, linestyle='-', label='O(log n)', color='green', linewidth=1)
plt.plot(X_ref, Y_ref_nlogn, linestyle='-', label='O(n log n)', color='orange', linewidth=1)
plt.plot(X_ref, Y_ref_linear, linestyle='-', label='O(n)', color='cyan', linewidth=1)
plt.plot(X_ref, Y_ref_exp, linestyle='-', label='O(2^n)', color='pink', linewidth=1)
plt.plot(X_ref, Y_ref_factorial, linestyle='-', label='O(n!)', color='brown', linewidth=1)

plt.xlabel('Elements')
plt.ylabel('Operations')
plt.title('Big-O Complexity')
plt.grid(True)

# Ajouter une légende
plt.legend()

plt.xlim(0, 100)  # Ajustez la plage de l'axe des X de 0 à 100
plt.ylim(0, 300)  # Ajustez la plage de l'axe des Y de 0 à 1000

plt.show()