#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# Extra information about the code is given in the exo2_for.sh script
[ "$#" -lt "1" ] && echo "Le script doit prendre au moins un paramètre" >&2 && exit 1

ret_code=0
nb_invalid=0
nb_robert=0
nb_test=0
nb_root=0

# We keep a copy of the $# value to print the number of parameters at the end of the script
initial_param_number="$#"

# The idea with the while loop is to perform destructive read of the script parameters. We only work with the $1
# parameter and remove it with shift command once the processing has been done
while [ "$#" -gt "0" ]; do
    case "$1" in
        robert)
            echo "Bonjour robert"
            (( nb_robert++ ))
            ;;
        test)
            echo "Attention ceci est un compte de test"
            (( nb_test++ ))
            ;;
        root)
            echo "Bienvenue administrateur"
            (( nb_root++ ))
            ;;
        *)
            echo "Erreur" >&2
            ret_code=2
            (( nb_invalid++ ))
            ;;
    esac

    # This command shifts all the parameter to the left: $1 is not accessible anymore(and is not taken in consideration
    # in $# either), $2 becomes $1, $3 becomes $2 and so on. $# is decreased by one.
    shift
done

output="Nombre d'arguments: ${initial_param_number} (dont ${nb_invalid} invalides)
Nombre de root: ${nb_root}
Nombre de test: ${nb_test}
Nombre de robert: ${nb_robert}"

echo "$output"

exit ${ret_code}
