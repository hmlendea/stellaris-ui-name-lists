#!/bin/bash

BUILD_DIRECTORY_PATH="./build"
OUTPUT_DIRECTORY_PATH="./out"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/localisation"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="dotnet /home/horatiu/Downloads/stellaris-name-list-generator/bin/Debug/netcoreapp2.2/StellarisNameListGenerator.dll"

[ ! -d "${BUILD_DIRECTORY_PATH}" ] && mkdir -p "${BUILD_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_NAMELISTS_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_NAMELISTS_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_LOCALISATION_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_LOCALISATION_DIRECTORY_PATH}"

echo "l_english:" > ${OUTPUT_LOCALISATION_FILE_PATH}

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

function add-localisation {
    NAMELIST_ID=$1
    NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    NAMELIST_NAME=$(sed -n '2{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +5)
    NAMELIST_LEADERS=$(sed -n '3{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +14)
    NAMELIST_SHIPS=$(sed -n '4{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +12)
    NAMELIST_FLEETS=$(sed -n '5{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +13)
    NAMELIST_COLONIES=$(sed -n '6{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +15)

    echo " name_list_${NAMELIST_ID}:0 \"${NAMELIST_NAME}\"" >> ${OUTPUT_LOCALISATION_FILE_PATH}
    echo " name_list_${NAMELIST_ID}_desc:0 \"§YLeaders:§! ${NAMELIST_LEADERS}\n§YShips:§! ${NAMELIST_SHIPS}\n§YFleets:§! ${NAMELIST_FLEETS}\n§YColonies:§! ${NAMELIST_COLONIES}\"" >> ${OUTPUT_LOCALISATION_FILE_PATH}
}

function build {
    NAMELIST_ID=$1
    NAMELIST_FILE_PATH="${BUILD_DIRECTORY_PATH}/${NAMELIST_ID}.xml"
    OUTPUT_NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    shift

    echo "Building ${NAMELIST_ID}..."

    merge ${NAMELIST_FILE_PATH} $@
    ${GENERATOR_EXECUTABLE} -i ${NAMELIST_FILE_PATH} -o ${OUTPUT_NAMELIST_FILE_PATH}
    add-localisation ${NAMELIST_ID}
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
