#!/bin/bash
#------------------------------------------------------------------------------
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

# Functions 'setupCURL' and 'installDEBS' are Copyright 2019 
# Alessandro "Locutus73" Miele
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# get the name of the script, or of the parent script if called through a 'curl ... | bash -'
ORIGINAL_SCRIPT_PATH="${0}"
[[ "${ORIGINAL_SCRIPT_PATH}" == "bash" ]] && \
	ORIGINAL_SCRIPT_PATH="$(ps -o comm,pid | awk -v PPID=${PPID} '$2 == PPID {print $1}')"

# ini file can contain user defined variables (as bash commands)
# Load and execute the content of the ini file, if there is one
INI_PATH="${ORIGINAL_SCRIPT_PATH%.*}.ini"
if [[ -f "${INI_PATH}" ]] ; then
	echo "$INI_PATH found :)"
	TMP=$(mktemp)
	# preventively eliminate DOS-specific format and exit command  
	dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP}
	source ${TMP}
	rm -f ${TMP}
else
	echo "$INI_PATH not found..."
fi

#------------------------------------------------------------------------------
if [ -z "$ALLOW_INSECURE_SSL" ];          then ALLOW_INSECURE_SSL="TRUE"; fi
if [ -z "$INSTALL_DIR" ];                 then INSTALL_DIR="/media/fat/ScummVM"; fi
if [ -z "$SCRIPTS_DIR" ];                 then SCRIPTS_DIR="/media/fat/Scripts"; fi
if [ -z "$GITHUB_REPO" ];                 then GITHUB_REPO="https://github.com/bbond007/MiSTer_ScummVM/raw/master"; fi
if [ -z "$GITHUB_DEB_REPO" ];             then GITHUB_DEB_REPO="$GITHUB_REPO/DEBS"; fi
if [ -z "$DEB_SCUMM" ];                   then DEB_SCUMMVM17="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM20" ];          then BBOND007_SCUMMVM20="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM21" ];          then BBOND007_SCUMMVM21="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM21_UNSTABLE" ]; then BBOND007_SCUMMVM21_UNSTABLE="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM22" ];          then BBOND007_SCUMMVM22="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM22_UNSTABLE" ]; then BBOND007_SCUMMVM22_UNSTABLE="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM23" ];          then BBOND007_SCUMMVM23="TRUE"; fi
if [ -z "$BBOND007_SCUMMVM23_UNSTABLE" ]; then BBOND007_SCUMMVM23_UNSTABLE="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM25" ];          then BBOND007_SCUMMVM25="FALSE"; fi
if [ -z "$BBOND007_SCUMMVM25_UNSTABLE" ]; then BBOND007_SCUMMVM25_UNSTABLE="FALSE"; fi
if [ -z "$ENGINE_DATA" ];                 then ENGINE_DATA="TRUE"; fi
if [ -z "$CREATE_DIRS" ];                 then CREATE_DIRS="TRUE"; fi
if [ -z "$DEFAULT_THEME" ];               then DEFAULT_THEME="FALSE"; fi
if [ -z "$INTERNET_CHECK" ];              then INTERNET_CHECK="https://github.com"; fi
if [ -z "$VERBOSE_MODE" ];                then VERBOSE_MODE="FALSE"; fi

#These options probably should not be changed...
if [ -z "$DELETE_JUNK" ];                 then DELETE_JUNK="TRUE"; fi
if [ -z "$DO_INSTALL" ];                  then DO_INSTALL="TRUE"; fi

#------------------------------------------------------------------------------
function setupCURL
{
	[ ! -z "${CURL}" ] && return
	CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"
	# test network and https by pinging the most available website 
	SSL_SECURITY_OPTION=""
	curl ${CURL_RETRY} --silent $INTERNET_CHECK > /dev/null 2>&1
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
	CURL="curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location"
	CURL_SILENT="${CURL} --silent --fail"
}

#------------------------------------------------------------------------------
function installGithubDEBS () {
	GITHUB_DEB_REPOSITORIES=( "${@}" )
	TEMP_PATH="/tmp"
	for GITHUB_DEB_REPOSITORY in "${GITHUB_DEB_REPOSITORIES[@]}"; do
		OLD_IFS="${IFS}"
		IFS="|"
		PARAMS=(${GITHUB_DEB_REPOSITORY})
		TEMP_PATH="/tmp"
		DEB_URL="${PARAMS[0]}"
		DEB_NAME="${PARAMS[1]}"
		ARC_FILES="${PARAMS[2]}"
		STRIP_CPT="${PARAMS[3]}"
        	DEST_DIR="${PARAMS[4]}"
		IFS="${OLD_IFS}"
		if [ "$VERBOSE_MODE" = "TRUE" ];
		then
 			echo "DEB_URL   --> $DEB_URL"
			echo "DEB_NAME  --> $DEB_NAME"
			echo "ARC_FILES --> $ARC_FILES"
			echo "STRIP_CPT --> $STRIP_CPT"
			echo "DEST_DIR  --> $DEST_DIR"	
		else
			echo "Downloading --> ${DEB_NAME}"
		fi
		${CURL} -L "${DEB_URL}/${DEB_NAME}" -o "${TEMP_PATH}/${DEB_NAME}"
		[ ! -f "${TEMP_PATH}/${DEB_NAME}" ] && echo "Error: no ${TEMP_PATH}/${DEB_NAME} found." && exit 1
		echo "Extracting ${ARC_FILES}"
		ORIGINAL_DIR="$(pwd)"
		cd "${TEMP_PATH}"
		rm data.tar.xz data.tar.gz > /dev/null 2>&1	
		ar -x "${TEMP_PATH}/${DEB_NAME}" data.tar.*
		cd "${ORIGINAL_DIR}"
		rm "${TEMP_PATH}/${DEB_NAME}"
		mkdir -p "${DEST_DIR}"
		if [ -f "${TEMP_PATH}/data.tar.xz" ]
		then
			tar -xJf "${TEMP_PATH}/data.tar.xz" --wildcards --no-anchored --strip-components="${STRIP_CPT}" -C "${DEST_DIR}" "${ARC_FILES}"
			rm "${TEMP_PATH}/data.tar.xz" > /dev/null 2>&1
		else
		  	[ ! -f "${TEMP_PATH}/data.tar.gz" ] && echo "Error: no ${TEMP_PATH}/data.tar found." && exit 1
		  	tar -xzf "${TEMP_PATH}/data.tar.gz" --wildcards --no-anchored --strip-components="${STRIP_CPT}" -C "${DEST_DIR}" "${ARC_FILES}"
		  	rm "${TEMP_PATH}/data.tar.gz" > /dev/null 2>&1
		fi
	done
}

#------------------------------------------------------------------------------
setupCURL
if [ "$DO_INSTALL" = "TRUE" ];
then
	echo "Beginning Install..."
	if [ -d "$INSTALL_DIR" ];
	then
		echo "ScummVM install directory found :)"
	else
		echo "ScummVM install directory not found :("
		echo "Creating --> $INSTALL_DIR"
		mkdir $INSTALL_DIR
	fi
	
	if [ -d "$SCRIPTS_DIR" ];
	then
		echo "Scripts directory found :)"
	else
		echo "Scripts directory not found :("
		echo "Creating --> $SCRIPTS_DIR"
		mkdir $SCRIPTS_DIR
	fi
	
	if [ "$DEB_SCUMMVM17" = "TRUE" ];
	then
		installGithubDEBS "$GITHUB_DEB_REPO|scummvm_1.7.0+dfsg-2_armhf.deb|scummvm|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libgl1_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libglvnd0_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libglx0_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
		${CURL} -L "$GITHUB_REPO/ScummVM_1_7_0.sh" -o "$SCRIPTS_DIR/ScummVM_1_7_0.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM20" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_0_0..."
		${CURL} -L "$GITHUB_REPO/scummvm20" -o "$INSTALL_DIR/scummvm20"
		${CURL} -L "$GITHUB_REPO/ScummVM_2_0_0.sh" -o "$SCRIPTS_DIR/ScummVM_2_0_0.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM21" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_1_0..."
		${CURL} -L "$GITHUB_REPO/scummvm21" -o "$INSTALL_DIR/scummvm21"		
		${CURL} -L "$GITHUB_REPO/ScummVM_2_1_0.sh" -o "$SCRIPTS_DIR/ScummVM_2_1_0.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM21_UNSTABLE" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_1_0_Unstable..."
		${CURL} -L "$GITHUB_REPO/scummvm21-unstable" -o "$INSTALL_DIR/scummvm21-unstable"
		${CURL} -L "$GITHUB_REPO/ScummVM_2_1_0_Unstable.sh" -o "$SCRIPTS_DIR/ScummVM_2_1_0_Unstable.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM22" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_2_0..."
		${CURL} -L "$GITHUB_REPO/scummvm22" -o "$INSTALL_DIR/scummvm22"		
		${CURL} -L "$GITHUB_REPO/ScummVM_2_2_0.sh" -o "$SCRIPTS_DIR/ScummVM_2_2_0.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM22_UNSTABLE" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_2_0_Unstable..."
		${CURL} -L "$GITHUB_REPO/scummvm22-unstable" -o "$INSTALL_DIR/scummvm22-unstable"
		${CURL} -L "$GITHUB_REPO/ScummVM_2_2_0_Unstable.sh" -o "$SCRIPTS_DIR/ScummVM_2_2_0_Unstable.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM23" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_3..."
		${CURL} -L "$GITHUB_REPO/scummvm23" -o "$INSTALL_DIR/scummvm23"		
		${CURL} -L "$GITHUB_REPO/ScummVM_2_3.sh" -o "$SCRIPTS_DIR/ScummVM_2_3.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM23_UNSTABLE" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_3_Unstable..."
		${CURL} -L "$GITHUB_REPO/scummvm23-unstable" -o "$INSTALL_DIR/scummvm23-unstable"
		${CURL} -L "$GITHUB_REPO/ScummVM_2_3_Unstable.sh" -o "$SCRIPTS_DIR/ScummVM_2_3_Unstable.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM25" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_5..."
		${CURL} -L "$GITHUB_REPO/scummvm25" -o "$INSTALL_DIR/scummvm25"		
		${CURL} -L "$GITHUB_REPO/ScummVM_2_5.sh" -o "$SCRIPTS_DIR/ScummVM_2_5.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM25UNSTABLE" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_5Unstable..."
		${CURL} -L "$GITHUB_REPO/scummvm25-unstable" -o "$INSTALL_DIR/scummvm25-unstable"
		${CURL} -L "$GITHUB_REPO/ScummVM_2_5_Unstable.sh" -o "$SCRIPTS_DIR/ScummVM_2_5_Unstable.sh"
	fi
	
	installGithubDEBS "$GITHUB_DEB_REPO|libasyncns0_0.8-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libbsd0_0.7.0-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libcaca0_0.99.beta19-2.1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libdb5.3_5.3.28-12+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libdirectfb-1.2-9_1.2.10.0-8+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libfaad2_2.8.8-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libflac8_1.3.2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libfluidsynth1_1.1.6-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libice6_1.0.9-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libjpeg62_6b2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|liblz4-1_1.9.1-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libmad0_0.15.1b-8+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libmpeg2-4_0.5.1-8_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libogg0_1.3.2-1+b1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libpng12-0_1.2.50-2+deb8u3_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libpulse0_10.0-1+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libreadline6_6.3-8+b3_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl1.2debian_1.2.15-10+b1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsm6_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndfile1_1.0.28-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndio6.1_1.1.0-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndio7.0_1.5.0-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsystemd0_215-17+deb8u7_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libtheora0_1.1.1+dfsg.1-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libtinfo5_6.1+20181013-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libtinfo6_6.1+20181013-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libvorbis0a_1.3.6-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libvorbisenc2_1.3.6-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libvorbisfile3_1.3.6-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwayland-egl1_1.16.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwrap0_7.6.q-28_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libx11-6_1.6.7-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libx11-xcb1_1.6.7-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxau6_1.0.8-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxcb1_1.12-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxcursor1_1.2.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxdmcp6_1.1.2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxext6_1.3.3-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxfixes3_5.0.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxi6_1.7.9-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxinerama1_1.1.4-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxrandr2_1.5.1-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxrender1_0.9.10-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxss1_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxtst6_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxxf86vm1_1.1.4-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"
		
	if [ "$DELETE_JUNK" = "TRUE" ];
	then
		echo "Deleting junk..."
		for JUNK_FILE in "bug" "doc" "lib" "lintian" "menu" "share";
		do
			rm -rf "$INSTALL_DIR/$JUNK_FILE"
		done
	fi

	if [ "$ENGINE_DATA" = "TRUE" ];
	then
		for ENGINE_FILE in "access.dat" "cryo.dat" "cryomni3d.dat" "drascula.dat" "fonts.dat" "hugo.dat" "kyra.dat" "lure.dat" "macventure.dat" "mort.dat" "prince_translation.dat" "supernova.dat" "teenagent.dat" "titanic.dat" "tony.dat" "toon.dat" "ultima.dat";
		do
			echo "Downloading engine data --> $ENGINE_FILE"
			${CURL} -L "$GITHUB_REPO/engine-data/$ENGINE_FILE" -o "$INSTALL_DIR/$ENGINE_FILE"
		done
	fi
	
	if [ "$DEFAULT_THEME" = "TRUE" ];
	then
		echo "Downloading --> SCUMM Modern theme"
		if [ "$BBOND007_SCUMMVM20" = "TRUE" ];
		then
			${CURL} -L "$GITHUB_REPO/scummmodern20.zip" -o "$INSTALL_DIR/scummmodern.zip"
		fi
		if [ "$BBOND007_SCUMMVM21" = "TRUE" ] || [ "$BBOND007_SCUMMVM21_UNSTABLE" = "TRUE" ];
		then
			${CURL} -L "$GITHUB_REPO/scummmodern21.zip" -o "$INSTALL_DIR/scummmodern.zip"
		fi
		if [ "$BBOND007_SCUMMVM22" = "TRUE" ] || [ "$BBOND007_SCUMMVM22_UNSTABLE" = "TRUE" ];
		then
			${CURL} -L "$GITHUB_REPO/scummmodern22.zip" -o "$INSTALL_DIR/scummmodern.zip"
		fi
		if [ "$BBOND007_SCUMMVM23" = "TRUE" ] || [ "$BBOND007_SCUMMVM23_UNSTABLE" = "TRUE" ];
		then
			${CURL} -L "$GITHUB_REPO/scummmodern23.zip" -o "$INSTALL_DIR/scummmodern.zip"
		fi
		if [ "$BBOND007_SCUMMVM25" = "TRUE" ] || [ "$BBOND007_SCUMMVM25_UNSTABLE" = "TRUE" ];
		then
			${CURL} -L "$GITHUB_REPO/scummmodern25.zip" -o "$INSTALL_DIR/scummmodern.zip"
		fi
	fi
	
	if [ "$CREATE_DIRS" = "TRUE" ];
	then
		echo "Creating additional directories..."
		for NEW_DIR in "GAMES";
		do
			if [ -d "$INSTALL_DIR/$NEW_DIR" ];
			then
				echo "$INSTALL_DIR/$NEW_DIR directory found :)"
			else
				echo "$INSTALL_DIR/$NEW_DIR directory not found :("
				echo "Creating --> $INSTALL_DIR/$NEW_DIR"
				mkdir $INSTALL_DIR/$NEW_DIR
			fi
		done
	fi
	
	echo "Done in:"
	for i in 3 2 1;
	do
		echo "$i"
		sleep 1
	done
fi

