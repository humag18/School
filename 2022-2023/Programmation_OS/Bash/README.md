# Bash
/!\ NE PAS OUBLIER LE PREFIXE AVANT DE COMMENCER À CODER /!\
## Variable
Création d'une variable :

```Bash 
declare name_of_variable="content_of_variable"
```

Quand il y a une manipulation de variable ne pas oublier le `$` expl : 

```Bash
echo "$Variable1"
```

Il n'y a pas de types de variables (int, float, char, ...) n'existent passer

>Les listes n'existent pas non plus mais il y a moyen d'en simulé avec un remplacement des espaces par des \n
>/!\ATTENTION/!\ le premier élément d'une variable et le n°1 et non n°0 
## Structure conditionnelle
`if` comme dans tous les languages

Suivant la structure : 

```Bash
if [[<condition>]]; then 
    echo "test"
else
    echo "exemple"

fi
```

Pour verifier si une variable est vide mettre en condition 

```Bash
if [[-z "$variable"]];
```

## Gestion des outputs

Pour passer d'un flux standard à un flux d'erreur standard utiliser l'otpion `>&2`

Pour passer d'un flux d'erreur standaed à un flux standard utiliser l'option `2>&1` 

Pour faire une concaténation de variable utiliser l'opérateur `.` exemple : 
```Bash
declare $var1.var2

```
> Pour un simple `echo` pas besoin de `.`

`$` est un caractère reservé ne pas oublier de mettre un `\` devant lors que l'on veut l'affecter à une variable exemple : 
```Bash
echo "Je possède 1000\$ sur mon compte en banque"
declare test="j'ai 300\$ sur moi"

```

## Les boucles

Il existe 2 types de boucles en Bash

### La boucle `while`

```Bash
i=1
while [[$i -le 5]];
do 
    echo "bonjour"
done

```

>Ce bout de code affiche 5 fois bonjour
>Généralement utiliser lorsqu'on connait les conditions pour sortir de la boucle

### La boucle `for`

```Bash
fot i in {1..5}
do 
    echo $i
done

```

>Ce bout de code affiche les chiffres allant de 1 à 5 

### La boucle until
```Bash
until [$i -ge 5 ]
do 
    echo $i
    i=$((i+1))
done

```
>Généralement utilisée lorsque l'on connait la condition pour rentrer dans la boucle

## Gestion des paramètres

Exemple de paramètre `./EX1.sh hugo` 

>ici nous avons donc 1 paramètres (hugo)

Pour afficher le nombre de variables passée en paramètres 

```Bash
echo $#
```

l'affichage des paramètre se fait grace à : 

```Bash
echo $1

```

>/!\ ici ce n'est pas comme dans la pluspart des langages, $1 est le premier paramètre et non le second 

## Les opérateurs

Dans l'ensemble cela reste la même chose que dans tous les langage 
pour les opératuers de bases
- `+` : Addition
- `-` : Soustraction 
- `*` : Multiplication
- `/` : Division
- `%` : Modulo 
- `=` : Affectation ed valeur
- `==` : Vérification d'égalité (pour les char)
- `!=` : Vérification de non égalité (pour les char)
- `-eq` : Test d'égalité numérique
- `-ne` : Test de non égalité numérique
- `-gt` : Supérieur à
- `-lt` : Inférieur à
- `-ge` : supérieur ou égal 
- `-le` : inférieur ou égal 

