#
# Thud - Bash attribute set operations
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

if [ -z "${_THUD_ATTRS_SH+set}" ]; then
declare _THUD_ATTRS_SH=

. thud_arr.sh
. thud_misc.sh

# Shell attribute state stack
declare -a _THUD_ATTRS_STACK=()

# Push shell attribute state to the state stack, optionally invoke "set".
# Args: [set_arg...]
function thud_attrs_push()
{
    # Using process substitution instead of command substitution,
    # because the latter resets errexit.
    declare attrs
    if read -rd '' attrs < <(set +o); [ $? != 1 ]; then
        thud_abort "Failed to read attrs"
    fi
    thud_arr_push _THUD_ATTRS_STACK "$attrs"
    if [ $# != 0 ]; then
        set "$@"
    fi
}

# Pop shell attribute state from the state stack.
function thud_attrs_pop()
{
    eval "`thud_arr_peek _THUD_ATTRS_STACK`"
    thud_arr_pop _THUD_ATTRS_STACK
}

fi # _THUD_ATTRS_SH
