#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2019 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/bbond007/MiSTer_ScummVM
# Version 2.1.2 - 2019-07-18 - Adapt for use with ScummVM_Installer.sh --> BinaryBond007
# Version 2.1.1 - 2019-06-10 - Testing Internet connectivity with github.com instead of google.com.
# Version 2.1   - 2019-02-23 - CURL RETRY OPTIONS by wesclemens, now the script has a timeout and retry logic to prevent spotty connections causing the update to lockup; thank you very much.
# Version 2.1   - 2019-02-23 - Code review by frederic-mahe, now the script is more standardized and elegant, thank you very much; ALLOW_INSECURE_SSH renamed to ALLOW_INSECURE_SSL.
# Version 2.0   - 2019-02-02 - Added ALLOW_INSECURE_SSH option: "true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html ) is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads, otherwise it will use --insecure option for disabling SSL certificate verification. If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh). "false" will never use --insecure option and if CA certificates aren't installed any download will fail.
# Version 1.0   - 2019-01-07 - First commit


# ========= OPTIONS ==================
SCRIPT_URL="https://github.com/bbond007/MiSTer_ScummVM/blob/master/ScummVM_Installer.sh"

# ========= ADVANCED OPTIONS =========
# ALLOW_INSECURE_SSL="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
# is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
# otherwise it will use --insecure option for disabling SSL certificate verification.
# If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
# ALLOW_INSECURE_SSL="false" will never use --insecure option and if CA certificates aren't installed
# any download will fail.
ALLOW_INSECURE_SSL="TRUE"

CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"

# test network and https by pinging the most available website 
SSL_SECURITY_OPTION=""
curl ${CURL_RETRY} --silent https://github.com > /dev/null 2>&1
case $? in
	0)
		;;
	60)
		if [[ "${ALLOW_INSECURE_SSL}" == "TRUE" ]]
		then
			SSL_SECURITY_OPTION="--insecure"
		else
			echo "CA certificates need"
			echo "to be fixed for"
			echo "using SSL certificate"
			echo "verification."
			echo "Please fix them i.e."
			echo "using security_fixes.sh"
			exit 2
		fi
		;;
	*)
		echo "No Internet connection"
		exit 1
		;;
esac

# download and execute the latest ScummVM_Installer.sh
SCRIPT_NAME="${SCRIPT_URL/*\//}"
echo "Downloading and executing --> $SCRIPT_NAME"
echo ""
curl \
	${CURL_RETRY} \
	${SSL_SECURITY_OPTION} \
	--fail \
	--location \
	--silent \
	"${SCRIPT_URL}?raw=true" | \
	bash -

exit 0
