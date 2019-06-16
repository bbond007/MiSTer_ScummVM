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

ALLOW_INSECURE_SSL=TRUE
INSTALL_DIR=/media/fat/ScummVM
SCRIPTS_DIR=/media/fat/Scripts
DEB_REPO=http://http.us.debian.org/debian/pool/main
DEB_SCUMMVM17=FALSE
BBOND007_SCUMMVM20=TRUE
GITHUB_REPO=https://github.com/bbond007/MiSTer_ScummVM/raw/master/
ENGINE_DATA=TRUE
CREATE_DIRS=TRUE
DEFAULT_THEME=FALSE
INTERNET_CHECK=https://github.com

#These options probably should not be changed...
DEB_SCUMMVM20=FALSE
DELETE_JUNK=TRUE
DO_INSTALL=TRUE


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
function installDEBS () {
	DEB_REPOSITORIES=( "${@}" )
	TEMP_PATH="/tmp"
	for DEB_REPOSITORY in "${DEB_REPOSITORIES[@]}"; do
		OLD_IFS="${IFS}"
		IFS="|"
		PARAMS=(${DEB_REPOSITORY})
		DEBS_URL="${PARAMS[0]}"
		DEB_PREFIX="${PARAMS[1]}"
		ARCHIVE_FILES="${PARAMS[2]}"
		STRIP_COMPONENTS="${PARAMS[3]}"
		DEST_DIR="${PARAMS[4]}"
		IFS="${OLD_IFS}"
		if [ ! -f "${DEST_DIR}/$(echo $ARCHIVE_FILES | sed 's/*//g')" ]
		then
			DEB_NAMES=$(${CURL_SILENT} "${DEBS_URL}" | grep -oE "\"${DEB_PREFIX}[a-zA-Z0-9%./_+-]*_(armhf|all)\.deb\"" | sed 's/\"//g')
			MAX_VERSION=""
			MAX_DEB_NAME=""
			for DEB_NAME in $DEB_NAMES; do
				CURRENT_VERSION=$(echo "${DEB_NAME}" | grep -o '_[a-zA-Z0-9%.+-]*_' | sed 's/_//g')
				if [[ "${CURRENT_VERSION}" > "${MAX_VERSION}" ]]
				then
					MAX_VERSION="${CURRENT_VERSION}"
					MAX_DEB_NAME="${DEB_NAME}"
				fi
			done
			[ "${MAX_DEB_NAME}" == "" ] && echo "Error searching for ${DEB_PREFIX} in ${DEBS_URL}" && exit 1
			echo "Downloading ${MAX_DEB_NAME}"
			${CURL} "${DEBS_URL}/${MAX_DEB_NAME}" -o "${TEMP_PATH}/${MAX_DEB_NAME}"
			[ ! -f "${TEMP_PATH}/${MAX_DEB_NAME}" ] && echo "Error: no ${TEMP_PATH}/${MAX_DEB_NAME} found." && exit 1
			echo "Extracting ${ARCHIVE_FILES}"
			ORIGINAL_DIR="$(pwd)"
			cd "${TEMP_PATH}"
			rm data.tar.xz data.tar.gz > /dev/null 2>&1	
			ar -x "${TEMP_PATH}/${MAX_DEB_NAME}" data.tar.*
			cd "${ORIGINAL_DIR}"
			rm "${TEMP_PATH}/${MAX_DEB_NAME}"
			mkdir -p "${DEST_DIR}"
			if [ -f "${TEMP_PATH}/data.tar.xz" ]
			then
				tar -xJf "${TEMP_PATH}/data.tar.xz" --wildcards --no-anchored --strip-components="${STRIP_COMPONENTS}" -C "${DEST_DIR}" "${ARCHIVE_FILES}"
				rm "${TEMP_PATH}/data.tar.xz" > /dev/null 2>&1
			else
			  	[ ! -f "${TEMP_PATH}/data.tar.gz" ] && echo "Error: no ${TEMP_PATH}/data.tar found." && exit 1
			  	tar -xzf "${TEMP_PATH}/data.tar.gz" --wildcards --no-anchored --strip-components="${STRIP_COMPONENTS}" -C "${DEST_DIR}" "${ARCHIVE_FILES}"
			  	rm "${TEMP_PATH}/data.tar.gz" > /dev/null 2>&1
			fi
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

	if [ "$DEB_SCUMMVM20" = "TRUE" ];
	then
		installDEBS "$DEB_REPO/s/scummvm|scummvm_2.0.0|scummvm|3|$INSTALL_DIR"
		installDEBS "$DEB_REPO/g/glibc|libc6_2.28-10|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
		installDEBS "$DEB_REPO/libs/libsdl2|libsdl2-2.0-0_2.0.5|lib*|3|$INSTALL_DIR"
		installDEBS "$DEB_REPO/p/pulseaudio|libpulse0_12.2-4|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	fi
	
	if [ "$DEB_SCUMMVM17" = "TRUE" ];
	then
		installDEBS "$DEB_REPO/s/scummvm|scummvm_1.7.0|scummvm|3|$INSTALL_DIR"
		installDEBS "$DEB_REPO/libg/libglvnd|libgl1_1.1.0-1|lib*|3|$INSTALL_DIR"
		installDEBS "$DEB_REPO/libg/libglvnd|libglx0_1.1.0-1|lib*|3|$INSTALL_DIR"
		installDEBS "$DEB_REPO/libg/libglvnd|libglvnd0_1.1.0-1|lib*|3|$INSTALL_DIR"
		curl $SSL_SECURITY_OPTION $CURL_RETRY -L "$GITHUB_REPO/ScummVM_1_7_0.sh" -o "$SCRIPTS_DIR/ScummVM_1_7_0.sh"
	fi
	
	if [ "$BBOND007_SCUMMVM20" = "TRUE" ];
	then
		echo "Downloading --> BBond007_ScummVM_2_0_0..."
		curl $SSL_SECURITY_OPTION $CURL_RETRY -L "$GITHUB_REPO/scummvm20" -o "$INSTALL_DIR/scummvm20"
	fi
	
	curl $SSL_SECURITY_OPTION $CURL_RETRY -L "$GITHUB_REPO/ScummVM_2_0_0.sh" -o "$SCRIPTS_DIR/ScummVM_2_0_0.sh"

	installDEBS "$DEB_REPO/d/directfb|libdirectfb-1.2-9_1.2.10.0|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/f/faad2|libfaad2_2.8.8-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/f/flac|libflac8_1.3.2-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/f/fluidsynth|libfluidsynth1_1.1.6-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/l/lz4|liblz4-1_1.9.1-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/m/mpeg2dec|libmpeg2-4_0.5.1-8|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/n/ncurses|libtinfo5_6.1|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/n/ncurses|libtinfo6_6.1|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/p/pulseaudio|libpulse0_10.0-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/r/readline6|libreadline6_6.3-8|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/s/sndio|libsndio6.1_1.1.0-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/s/sndio|libsndio7.0_1.5.0-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/s/systemd|libsystemd0_215-17|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/t/tcp-wrappers|libwrap0_7.6.q-28|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/w/wayland|libwayland-egl1_1.16.0-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/liba/libasyncns|libasyncns0_0.8-6|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libb/libbsd|libbsd0_0.7.0-2|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/libc/libcaca|libcaca0_0.99.beta19-2|lib*|3|$INSTALL_DIR"	
	installDEBS "$DEB_REPO/libi/libice|libice6_1.0.9-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libj/libjpeg6b|libjpeg62_6b2-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libm/libmad|libmad0_0.15.1b-8|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libo/libogg|libogg0_1.3.2-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libp/libpng|libpng12-0_1.2.50-2|lib*|3|$INSTALL_DIR/arm-linux-gnueabihf"
	installDEBS "$DEB_REPO/libs/libsdl1.2|libsdl1.2debian_1.2.15-10|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libs/libsm|libsm6_1.2.3-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libs/libsndfile|libsndfile1_1.0.28-6|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libt/libtheora|libtheora0_1.1.1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libv/libvorbis|libvorbis0a_1.3.6-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libv/libvorbis|libvorbisenc2_1.3.6-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libv/libvorbis|libvorbisfile3_1.3.6-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libx11|libx11-6_1.6.7-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libx11|libx11-xcb1_1.6.7-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxau|libxau6_1.0.8-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxcb|libxcb1_1.12-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxcursor|libxcursor1_1.2.0-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxdmcp|libxdmcp6_1.1.2-3|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxext|libxext6_1.3.3-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxfixes|libxfixes3_5.0.3-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxi|libxi6_1.7.9-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxinerama|libxinerama1_1.1.4-2|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxrandr|libxrandr2_1.5.1-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxrender|libxrender1_0.9.10-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxss|libxss1_1.2.3-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxtst|libxtst6_1.2.3-1|lib*|3|$INSTALL_DIR"
	installDEBS "$DEB_REPO/libx/libxxf86vm|libxxf86vm1_1.1.4-1|lib*|3|$INSTALL_DIR"
	
	if [ "$DELETE_JUNK" = "TRUE" ];
	then
		echo "Deleting junk..."
		rm -rf $INSTALL_DIR/bug
		rm -rf $INSTALL_DIR/doc
		rm -rf $INSTALL_DIR/lintian
		rm -rf $INSTALL_DIR/menu
		rm -rf $INSTALL_DIR/arm-linux-gnueabihf/doc
		rm -rf $INSTALL_DIR/arm-linux-gnueabihf/doc-base
	fi
	
	if [ "$ENGINE_DATA" = "TRUE" ];
	then
		for ENGINE_FILE in "access.dat" "cryo.dat" "drascula.dat" "hugo.dat" "kyra.dat" "lure.dat" "macventure.dat" "mort.dat" "teenagent.dat" "titanic.dat" "tony.dat" "toon.dat";
		do
			echo "Downloading engine data --> $ENGINE_FILE"
			curl $SSL_SECURITY_OPTION $CURL_RETRY -L "$GITHUB_REPO/engine-data/$ENGINE_FILE" -o "$INSTALL_DIR/$ENGINE_FILE"
		done
	fi
	
	if [ "$DEFAULT_THEME" = "TRUE" ];
	then
		echo "Downloading --> SCUMM Modern theme"
		curl $SSL_SECURITY_OPTION $CURL_RETRY -L "$GITHUB_REPO/scummmodern.zip" -o "$INSTALL_DIR/scummmodern.zip"
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


