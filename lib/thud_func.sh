#
# Thud - function operations
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

if [ -z "${_THUD_FUNC_SH+set}" ]; then
declare _THUD_FUNC_SH=

# Copy a function under another name.
# Args: _new_name _orig_name
function thud_func_copy()
{
    declare -r _new_name="$1"
    declare -r _orig_name="$2"
    declare -r _definition=`declare -f "$orig_name"`
    eval "${_definition/$_orig_name/$_new_name}"
}

# Rename a function.
# Args: _new_name _orig_name
function thud_func_rename()
{
    declare -r _new_name="$1"
    declare -r _orig_name="$2"
    declare -r _definition=`declare -f "$orig_name"`
    eval "${_definition/$_orig_name/$_new_name}"
    unset "$orig_name"
}

fi # _THUD_FUNC_SH
