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

if [ -z "${_THUD_MISC_SH+set}" ]; then
declare _THUD_MISC_SH=

# The topmost PID (along the child->parent chain) that thud_abort_frame should
# send SIGABRT to, or current shell PID if unset or empty.
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

# Get current shell process ID.
# Args: _pid_var
function thud_get_pid()
{
    declare -r _pid_var="$1"
    if [ "${BASHPID+set}" ]; then
        eval "$_pid_var=\$BASHPID"
    else
        declare _discard
        read -r "$_pid_var" _discard < /proc/self/stat
    fi
}

# Get the specified or current shell process parent process ID.
# Args: _ppid_var [_pid]
function thud_get_ppid()
{
    declare -r _ppid_var="$1";  shift
    declare -r _pid="$1";       shift
    declare _status
    read -rd '' _status < "/proc/${_pid-self}/status"
    read -r "$_ppid_var" < <(awk '/^PPid:/ {print $2}' <<<"$_status")
}

# Send a signal to each process between a child and a parent, starting from
# the parent, don't send any signal if either of them is not found.
# Args: signal parent_pid child_pid
function thud_kill_branch()
{
    declare -r signal="$1";     shift
    declare -r parent_pid="$1"; shift
    declare -r child_pid="$1";  shift
    declare next_child_pid

    if [ "$child_pid" == "0" ]; then
        return 1
    fi

    if [ "$child_pid" != "$parent_pid" ]; then
        thud_get_ppid next_child_pid "$child_pid"
        if ! thud_kill_branch "$signal" "$parent_pid" "$next_child_pid"; then
            return 1
        fi
    fi
    kill -s "$signal" "$child_pid"
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

# Abort execution by sending SIGABRT to the process branch starting from the
# current shell and up to THUD_ABORT_PID, or just the current shell, if
# THUD_ABORT_PID is not set, empty or such process is not found. Before doing
# that, output a stack trace starting from the specified frame (0 is the
# caller's frame) and an optional message (default is "Aborted").
# Args: frame [echo_arg]...
function thud_abort_frame()
{
    declare -r frame="$1";  shift
    declare pid
    {
        echo Backtrace:
        thud_backtrace "$((frame + 2))"
        echo -n "${BASH_SOURCE[frame+1]-}:${BASH_LINENO[frame]}: "
        echo "${@-Aborted}"
    } >&2
    thud_get_pid pid
    [ "${THUD_ABORT_PID:+set}" ] &&
        thud_kill_branch SIGABRT "$THUD_ABORT_PID" "$pid" ||
            kill -s SIGABRT "$pid"
}

# Abort execution by sending SIGABRT to the process branch starting from the
# current shell and up to THUD_ABORT_PID, or just the current shell, if
# THUD_ABORT_PID is not set, empty or such process is not found. Before doing
# that, output a stack trace starting from the caller's frame and an optional
# message (default is "Aborted").
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

# Check if a string is an existing variable name.
# Args: str
function thud_is_var()
{
    declare -p "$1" >/dev/null 2>&1
}

# Check if a string is an existing array variable name.
# Args: str
function thud_is_arr()
{
    [[ `declare -p "$1" 2>/dev/null` == "declare -"[Aa]* ]]
}

# Check if a string is an existing indexed array variable name.
# Args: str
function thud_is_idx_arr()
{
    [[ `declare -p "$1" 2>/dev/null` == "declare -a"* ]]
}

# Check if a string is an existing associative array variable name.
# Args: str
function thud_is_ass_arr()
{
    [[ `declare -p "$1" 2>/dev/null` == "declare -A"* ]]
}

# Check if a string is an existing function name
# Args: str
function thud_is_func()
{
    declare -f "$1" >/dev/null 2>&1
}

# Check if a string is a valid boolean value, i.e. "true" or "false".
# Args: str
function thud_is_bool()
{
    [[ "$1" == "true" || "$1" == "false" ]]
}

fi # _THUD_MISC_SH
