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
import math
import os
import sys
import docker

dico = {
    'unary_add': "{'1' * i}+{'1' * i}",
    'unary_sub': "{'1' * i}-{'1' * i}=",
    '02n': "{'0' * i}",
    '0n1n': "{'0' * i}{'1' * i}",
    '0n12n': "{'0' * i}{'11' * i}",
    'X+1': "{'0' * i}{'1' * i}",
    'X-1': "{'1' * i}{'0' * i}",
    'X+Y': "{'1' * i}{'0' * i}+{'1' * i}{'0' * i}=",
    'palindrome': "{'0' * i}{'1' * i}",
    'palindrome_letters': "{'a' * i}{'b' * i}{'c' * i}",
}

def generate_input (pattern, max):
    input_sizes = []
    for i in range(1, max + 1):
        input_string = eval(f'f"{pattern}"')
        input_sizes.append(input_string)
    return input_sizes

def calc_complex(container, machine, max=100):
    pattern = dico[machine]
    input_sizes = generate_input(pattern, max)
    # Initialiser une liste pour stocker les résultats (X, Y)
    results = []
    for input_size in input_sizes:
        # Exécuter la machine de Turing avec l'entrée spécifiée
        command = f"./ft_turing -c machines/{machine}.json {input_size}"
        try:
            if (container):
                exec_result = container.exec_run(command)
                output = exec_result.output.decode("utf-8").strip()
            else:
                output = subprocess.check_output(command, shell=True, text=True)
        except docker.errors.ContainerError as e:
            print(f"Error during command execution : {e}")
            exit(0)
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
    Y_ref_factorial = [math.factorial(int(x)) for x in X_ref]  # O(n!)

    plt.plot(X, Y, marker='.', linestyle='-', label=machine, color='blue', linewidth=1.5)
    plt.plot(X_ref, Y_ref_1, linestyle='-', label='O(1)', color='red', linewidth=1)
    plt.plot(X_ref, Y_ref_log, linestyle='-', label='O(log n)', color='green', linewidth=1)
    plt.plot(X_ref, Y_ref_nlogn, linestyle='-', label='O(n log n)', color='orange', linewidth=1)
    plt.plot(X_ref, Y_ref_linear, linestyle='-', label='O(n)', color='cyan', linewidth=1)
    plt.plot(X_ref, Y_ref_quadratic, linestyle='-', label='O(n^2)', color='black', linewidth=1)
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

def check_machine(json_file, machine):
    if not(os.path.isfile(json_file)):
        print(f"{json_file} not found.")
        return False
    if machine not in dico:
        print(f"'{machine}' is not in dictionary to create input for this machine.")
        return False
    return (True)

def check_ft_turing():
    # if not(os.path.islink('ft_turing')) or not(os.access('ft_turing', os.X_OK)):
    if not(os.path.isfile('ft_turing')):
        print(f"'ft_turing' not found.")
        exit(0)

def check_container(container):
    command = "ls ./ft_turing"
    try:
        return_code = container.exec_run(command).exit_code
        if (return_code != 0):
            print(f"'ft_turing is not compiled, please compile in docker ")
            return False
        else:
            return True
    except docker.errors.ContainerError as e:
        print(f"Docker error when checking for the existence of 'ft_turing' in the container: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error : {e}")
        return False

def get_docker():
    print("Searching container 'turing' ... ", end='')
    try:
        container = docker.from_env()
        return(container.containers.get('turing'))
    except docker.errors.NotFound as e:
        print(f"Not Found.")
        return None

if __name__ == "__main__":
    machine = ""
    if len(sys.argv) == 2:
        machine = sys.argv[1]
    while machine not in dico:
        machine = input ("Enter the name of Machine or list : ")
        if (machine == "list"):
            for cle in dico.keys():
                print(f"\t[{cle}]")
    container_turing = get_docker()
    if (container_turing):
        print("Ok")
        if not check_container(container_turing):
            exit(0)
    else:
        print("searching './ft_turing' ... ", end='')
        check_ft_turing()
        print("Ok")
    path = f"machines/{machine}.json"
    if check_machine(path, machine):
        if machine == "X+Y":
            max = 5
        else:
            max = 100
        calc_complex(container_turing, machine, max)
    print ("end")
