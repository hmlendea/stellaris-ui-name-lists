#!/bin/bash

BUILD_DIRECTORY_PATH="./build"
OUTPUT_DIRECTORY_PATH="./out"
GENERATOR_EXECUTABLE="dotnet /home/horatiu/Downloads/stellaris-name-list-generator/bin/Debug/netcoreapp2.2/StellarisNameListGenerator.dll"

[ ! -d "${BUILD_DIRECTORY_PATH}" ] && mkdir "${BUILD_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_DIRECTORY_PATH}" ] && mkdir "${OUTPUT_DIRECTORY_PATH}"

function merge {
    OUTPUT_FILE_NAME=$1
    shift 1

    head -2 "./name-lists/$1.xml" > "${OUTPUT_FILE_NAME}"

    for NAME_LIST in "$@"; do
        tail -n +3 "./name-lists/${NAME_LIST}.xml" | head -n -1 >> "${OUTPUT_FILE_NAME}"
        echo " " >> "${OUTPUT_FILE_NAME}"
    done

    tail -1 "./name-lists/$1.xml" >> "${OUTPUT_FILE_NAME}"
}

function build {
    NAMELIST_ID=$1
    NAMELIST_FILE_PATH="${BUILD_DIRECTORY_PATH}/${NAMELIST_ID}.xml"
    OUTPUT_FILE_PATH="${OUTPUT_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    shift

    echo "Building ${NAMELIST_ID}..."

    merge ${NAMELIST_FILE_PATH} $@
    ${GENERATOR_EXECUTABLE} -i ${NAMELIST_FILE_PATH} -o ${OUTPUT_FILE_PATH}
}

build ui_extra_humans_asian human/asian
build ui_extra_humans_germanic human/germanic
build ui_extra_humans_slavic human/slavic
build ui_extra_humans_spqr_extended human/roman
build ui_extra_humans_extended \
      human/african human/arabic human/asian human/baltic human/celtic human/english \
      human/french human/germanic human/hellenic human/hindi human/italian human/latino \
      human/persian human/roman human/romanian human/slavic human/turkic human/common \
      starcraft/human starwars/human runescape/human other-media/human

build ui_dnd_kobold dnd/kobold

build ui_elderscrolls_argonian elderscrolls/argonian
build ui_elderscrolls_khajiit elderscrolls/khajiit
build ui_elderscrolls_orc elderscrolls/orc
build ui_elderscrolls_spriggan elderscrolls/spriggan

build ui_narivia_rodah narivia/rodah

build ui_runescape_human runescape/human

build ui_starcraft_human starcraft/human
build ui_starcraft_protoss starcraft/protoss

build ui_starwars_human starwars/human

build ui_extra_art1 ui/art1
build ui_extra_avi1 ui/avi1
build ui_extra_fun1 ui/fun1
build ui_extra_hum1 ui/hum1
build ui_extra_mam1 ui/mam1
build ui_extra_mam2 ui/mam2
build ui_extra_mol1 ui/mol1
build ui_extra_mol2 ui/mol2
build ui_extra_pla1 ui/pla1
build ui_extra_rep1 ui/rep1
build ui_extra_rep2 ui/rep2
build ui_extra_rep3 ui/rep3
