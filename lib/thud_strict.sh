#
# Thud - strict shell mode management
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

if [ -z "${_THUD_STRICT_SH+set}" ]; then
declare _THUD_STRICT_SH=

. thud_attrs.sh
. thud_opts.sh

declare -r -a THUD_STRICT_ATTRS_ON=(-o errexit
                                    -o nounset
                                    -o pipefail
                                    -o noclobber)

declare -r -a THUD_STRICT_ATTRS_OFF=(${THUD_STRICT_ATTRS_ON[@]/-/+})

declare -r -a THUD_STRICT_OPTS=(shift_verbose failglob)

# Set strict mode.
# Args: strict
function thud_strict_set()
{
    declare -r strict="$1"
    thud_assert 'thud_is_bool "$strict"'
    if "$strict"; then
        set "${THUD_STRICT_ATTRS_ON[@]}"
        shopt -s "${THUD_STRICT_OPTS[@]}"
    else
        set "${THUD_STRICT_ATTRS_OFF[@]}"
        shopt -u "${THUD_STRICT_OPTS[@]}"
    fi
}

# Enable strict mode.
function thud_strict_on()
{
    thud_strict_set true
}

# Disable strict mode.
function thud_strict_off()
{
    thud_strict_set false
}

# Push current attributes and options to the corresponding stacks and replace
# with attributes and options for the specified strict mode.
# Args: strict
function thud_strict_push()
{
    declare strict="$1"
    thud_assert 'thud_is_bool "$strict"'
    thud_attrs_push
    thud_opts_push
    thud_strict_set "$strict"
}

# Pop saved attributes and options from the corresponding stacks.
function thud_strict_pop()
{
    thud_attrs_pop
    thud_opts_pop
}

fi # _THUD_STRICT_SH
