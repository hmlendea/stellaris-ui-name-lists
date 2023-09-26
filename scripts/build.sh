#!/bin/bash
source "scripts/common/paths.sh"

MOD_ID="ui-name-lists"
MOD_NAME="Universum Infinitum: Name Lists"
STELLARIS_VERSION="3.9.*"

OUTPUT_MOD_DIRECTORY_PATH="${OUTPUT_DIR}/${MOD_ID}"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/localisation/english"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="${MOD_BUILDER_DIRECTORY}/StellarisNameListGenerator"

MOD_THUMBNAIL_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/thumbnail.png"
MOD_DESCRIPTOR_PRIMARY_FILE_PATH="${OUTPUT_DIR}/${MOD_ID}.mod"
MOD_DESCRIPTOR_SECONDARY_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/descriptor.mod"

if [[ $* != *--skip-updates* ]]; then
    "${SCRIPTS_DIR}"/update-builder.sh
fi

if [[ $* != *--skip-validation* ]]; then
    echo "Validating the files..."
    VALIDATE_DATA="$(scripts/validate-data.sh | tr '\0' '\n')"
    if [ -n "${VALIDATE_DATA}" ]; then
        echo "Input files validation failed!"
        echo "${VALIDATE_DATA}"
        exit 1
    fi
fi

[ ! -d "${BUILD_DIR}" ] && mkdir -p "${BUILD_DIR}"
[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"
[ ! -d "${OUTPUT_NAMELISTS_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_NAMELISTS_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_LOCALISATION_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_LOCALISATION_DIRECTORY_PATH}"

printf '\xEF\xBB\xBF' > ${OUTPUT_LOCALISATION_FILE_PATH}
printf "l_english:\n" >> ${OUTPUT_LOCALISATION_FILE_PATH}

function merge {
    local OUTPUT_FILE_NAME=$1
    shift 1

    head -2 "./name-lists/$1.xml" > "${OUTPUT_FILE_NAME}"

    for NAME_LIST in $(get-namelists-merged ${@}); do
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
    NAMELIST_ID=$1 && shift
    NAMELIST_NAME=$1 && shift
    NAMELIST_ISLOCKED=$1 && shift
    NAMELIST_FILE_PATH="${BUILD_DIR}/${NAMELIST_ID}.xml"
    OUTPUT_NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    echo "Building ${NAMELIST_ID}..."

    GENERATOR_EXECUTABLE_WITH_ARGS=${GENERATOR_EXECUTABLE}
    [ "${NAMELIST_ISLOCKED}" == "L" ] && GENERATOR_EXECUTABLE_WITH_ARGS="${GENERATOR_EXECUTABLE} --locked"

    merge ${NAMELIST_FILE_PATH} $@
    ${GENERATOR_EXECUTABLE_WITH_ARGS} -i "${NAMELIST_FILE_PATH}" -o "${OUTPUT_NAMELIST_FILE_PATH}" -n "${NAMELIST_NAME}"
    add-localisation ${NAMELIST_ID}
}

function generate-mod-descriptor {
    FILE_PATH=$1

    echo "name=\"${MOD_NAME}\"" > ${FILE_PATH}
    echo "path=\"mod/${MOD_ID}\"" >> ${FILE_PATH}
    echo "tags={" >> ${FILE_PATH}
    echo "  \"Species\"" >> ${FILE_PATH}
    echo "}" >> ${FILE_PATH}
    echo "supported_version=\"${STELLARIS_VERSION}\"" >> ${FILE_PATH}
}

function get-namelists-merged {
    local MERGED_NAMELIST=""

    for NAMELIST in $(echo ${@} | \
        sed 's/\s/\n/g' | \
        sed 's/real\//0real\//g' | \
        sed 's/media\//1media\//g' | \
        sed 's/^\s*\(.*\)\(_\|common\)\(.*\)$/9\1\2\3/g' | \
        sort | uniq); do
        MERGED_NAMELIST="${MERGED_NAMELIST} ${NAMELIST}"
    done

    MERGED_NAMELIST=$(echo "${MERGED_NAMELIST}" | sed -e 's/\s\s*/ /g' -e 's/^\s*\(.*\)\s*$/\1/g')

    echo "${MERGED_NAMELIST}" | sed \
        -e 's/^[0-9]*//g' \
        -e 's/ [0-9]*/ /g'
}

###############
### AFRICAN ###
###############
AFRICAN_MEDIA_NAMELISTS="media/other/human/african media/other/human/shona media/other/human/somali media/other/human/swahili \
media/other/human/tswana media/other/human/xhosa media/other/human/zulu"
AFRICAN_REAL_NAMELISTS="real/african/algerian real/african/chadian real/african/congolese real/african/eritrean real/african/ethiopian \
real/african/igbo real/african/kabyle real/african/kenyan real/african/liberian real/african/malian real/african/mauritanian \
real/african/mossi real/african/namibian real/african/nigerian real/african/senegalese real/african/shona real/african/somali \
real/african/sudanese real/african/swahili real/african/tswana real/african/yoruba real/african/zambian real/african/zande \
real/african/zulu real/african/others real/african/common \
real/common/_"
AFRICAN_NAMELISTS=$(get-namelists-merged ${AFRICAN_MEDIA_NAMELISTS} ${AFRICAN_REAL_NAMELISTS})

##############
### ARABIC ###
##############
ARABIC_MEDIA_NAMELISTS="media/other/human/arabic media/runescape/human_kharidian"
ARABIC_REAL_NAMELISTS="real/arabic/berber real/arabic/egyptian real/arabic/iraqi real/arabic/jordanian real/arabic/kuwaiti \
real/arabic/moroccan real/arabic/palestinian real/arabic/saudi real/arabic/syrian real/arabic/uae real/arabic/_ real/common/_"
ARABIC_NAMELISTS=$(get-namelists-merged ${ARABIC_MEDIA_NAMELISTS} ${ARABIC_REAL_NAMELISTS})

##############
### CELTIC ###
##############
CELTIC_MEDIA_NAMELISTS="media/other/human/celtic/irish media/other/human/celtic/scottish media/other/human/celtic/welsh  media/other/human/celtic/common"
CELTIC_REAL_NAMELISTS="real/celtic/breton real/celtic/celtic real/celtic/cornish real/celtic/icenic real/celtic/irish real/celtic/scottish real/celtic/welsh real/celtic/common real/common/european real/common/_"
CELTIC_NAMELISTS=$(get-namelists-merged ${CELTIC_MEDIA_NAMELISTS} ${CELTIC_REAL_NAMELISTS})

###############
### ENGLISH ###
###############
ENGLISH_AMERICAN_MEDIA_NAMELISTS="media/other/human/american media/other/human/canadian media/other/human/english_int"
ENGLISH_AMERICAN_REAL_NAMELISTS="real/english/american real/english/canadian real/english/common real/common/_"
ENGLISH_AMERICAN_NAMELISTS=$(get-namelists-merged ${ENGLISH_AMERICAN_MEDIA_NAMELISTS} ${ENGLISH_AMERICAN_REAL_NAMELISTS})

ENGLISH_EURO_MEDIA_NAMELISTS="media/other/human/british media/other/human/english media/other/human/english_int"
ENGLISH_EURO_REAL_NAMELISTS="real/english/english media/other/human/english_int real/english/common_british real/english/common real/common/european real/common/_"
ENGLISH_EURO_NAMELISTS=$(get-namelists-merged ${ENGLISH_EURO_MEDIA_NAMELISTS} ${ENGLISH_EURO_REAL_NAMELISTS})

ENGLISH_OCEANIAN_MEDIA_NAMELISTS="media/other/human/australian media/other/human/english_int"
ENGLISH_OCEANIAN_REAL_NAMELISTS="real/english/australian real/english/zealandian real/english/common real/common/_"
ENGLISH_OCEANIAN_NAMELISTS=$(get-namelists-merged ${ENGLISH_OCEANIAN_MEDIA_NAMELISTS} ${ENGLISH_OCEANIAN_REAL_NAMELISTS})

ENGLISH_NAMELISTS=$(get-namelists-merged ${ENGLISH_AMERICAN_NAMELISTS} ${ENGLISH_EURO_NAMELISTS} ${ENGLISH_OCEANIAN_NAMELISTS})

###############
### FRENCH ###
###############
FRENCH_AFRO_MEDIA_NAMELISTS="media/other/human/romance/french/common"
FRENCH_AFRO_REAL_NAMELISTS="real/romance/french/ivorian real/common/_"
FRENCH_AFRO_NAMELISTS=$(get-namelists-merged ${FRENCH_AFRO_REAL_NAMELISTS} ${FRENCH_AFRO_MEDIA_NAMELISTS})
FRENCH_EURO_MEDIA_NAMELISTS="media/other/human/romance/french/french media/other/human/romance/french/common"
FRENCH_EURO_REAL_NAMELISTS="real/romance/french/french real/common/european real/common/_"
FRENCH_EURO_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_REAL_NAMELISTS} ${FRENCH_EURO_MEDIA_NAMELISTS})
FRENCH_NAMELISTS=$(get-namelists-merged ${FRENCH_AFRO_NAMELISTS} ${FRENCH_EURO_NAMELISTS})

################
### HELLENIC ###
################
HELLENIC_MEDIA_NAMELISTS="media/other/human/hellenic/common"
HELLENIC_REAL_NAMELISTS="real/hellenic/cypriote real/hellenic/greek real/hellenic/common real/common/european real/common/_"
HELLENIC_NAMELISTS=$(get-namelists-merged ${HELLENIC_REAL_NAMELISTS} ${HELLENIC_MEDIA_NAMELISTS})

###############
### IBERIAN ###
###############
IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_EURO_MEDIA_NAMELISTS} ${SPANISH_EURO_MEDIA_NAMELISTS} media/other/human/romance/iberian/catalan)
IBERIAN_ROMANCE_EURO_REAL_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_EURO_REAL_NAMELISTS} ${SPANISH_EURO_REAL_NAMELISTS} real/romance/iberian/catalan real/romance/iberian/common real/common/european real/common/_)
IBERIAN_ROMANCE_EURO_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_REAL_NAMELISTS} ${IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS})
IBERIAN_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS} media/other/human/basque)
IBERIAN_EURO_REAL_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_REAL_NAMELISTS} real/basque real/romance/iberian/common real/common/european real/common/_)
IBERIAN_EURO_NAMELISTS=$(get-namelists-merged ${IBERIAN_EURO_REAL_NAMELISTS} ${IBERIAN_EURO_MEDIA_NAMELISTS})
IBERIAN_NAMELISTS=$(get-namelists-merged ${IBERIAN_EURO_NAMELISTS} ${PORTUGUESE_NAMELISTS} ${SPANISH_NAMELISTS})

###############
### ITALIAN ###
###############
ITALIAN_MEDIA_NAMELISTS="media/other/human/romance/italian"
ITALIAN_REAL_NAMELISTS="real/romance/italian real/common/european real/common/_"
ITALIAN_NAMELISTS=$(get-namelists-merged ${ITALIAN_REAL_NAMELISTS} ${ITALIAN_MEDIA_NAMELISTS})

#############
### LATIN ###
#############
LATIN_MEDIA_NAMELISTS="media/other/human/romance/latin media/stellaris/human3"
LATIN_REAL_NAMELISTS="real/romance/latin real/common/european real/common/_"
LATIN_NAMELISTS=$(get-namelists-merged ${LATIN_REAL_NAMELISTS} ${LATIN_MEDIA_NAMELISTS})

################
### NORSE ###
################
NORSE_EURO_MEDIA_NAMELISTS="media/other/human/norse/danish media/other/human/norse/icelandic media/other/human/norse/norwegian media/other/human/norse/swedish media/other/human/norse/norse media/elderscrolls/atmoran media/elderscrolls/nord"
NORSE_EURO_REAL_NAMELISTS="real/norse/danish real/norse/icelandic real/norse/norwegian real/norse/swedish real/norse/common real/common/european real/common/_"
NORSE_EURO_NAMELISTS=$(get-namelists-merged ${NORSE_EURO_MEDIA_NAMELISTS} ${NORSE_EURO_REAL_NAMELISTS})
NORSE_GLOBAL_MEDIA_NAMELISTS=$(get-namelists-merged ${NORSE_EURO_MEDIA_NAMELISTS} media/elderscrolls/atmoran media/elderscrolls/nord)
NORSE_GLOBAL_REAL_NAMELISTS=$(get-namelists-merged ${NORSE_EURO_REAL_NAMELISTS} real/norse/greenlandic)
NORSE_GLOBAL_NAMELISTS=$(get-namelists-merged ${NORSE_GLOBAL_REAL_NAMELISTS} ${NORSE_GLOBAL_MEDIA_NAMELISTS})

##################
### PORTUGUESE ###
##################
PORTUGUESE_AFRICAN_MEDIA_NAMELISTS="media/other/human/romance/iberian/portuguese/common"
PORTUGUESE_AFRICAN_REAL_NAMELISTS="real/romance/iberian/portuguese/angolan real/romance/iberian/portuguese/common real/common/_"
PORTUGUESE_AFRICAN_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_AFRICAN_REAL_NAMELISTS} ${PORTUGUESE_AFRICAN_MEDIA_NAMELISTS})
PORTUGUESE_EURO_MEDIA_NAMELISTS="media/other/human/romance/iberian/portuguese/common"
PORTUGUESE_EURO_REAL_NAMELISTS="real/romance/iberian/portuguese/portuguese real/romance/iberian/portuguese/common real/romance/iberian/common real/common/european real/common/_"
PORTUGUESE_EURO_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_EURO_REAL_NAMELISTS} ${PORTUGUESE_EURO_MEDIA_NAMELISTS})
PORTUGUESE_LATAM_MEDIA_NAMELISTS="media/other/human/romance/iberian/portuguese/common"
PORTUGUESE_LATAM_REAL_NAMELISTS="real/romance/iberian/portuguese/brazilian real/romance/iberian/portuguese/common real/common/_"
PORTUGUESE_LATAM_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_LATAM_REAL_NAMELISTS} ${PORTUGUESE_LATAM_MEDIA_NAMELISTS})
PORTUGUESE_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_AFRICAN_NAMELISTS} ${PORTUGUESE_EURO_NAMELISTS} ${PORTUGUESE_LATAM_NAMELISTS})

################
### ROMANIAN ###
################
ROMANIAN_MEDIA_NAMELISTS="media/other/human/romance/romanian"
ROMANIAN_REAL_NAMELISTS="real/romance/romanian real/common/european real/common/_"
ROMANIAN_NAMELISTS=$(get-namelists-merged ${ROMANIAN_REAL_NAMELISTS} ${ROMANIAN_MEDIA_NAMELISTS})

###############
### ROMANCE ###
###############
ROMANCE_EURO_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_NAMELISTS} ${IBERIAN_ROMANCE_EURO_NAMELISTS} ${ITALIAN_NAMELISTS} ${LATIN_NAMELISTS} ${ROMANIAN_NAMELISTS})
ROMANCE_NAMELISTS=$(get-namelists-merged ${ROMANCE_EURO_NAMELISTS} ${FRENCH_NAMELISTS})

###############
### SPANISH ###
###############
SPANISH_EURO_MEDIA_NAMELISTS="media/other/human/romance/iberian/spanish/spanish media/other/human/romance/iberian/spanish/common"
SPANISH_EURO_REAL_NAMELISTS="real/romance/iberian/spanish/spanish real/romance/iberian/spanish/common real/romance/iberian/common real/common/european real/common/_"
SPANISH_EURO_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_REAL_NAMELISTS} ${SPANISH_EURO_MEDIA_NAMELISTS})
SPANISH_LATAM_MEDIA_NAMELISTS="media/other/human/romance/iberian/spanish/mexican media/other/human/romance/iberian/spanish/venezuelan media/other/human/romance/iberian/spanish/common"
SPANISH_LATAM_REAL_NAMELISTS="real/romance/iberian/spanish/argentinian real/romance/iberian/spanish/colombian real/romance/iberian/spanish/cuban real/romance/iberian/spanish/ecuadorian real/romance/iberian/spanish/guatemalan real/romance/iberian/spanish/mexican real/romance/iberian/spanish/venezuelan real/romance/iberian/spanish/common_american real/romance/iberian/spanish/common real/common/_"
SPANISH_LATAM_NAMELISTS=$(get-namelists-merged ${SPANISH_LATAM_REAL_NAMELISTS} ${SPANISH_LATAM_MEDIA_NAMELISTS})
SPANISH_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_NAMELISTS} ${SPANISH_LATAM_NAMELISTS})

##############
### SLAVIC ###
##############
SLAVIC_CZECHOSLOVAKIAN_MEDIA_NAMELISTS="media/other/human/slavic/western/czechoslovakian/czech media/other/human/slavic/common"
SLAVIC_CZECHOSLOVAKIAN_REAL_NAMELISTS="real/slavic/western/czechoslovakian/czech real/slavic/western/czechoslovakian/slovakian real/slavic/common real/common/european real/common/_"
SLAVIC_CZECHOSLOVAKIAN_NAMELISTS=$(get-namelists-merged ${SLAVIC_CZECHOSLOVAKIAN_REAL_NAMELISTS} ${SLAVIC_CZECHOSLOVAKIAN_MEDIA_NAMELISTS})
SLAVIC_RUSSIAN_MEDIA_NAMELISTS="media/aow/dvar media/other/human/slavic/eastern/russian media/other/human/slavic/common"
SLAVIC_RUSSIAN_REAL_NAMELISTS="real/slavic/eastern/russian real/slavic/common real/common/european real/common/_"
SLAVIC_RUSSIAN_NAMELISTS=$(get-namelists-merged ${SLAVIC_RUSSIAN_MEDIA_NAMELISTS} ${SLAVIC_RUSSIAN_NAMELISTS})
SLAVIC_YUGOSLAVIC_MEDIA_NAMELISTS="media/other/human/slavic/southern/yugoslavic/croatian media/other/human/slavic/southern/yugoslavic/common  media/other/human/slavic/common"
SLAVIC_YUGOSLAVIC_REAL_NAMELISTS="real/slavic/southern/yugoslavic/bosnian real/slavic/southern/yugoslavic/croatian real/slavic/southern/yugoslavic/montenegrin real/slavic/southern/yugoslavic/serbian real/slavic/southern/yugoslavic/slovenian real/slavic/southern/yugoslavic/common real/slavic/common real/common/european real/common/_"
SLAVIC_YUGOSLAVIC_NAMELISTS=$(get-namelists-merged ${SLAVIC_YUGOSLAVIC_REAL_NAMELISTS} ${SLAVIC_YUGOSLAVIC_MEDIA_NAMELISTS})
SLAVIC_EASTERN_MEDIA_NAMELISTS=$(get-namelists-merged ${SLAVIC_RUSSIAN_MEDIA_NAMELISTS} media/other/human/slavic/eastern/belarusian media/other/human/slavic/eastern/ukrainian media/other/human/slavic/common)
SLAVIC_EASTERN_REAL_NAMELISTS=$(get-namelists-merged ${SLAVIC_RUSSIAN_REAL_NAMELISTS} real/slavic/eastern/belarusian real/slavic/eastern/ukrainian real/slavic/common real/common/european real/common/_)
SLAVIC_EASTERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_REAL_NAMELISTS} ${SLAVIC_EASTERN_MEDIA_NAMELISTS})
SLAVIC_SOUTHERN_MEDIA_NAMELISTS=$(get-namelists-merged ${SLAVIC_YUGOSLAVIC_MEDIA_NAMELISTS} media/other/human/slavic/common)
SLAVIC_SOUTHERN_REAL_NAMELISTS=$(get-namelists-merged ${SLAVIC_YUGOSLAVIC_REAL_NAMELISTS} real/slavic/southern/bulgarian real/slavic/common real/common/european real/common/_)
SLAVIC_SOUTHERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_SOUTHERN_REAL_NAMELISTS} ${SLAVIC_SOUTHERN_MEDIA_NAMELISTS})
SLAVIC_WESTERN_MEDIA_NAMELISTS=$(get-namelists-merged ${SLAVIC_CZECHOSLOVAKIAN_MEDIA_NAMELISTS} media/other/human/slavic/western/polish media/other/human/slavic/common)
SLAVIC_WESTERN_REAL_NAMELISTS=$(get-namelists-merged ${SLAVIC_CZECHOSLOVAKIAN_REAL_NAMELISTS} real/slavic/western/polish real/slavic/common real/common/european real/common/_)
SLAVIC_WESTERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_WESTERN_REAL_NAMELISTS} ${SLAVIC_WESTERN_MEDIA_NAMELISTS})
SLAVIC_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_NAMELISTS} ${SLAVIC_SOUTHERN_NAMELISTS} ${SLAVIC_WESTERN_NAMELISTS})

##############
### TURKIC ###
##############
TURKIC_MEDIA_NAMELISTS="media/other/human/turkish"
TURKIC_REAL_NAMELISTS="real/turkic/turkish real/turkic/turkmen real/turkic/uyghur real/turkic/common real/common/_"
TURKIC_NAMELISTS=$(get-namelists-merged ${TURKIC_MEDIA_NAMELISTS} ${TURKIC_REAL_NAMELISTS})

build "ui_extra_humans_african"         "Human - African"           "L" ${AFRICAN_NAMELISTS} ${FRENCH_AFRO_NAMELISTS} ${PORTUGUESE_AFRICAN_NAMELISTS} real/tunisian
build "ui_extra_humans_american_north"  "Human - American NA"       "L" ${ENGLISH_AMERICAN_NAMELISTS}
build "ui_extra_humans_american_usa"    "Human - American USA"      "L" \
    real/english/american real/english/common \
    media/other/human/american media/other/human/english_int \
    real/common/_
build "ui_extra_humans_arabic"          "Human - Arabic"            "L" ${ARABIC_NAMELISTS}
build "ui_extra_humans_asian"           "Human - Asian"             "L" \
    real/chinese real/japanese real/korean real/mongol real/taiwanese real/tibetan real/vietnamese \
    real/common/asian \
    media/other/human/chinese media/other/human/japanese media/other/human/korean media/other/human/tibetan media/other/human/vietnamese \
    real/common/_
build "ui_extra_humans_austronesian"    "Human - Austronesian"      "L" \
    real/filipino real/hawaiian real/indonesian real/kiribatian real/malaysian real/maori real/polynesian \
    real/austronesian \
    media/other/human/filipino media/other/human/indonesian media/other/human/malaysian media/other/human/maori \
    real/common/_
build "ui_extra_humans_british"         "Human - British"           "L" ${ENGLISH_EURO_NAMELISTS} real/celtic/scottish real/celtic/welsh media/other/human/celtic/scottish
build "ui_extra_humans_celtic"          "Human - Celtic"            "L" ${CELTIC_NAMELISTS}
build "ui_extra_humans_chinese"         "Human - Chinese"           "L" \
    real/chinese real/taiwanese \
    real/common/asian \
    media/other/human/chinese \
    real/common/_
build "ui_extra_humans_english"         "Human - English"           "L" "${ENGLISH_NAMELISTS}"
build "ui_extra_humans_european"        "Human - European"          "L" \
    ${CELTIC_NAMELISTS} ${ENGLISH_EURO_NAMELISTS} ${HELLENIC_NAMELISTS} ${IBERIAN_EURO_NAMELISTS} ${NORSE_EURO_NAMELISTS} ${ROMANCE_EURO_NAMELISTS} ${SLAVIC_NAMELISTS} \
    real/austrian real/dutch real/estonian real/finnish real/german real/germanic real/hungarian real/latvian real/lithuanian real/swiss \
    \
    real/common/german \
    \
    media/runescape/human_asgarnian media/runescape/human_kandarin media/runescape/human_misthalinian media/runescape/human media/other/human/german media/other/human/swiss
build "ui_extra_humans_franco-iberian"  "Human - Franco-Iberian"    "L" ${FRENCH_EURO_NAMELISTS} ${IBERIAN_EURO_NAMELISTS}
build "ui_extra_humans_french"          "Human - French EU"         "L" ${FRENCH_EURO_NAMELISTS}
build "ui_extra_humans_french_int"      "Human - French INT"        "L" ${FRENCH_NAMELISTS}
build "ui_extra_humans_german"          "Human - German"            "L" \
    real/austrian real/german real/swiss \
    real/common/european real/common/german \
    media/other/human/austrian media/other/human/german media/other/human/swiss \
    real/common/_
build "ui_extra_humans_germanic"        "Human - Germanic"          "L" \
    ${NORSE_EURO_NAMELISTS} real/austrian real/dutch real/german real/swiss real/germanic real/common/german \
    media/other/human/austrian media/other/human/german media/other/human/swiss \
    real/common/_
build "ui_extra_humans_hellenic"        "Human - Hellenic"          "L" ${HELLENIC_NAMELISTS}
build "ui_extra_humans_hindi"           "Human - Hindi"             "L" \
    real/bengal real/indian real/nepali real/tamil real/urdu real/hindi \
    media/other/human/hindi media/other/human/indian media/other/human/sanskrit media/other/human/tamil media/other/human/urdu \
    real/common/_
build "ui_extra_humans_iberian"         "Human - Iberian"           "L" ${IBERIAN_EURO_NAMELISTS}
build "ui_extra_humans_italian"         "Human - Italian"           "L" ${ITALIAN_NAMELISTS}
build "ui_extra_humans_japanese"        "Human - Japanese"          "L" \
    real/japanese \
    media/other/human/japanese \
    real/common/_
build "ui_extra_humans_latino"          "Human - Latino"            "L" \
    "${SPANISH_LATAM_NAMELISTS}" "${PORTUGUESE_LATAM_NAMELISTS}" real/nahuatl real/common/_
build "ui_extra_humans_norse"           "Human - Norse"             "L" ${NORSE_NAMELISTS}
build "ui_extra_humans_portuguese"      "Human - Portuguese EU"     "L" ${PORTUGUESE_EURO_NAMELISTS}
build "ui_extra_humans_portuguese_int"  "Human - Portuguese INT"    "L" ${PORTUGUESE_NAMELISTS}
build "ui_extra_humans_romanian"        "Human - Romanian"          "L" ${ROMANIAN_NAMELISTS}
build "ui_extra_humans_romance"         "Human - Romance"           "L" ${ROMANCE_NAMELISTS}
build "ui_extra_humans_russian"         "Human - Russian"           "L" ${SLAVIC_RUSSIAN_NAMELISTS}
build "ui_extra_humans_slavic"          "Human - Slavic"            "L" ${SLAVIC_NAMELISTS}
build "ui_extra_humans_spqr_extended"   "Human - Latin"             "L" ${LATIN_NAMELISTS}
build "ui_extra_humans_turkic"          "Human - Turkic"            "L" ${TURKIC_NAMELISTS}
build "ui_extra_humans_yugoslavic"      "Human - Yugoslavic"        "L" ${SLAVIC_YUGOSLAVIC_NAMELISTS}
build "ui_extra_humans_extended"        "Human - *Extended*"        "L" \
    real/afghan \
    ${AFRICAN_NAMELISTS} ${ARABIC_NAMELISTS} ${CELTIC_NAMELISTS} ${ENGLISH_NAMELISTS} ${IBERIAN_NAMELISTS} ${ROMANCE_NAMELISTS} ${SLAVIC_NAMELISTS} ${TURKIC_NAMELISTS} \
    real/armenian real/austrian real/austronesian real/bengal real/chinese real/dutch real/estonian real/filipino real/finnish real/german real/germanic \
    real/hawaiian real/hebrew real/hindi real/hungarian real/indian real/indonesian real/iranian real/japanese real/kazakh \
    real/kiribatian real/korean real/latvian real/lithuanian real/malaysian real/maori real/mongol real/nahuatl real/nepali real/persian real/polynesian \
    real/swiss real/taiwanese real/tajik real/tamil real/tibetan real/tunisian real/urdu real/vietnamese \
    \
    real/common/asian real/common/german \
    \
    media/galciv/human media/sose/human media/starcraft/human media/starwars/human/_ \
    media/starwars/human/alderaanian media/starwars/human/corellian media/starwars/human/coruscanti media/runescape/human_asgarnian media/runescape/human_kandarin \
    media/runescape/human_menaphite media/runescape/human_misthalinian media/runescape/human media/other/human/armenian media/other/human/austrian \
    media/other/human/chinese media/other/human/filipino media/other/human/german media/other/human/hebrew  media/other/human/hindi \
    media/other/human/indian media/other/human/indonesian media/other/human/japanese media/other/human/korean media/other/human/malaysian \
    media/other/human/maori media/other/human/mongol media/other/human/sanskrit \
    media/other/human/swiss media/other/human/tamil media/other/human/tibetan media/other/human/urdu media/other/human/vietnamese \
    \
    real/human1 real/human2 ui/human_extra real/zextended

build "ui_aow_dvar"  "AoW:P - Dvar"     "L" media/aow/dvar
build "ui_aow_kirko" "AoW:P - Kir'Ko"   "L" media/aow/kirko

build "ui_dnd_kobold" "D&D - Kobold" "L" media/dnd/kobold

build "ui_elderscrolls_altmer"      "ElderScrolls - Altmer"     "R" media/elderscrolls/altmer
build "ui_elderscrolls_argonian"    "ElderScrolls - Argonian"   "R" media/elderscrolls/argonian
build "ui_elderscrolls_dremora"     "ElderScrolls - Dremora"    "R" media/elderscrolls/dremora
build "ui_elderscrolls_khajiit"     "ElderScrolls - Khajiit"    "R" media/elderscrolls/khajiit
build "ui_elderscrolls_orc"         "ElderScrolls - Orc"        "R" media/elderscrolls/orc
build "ui_elderscrolls_spriggan"    "ElderScrolls - Spriggan"   "R" media/elderscrolls/spriggan

build "ui_fng_lizardfolk" "FNG - Lizardfolk" "R" generated/fantasy-name-generators/lizardfolk

build "ui_galciv_yor" "GalCiv - Yor" "R" media/galciv/yor

build "ui_narivia_rodah" "Narivia - Rodah" "R" media/narivia/rodah

build "ui_runescape_human" "RuneScape - Human" "L" \
    media/runescape/human_asgarnian media/runescape/human_kandarin media/runescape/human_kharidian media/runescape/human_menaphite \
    media/runescape/human_misthalinian media/runescape/human

build "ui_starcraft_human"      "StarCraft - Human"     "L" media/starcraft/human
build "ui_starcraft_protoss"    "StarCraft - Protoss"   "R" \
    media/starcraft/protoss/khalai media/starcraft/protoss/nerazim media/starcraft/protoss/purifier media/starcraft/protoss/taldarim \
    media/starcraft/protoss/_

build "ui_starwars_human" "StarWars - Human" "L" \
    media/starwars/human/alderaanian media/starwars/human/corellian media/starwars/human/coruscanti \
    media/starwars/human/_

build "ui_catfolk"          "Fantasy - Catfolk" "R" media/aow/tigran media/elderscrolls/khajiit
build "ui_demon"            "Fantasy - Demon"   "R" \
    media/aow/draconian media/divinity/demon media/elderscrolls/dremora \
    generated/fantasy-name-generators/demon
build "ui_dwarven"          "Fantasy - Dwarven" "R" media/aow/dwarven media/divinity/dwarven
build "ui_elven"            "Fantasy - Elven"   "R" \
    media/aow/elven media/divinity/elven \
    media/elderscrolls/altmer media/elderscrolls/ayleid \
    media/middle-earth/elven \
    generated/fantasy-name-generators/elven-dark
build "ui_fantasy_spider"   "Fantasy - Spider"  "R" \
    media/elderscrolls/spider media/middle-earth/spider \
    generated/fantasy-name-generators/spiderfolk
build "ui_goblin"           "Fantasy - Goblin"  "R" \
    media/aow/goblin media/divinity/goblin media/elderscrolls/goblin media/runescape/goblin \
    generated/fantasy-name-generators/goblin
build "ui_lizard"           "Fantasy - Lizard"  "R" \
    media/divinity/lizard media/elderscrolls/argonian \
    generated/fantasy-name-generators/lizardfolk
build "ui_orc"              "Fantasy - Orc"     "R" media/aow/orc media/divinity/orc media/elderscrolls/orc media/middle-earth/orc

build "ui_extra_art1" "Extra - Arthropoid 1"    "R" ui/art1
build "ui_extra_avi1" "Extra - Avian 1"         "R" ui/avi1
build "ui_extra_avi2" "Extra - Avian 2"         "R" ui/avi2
build "ui_extra_fun1" "Extra - Fungoid 1"       "R" ui/fun1
build "ui_extra_hum1" "Extra - Humanoid 1"      "R" ui/hum1
build "ui_extra_hum2" "Extra - Humanoid 2"      "R" ui/hum2
build "ui_extra_hum3" "Extra - Humanoid 3"      "R" ui/hum3
build "ui_extra_hum4" "Extra - Humanoid 4"      "R" ui/hum4
build "ui_extra_mam1" "Extra - Mammalian 1"     "R" ui/mam1
build "ui_extra_mam2" "Extra - Mammalian 2"     "R" ui/mam2
build "ui_extra_mam3" "Extra - Mammalian 3"     "R" ui/mam3
build "ui_extra_mol1" "Extra - Molluscoid 1"    "R" ui/mol1
build "ui_extra_mol2" "Extra - Molluscoid 2"    "R" ui/mol2
build "ui_extra_pla1" "Extra - Plantoid 1"      "R" ui/pla1
build "ui_extra_pla2" "Extra - Plantoid 2"      "R" ui/pla2
build "ui_extra_rep1" "Extra - Reptillian 1"    "R" ui/rep1
build "ui_extra_rep2" "Extra - Reptillian 2"    "R" ui/rep2
build "ui_extra_rep3" "Extra - Reptillian 3"    "R" ui/rep3
build "ui_extra_rep4" "Extra - Reptillian 4"    "R" ui/rep4

generate-mod-descriptor ${MOD_DESCRIPTOR_PRIMARY_FILE_PATH}
generate-mod-descriptor ${MOD_DESCRIPTOR_SECONDARY_FILE_PATH}

cp thumbnail.png ${MOD_THUMBNAIL_FILE_PATH}
