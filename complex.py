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
import os
import sys

dico = {
    'unary_add': "{'1' * i}+{'1' * i}",
    'unary_sub': "{'1' * i}-{'1' * i}=",
    '02n': "{'0' * i}",
    '0n1n': "{'0' * i}{'1' * i}",
    '0n12n': "{'0' * i}{'11' * i}",
    'X+1': "{'0' * i}{'1' * i}",
}

def generate_input (pattern, max):
    input_sizes = []
    for i in range(1, max + 1):
        input_string = eval(f'f"{pattern}"')
        input_sizes.append(input_string)
    return input_sizes

def calc_complex(machine, max=100):
    pattern = dico[machine]
    input_sizes = generate_input(pattern, max)
    # Initialiser une liste pour stocker les résultats (X, Y)
    results = []
    for input_size in input_sizes:
        # Exécuter la machine de Turing avec l'entrée spécifiée
        command = f"./ft_turing -c machines/{machine}.json {input_size}"
        try:
            output = subprocess.check_output(command, shell=True, text=True)
        except subprocess.CalledProcessError as e:
            print(f"Erreur lors de l'exécution de la commande : {e}")
            exit(0)

        # Analyser la sortie pour obtenir le nombre total d'opérations (Y)
        step_counter = int(output.strip())
        
        # Enregistrer (input_size, nombre de pas) dans la liste des résultats
        results.append((len(input_size), step_counter))

    X, Y = zip(*results)

    #courbes de référence
    X_ref = np.linspace(1, 100, 1000)  # plage de X de 0 à 100
    Y_ref_1 = np.ones_like(X_ref)  # O(1)
    Y_ref_log = np.log2(X_ref)  # O(log n)
    Y_ref_linear = X_ref  # O(n)
    Y_ref_nlogn = X_ref * np.log2(X_ref)  # O(n log n)
    Y_ref_quadratic = X_ref**2  # O(n^2)
    Y_ref_exp = 2**X_ref  # O(2^n)

    # Calculer le facteur de n! pour chaque valeur dans X_ref
    Y_ref_factorial = [np.math.factorial(int(x)) for x in X_ref]  # O(n!)

    plt.plot(X, Y, marker='.', linestyle='-', label=machine, color='blue', linewidth=1.5)
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

    plt.legend()

    plt.xlim(0, 100)
    plt.ylim(0, 300)

    plt.show()

def check(json_file, machine):
    if not(os.path.isfile(json_file)):
        print(f"{json_file} not found.")
        return False
    if not(os.path.islink('ft_turing')) or not(os.access('ft_turing', os.X_OK)):
        print(f"'ft_turing' not found.")
        return False
    if machine not in dico:
        print(f"'{machine}' is not in dictionary to create input for this machine.")
        return False
    return (True)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: complex.py <json_file>")
        sys.exit(1)
    machine = sys.argv[1]
    path = f"machines/{machine}.json"
    if check(path, machine):
        calc_complex(machine)
    print ("end")