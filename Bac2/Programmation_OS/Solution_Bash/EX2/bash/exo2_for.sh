#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# First test the number of parameters
[ "$#" -lt "1" ] && echo "Le script doit prendre au moins un paramètre" >&2 && exit 1

# Another approach is the following one

# if [ "$1" = "" ]; then
#     echo "Le script doit prendre au moins un paramètre" >&2
#     exit 1
# fi

# However the latter does not handle properly the case where the first parameter is an empty string


# We set up a return code initialized to success value. The following variable is set to error code
# if an invalid argument is given.
ret_code=0
nb_invalid=0
nb_robert=0
nb_test=0
nb_root=0

# XXX Note the use of $@ instead of $* to correctly handle parameters that contains space
for arg in "$@"; do
    case "$arg" in
        robert)
            echo "Bonjour robert"
            # We use the arithmetic operator (( )) allowing us to perform mathematical operations in bash
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
            # We do not want to exit the script now. There may be other parameters to process after
            # the invalid one. So we set up the return code here and the latter will be returned
            # after the loop
            ret_code=2
            (( nb_invalid++ ))
            ;;
    esac
done

# We use a variable to have multiline string
output="Nombre d'arguments: $# (dont ${nb_invalid} invalides)
Nombre de root: ${nb_root}
Nombre de test: ${nb_test}
Nombre de robert: ${nb_robert}"

echo "$output"


# Return the return code (set to 2 if an invalid argument is given).
exit ${ret_code}
