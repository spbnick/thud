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

AC_PREREQ(2.60)
AC_INIT([thud], [1])
AM_INIT_AUTOMAKE([1.10 -Wall foreign])
AC_PROG_INSTALL
AC_PROG_SED

AC_ARG_ENABLE([docs],
              [AC_HELP_STRING(
                    [--disable-docs],
                    [Disable installation of documentation]
               )
              ],
              [
                    case "${enableval}" in
                        yes)    enable_docs=true ;;
                        no)     enable_docs=false ;;
                        *)      AC_MSG_ERROR([invalid --enable-docs value]) ;;
                    esac
              ],
              [enable_docs=true]
)
AM_CONDITIONAL([ENABLE_DOCS], [test x$enable_docs = xtrue])

AC_ARG_ENABLE([lib-path],
              [AC_HELP_STRING(
                    [--enable-lib-path=PATH],
                    [Specify installed module library path [pkgdatadir]]
               )
              ],
              [thud_lib_path="$enableval"]
)
AC_SUBST(thud_lib_path)

AC_CONFIG_FILES([Makefile lib/Makefile src/Makefile])
AC_OUTPUT
