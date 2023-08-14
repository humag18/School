#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# function check_compat() {{{
check_compat() {
    [ "$#" -ne "2" ] && $print_error "Not enough args for check_compat. Aborting..." && return 2

    local tar_archive file_path file_name

    # Get the absolute path of each file 
    tar_archive="$(readlink -f "$1")"
    file_path="$(readlink -f "$2")"

    # Test the archive file

    # Existence (if the archive does not exist, every file is compatible)
    [ ! -e "$tar_archive" ] && return 0
    # Regular file
    [ ! -f "$tar_archive" ] && $print_error "File $tar_archive is not a regular file" && return 5
    # Readable
    [ ! -r "$tar_archive" ] && $print_error "File $tar_archive is not a readable" && return 6
    # Test if the first argument is a tar archive
    if [ "$(file -b --mime-type "$tar_archive" 2> /dev/null)" != "application/x-tar" ]; then
        $print_error "The file ($tar_archive) does not seems to be a tar archive"
        return 3
    fi

    # Get the name of the file
    file_name=$(basename "${file_path}")

    # Test if the file is already in the tar file
    ! (tar -tf "$tar_archive" | grep -qE "^${file_name}\$")

    # No need to have a return statement since the functions returns the exit status of the last executed command. Here,
    # we launch the commands in a subshell. The exit status of the subshell is also equal to the exit status of the last
    # command executed.

    # Here tar -tf $tar_archive list all the files contained in the archive. The archive exists, and is readable, so the
    # tar command should return success. The grep command return success if the pattern is found (and thus if the file
    # exists in the archive). So the subshell will have an exit status equal to 0 if the file is in the arhive and 1 if
    # not. That's why we use the negation before the subshell: if the file is found, grep returns 0, so as the subshell
    # and the negation turns the latter into 1.
}
# }}}

# function backup_files() {{{
backup_files() {
    local tar_archive index_file file_list parent_dir exit_status file_name

    exit_status=0

    # We use readlink to get the absolute path of all parameters
    tar_archive="$(readlink -f "$1")"
    index_file="$(readlink -f "$2")"
    file_list="$(readlink -f "$3")"

    # Tests on the archive
    # If the archive does not exists we check that we can create it
    if [ ! -e "$tar_archive" ]; then
        # First we get the parent directory of tar archive
        parent_dir="$(dirname "${tar_archive}")"

        # If it does not exist we try to create it
        if [ ! -e "${parent_dir}" ] && ! mkdir -p "$parent_dir"; then
            $print_error "Unable to create $parent_dir. Aborting"
            return 3
        fi

        # If it exists we ensure that we can write in it 
        [ ! -w "$parent_dir" ] && $print_error "File ($parent_dir) is not writable" && return 4
    fi

    # Tests on the index file (same as tar archive above)
    if [ ! -e "$index_file" ]; then
        parent_dir="$(dirname "${index_file}")"

        if [ ! -e "${parent_dir}" ] && ! mkdir -p "$parent_dir"; then
            $print_error "Unable to create $parent_dir. Aborting"
            return 5
        fi

        [ ! -w "$parent_dir" ] && $print_error "File ($parent_dir) is not writable" && return 6
    fi
    
    # Test on the file list
    [ ! -e "$file_list" ] && $print_error "File $file_list does not exists" && return 7
    [ ! -f "$file_list" ] && $print_error "File $file_list is not a regular file" && return 8
    [ ! -r "$file_list" ] && $print_error "File $file_list is not a readable" && return 9
    
    while read -r to_backup; do
        [ ! -e "$to_backup" ] && $print_error "File ($to_backup) does not exists" && return 2
        [ ! -r "$to_backup" ] && $print_error "File ($to_backup) is not readable" && return 2

        file_name=$(readlink -f "$to_backup")

        if check_compat "$tar_archive" "$file_name"; then
            tar -C "$(dirname "$file_name")" -rf "$tar_archive" "$(basename "$file_name")"
            echo "$file_name" >> "$index_file"
        else
            exit_status=1
        fi
    done < "$file_list"

    return "$exit_status"
}
# }}}

# function restor_file() {{{
restore_file() {
    local exit_status tmp_dir tar_archive extracted_index cur_file cur_dir

    tar_archive="$1"
    exit_status=0

    [ ! -e "$tar_archive" ] && $print_error "File $tar_archive does not exists" && return 2
    [ ! -f "$tar_archive" ] && $print_error "File $tar_archive is not a regular file" && return 2
    [ ! -r "$tar_archive" ] && $print_error "File $tar_archive is not a readable" && return 2

    tar_archive=$(readlink -f "$tar_archive")

    # We create a temporary dir to be sure that the index file will not override an existing one
    tmp_dir=$(mktemp -d)
    extracted_index="${tmp_dir}/$(basename "$index_file")"


    if ! tar -C "$tmp_dir" -xf "$tar_archive" "$index_file"; then
        $print_error "Unable to extract index file ($index_file)."
        rmdir "$tmp_dir"
        return 2
    fi

    [ ! -e "$extracted_index" ] && $print_error "File $extracted_index does not exists" && return 2
    [ ! -f "$extracted_index" ] && $print_error "File $extracted_index is not a regular file" && return 2
    [ ! -r "$extracted_index" ] && $print_error "File $extracted_index is not a readable" && return 2
    
    while read -r to_extract; do
        cur_file="$(basename "$to_extract")"
        
        if ! tar -C "$tmp_dir" -xf "$tar_archive" "$cur_file"; then
            $print_error "Unable to extract file ($cur_file)."
            exit_status=1
            continue
        fi

        cur_dir=$(dirname "$to_extract")
        mkdir -p "$cur_dir" 2> /dev/null

        if [ ! -e "$cur_dir" ]; then
            $print_error "Unable to create $cur_dir for file ($to_extract)"
            exit_status=1
            continue
        fi

        if ! mv "${tmp_dir}/${cur_file}" "$to_extract"; then
            $print_error "Unable to deploy $to_extract"
            exit_status=1
            continue
        fi
    done < "$extracted_index"

    rm -r "$tmp_dir"

    return "$exit_status"
}
# }}}

# function log_echo() {{{
log_echo() {
    echo "$@" >> "$log_file"
}
# }}}

# function err_echo() {{{
err_echo() {
    echo "$@" >&2
}
# }}}

# function print_help() {{{
print_help() {
    echo "SYNOPSIS"
    echo -e "\t$script_name [-c file1[,file2[,file3[,...]]]] [-h] [-i index_file] [-L logfile] archive"
    echo ""
    echo "DESCRIPTION"
    echo -e "\t$script_name allows the creation of tar backups based on file list or the deployment of an already created backup."
    echo ""
    echo "OPTIONS"
    echo -e "\t-h print this help"
    echo -e "\t-c file1,[file2,[...]] defines a list of files. Each files contains the path to the files that need to be backuped (one per line)."
    echo -e "\t-L logfile print error to logfile instead of stderr."
    echo -e "\t-i set the name of the index file (that contains the absolute paths for all backuped file (used for deployment)."
}
# }}}

script_name="${0##*/}"

# Default values
index_file=".index_list"
log_file=""
list_of_file_list=""
expand=true

# This variable contains the function that will be called when we need to print an error. err_echo prints on stderr
# while log_echo print in the log file.
print_error=err_echo

while getopts "c:hi:L:" args; do
    case ${args} in
        c)
            # Option -c
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option c requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            # If c option is given, the archive needs to be created
            expand=false
            list_of_file_list="$OPTARG"
            ;;
        h)
            # Option -h
            print_help
            exit 0
            ;;
        i)
            # Option -i
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option i requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            index_file="$OPTARG"
            ;;
        L)
            # Option -L
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option L requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            log_file="$OPTARG"
            # We also change the function used to print error messages
            print_error=log_echo
            ;;
        *)
            echo "Unknown option: $args"
            print_help
            exit 1
            ;;
    esac
done

shift $(( OPTIND - 1 ))

tar_archive="$1"

# Test if the archive should be expanded and if it exists
if ! $expand && [ -e "$tar_archive" ]; then
    echo "User asked for create mode and archive ($tar_archive) already exists. Aborting..." >&2
    exit 1
fi

# If expand is false, then the backup shoul dbe created
if ! $expand; then
    if [ -e "$index_file" ]; then
        echo "File $index_file already exists. Please remove it and start the script again."
        exit 2
    fi

    # This loop is a little bit tricky. The file list are comma separated. To get a list that can be used in a loop, we
    # can create an array and use a for loop (but arrays are not covered in this teaching), or we split the list by
    # replacing commas by carriage returns (\n).
    while read -r file_list; do
        # No further tests are needed sinc they are all integrated in the function.
        backup_files "$tar_archive" "$index_file" "$file_list"

        # We need to store the exit status of the command for further use, since the followinf echo will override it.
        cmd_ret=$?

        # Prefix the line with the name of the current file
        echo -n "$file_list => "

        # Based on the return of the command we can print useful informations for all lists
        case $cmd_ret in
            0)
                echo "[OK]"
                ;;
            1)
                echo "[Warning] Some files are already in the archive"
                ;;
            2)
                echo "[Error] Some files are missing or not readable"
                ;;
            3|4)
                echo "[Fatal] Unable to create archive $tar_archive."
                exit 3
                ;;
            5|6)
                echo "[Fatal] Unable to create index file $index_file."
                exit 4
                ;;
            *)
                echo "[Error] $file_list can not be parsed."
                ;;
        esac
    done < <(echo "$list_of_file_list" | tr ',' '\n')

    tar -rf "$tar_archive" "$index_file"
else
    restore_file "$tar_archive"
fi
