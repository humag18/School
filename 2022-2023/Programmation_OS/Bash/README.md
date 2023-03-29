# Bash
/!\ NE PAS OUBLIER LE PREFIXE AVANT DE COMMENCER À CODER /!\
## Variable
Création d'une variable :

```Bash 
declare name_of_variable="content_of_variable"
```

Quand il y a une manipulation de variable ne pas oublier le `$` expl : 

`echo $variable`

## Structure conditionnelle
`if` comme dans tous les languages

Suivant la structure : 

```Bash
if [[<condition>]]; then 
    echo "test"

echo
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

## Gestion des paramètres

exemple de paramètre `./EX1.sh` 
