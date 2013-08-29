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

# Output a backtrace, starting with the specified frame (default is 1,
# caller's frame).
# Args: [start_frame]
function thud_backtrace()
{
    declare start_frame=${1-1}
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
# printing a stack trace starting from the specified frame (0 is the caller's
# frame) and an optional message (default is "Aborted").
# Args: frame [echo_arg]...
function thud_abort_frame()
{
    declare -r frame="$1";  shift
    declare pid=

    if [ -n "${THUD_ABORT_PID:+set}" ]; then
        pid="$THUD_ABORT_PID"
    else
        pid="$$"
    fi
    {
        echo Backtrace:
        thud_backtrace "$((frame + 2))"
        echo -n "${BASH_SOURCE[frame+1]}:${BASH_LINENO[frame]}: "
        echo "${@-Aborted}"
    } >&2
    kill -s SIGABRT "$pid"
}

# Abort execution by sending SIGABRT to THUD_ABORT_PID, or to $$ if not set,
# printing the caller's stack trace and an optional message.
# Args: [echo_arg]...
function thud_abort()
{
    thud_abort_frame 1 "$@"
}

# Evaluate and execute a command string, abort shell if unsuccessfull.
# Args: [eval_arg]...
function thud_assert()
{
    # Use private global-style variable names
    # to avoid clashes with "evaled" names
    declare _THUD_ASSERT_ATTRS
    declare _THUD_ASSERT_STATUS

    read -rd '' _THUD_ASSERT_ATTRS < <(set +o) || [ $? == 1 ]
    set +o errexit
    (
        eval "$_THUD_ASSERT_ATTRS"
        eval "$@"
    )
    _THUD_ASSERT_STATUS=$?
    eval "$_THUD_ASSERT_ATTRS"
    if [ "$_THUD_ASSERT_STATUS" != 0 ]; then
        thud_abort_frame 1 "Assertion failed: $*"
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
