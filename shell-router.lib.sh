#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Jeff Walter <jeff@404ster.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

__SHELL_ROUTER_N="0"
__SHELL_ROUTER_COMMANDS=()
__SHELL_ROUTER_ROUTES=()
__SHELL_ROUTER_OPTIONS=()

shellrouteAdd() {
	__SHELL_ROUTER_N="$((__SHELL_ROUTER_N + 1))"
	__SHELL_ROUTER_COMMANDS[__SHELL_ROUTER_N]="${1}"
	__SHELL_ROUTER_ROUTES[__SHELL_ROUTER_N]="${2}"
	__SHELL_ROUTER_OPTIONS[__SHELL_ROUTER_N]="${3}"
}
shellrouteSerializeArray() {
	local OUTPUT ELEMENT

	OUTPUT=""
	for ELEMENT in "${@}"; do
		OUTPUT="${OUTPUT} \"$(sed -e 's/\\/\\\\/g' -e 's/"/\"/g' -e 's/\$/\\$/g' <<<"${ELEMENT}")\""
	done

	echo "($(sed -e 's/^ //' <<<"${OUTPUT}"))"
}
shellrouteProcess() {
	local COMMAND_ARGS ARGS_ORIG ARGS ROUTE_I MATCH ROUTE OPTIONS_SPEC OPTION OPTION_FOUND

	ARGS_ORIG=("${@}")

	for ((ROUTE_I="1"; ROUTE_I <= __SHELL_ROUTER_N; ROUTE_I++)); do
		ARGS=("${ARGS_ORIG[@]}")
		eval "ROUTE=(${__SHELL_ROUTER_ROUTES[ROUTE_I]})"
		COMMAND_ARGS=()
		MATCH="n"

		while true; do
			# Check for breaking
			if [ "${#ROUTE[@]}" = "0" ]; then
				if [ "${#ARGS[@]}" = "0" ]; then
					MATCH="y"
				else
					MATCH="n"
				fi
				break
			fi

#			if grep -qE '^:-.+\*$' <<<"${ROUTE[0]}"; then
#				# Options, until a non-option or the end
#				if [ "${#ARGS[@]}" != "0" ]; then
#					# Parse options
#					OPTIONS_SPEC=($(sed -e 's/^:-//' -e 's/\*$//' -e 's/,/ /g' <<<"${ROUTE[0]}"))
#					while [ "${#ARGS[@]}" != "0" ]; do
#						OPTION_FOUND=""
#						for OPTION in "${OPTIONS_SPEC[@]}"; do
#							if grep -qE "^${ARGS[0]}:?\$" <<<"${OPTION}"; then
#								if ! grep -qE ':$' <<<"${OPTION}"; then
#									COMMAND_ARGS+=("OPT_$(sed -e 's/[^a-zA-z0-9_]/_/g' <<<"${OPTION%:}")=\"1\"")
#									OPTION_FOUND="y"
#								elif [ "${#ARGS[@]}" -ge "2" ]; then
#									COMMAND_ARGS+=("OPT_$(sed -e 's/[^a-zA-z0-9_]/_/g' <<<"${OPTION%:}")=\"$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' <<<"${ARGS[1]}")\"")
#									ARGS=("${ARGS[@]:1}")
#								else
#									echo "Error: Option \"${OPTION%:}\" expects a parameter, but none exists" 1>&2
#									return 1
#								fi
#								break
#							fi
#						done
#						if [ -n "${OPTION_FOUND}" ]; then
#							ARGS=("${ARGS[@]:1}")
#						else
#							break
#						fi
#					done
#				fi
#				MATCH="y"
#				break
#
#			else
			if grep -qE '^::.+\*$' <<<"${ROUTE[0]}"; then
				# Optional options, all the way to the end
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" != "0" ]; then
					# Parse options
					OPTIONS_SPEC=($(sed -e 's/^:://' -e 's/\*$//' -e 's/,/ /g' <<<"${ROUTE[0]}"))
					while [ "${#ARGS[@]}" != "0" ]; do
						for OPTION in "${OPTIONS_SPEC[@]}"; do
							if grep -qE "^${ARGS[0]}:?\$" <<<"${OPTION}"; then
								if ! grep -qE ':$' <<<"${OPTION}"; then
									COMMAND_ARGS+=("OPT_${OPTION%:}=\"1\"")
								elif [ "${#ARGS[@]}" -ge "2" ]; then
									COMMAND_ARGS+=("OPT_${OPTION%:}=\"$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' <<<"${ARGS[1]}")\"")
									ARGS=("${ARGS[@]:1}")
								else
									echo "Error: Option \"${OPTION%:}\" expects a parameter, but none exists" 1>&2
									return 1
								fi
								break
							fi
						done
						ARGS=("${ARGS[@]:1}")
					done
				fi
				MATCH="y"
				break

			elif grep -qE '^::.+\+$' <<<"${ROUTE[0]}"; then
				# Required options, all the way to the end
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" != "0" ]; then
					# Parse options
					OPTIONS_SPEC=($(sed -e 's/^:://' -e 's/\*$//' -e 's/,/ /g' <<<"${ROUTE[0]}"))
					while [ "${#ARGS[@]}" != "0" ]; do
						for OPTION in "${OPTIONS_SPEC[@]}"; do
							if grep -qE "^${ARGS[0]}:?\$" <<<"${OPTION}"; then
								if ! grep -qE ':$' <<<"${OPTION}"; then
									COMMAND_ARGS+=("OPT_${OPTION%:}=\"1\"")
								elif [ "${#ARGS[@]}" -ge "2" ]; then
									COMMAND_ARGS+=("OPT_${OPTION%:}=\"$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' <<<"${ARGS[1]}")\"")
									ARGS=("${ARGS[@]:1}")
								else
									echo "Error: Option \"${OPTION%:}\" expects a parameter, but none exists" 1>&2
									return 1
								fi
								break
							fi
						done
						ARGS=("${ARGS[@]:1}")
					done
					MATCH="y"
				else
					MATCH="n"
				fi
				break

			elif grep -qE '^:.+@$' <<<"${ROUTE[0]}"; then
				# Optional arguments, all the way to the end
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" != "0" ]; then
					COMMAND_ARGS+=("ARGV_$(sed -e 's/^://' -e 's/@$//' <<<"${ROUTE[0]}")=$(shellrouteSerializeArray "${ARGS[@]}")")
				fi
				MATCH="y"
				break

			elif grep -qE '^:.+\*$' <<<"${ROUTE[0]}"; then
				# Optional variable, all the way to the end
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" != "0" ]; then
					COMMAND_ARGS+=("ARGV_$(sed -e 's/^://' -e 's/\*$//' <<<"${ROUTE[0]}")=\"$(sed -e 's/"/\"/g' -e 's/\\/\\\\/g' <<<"${ARGS[*]}")\"")
				fi
				MATCH="y"
				break

			elif grep -qE '^:.+\+$' <<<"${ROUTE[0]}"; then
				# Required variable, all the way to the end
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" != "0" ]; then
					COMMAND_ARGS+=("ARGV_$(sed -e 's/^://' -e 's/\+$//' <<<"${ROUTE[0]}")=\"$(sed -e 's/"/\"/g' -e 's/\\/\\\\/g' <<<"${ARGS[*]}")\"")
					MATCH="y"
				else
					MATCH="n"
				fi
				break

			elif grep -qE '^:.+\?$' <<<"${ROUTE[0]}"; then
				# Optional variable
				if [ "${#ROUTE[@]}" != "1" ]; then
					MATCH="n"
					break
				fi
				if [ "${#ARGS[@]}" = "1" ]; then
					COMMAND_ARGS+=("ARG_$(sed -e 's/^://' -e 's/\?$//' <<<"${ROUTE[0]}")=\"$(sed -e 's/"/\"/g' -e 's/\\/\\\\/g' <<<"${ARGS[0]}")\"")
				fi
				if [ "${#ARGS[@]}" -le "1" ]; then
					MATCH="y"
				else
					MATCH="n"
				fi
				break

			elif grep -qE '^:' <<<"${ROUTE[0]}"; then
				# Required variable
				if [ "${#ARGS[@]}" != "0" ]; then
					COMMAND_ARGS+=("ARG_$(sed -e 's/^://' <<<"${ROUTE[0]}")=\"$(sed -e 's/"/\"/g' -e 's/\\/\\\\/g' <<<"${ARGS[0]}")\"")
					MATCH="y"
					ARGS=("${ARGS[@]:1}")
					ROUTE=("${ROUTE[@]:1}")
				else
					MATCH="n"
					break
				fi

			elif grep -qE '\?$' <<<"${ROUTE[0]}"; then
				# Optional element
				ROUTE[0]="$(sed -e 's/\?$//' <<<"${ROUTE[0]}")"
				if [ "${#ARGS[@]}" = "0" ] || [ "${ARGS[0]}" != "${ROUTE[0]}" ]; then
					# Trim from selector
					ROUTE=("${ROUTE[@]:1}")

				elif [ "${ARGS[0]}" = "${ROUTE[0]}" ]; then
					# Trim from both
					COMMAND_ARGS+=("STATIC_$(sed -e 's/\?$//' <<<"${ROUTE[0]}")=\"1\"")
					ARGS=("${ARGS[@]:1}")
					ROUTE=("${ROUTE[@]:1}")
				fi

			else
				# Required element
				if [ "${#ARGS[@]}" = "0" ] || [ "${ARGS[0]}" != "${ROUTE[0]}" ]; then
					MATCH="n"
					break
				fi
				ARGS=("${ARGS[@]:1}")
				ROUTE=("${ROUTE[@]:1}")
			fi
		done

		if [ "${MATCH}" = "y" ]; then
			break
		fi
	done

	if [ "${MATCH}" = "y" ]; then
		"${__SHELL_ROUTER_COMMANDS[ROUTE_I]}" "${COMMAND_ARGS[@]}"
		return 0
	fi

	return 1
}
