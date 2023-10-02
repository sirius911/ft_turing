## 02n

verifie que l'input est de la forme 02n
0 -> n
00 -> y
000 -> n
0000 -> y
on se place à gauche du premier caractère avec scan_left
puis on passe d'un état ping à un état pong en allant toujours sur la droite
si c'est ping qui trouve le blank c'est pair, si c'est pong c'est impaire


## X+1.json 

X+1 est une machine de turing permettant de calculer X+1 (X est un mot binaire)
On commence par chercher le dernier 0 et on le remplace par 1. Pour cela on se place à
la fin du mot en cherchant l'espace '.'

etat initial : q0
    transitions ->  1/1 R q0
                    0/0 R q0
                    ./. L -> q1

On remonte jusqu'à touver un 0 en remplaçant les 1 par des 0:

etat q1: (fin du mot)
    transitions ->  0/1 R -> q3 (On remonte)
                    1/0 L -> q2 (On cherche le 0)

etat q2: on cherche le 0:
    transition ->   1/0 L 
                    0/1 R -> q3 (On a trouvé)
                    ./1 R -> q3 (Début du mot on rajoute un 1)

etat q3: on remonte :
    transition ->   0/0 L
                    1/1 L
                    ./. R -> fin