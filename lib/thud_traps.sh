#
# Thud - trap set operations
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

if [ -z "${_THUD_TRAPS_SH+set}" ]; then
declare _THUD_TRAPS_SH=

. thud_arr.sh

# Trap set state stack
declare -a _THUD_TRAPS_STACK=()

# Push trap set state to the state stack, optionally invoke "trap".
# Args: [trap_arg...]
function thud_traps_push()
{
    thud_arr_push _THUD_TRAPS_STACK "`trap -p`"
    if [ $# != 0 ]; then
        trap "$@"
    fi
}

# Pop trap set state from the state stack.
function thud_traps_pop()
{
    eval "`thud_arr_peek _THUD_TRAPS_STACK`" || true
    thud_arr_pop _THUD_TRAPS_STACK
}

fi # _THUD_TRAPS_SH
