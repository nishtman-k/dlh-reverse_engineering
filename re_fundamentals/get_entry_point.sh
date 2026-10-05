#!/bin/bash

# Keep readelf's field names in English.
export LC_ALL=C

# Require exactly one filename.
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <ELF_file>" >&2
    exit 1
fi

file_name="$1"

# Check that the argument is a readable regular file.
if [[ ! -f "$file_name" || ! -r "$file_name" ]]; then
    echo "Error: '$file_name' is missing or not a readable file." >&2
    exit 1
fi

# Read the ELF header and check whether the command succeeded.
if ! header=$(readelf -h -- "$file_name" 2>/dev/null); then
    echo "Error: unable to read '$file_name' as an ELF file." >&2
    exit 1
fi

# Extract the required fields.
magic_number=""
class=""
byte_order=""
entry_point_address=""

while read -r label value; do
    case "$label" in
        Magic:)
            magic_number="$value"
            ;;
        Class:)
            class="$value"
            ;;
        Data:)
            byte_order="${value#*, }"
            ;;
        Entry)
            entry_point_address="${value##* }"
            ;;
    esac
done <<< "$header"

# Locate messages.sh beside this script.
script_dir="."
if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    script_dir="${BASH_SOURCE[0]%/*}"
fi

if ! source "$script_dir/messages.sh"; then
    echo "Error: could not load messages.sh." >&2
    exit 1
fi

display_elf_header_info
