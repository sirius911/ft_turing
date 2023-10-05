## unary_add
A machine able to compute an unary addition.

## unary_sub
A machine able to compute an unary substraction.

## palindrome
A machine able to decide whether its input is a palindrome or not. Before halting,
write the result on the tape as a ’n’ or a ’y’ at the right of the rightmost character
of the tape.

## 0n1n
A machine able to decide if the input is a word of the language 0n1n, for instance
the words 000111 or 0000011111. Before halting, write the result on the tape as a
’n’ or a ’y’ at the right of the rightmost character of the tape.

## 02n
A machine able to decide if the input is a word of the language 02n, for instance
the words 00 or 0000, but not the words 000 or 00000. Before halting, write the
result on the tape as a ’n’ or a ’y’ at the right of the rightmost character of the
tape.

verifie que l'input est de la forme 02n
0 -> n
00 -> y
000 -> n
0000 -> y
on se place à gauche du premier caractère avec scan_left
puis on passe d'un état ping à un état pong en allant toujours sur la droite
si c'est ping qui trouve le blank c'est pair, si c'est pong c'est impaire

## 0n12n
verifie aue l'input est de la forme 0n 1 2n

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

## UTM_xxx
Pseudo UTM 

## gerenator_cmd.py
Programme python qui donne l'input pour une UTM en fournissant une machine de turing par le fichier json. Exemple :
python3 generator_cmd.py machines/unary_add.json

## generatorUTM.py
Generateur du fichier json d'un pseudo UTM. exemple :
python3 generatorUTN machines/unary_add.json  
--> ecrit le fichier UTM_unary-add.json pour une UTM et affiches l'input