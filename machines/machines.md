## unary_add
A machine able to compute an unary addition.

![unary_add](https://github.com/sirius911/ft_turing/assets/25301163/1f70553b-f50c-49c4-a7ef-3641932a55b6)


## unary_sub
A machine able to compute an unary substraction.

![unary_sub](https://github.com/sirius911/ft_turing/assets/25301163/646fd1a7-3f8b-4987-99c0-4cde0ece9fba)


## palindrome
A machine able to decide whether its input is a palindrome or not. Before halting,
write the result on the tape as a ’n’ or a ’y’ at the right of the rightmost character
of the tape.

## 0n1n
A machine able to decide if the input is a word of the language 0n1n, for instance
the words 000111 or 0000011111. Before halting, write the result on the tape as a
’n’ or a ’y’ at the right of the rightmost character of the tape.

![0n1n](https://github.com/sirius911/ft_turing/assets/25301163/4eb3ede1-65f3-438e-b068-0b0f7f82ebd2)


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

![02n](https://github.com/sirius911/ft_turing/assets/25301163/7ed1888d-22a5-41c9-ae02-83f6ea046b52)


## 0n12n
verifie aue l'input est de la forme 0n 1 2n

![0n12n](https://github.com/sirius911/ft_turing/assets/25301163/aa08d616-f838-4d76-b12a-fd43464efb37)

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

![X+1](https://github.com/sirius911/ft_turing/assets/25301163/2888e0d6-43b5-46ec-b728-6e2f854d8c5d)


## UTM_xxx
Pseudo UTM 

## gerenator_cmd.py *
Programme python qui donne l'input pour une UTM en fournissant une machine de turing par le fichier json. 
Exemple :
```shell
python3 generator_cmd.py machines/unary_add.json
```

## generatorUTM.py *
Generateur du fichier json d'un pseudo UTM. exemple :
```shell
python3 generatorUTN machines/unary_add.json
```

--> ecrit le fichier UTM_unary-add.json pour une UTM et affiches l'input

largely inspired by [Mikhail Pasechnik](https://github.com/MikhailPasechnik) 's codes !
