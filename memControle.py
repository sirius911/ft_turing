import os
import subprocess
import psutil
import matplotlib.pyplot as plt
import time

# Fonction pour récupérer le PID du processus "ft_turing"
def get_pid_by_name(process_name):
    print(f"En attente du processus '{process_name}'...")
    while True:
        for process in psutil.process_iter(attrs=['pid', 'name']):
            if process.info['name'] == process_name:
                return process.info['pid']
        time.sleep(1)  # Attendre une seconde si le processus n'est pas encore démarré

# Fonction pour exécuter la commande "pmap" et récupérer la quantité de mémoire
def get_memory_usage(pid):
    cmd = f'pmap {pid} | grep "total"'
    result = subprocess.check_output(cmd, shell=True, text=True)
    memory_str = result.split()[1]  # Extrait la quantité de mémoire (en KB)
    memory_str = memory_str.rstrip('K')  # Supprime le "K" à la fin de la chaîne
    return float(memory_str) / 1024  # Convertit en MB et retourne un flottant

if __name__ == "__main__":
    process_name = "ft_turing"
    pid = get_pid_by_name(process_name)
    
    if pid is None:
        pid = get_pid_by_name(process_name)  # Attendre que le processus soit lancé
    
    if pid is not None:
        memory_usage_history = []
        time_history = []
        
        try:
            start_time = time.time()
            while True:
                if not psutil.pid_exists(pid):
                    print(f"Le processus '{process_name}' n'existe plus. Arrêt de la surveillance.")
                    break
                memory_usage = get_memory_usage(pid)
                memory_usage_history.append(memory_usage)
                print(".", end='')
                # Calcul du temps écoulé en secondes
                elapsed_time = time.time() - start_time
                time_history.append(elapsed_time)

                # Affichage du graphique en temps réel
                plt.plot(time_history, memory_usage_history)
                plt.xlabel("Temps (s)")
                plt.ylabel("Mémoire utilisée (MB)")
                plt.title(f"Évolution de la mémoire pour '{process_name}'")
                plt.pause(1)  # Met à jour toutes les secondes
                plt.clf()

                time.sleep(1)  # Attend une seconde
        except KeyboardInterrupt:
            print("Arrêt de la surveillance par User")
        plt.plot(time_history, memory_usage_history)
        plt.xlabel("Temps (s)")
        plt.ylabel("Mémoire utilisée (MB)")
        plt.title(f"Évolution de la mémoire pour '{process_name}'")
        plt.show()  # Affiche la figure à l'écran (facultatif)