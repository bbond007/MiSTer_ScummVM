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

SCUMMVM_CPU_MASK=03
MT32PI_CPU_MASK=03
SCUMMVM_EXE_NAME="scummvm250"
SCUMMVM_HOME_DIR="/media/fat/ScummVM"
SCUMMVM_OPTIONS="--opl-driver=db --output-rate=48000"
SCUMMVM_LIB_PATH="${SCUMMVM_HOME_DIR}/arm-linux-gnueabihf:${SCUMMVM_HOME_DIR}/arm-linux-gnueabihf/pulseaudio"
MT32PI_DRIVER="/media/fat/linux/MIDIMeister"

# Set corename for tty2oled/i2c2oled
echo "ScummVM" > /tmp/CORENAME

echo "Setting Video mode..."
vmode -r 640 480 rgb16

echo "Setting library path..."
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${SCUMMVM_LIB_PATH}"
echo ${LD_LIBRARY_PATH}
echo "Setting ScummVM HOME path..."
export HOME="${SCUMMVM_HOME_DIR}"

if [ -f "${MT32PI_DRIVER}" ]
then
	killall ${MT32PI_DRIVER}
	echo "Startting MIDIMeister..."
	# for UDP mode
	#taskset ${MT32PI_CPU_MASK} ${MT32PI_DRIVER} QUIET UDP mt32-pi1.com-in.de &
	# for normal mode
	taskset ${MT32PI_CPU_MASK} ${MT32PI_DRIVER} QUIET &
fi

cd ${SCUMMVM_HOME_DIR}
echo "Starting ScummVM..."
taskset ${SCUMMVM_CPU_MASK} ${SCUMMVM_HOME_DIR}/${SCUMMVM_EXE_NAME} ${SCUMMVM_OPTIONS} 

if [ -f "${MT32PI_DRIVER}" ]
then
	echo "Killing MIDIMeister..."
	killall ${MT32PI_DRIVER}
fi

# Set corename for tty2oled/i2c2oled
echo "MENU" > /tmp/CORENAME
