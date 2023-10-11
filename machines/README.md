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

![palindrome](https://github.com/sirius911/ft_turing/assets/25301163/d292b8dc-641f-43cc-a539-c7867222a85d)


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

## X-1
Same machine as 'X+1' but subtracts 1 from a binary number

## X+Y
Machine adding two binary numbers

1010+11010=

## UTM_xxx
Pseudo UTM 
Alphabet, states, transitions and machine input ARE machine input.

All machine states have been renamed with a capital letter [A, B, etc.].
the pseudo MU input format is :

| Example | A&A{[0C>.][...]}:0011 |
|:-------------------|:-----------------|
| A | Initial state |
|**&** | |
| A | State |
| **{** | *start of transition list for state A* |
| **[** | *transition* |
| 0 | *'alphabet character read'* |
| C | *New State* |
| > | *for the direction of the read head* |
| . | *'alphabet character written'* |
| **]** | *end of transition* |
| **[** | *transition* | 
| ... | ...|
| **]** | *end of transition* |
| **}** | *end of transitions for state A* |
| **:** | *start of input* |
| 0011 | *input* |


#### UTM_unary_add.json
A machine able to run the machine (unary_add), an unary addition.
exemple commands : 
```bash
'A&A{[1A>1][+B>.][.Z>.]}B{[1C<+][.Z<.]}C{[.A>1]}:111+1'
```

#### UTM_unary_sub.json
A machine able to run the machine (unary_sub), an unary subtraction.
exemple commands : 
```bash
'A&A{[.A>.][1A>1][-A>-][=B<.]}B{[1C<=][-Z<.]}C{[1C<1][-D<-]}D{[.D<.][1A>.]}:111-11='
```
#### UTM_0n1n.json
A machine able to run the machine (0n1n).
exemple commands : 
```bash
'A&A{[0F>?][1N>1]}B{[1C<!][?N>0][0I<0]}C{[1C<1][.C<.][0D>0][?G>?]}D{[1E<.][.D>.][!I<!]}E{[0C<.][.E<.]}F{[1F>1][0F>0][.B<.]}G{[.G>.][!H>!][1I>1]}H{[.I<y]}I{[.J<1][!I<!][1I<1][0I<0][?N>0]}J{[?K>?][0K>0][.J<.]}K{[.L>0]}L{[.L>.][1L>1][!I<!]}M{[1M>1][0M>0][.M>.][!H>!]}N{[1N>1][0N>0][!N>1][nZ>n][.Z<n][yZ<y]}:0011'
```
#### UTM_0n12n.json
A machine able to run the machine (0n12n), an unary subtraction.
exemple commands : 
```
'A&A{[0B>X][YE>Y][1Z>n][.Z>n]}B{[0B>0][YB>Y][1C>Y][.Z<n]}C{[1D<Y][.Z<n]}D{[0D<0][YD<Y][XA>X]}E{[YE>Y][.Z>y][1Z>n]}:001111'
```

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
