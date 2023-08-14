#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# This task can be performed in lots of different ways. Few of them are given here producing the
# same output. We include time measurement to give an idea of the different processing time
# (informations on time measurement can be found at the following url:
# https://www.xmodulo.com/measure-elapsed-time-bash.html)

passwd_file="/etc/passwd"

while getopts ":u:" args; do
    case ${args} in
        u)
            # Option -u
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option u requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            
            # If the option -u is given, we create a temporary file and store in it only the line concerning the user
            # given to the option. It allows us to keep the same code.
            old_passwd_file="$passwd_file"
            passwd_file=$(mktemp)
            
            if ! grep -E "^${OPTARG}:" "${old_passwd_file}" >> "${passwd_file}"; then
                # Remove the temporary file
                rm "${passwd_file}"

                echo "User ${OPTARG} does not exist" >&2
                exit 11
            fi

            # Check if the user is a regular user
            if [ "$(id -u "$OPTARG")" -lt "500" ]; then
                # Remove the temporary file
                rm "${passwd_file}"

                echo "User ${OPTARG} is not a regular user" >&2
                exit 12
            fi
            ;;
        ?)
            # Unknown option
            echo "Unknown option given: -${OPTARG}" >&2
            exit 9
            ;;
    esac
done


# Read the file and perform the string manipulation in the loop.
echo -e "In loop process"
echo -e "===============\n"

start_time=$(date +%s.%3N)

# In this example we read the /etc/passwd file line by line and perform the information retrieval
# process inside of the loop. This is the most straightforward processing.
while read -r line; do
    # The cut command read stdin and cut the line according to a given seperator. The latter is
    # space by default but can be specified using -d (delimiter) option. The -f option allows us to
    # specify the field, we want to be printed.

    # Since cut write on stdout, we need to use $() to retreive the output of the given command.
    # Note also the use of echo and pipe |. echo prints the given line on stdout and pipe allows us
    # to map the stdout of echo to the stdin of cut. 
    user=$(echo "${line}" | cut -d ':' -f 1)
    uid=$(echo "${line}" | cut -d ':' -f 3)
    shell=$(echo "${line}" | cut -d ':' -f 7)

    # Once informations are extracted, we just have to perform the test on the uid field.
    [ "${uid}" -ge "500" ] && echo "${user} (${uid}): ${shell}"
done < "$passwd_file"

end_time=$(date +%s.%3N)
elapsed=$(echo "scale=3; ${end_time} - ${start_time}" | bc)
echo -e "\nTime: ${elapsed}"



# Preprocess the file with cut and feed the loop with command output
echo -e "\nCut preprocess"
echo -e "==============\n"

start_time=$(date +%s.%3N)

# In this example the /etc/passwd file is preprocessed by command cut. When using cut on a file, all
# lines are sequentially processed by the cut command. Here we use : as a delimiter and we retreive
# the first, third and seventh fields. 

# When used with a list of fields, cut prints all extracted fields separated with the given
# delimiter (the one given with -d option). This would return for instance a line like
# username:1000:/bin/bash

# As such this would require the same in-loop processing to extract value and assign them to
# variables uid, user and shell. 

# However, the option --output-delimiter allows us to force cut to use a new delimiter when printing
# result. With space as output delimiter, we get a line like
# username 1000 /bin/bash

# Remember that spaces are default delimiter in bash, and those delimiters are recognised by read
# command. Indeed several variable names can be given to read (see read --help to get help for this
# command), each of which will get a part of the read line. For instance when reading line:
# username 1000 /bin/bash

# with the command
# read user uid shell

# variable user will contain username, variable uid will contain 1000 and variable bash will contain
# /bin/bash. Thus automatically performing the split of the line.
while read -r user uid shell; do
    [ "${uid}" -ge "500" ] && echo "${user} (${uid}): ${shell}"
done < <(cut -d ':' -f 1,3,7 --output-delimiter " " "$passwd_file")

# Note the <() syntax. The following while syntax
# while read line; do
#   statement
# done < input

# expect input to be a file descriptor (this can be roughly seen as a file). Thus we cannot use the
# syntax:
# while read line; do
#   statement
# done < $(cmd)

# since $() expands to output of the command. Let's take an example. Suppose, for sake of ease, that
# command 
# cut -d ':' -f 1,3,7 --output-delimiter " " /etc/passwd

# prints the single line:
# username 1000 /bin/bash

# Thus 
# while read line; do
#   statement
# done < $(cut -d ':' -f 1,3,7 --output-delimiter " " /etc/passwd)

# Would execute the cut command and expand $() content to cut output:
# while read line; do
#   statement
# done < username 1000 /bin/bash

# leading to syntax error (since a single field is expected by <). Note that if cut command only
# returns a single field (let's say username), then while will try to read a file called username
# leading to error if the file does not exist (this is the best case), or leading to unwanted
# process of username file.

# This is why we use <() syntax. When using this operator, a subshell is created and the output of
# the commands is stored in a temporary file (that will feed the while loop). In other term, the
# following syntax:
# while read line; do
#   statement
# done < <(cmd)

# is equivalent to the following one:
# tmp_file=$(mktemp)        # Creates a temporary file
# cmd > "${tmp_file}"       # Store the output of cmd into temporary file
# while read line; do
#   statement
# done < "${tmp_file}"      # Process the file
# rm "$tmp_file"            # Remove the file

end_time=$(date +%s.%3N)

elapsed=$(echo "scale=3; ${end_time} - ${start_time}" | bc)
echo -e "\nTime: ${elapsed}"
    
# Use of awk
echo -e "\nAwk processing"
echo -e "==============\n"
start_time=$(date +%s.%3N)

# This approach is given for sake of completeness. The awk command allows efficient processing of
# string and define for the latter a whole scripting language. Obviously this goes out of the
# boundaries of the lessons, but please note that such command exists and can be very useful.
awk -F ':' '{ if(($3 + 0) >= 500) { print$1" ("$3") : "$7 }}' "$passwd_file"
end_time=$(date +%s.%3N)

elapsed=$(echo "scale=3; ${end_time} - ${start_time}" | bc)
echo -e "\nTime: ${elapsed}"

# Use of regex
echo -e "\nRegex with sed"
echo -e "==============\n"
start_time=$(date +%s.%3N)
# This approach uses sed regex substitution to do the work. In this case we design the regex as
# follows:
# - ^ stands for the beginning of the line
# - (.*) . represents any character and * is the quantifier that stands for any number (from 0 to
#   infinite). The parenthesis surrounding the expressions tells sed to store the word matched by .*
#   into the \1 variable (since this is the first pair of parentheses)
# - : matches a :
# - .* matches another arbitrary number of any character but this time, the matching patterns is not
#   saved.
# - ([5-9][0-9]{2}|[0-9]{4,}) matches any number greater of equal to 500 and stores the result in
#   \2. A number is greater or equal to 500 if it is a 3 digits number with first digit being
#   5,6,7,8 or 9 (this is matched with [5-9][0-9]{2}), OR a 4 or more digits number (being match
#   with [0-9]{4,}).
# - (:.*){3} match three times a pattern beginning by : and then composed of any number of any
#   character and stores the pattern in \3
# - (.*) match any number of any character
# - $ matches the end of the line.

# In other word, we are looking for exactly 7 fields, delimited with : and such that third field is
# a number greater or equal to 500. 

# the s command (at the beginning of sed expression) asks for a substitution (it can be roughly seen
# as a search and replace). This ask to replace the found pattern (described by the regex) by the
# pattern: \1 (\2) : \4 where \1 contains the field matched in the first pair of parentheses (thus
# username), \2 the field matched in the second pair of parentheses (i.e. the number greater or
# equal to 500) and \4 the field matched in the fourth pair of parentheses (thus the shell
# interpreter).

# p at the end of sed expression asks to print matched lines.
sed -nE 's/^(.*):.*:([5-9][0-9]{2}|[0-9]{4,})(:.*){3}:(.*)$/\1 (\2) : \4/p' "$passwd_file"

# Note that while this approach is extremely concise and powerful, this has some serious drawbacks.
# One of them is maintainability. Indeed, if you need to match uid greater or equal to 750 for
# instance, you'll have to write a whole new regex.
end_time=$(date +%s.%3N)

elapsed=$(echo "scale=3; ${end_time} - ${start_time}" | bc)
echo -e "\nTime: ${elapsed}"

