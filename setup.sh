#!/usr/bin/env bash

# Options
export SET_MIRRORS="${SET_MIRRORS:-true}"

# Colors
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
WHITE="\033[37m"
RESET="\033[0m"

# Start logging
LOG_FILE="$PWD/os-setup.log"
if [[ -f "$LOG_FILE" ]]; then
	mv -f "$LOG_FILE" "${LOG_FILE}.old"
fi
exec 2> >(tee -a "$LOG_FILE" >&2)
echo -e "${BOLD}${WHITE}The script output will be logged to file ${YELLOW}\"$LOG_FILE\"${WHITE}.${RESET}" >&2

# Get system information
OS_NAME=""
if [[ "$(uname -s)" == "Darwin" ]]; then
	OS_NAME="macOS"
elif [[ "$(uname -s)" == "Linux" ]]; then
	if grep -qiE 'ID.*ubuntu' /etc/*-release; then
		OS_NAME="Ubuntu"
	elif grep -qiE 'ID.*manjaro' /etc/*-release; then
		OS_NAME="Manjaro"
	fi
fi

if [[ -z "$OS_NAME" ]]; then
	echo -e "${BOLD}${RED}The operating system is not supported yet. ${YELLOW}Only macOS, Ubuntu Linux, and Manjaro Linux are supported.${RESET}" >&2
	exit 1
fi

echo -e "${BOLD}${WHITE}Operating System: ${GREEN}${OS_NAME}${RESET}"

# Run script if it exists
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -x "$SCRIPT_DIR/setup_${OS_NAME}.sh" && "$(basename "$0")" == "setup.sh" ]]; then
	if [[ -d "$SCRIPT_DIR/.git" || "$(basename "$SCRIPT_DIR")" == "OS-Setup-master" ]]; then
		echo -e "${BOLD}${WHITE}Run existing script ${GREEN}\"$SCRIPT_DIR/setup_${OS_NAME}.sh\"${WHITE}.${RESET}" >&2
		bash "$SCRIPT_DIR/setup_${OS_NAME}.sh"
		exit
	fi
fi

# Download and run
if [[ -x "$(command -v wget)" ]]; then
	echo -e "${BOLD}${WHITE}Download and run script via ${GREEN}wget${WHITE}.${RESET}" >&2
	bash -c "$(wget --progress=bar:force:noscroll -O - https://github.com/XuehaiPan/OS-Setup/raw/master/setup_${OS_NAME}.sh)"
elif [[ -x "$(command -v curl)" ]]; then
	echo -e "${BOLD}${WHITE}Download and run script via ${GREEN}curl${WHITE}.${RESET}" >&2
	bash -c "$(curl -fL# https://github.com/XuehaiPan/OS-Setup/raw/master/setup_${OS_NAME}.sh)"
elif [[ -x "$(command -v git)" ]]; then
	echo -e "${BOLD}${WHITE}Download and run script via ${GREEN}git${WHITE}.${RESET}" >&2
	git clone --depth=1 https://github.com/XuehaiPan/OS-Setup.git 2>&1
	bash "OS-Setup/setup_${OS_NAME}.sh"
else
	echo -e "${BOLD}${WHITE}Please download the script from ${YELLOW}https://github.com/XuehaiPan/OS-Setup${WHITE} manually.${RESET}" >&2
fi
