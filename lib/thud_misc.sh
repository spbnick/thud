#
# Thud - miscellaneous functions
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

if [ -z "${_THUD_SH+set}" ]; then
declare _THUD_SH=

# The PID thud_abort should send SIGABRT to, or empty, meaning $$.
declare THUD_ABORT_PID=

# Unindent text by removing at most the number of spaces present in the first
# non-empty line from the beginning of every line.
# Input: indented text
# Output: unindented text
function thud_unindent()
{
    awk --re-interval '
        BEGIN {
            p = ""
        }
        {
            l = $0
            if (l != "") {
                if (p == "")
                    p = "^ {0," (match(l, /[^ ]/) - 1) "}"
                sub(p, "", l)
            }
            print l
        }
    '
}

# Output a backtrace.
# Args: [start_frame]
function thud_backtrace()
{
    declare start_frame=${1-1}
    thud_assert '((start_frame >= 0))'
    declare frame
    declare argc
    declare argi="${#BASH_ARGV[@]}"

    for ((frame = ${#FUNCNAME[@]} - 1; frame >= start_frame; frame--)); do
        echo -n "#$((frame - start_frame))" \
                "${BASH_SOURCE[frame+1]-}:${BASH_LINENO[frame]}" \
                "${FUNCNAME[frame]}"
        for ((argc = ${BASH_ARGC[frame]-0}; argc > 0; argc--)); do
            printf ' %q' "${BASH_ARGV[--argi]}"
        done
        echo
    done
}

# Abort execution by sending SIGABRT to THUD_ABORT_PID, or to $$ if not set,
# printing a stack trace starting from the specified frame and an optional
# message.
# Args: frame [echo_arg]...
function thud_abort_frame()
{
    declare -r frame="$1";  shift
    thud_assert '(("$frame" >= 0))'
    declare pid=

    if [ -n "${THUD_ABORT_PID:+set}" ]; then
        pid="$THUD_ABORT_PID"
    else
        pid="$$"
    fi
    echo Backtrace: >&2
    thud_backtrace "$((frame + 1))" >&2
    if [ $# != 0 ]; then
        echo "$@" >&2
    fi
    kill -s SIGABRT "$pid"
}

# Abort execution by sending SIGABRT to THUD_ABORT_PID, or to $$ if not set,
# printing the caller's stack trace and an optional message.
# Args: [echo_arg]...
function thud_abort()
{
    thud_abort_frame 2 "$@"
}

# Evaluate and execute a command string, abort shell if unsuccessfull.
# Args: [eval_arg]...
function thud_assert()
{
    thud_attrs_push +o errexit
    (
        thud_attrs_pop
        eval "$@"
    )
    if [ $? != 0 ]; then
        thud_attrs_pop
        thud_abort_frame \
            2 "${BASH_SOURCE[1]}:${BASH_LINENO[0]}: Assertion failed: $*"
    else
        thud_attrs_pop
    fi
}

# Check if a string is a valid variable or function name.
# Args: str
function thud_is_name()
{
    [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Check if a string is a valid boolean value, i.e. "true" or "false".
# Args: str
function thud_is_bool()
{
    [[ "$1" == "true" || "$1" == "false" ]]
}

fi # _THUD_SH
