#
# Thud - Bash (shopt) option operations
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

if [ -z "${_THUD_OPTS_SH+set}" ]; then
declare _THUD_OPTS_SH=

. thud_arr.sh

# Shell option state stack
declare -a _THUD_OPTS_STACK=()

# Push shell option state to the state stack, optionally invoke "shopt".
# Args: [shopt_arg...]
function thud_opts_push()
{
    thud_arr_push _THUD_OPTS_STACK "`shopt -p`"
    if [ $# != 0 ]; then
        shopt "$@"
    fi
}

# Pop shell option state from the state stack.
function thud_opts_pop()
{
    eval "`thud_arr_peek _THUD_OPTS_STACK`" || true
    thud_arr_pop _THUD_OPTS_STACK
}

fi # _THUD_OPTS_SH
