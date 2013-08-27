#
# Thud - string operations
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

if [ -z "${_THUD_STR_SH+set}" ]; then
declare _THUD_STR_SH=

# Push values to a string-based stack.
# Args: _stack _sep _value...
function thud_str_push()
{
    declare -r _stack="$1"; shift
    declare -r _sep="$1"; shift
    thud_assert 'thud_is_name "$_stack"'
    thud_assert '[ -n "$_sep" ]'
    while (($# > 0)); do
        if [[ "$1" == *$_sep* ]]; then
            thud_abort "Invalid string-based stack value: $1"
        fi
        eval "$_stack+=\"\${_sep}\${1}\"";
        shift
    done
}

# Get a value from the top of a string-based stack.
# Args: _stack _sep
function thud_str_peek()
{
    declare -r _stack="$1"
    declare -r _sep="$2"
    thud_assert 'thud_is_name "$_stack"'
    thud_assert '[ -n "$_sep" ]'
    if [ -z "${!_stack}" ]; then
        thud_abort "Not enough values in a string-based stack"
    fi
    echo "${!_stack##*$_sep}"
}

# Pop values from a string-based stack.
# Args: _stack _sep [_num_values]
function thud_str_pop()
{
    declare -r _stack="$1"
    declare -r _sep="$2"
    declare _num_values="${3:-1}"
    thud_assert 'thud_is_name "$_stack"'

    while ((_num_values > 0)); do
        if [ -z "${!_stack}" ]; then
            thud_abort "Not enough values in a string-based stack"
        fi
        eval "$_stack=\"\${$_stack%\$_sep*}\""
        _num_values=$((_num_values-1))
    done
}

fi # _THUD_STR_SH
