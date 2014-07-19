#
# Thud - tracing
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

if [ -z "${_THUD_TRACE_SH+set}" ]; then
declare _THUD_TRACE_SH=

. thud_misc.sh

# File descriptor to write trace messages to (used by thud_trace_write)
declare THUD_TRACE_FD=2

# Command registering a trace message which is passed as the argument
declare THUD_TRACE_CMD="thud_trace_write"

# List of glob patterns matching names of functions that shouldn't be traced
declare -a _THUD_TRACE_MASK_LIST=("thud_*" "_thud_*")

# Write a trace message to THUD_TRACE_FD.
# Args: message...
function thud_trace_write()
{
    printf "%s\n" "$*" >&"$THUD_TRACE_FD"
}

# Register a tracing message using THUD_TRACE_CMD, if the executing function
# doesn't match one of _THUD_TRACE_MASK_LIST.
function _thud_trace_trap()
{
    declare func="${FUNCNAME[1]-}"
    declare mask
    for mask in "${_THUD_TRACE_MASK_LIST[@]}"; do
        if [[ "$func" == $mask ]]; then
            return 0
        fi
    done
    declare -r nl=$'\n'
    declare -r loc="${BASH_SOURCE[1]-}:${BASH_LINENO[0]} "
    declare pad
    printf -v pad "%${#loc}s" ""
    "$THUD_TRACE_CMD" "$loc${BASH_COMMAND//$nl/$nl$pad}"
    return 0
}

# Enable tracing.
function thud_trace_on()
{
    trap _thud_trace_trap DEBUG
    set -o functrace
}

# Disable tracing.
function thud_trace_off()
{
    trap - DEBUG
    set +o functrace
}

# Set tracing status.
# Args: trace
function thud_trace_set()
{
    declare -r trace="$1"
    thud_assert 'thud_is_bool "$trace"'
    if "$trace"; then
        thud_trace_on
    else
        thud_trace_off
    fi
}

# Push current traps and attributes to the corresponding stacks and replace
# with those for the specified tracing state.
# Args: trace
function thud_trace_push()
{
    declare trace="$1"
    thud_assert 'thud_is_bool "$trace"'
    thud_traps_push
    thud_attrs_push
    thud_trace_set "$trace"
}

# Pop saved traps and attributes from the corresponding stacks.
function thud_trace_pop()
{
    thud_traps_pop
    thud_attrs_pop
}

# Add a glob pattern matching names of functions that shouldn't be traced.
# Args: glob
function thud_trace_mask()
{
    declare -r glob="$1"
    declare i
    for ((i = 0; i < ${#_THUD_TRACE_MASK_LIST[@]}; i++)); do
        if [ "$glob" == "${_THUD_TRACE_MASK_LIST[i]}" ]; then
            return
        fi
    done
    _THUD_TRACE_MASK_LIST+=("$glob")
}

# Remove a glob pattern matching names of functions that shouldn't be traced.
# Args: glob
function thud_trace_unmask()
{
    declare -r glob="$1"
    declare i
    for ((i = 0; i < ${#_THUD_TRACE_MASK_LIST[@]}; i++)); do
        if [ "$glob" == "${_THUD_TRACE_MASK_LIST[i]}" ]; then
            unset _THUD_TRACE_MASK_LIST[i]
            return
        fi
    done
}

fi # _THUD_TRACE_SH
