#
# Thud - array operations
#
# Copyright (c) 2013 Red Hat, Inc. All rights reserved.
#
# This copyrighted material is made available to anyone wishing
# to use, modify, copy, or redistribute it subject to the terms
# and conditions of the GNU General Public License version 2.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301, USA.

if [ -z "${_THUD_ARR_SH+set}" ]; then
declare _THUD_ARR_SH=

. thud_misc.sh

# Push values to an array-based stack.
# Args: stack value...
function thud_arr_push()
{
    declare -r _stack="$1"
    shift
    while (( $# > 0 )); do
        eval "$_stack+=(\"\$1\")"
        shift
    done
}

# Get a value from the top of an array-based stack.
# Args: stack
function thud_arr_peek()
{
    declare -r _stack="$1"
    if eval "test \${#$_stack[@]} -eq 0"; then
        thud_abort 1 "Not enough values in an array-based stack"
    fi
    eval "echo \"\${$_stack[\${#$_stack[@]}-1]}\""
}

# Pop values from an array-based stack.
# Args: stack [num_values]
function thud_arr_pop()
{
    declare -r _stack="$1"
    declare _num_values="${2:-1}"

    if [[ "$_num_values" == *[^0-9]* ]]; then
        thud_abort 1 "Invalid number of values: $_num_values"
    fi

    while (( _num_values > 0 )); do
        if eval "test \${#$_stack[@]} -eq 0"; then
            thud_abort 1 "Not enough values in an array-based stack"
        fi
        eval "unset '$_stack[\${#$_stack[@]}-1]'"
        _num_values=$((_num_values-1))
    done
}

# Copy (associative) array contents.
# Args: _dst _src
function thud_arr_copy()
{
    declare _dst="$1";  shift
    declare _src="$1";  shift
    declare _k

    eval "
        $_dst=()
        for _k in \"\${!$_src[@]}\"; do
            $_dst[\$_k]=\"\${$_src[\$_k]}\"
        done
    "
}

# Output an (associative) array.
# Args: _var
# Output: the array with keys and values on separate lines with newlines
#         and backslashes escaped, terminated by a "*"
function thud_arr_print()
{
    declare -r _var="$1"
    thud_assert 'thud_is_name "$_var"'
    declare -r _bs='\'
    declare _k
    declare _v
    eval "
        for _k in \"\${!$_var[@]}\"; do
            _v=\"\${$_var[\$_k]}\"
            _k=\"\${_k//\\\\/\$_bs\$_bs}\"
            _v=\"\${_v//\\\\/\$_bs\$_bs}\"
            echo \"\${_k//\$'\\n'/\\\\n}\"
            echo \"\${_v//\$'\\n'/\\\\n}\"
        done
        echo \"*\"
    "
}

# Parse an (associative) array from a format output by thud_arr_print.
# Args: _var
# Input: the array in thud_arr_print output format: keys and values on
#        separate lines with newlines and backslashes escaped, terminated by a
#        "*".
function thud_arr_parse()
{
    declare -r _var="$1"
    thud_assert 'thud_is_name "$_var"'
    declare _k
    declare _v
    eval "
        $_var=()
        while IFS='' read -r _k && [ \"\$_k\" != \"*\" ]; do
            IFS='' read -r _v || break
            printf -v _k '%b' \"\$_k\"
            printf -v _v '%b' \"\$_v\"
            $_var[\$_k]=\"\$_v\"
        done
    "
}

fi # _THUD_ARR_SH
