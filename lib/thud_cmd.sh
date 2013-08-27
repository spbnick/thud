#
# Thud - command operations
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

if [ -z "${_THUD_CMD_SH+set}" ]; then
declare _THUD_CMD_SH=

. thud_strict.sh
. thud_attrs.sh

# Execute a command with "relaxed" shell mode.
# Args: ...
function thud_cmd_relaxed()
{
    declare status=
    thud_strict_push false
    "$@"
    status=$?
    thud_strict_pop
    return $status
}   

# Execute a command within within a "strict" mode subshell.
# Args: ...
function thud_cmd_strict()
{
    (
        thud_strict_on
        "$@"
    )   
}   

# Execute a command within a subshell, ignoring return status regardless of
# the shell attributes.
# Args: ...
function thud_cmd_ignored()
{
    thud_attrs_push +o errexit
    (
        thud_attrs_pop
        "$@"
    )
    thud_attrs_pop
}   

# Define a function executing a command using a modifier command.
# Args: wrapper_name modifier_name command_name
function thud_cmd_wrap()
{
    declare -r wrapper_name="$1";   shift
    declare -r modifier_name="$1";  shift
    declare -r command_name="$1";   shift
    eval '
        function '"$wrapper_name"'()
        {
            '"$modifier_name"' '"$command_name"' "$@"
        }
    '
}

# Define a function executing a command with "relaxed" shell mode.
# Args: wrapper_name command_name
function thud_cmd_relaxify()
{
    declare -r wrapper_name="$1";   shift
    declare -r command_name="$1";   shift
    thud_cmd_wrap "$wrapper_name" thud_cmd_relaxed "$command_name"
}

# Define a function executing a command within a "strict" mode subshell.
# Args: wrapper_name command_name
function thud_cmd_strictify()
{
    declare -r wrapper_name="$1";   shift
    declare -r command_name="$1";   shift
    thud_cmd_wrap "$wrapper_name" thud_cmd_strict "$command_name"
}

# Define a function executing a command within a subshell, ignoring return
# status regardless of the shell attributes.
# Args: wrapper_name command_name
function thud_cmd_ignorify()
{
    declare -r wrapper_name="$1";   shift
    declare -r command_name="$1";   shift
    thud_cmd_wrap "$wrapper_name" thud_cmd_ignored "$command_name"
}

fi # _THUD_CMD_SH
