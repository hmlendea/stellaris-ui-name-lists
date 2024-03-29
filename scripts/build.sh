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
AFRICAN_COMMON_MEDIA_NAMELISTS="media/stellaris/human/african/common media/other/human/african/common"
AFRICAN_REAL_MEDIA_NAMELISTS="real/african/others real/african/common real/common real/common/_"

AFRICAN_BANTU_COMMON_MEDIA_NAMELISTS=$(get-namelists-merged media/ypp/african/bantu/common ${AFRICAN_COMMON_MEDIA_NAMELISTS})

SWAHILI_MEDIA_NAMELISTS="media/dishonored/african/swahili media/galactik-football/african/swahili media/starcraft/human/african/swahili media/stellaris/human/african/swahili ${AFRICAN_BANTU_COMMON_MEDIA_NAMELISTS}"
SWAHILI_REAL_NAMELISTS="real/african/swahili ${AFRICAN_REAL_MEDIA_NAMELISTS}"
SWAHILI_NAMELISTS=$(get-namelists-merged ${SWAHILI_REAL_NAMELISTS} ${SWAHILI_MEDIA_NAMELISTS})

AFRICAN_MEDIA_NAMELISTS="media/alien/human/african/congolese media/civbe/human/african/shona media/civbe/human/african/somali media/civbe/human/african/swahili \
media/civbe/human/african/tswana media/civbe/human/african/xhosa media/civbe/human/african/zulu media/galactik-football/african/yoruba \
media/marvel/human/african/common media/pandora/human/african/common media/paxnova/human/african/common \
${SWAHILI_MEDIA_NAMELISTS} ${AFRICAN_COMMON_MEDIA_NAMELISTS}"
AFRICAN_REAL_NAMELISTS="real/african/algerian real/african/chadian real/african/congolese real/african/eritrean real/african/ethiopian \
real/african/igbo real/african/kabyle real/african/kenyan real/african/liberian real/african/malian real/african/mauritanian \
real/african/mossi real/african/namibian real/african/nigerian real/african/senegalese real/african/shona real/african/somali \
real/african/sudanese ${SWAHILI_REAL_NAMELISTS} real/african/tswana real/african/ugandan real/african/yoruba real/african/zambian real/african/zande \
real/african/zulu ${AFRICAN_REAL_MEDIA_NAMELISTS}"
AFRICAN_NAMELISTS=$(get-namelists-merged ${AFRICAN_MEDIA_NAMELISTS} ${AFRICAN_REAL_NAMELISTS})

##############
### ARABIC ###
##############
ARABIC_GENERATED_NAMELISTS="generated/ung/human/semitic/arabic"
ARABIC_MEDIA_NAMELISTS="media/civbe/human/semitic/arabic media/pandora/human/arabic media/paxnova/human/arabic media/runescape/human/kharidian media/starcraft/human/semitic/arabic media/warhammer/fantasy/human/arabyan"
ARABIC_REAL_NAMELISTS="real/semitic/arabic/berber real/semitic/arabic/egyptian real/semitic/arabic/iraqi real/semitic/arabic/jordanian real/semitic/arabic/kuwaiti \
real/semitic/arabic/moroccan real/semitic/arabic/palestinian real/semitic/arabic/saudi real/semitic/arabic/syrian real/semitic/arabic/uae real/semitic/arabic/common real/common real/common/_"
ARABIC_NAMELISTS=$(get-namelists-merged ${ARABIC_MEDIA_NAMELISTS} ${ARABIC_REAL_NAMELISTS} ${ARABIC_GENERATED_NAMELISTS})

################
### ARMENIAN ###
################
ARMENIAN_MEDIA_NAMELISTS="media/paxnova/human/armenian"
ARMENIAN_REAL_NAMELISTS="real/armenian real/common real/common/_"
ARMENIAN_NAMELISTS=$(get-namelists-merged ${ARMENIAN_REAL_NAMELISTS} ${ARMENIAN_MEDIA_NAMELISTS})

#############
### ASIAN ###
#############
ASIAN_COMMON_REAL_NAMELISTS="real/asian/common real/common real/common/_"

CHINESE_GENERATED_NAMELISTS="media/alien/human/asian/chinese media/civbe/human/asian/chinese media/dishonored/asian/chinese media/pandora/human/asian/chinese media/stellaris/human/asian/chinese media/ypp/asian/chinese ui/human/asian/chinese"
CHINESE_MEDIA_NAMELISTS="media/alien/human/asian/chinese media/civbe/human/asian/chinese media/dishonored/asian/chinese media/pandora/human/asian/chinese media/stellaris/human/asian/chinese media/ypp/asian/chinese ui/human/asian/chinese"
CHINESE_REAL_NAMELISTS="real/asian/chinese/chinese real/asian/chinese/taiwanese ${ASIAN_COMMON_REAL_NAMELISTS}"
CHINESE_NAMELISTS=$(get-namelists-merged ${CHINESE_REAL_NAMELISTS} ${CHINESE_MEDIA_NAMELISTS} ${CHINESE_GENERATED_NAMELISTS})

JAPANESE_GENERATED_NAMELISTS="generated/ung/human/asian/japanese"
JAPANESE_MEDIA_NAMELISTS="media/alien/human/asian/japanese media/pandora/human/asian/japanese media/stellaris/human/asian/japanese media/ypp/asian/japanese ui/human/asian/japanese"
JAPANESE_REAL_NAMELISTS="real/asian/japanese ${ASIAN_COMMON_REAL_NAMELISTS}"
JAPANESE_NAMELISTS=$(get-namelists-merged ${JAPANESE_REAL_NAMELISTS} ${JAPANESE_MEDIA_NAMELISTS} ${JAPANESE_GENERATED_NAMELISTS})

KOREAN_MEDIA_NAMELISTS="media/civbe/human/asian/korean ui/human/asian/korean"
KOREAN_REAL_NAMELISTS="real/asian/korean ${ASIAN_COMMON_REAL_NAMELISTS}"
KOREAN_NAMELISTS=$(get-namelists-merged ${KOREAN_REAL_NAMELISTS} ${KOREAN_MEDIA_NAMELISTS})

MONGOL_MEDIA_NAMELISTS="media/civbe/human/asian/mongol media/stellaris/human/asian/mongol"
MONGOL_REAL_NAMELISTS="real/asian/mongol ${ASIAN_COMMON_REAL_NAMELISTS}"
MONGOL_NAMELISTS=$(get-namelists-merged ${MONGOL_REAL_NAMELISTS} ${MONGOL_MEDIA_NAMELISTS})

TIBETAN_MEDIA_NAMELISTS="media/paxnova/human/asian/tibetan"
TIBETAN_REAL_NAMELISTS="real/asian/tibetan ${ASIAN_COMMON_REAL_NAMELISTS}"
TIBETAN_NAMELISTS=$(get-namelists-merged ${TIBETAN_REAL_NAMELISTS} ${TIBETAN_MEDIA_NAMELISTS})

VIETNAMESE_MEDIA_NAMELISTS="media/civbe/human/asian/vietnamese"
VIETNAMESE_REAL_NAMELISTS="real/asian/vietnamese ${ASIAN_COMMON_REAL_NAMELISTS}"
VIETNAMESE_NAMELISTS=$(get-namelists-merged ${VIETNAMESE_REAL_NAMELISTS} ${VIETNAMESE_MEDIA_NAMELISTS})

ASIAN_GENERATED_NAMELISTS=$(get-namelists-merged ${CHINESE_GENERATED_NAMELISTS} ${JAPANESE_GENERATED_NAMELISTS})
ASIAN_MEDIA_NAMELISTS=$(get-namelists-merged ${CHINESE_MEDIA_NAMELISTS} ${JAPANESE_MEDIA_NAMELISTS} ${KOREAN_MEDIA_NAMELISTS} ${MONGOL_MEDIA_NAMELISTS} ${TIBETAN_MEDIA_NAMELISTS} ${VIETNAMESE_MEDIA_NAMELISTS})
ASIAN_REAL_NAMELISTS=$(get-namelists-merged ${CHINESE_REAL_NAMELISTS} ${JAPANESE_REAL_NAMELISTS} ${KOREAN_REAL_NAMELISTS} ${MONGOL_REAL_NAMELISTS} ${TIBETAN_REAL_NAMELISTS} ${VIETNAMESE_REAL_NAMELISTS})
ASIAN_NAMELISTS=$(get-namelists-merged ${ASIAN_REAL_NAMELISTS} ${ASIAN_MEDIA_NAMELISTS} ${ASIAN_GENERATED_NAMELISTS})

####################
### AUSTRONESIAN ###
####################
AUSTRONESIAN_COMMON_MEDIA_NAMELISTS=""
AUSTRONESIAN_COMMON_REAL_NAMELISTS="real/austronesian/common real/common real/common/_"

FILIPINO_MEDIA_NAMELISTS="media/civbe/human/austronesian/filipino ui/human/austronesian/filipino ${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
FILIPINO_REAL_NAMELISTS="real/austronesian/filipino ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
FILIPINO_NAMELISTS=$(get-namelists-merged ${FILIPINO_REAL_NAMELISTS} ${FILIPINO_MEDIA_NAMELISTS})

HAWAIIAN_MEDIA_NAMELISTS="${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
HAWAIIAN_REAL_NAMELISTS="real/austronesian/hawaiian ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
HAWAIIAN_NAMELISTS=$(get-namelists-merged ${HAWAIIAN_REAL_NAMELISTS} ${HAWAIIAN_MEDIA_NAMELISTS})

INDONESIAN_MEDIA_NAMELISTS="media/civbe/human/austronesian/indonesian ${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
INDONESIAN_REAL_NAMELISTS="real/austronesian/indonesian ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
INDONESIAN_NAMELISTS=$(get-namelists-merged ${INDONESIAN_REAL_NAMELISTS} ${INDONESIAN_MEDIA_NAMELISTS})

KIRIBATIAN_MEDIA_NAMELISTS="${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
KIRIBATIAN_REAL_NAMELISTS="real/austronesian/kiribatian ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
KIRIBATIAN_NAMELISTS=$(get-namelists-merged ${KIRIBATIAN_REAL_NAMELISTS} ${KIRIBATIAN_MEDIA_NAMELISTS})

MALAYSIAN_MEDIA_NAMELISTS="media/civbe/human/austronesian/malaysian ${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
MALAYSIAN_REAL_NAMELISTS="real/austronesian/malaysian ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
MALAYSIAN_NAMELISTS=$(get-namelists-merged ${MALAYSIAN_REAL_NAMELISTS} ${MALAYSIAN_MEDIA_NAMELISTS})

MAORI_MEDIA_NAMELISTS="media/civbe/human/austronesian/maori ${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
MAORI_REAL_NAMELISTS="real/austronesian/maori ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
MAORI_NAMELISTS=$(get-namelists-merged ${MAORI_REAL_NAMELISTS} ${MAORI_MEDIA_NAMELISTS})

POLYNESIAN_MEDIA_NAMELISTS="${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS}"
POLYNESIAN_REAL_NAMELISTS="real/austronesian/polynesian ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
POLYNESIAN_NAMELISTS=$(get-namelists-merged ${POLYNESIAN_REAL_NAMELISTS} ${POLYNESIAN_MEDIA_NAMELISTS})

AUSTRONESIAN_MEDIA_NAMELISTS="${FILIPINO_MEDIA_NAMELISTS} ${HAWAIIAN_MEDIA_NAMELISTS} ${INDONESIAN_MEDIA_NAMELISTS} ${KIRIBATIAN_MEDIA_NAMELISTS} ${MALAYSIAN_MEDIA_NAMELISTS} ${MAORI_MEDIA_NAMELISTS} ${POLYNESIAN_MEDIA_NAMELISTS} ${AUSTRONESIAN_COMMON_MEDIA_NAMELISTS} media/civbe/human/austronesian/wathawurrung media/civbe/human/austronesian/yugambeh media/civbe/human/austronesian/common"
AUSTRONESIAN_REAL_NAMELISTS="${FILIPINO_REAL_NAMELISTS} ${HAWAIIAN_REAL_NAMELISTS} ${INDONESIAN_REAL_NAMELISTS} ${KIRIBATIAN_REAL_NAMELISTS} ${MALAYSIAN_REAL_NAMELISTS} ${MAORI_REAL_NAMELISTS} ${POLYNESIAN_REAL_NAMELISTS} real/austronesian/australian_aboriginal ${AUSTRONESIAN_COMMON_REAL_NAMELISTS}"
AUSTRONESIAN_NAMELISTS=$(get-namelists-merged ${AUSTRONESIAN_REAL_NAMELISTS} ${AUSTRONESIAN_MEDIA_NAMELISTS})

##############
### BALTIC ###
##############
ESTONIAN_MEDIA_NAMELISTS="ui/human/baltic/estonian"
ESTONIAN_REAL_NAMELISTS="real/baltic/estonian real/common/european real/common real/common/_"
ESTONIAN_NAMELISTS=$(get-namelists-merged ${ESTONIAN_REAL_NAMELISTS} ${ESTONIAN_MEDIA_NAMELISTS})

FINNISH_GENERATED_NAMELISTS="generated/ung/human/baltic/finnish"
FINNISH_MEDIA_NAMELISTS="ui/human/baltic/finnish"
FINNISH_REAL_NAMELISTS="real/baltic/finnish real/common/european real/common real/common/_"
FINNISH_NAMELISTS=$(get-namelists-merged ${FINNISH_REAL_NAMELISTS} ${FINNISH_MEDIA_NAMELISTS})

LATVIAN_MEDIA_NAMELISTS="ui/human/baltic/lithuanian"
LATVIAN_REAL_NAMELISTS="real/baltic/lithuanian real/common/european real/common real/common/_"
LATVIAN_NAMELISTS=$(get-namelists-merged ${LITHUANIAN_REAL_NAMELISTS} ${LITHUANIAN_MEDIA_NAMELISTS})

LITHUANIAN_MEDIA_NAMELISTS="ui/human/baltic/latvian"
LITHUANIAN_REAL_NAMELISTS="real/baltic/latvian real/common/european real/common real/common/_"
LITHUANIAN_NAMELISTS=$(get-namelists-merged ${LITHUANIAN_REAL_NAMELISTS} ${LITHUANIAN_MEDIA_NAMELISTS})

BALTIC_GENERATED_NAMELISTS=$(get-namelists-merged ${FINNISH_GENERATED_NAMELISTS})
BALTIC_GENERATED_NAMELISTS="${ESTONIAN_MEDIA_NAMELISTS} ${FINNISH_MEDIA_NAMELISTS} ${LATVIAN_MEDIA_NAMELISTS} ${LITHUANIAN_MEDIA_NAMELISTS}"
BALTIC_MEDIA_NAMELISTS="${ESTONIAN_MEDIA_NAMELISTS} ${FINNISH_MEDIA_NAMELISTS} ${LATVIAN_MEDIA_NAMELISTS} ${LITHUANIAN_MEDIA_NAMELISTS}"
BALTIC_REAL_NAMELISTS="${ESTONIAN_REAL_NAMELISTS} ${FINNISH_NAMELISTS} ${LATVIAN_REAL_NAMELISTS} ${LITHUANIAN_REAL_NAMELISTS} real/common/european real/common real/common/_"
BALTIC_NAMELISTS=$(get-namelists-merged ${BALTIC_REAL_NAMELISTS} ${BALTIC_MEDIA_NAMELISTS} ${BALTIC_GENERATED_NAMELISTS})

##############
### CELTIC ###
##############
CELTIC_COMMON_MEDIA_NAMELISTS="media/dishonored/celtic/common media/stellaris/human/celtic/common"
CELTIC_COMMON_REAL_NAMELISTS="real/celtic/common real/common/european real/common real/common/_"

BRETON_MEDIA_NAMELISTS="ui/human/celtic/breton ${CELTIC_COMMON_MEDIA_NAMELISTS}"
BRETON_REAL_NAMELISTS="real/celtic/breton ${CELTIC_COMMON_REAL_NAMELISTS}"
BRETON_NAMELISTS=$(get-namelists-merged ${BRETON_REAL_NAMELISTS} ${BRETON_MEDIA_NAMELISTS})

CORNISH_MEDIA_NAMELISTS="${CELTIC_COMMON_MEDIA_NAMELISTS}"
CORNISH_REAL_NAMELISTS="real/celtic/cornish ${CELTIC_COMMON_REAL_NAMELISTS}"
CORNISH_NAMELISTS=$(get-namelists-merged ${CORNISH_REAL_NAMELISTS} ${CORNISH_MEDIA_NAMELISTS})

ICENIC_MEDIA_NAMELISTS="${CELTIC_COMMON_MEDIA_NAMELISTS}"
ICENIC_REAL_NAMELISTS="real/celtic/icenic ${CELTIC_COMMON_REAL_NAMELISTS}"
ICENIC_NAMELISTS=$(get-namelists-merged ${ICENIC_REAL_NAMELISTS} ${ICENIC_MEDIA_NAMELISTS})

IRISH_GENERATED_NAMELISTS="generated/ung/human/celtic/irish"
IRISH_MEDIA_NAMELISTS="media/civbe/human/celtic/irish media/dishonored/celtic/irish media/pandora/human/celtic/irish media/starcraft/human/celtic/irish ui/human/celtic/irish ${CELTIC_COMMON_MEDIA_NAMELISTS}"
IRISH_REAL_NAMELISTS="real/celtic/irish ${CELTIC_COMMON_REAL_NAMELISTS}"
IRISH_NAMELISTS=$(get-namelists-merged ${IRISH_REAL_NAMELISTS} ${IRISH_MEDIA_NAMELISTS} ${IRISH_GENERATED_NAMELISTS})

SCOTTISH_MEDIA_NAMELISTS="media/civbe/human/celtic/scottish media/dishonored/celtic/scottish media/stellaris/human/celtic/scottish ${CELTIC_COMMON_MEDIA_NAMELISTS}"
SCOTTISH_REAL_NAMELISTS="real/celtic/scottish ${CELTIC_COMMON_REAL_NAMELISTS}"
SCOTTISH_NAMELISTS=$(get-namelists-merged ${SCOTTISH_REAL_NAMELISTS} ${SCOTTISH_MEDIA_NAMELISTS})

WELSH_GENERATED_NAMELISTS="generated/ung/human/celtic/welsh"
WELSH_MEDIA_NAMELISTS="media/dishonored/celtic/welsh ui/human/celtic/welsh ${CELTIC_COMMON_MEDIA_NAMELISTS}"
WELSH_REAL_NAMELISTS="real/celtic/welsh ${CELTIC_COMMON_REAL_NAMELISTS}"
WELSH_NAMELISTS=$(get-namelists-merged ${WELSH_REAL_NAMELISTS} ${WELSH_MEDIA_NAMELISTS} ${WELSH_GENERATED_NAMELISTS})

CELTIC_GENERATED_NAMELISTS=$(get-namelists-merged ${IRISH_GENERATED_NAMELISTS} ${WELSH_GENERATED_NAMELISTS})
CELTIC_MEDIA_NAMELISTS="${IRISH_MEDIA_NAMELISTS} ${SCOTTISH_MEDIA_NAMELISTS} ${BRETON_MEDIA_NAMELISTS} ${WELSH_MEDIA_NAMELISTS} ${CORNISH_MEDIA_NAMELISTS} ${ICENIC_MEDIA_NAMELISTS} ${CELTIC_COMMON_MEDIA_NAMELISTS}"
CELTIC_REAL_NAMELISTS="${IRISH_REAL_NAMELISTS} ${SCOTTISH_REAL_NAMELISTS} ${BRETON_REAL_NAMELISTS} ${WELSH_REAL_NAMELISTS} ${CORNISH_REAL_NAMELISTS} ${ICENIC_REAL_NAMELISTS} real/celtic/celtic ${CELTIC_COMMON_REAL_NAMELISTS}"
CELTIC_NAMELISTS=$(get-namelists-merged ${CELTIC_MEDIA_NAMELISTS} ${CELTIC_REAL_NAMELISTS} ${CELTIC_GENERATED_NAMELISTS})

#####################
### ELDER SCROLLS ###
#####################
ELDERSCROLLS_HUMAN_BRETON_NAMELISTS="media/elderscrolls/human/breton/english media/elderscrolls/human/breton/french media/elderscrolls/human/breton/germanic media/elderscrolls/human/breton/latin media/elderscrolls/human/breton/common generated/fng/human/english"
ELDERSCROLLS_HUMAN_IMPERIAL_NAMELISTS="media/elderscrolls/human/imperial/english media/elderscrolls/human/imperial/french media/elderscrolls/human/imperial/slavic media/elderscrolls/human/imperial/common"
ELDERSCROLLS_HUMAN_NORD_NAMELISTS="media/elderscrolls/human/nord/atmoran media/elderscrolls/human/nord/nord media/elderscrolls/human/nord/common"
ELDERSCROLLS_HUMAN_NAMELISTS="${ELDERSCROLLS_HUMAN_BRETON_NAMELISTS} ${ELDERSCROLLS_HUMAN_IMPERIAL_NAMELISTS} ${ELDERSCROLLS_HUMAN_NORD_NAMELISTS} media/elderscrolls/human/common"

###############
### ENGLISH ###
###############
ENGLISH_COMMON_GENERATED_NAMELISTS="generated/ung/human/english/common"
ENGLISH_COMMON_MEDIA_NAMELISTS="media/aow/planetfall/human/english/common media/elderscrolls/human/breton/english media/elderscrolls/human/imperial/english media/foundation/english media/galciv/human/english media/pandora/human/english/common media/paxnova/human/english/common media/runescape/human/kandarin/english media/runescape/human/misthalinian/english media/starcraft/human/english/common media/stellaris/human/english/common media/ypp/english/common media/other/human/english/common ui/human/english/common"
ENGLISH_COMMON_REAL_NAMELISTS="real/english/common real/common real/common/_"

ENGLISH_USA_GENERATED_NAMELISTS=$(get-namelists-merged ${ENGLISH_COMMON_GENERATED_NAMELISTS})
ENGLISH_USA_MEDIA_NAMELISTS="media/civbe/human/english/american media/gta/english/american media/pandora/human/english/american media/starcraft/human/english/american/american media/stellaris/human/english/american/american media/other/human/english/american/american ${ENGLISH_COMMON_MEDIA_NAMELISTS}"
ENGLISH_USA_REAL_NAMELISTS="real/english/american/american real/english/american/common ${ENGLISH_COMMON_REAL_NAMELISTS}"
ENGLISH_USA_NAMELISTS=$(get-namelists-merged ${ENGLISH_USA_REAL_NAMELISTS} ${ENGLISH_USA_MEDIA_NAMELISTS} ${ENGLISH_USA_GENERATED_NAMELISTS})

ENGLISH_NORTHAMERICAN_GENERATED_NAMELISTS=$(get-namelists-merged ${ENGLISH_USA_GENERATED_NAMELISTS} ${ENGLISH_COMMON_GENERATED_NAMELISTS})
ENGLISH_NORTHAMERICAN_MEDIA_NAMELISTS=$(get-namelists-merged ${ENGLISH_USA_MEDIA_NAMELISTS} media/stellaris/human/english/american/canadian ${ENGLISH_COMMON_MEDIA_NAMELISTS})
ENGLISH_NORTHAMERICAN_REAL_NAMELISTS=$(get-namelists-merged ${ENGLISH_USA_REAL_NAMELISTS} real/english/american/canadian real/english/american/common ${ENGLISH_COMMON_REAL_NAMELISTS})
ENGLISH_NORTHAMERICAN_NAMELISTS=$(get-namelists-merged ${ENGLISH_NORTHAMERICAN_MEDIA_NAMELISTS} ${ENGLISH_NORTHAMERICAN_REAL_NAMELISTS} ${ENGLISH_NORTHAMERICAN_GENERATED_NAMELISTS})

ENGLISH_EURO_GENERATED_NAMELISTS=$(get-namelists-merged generated/ung/human/english/english ${ENGLISH_COMMON_GENERATED_NAMELISTS})
ENGLISH_EURO_MEDIA_NAMELISTS="media/alien/human/english/british media/civbe/human/english/british media/dune/english/english media/pandora/human/english/english media/pandora/human/english/british media/starcraft/human/english/english media/stellaris/human/english/english media/stellaris/human/english/british media/witcher/human/english/british media/ypp/english/english media/ypp/english/british media/other/human/english/british ui/human/english/english ${ENGLISH_COMMON_MEDIA_NAMELISTS}"
ENGLISH_EURO_REAL_NAMELISTS="real/english/english real/english/british real/common/european ${ENGLISH_COMMON_REAL_NAMELISTS}"
ENGLISH_EURO_NAMELISTS=$(get-namelists-merged ${ENGLISH_EURO_MEDIA_NAMELISTS} ${ENGLISH_EURO_REAL_NAMELISTS} ${ENGLISH_EURO_GENERATED_NAMELISTS})

ENGLISH_OCEANIAN_GENERATED_NAMELISTS=$(get-namelists-merged ${ENGLISH_COMMON_GENERATED_NAMELISTS})
ENGLISH_OCEANIAN_MEDIA_NAMELISTS="media/civbe/human/english/australian ${ENGLISH_COMMON_MEDIA_NAMELISTS}"
ENGLISH_OCEANIAN_REAL_NAMELISTS="real/english/oceanian/australian real/english/oceanian/zealandian real/english/british ${ENGLISH_COMMON_REAL_NAMELISTS}"
ENGLISH_OCEANIAN_NAMELISTS=$(get-namelists-merged ${ENGLISH_OCEANIAN_MEDIA_NAMELISTS} ${ENGLISH_OCEANIAN_REAL_NAMELISTS} ${ENGLISH_OCEANIAN_NAMELISTS})

ENGLISH_NAMELISTS=$(get-namelists-merged ${ENGLISH_NORTHAMERICAN_NAMELISTS} ${ENGLISH_EURO_NAMELISTS} ${ENGLISH_OCEANIAN_NAMELISTS})

################
### GERMANIC ###
################
BENELUX_COMMON_MEDIA_NAMELISTS="ui/human/germanic/benelux/common"
BENELUX_COMMON_REAL_NAMELISTS="real/common/european real/common real/common/_"

BELGIAN_MEDIA_NAMELISTS="${BENELUX_COMMON_MEDIA_NAMELISTS}"
BELGIAN_REAL_NAMELISTS="real/germanic/benelux/belgian ${BENELUX_COMMON_REAL_NAMELISTS}"
BELGIAN_NAMELISTS=$(get-namelists-merged ${BELGIAN_REAL_NAMELISTS} ${BELGIAN_MEDIA_NAMELISTS})

DUTCH_GENERATED_NAMELISTS="generated/ung/human/germanic/dutch"
DUTCH_MEDIA_NAMELISTS="media/starcraft/human/germanic/dutch ui/human/germanic/benelux/dutch ${BENELUX_COMMON_MEDIA_NAMELISTS}"
DUTCH_REAL_NAMELISTS="real/germanic/benelux/dutch ${BENELUX_COMMON_REAL_NAMELISTS}"
DUTCH_NAMELISTS=$(get-namelists-merged ${DUTCH_REAL_NAMELISTS} ${DUTCH_MEDIA_NAMELISTS})

LUXEMBOURGISH_MEDIA_NAMELISTS="ui/human/germanic/benelux/dutch ${BENELUX_COMMON_MEDIA_NAMELISTS}"
LUXEMBOURGISH_REAL_NAMELISTS="real/germanic/benelux/dutch ${BENELUX_COMMON_REAL_NAMELISTS}"
LUXEMBOURGISH_NAMELISTS=$(get-namelists-merged ${LUXEMBOURGISH_REAL_NAMELISTS} ${LUXEMBOURGISH_MEDIA_NAMELISTS})

BENELUX_GENERATED_NAMELISTS=$(get-namelists-merged ${DUTCH_GENERATED_NAMELISTS})
BENELUX_MEDIA_NAMELISTS=$(get-namelists-merged ${BELGIAN_MEDIA_NAMELISTS} ${DUTCH_MEDIA_NAMELISTS} ${LUXEMBOURGISH_MEDIA_NAMELISTS} ${BENELUX_COMMON_MEDIA_NAMELISTS})
BENELUX_REAL_NAMELISTS=$(get-namelists-merged ${BELGIAN_REAL_NAMELISTS} ${DUTCH_REAL_NAMELISTS} ${LUXEMBOURGISH_REAL_NAMELISTS} ${BENELUX_COMMON_REAL_NAMELISTS})
BENELUX_NAMELISTS=$(get-namelists-merged ${BENELUX_REAL_NAMELISTS} ${BENELUX_MEDIA_NAMELISTS})

GERMANIC_COMMON_MEDIA_NAMELISTS="media/warhammer/40k/human/germanic/common ui/human/germanic/common"

GERMAN_GENERATED_NAMELISTS="generated/letsmakeagame/human/germanic/german generated/ung/human/germanic/german"
GERMAN_MEDIA_NAMELISTS="media/alien/human/germanic/german media/civbe/human/germanic/german media/dune/germanic/german media/gta/germanic/german media/pandora/human/germanic/german/german media/runescape/human/misthalinian/german media/starcraft/human/germanic/german media/pandora/human/germanic/german/austrian media/pandora/human/germanic/german/german media/pandora/human/germanic/german/swiss media/stellaris/human/germanic/german media/warhammer/40k/human/germanic/german media/warhammer/fantasy/human/imperial media/ypp/germanic/german media/other/human/germanic/german media/other/human/germanic/german ui/human/germanic/german ${GERMANIC_COMMON_MEDIA_NAMELISTS}"
GERMAN_REAL_NAMELISTS="real/germanic/german/austrian real/germanic/german/german real/germanic/german/swiss real/germanic/german/common real/common/european real/common real/common/_"
GERMAN_NAMELISTS=$(get-namelists-merged ${GERMAN_REAL_NAMELISTS} ${GERMAN_MEDIA_NAMELISTS} ${GERMAN_GENERATED_NAMELISTS})

SCANDINAVIAN_COMMON_GENERATED_NAMELISTS="generated/fng/human/germanic/norse"
SCANDINAVIAN_COMMON_MEDIA_NAMELISTS="media/borderlands/germanic/scandinavian/common media/civbe/human/germanic/norse/norse media/starcraft/human/germanic/norse media/stellaris/human/germanic/norse media/elderscrolls/human/breton/germanic media/witcher/human/germanic/norse media/ypp/germanic/norse ${GERMANIC_COMMON_MEDIA_NAMELISTS} ${ELDERSCROLLS_HUMAN_NORD_NAMELISTS}"
SCANDINAVIAN_EURO_GENERATED_NAMELISTS="${SCANDINAVIAN_COMMON_GENERATED_NAMELISTS}"
SCANDINAVIAN_EURO_MEDIA_NAMELISTS="media/civbe/human/germanic/norse/danish media/civbe/human/germanic/norse/icelandic media/civbe/human/germanic/norse/norwegian media/civbe/human/germanic/norse/swedish media/pandora/human/germanic/norse/swedish ${SCANDINAVIAN_COMMON_MEDIA_NAMELISTS}"
SCANDINAVIAN_EURO_REAL_NAMELISTS="real/germanic/scandinavian/danish real/germanic/scandinavian/icelandic real/germanic/scandinavian/norwegian real/germanic/scandinavian/swedish real/germanic/scandinavian/common real/germanic/common real/common/european real/common real/common/_"
SCANDINAVIAN_EURO_NAMELISTS=$(get-namelists-merged ${SCANDINAVIAN_EURO_MEDIA_NAMELISTS} ${SCANDINAVIAN_EURO_REAL_NAMELISTS} ${SCANDINAVIAN_EURO_GENERATED_NAMELISTS})
SCANDINAVIAN_GENERATED_NAMELISTS="${SCANDINAVIAN_COMMON_GENERATED_NAMELISTS}"
SCANDINAVIAN_MEDIA_NAMELISTS=$(get-namelists-merged ${SCANDINAVIAN_EURO_MEDIA_NAMELISTS} ${SCANDINAVIAN_COMMON_MEDIA_NAMELISTS})
SCANDINAVIAN_REAL_NAMELISTS=$(get-namelists-merged ${SCANDINAVIAN_EURO_REAL_NAMELISTS} real/germanic/scandinavian/greenlandic real/germanic/common)
SCANDINAVIAN_NAMELISTS=$(get-namelists-merged ${SCANDINAVIAN_REAL_NAMELISTS} ${SCANDINAVIAN_MEDIA_NAMELISTS} ${SCANDINAVIAN_GENERATED_NAMELISTS})

GERMANIC_EURO_GENERATED_NAMELISTS=$(get-namelists-merged ${GERMAN_GENERATED_NAMELISTS} ${SCANDINAVIAN_EURO_GENERATED_NAMELISTS})
GERMANIC_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${BENELUX_MEDIA_NAMELISTS} ${GERMAN_MEDIA_NAMELISTS} ${SCANDINAVIAN_EURO_MEDIA_NAMELISTS})
GERMANIC_EURO_REAL_NAMELISTS=$(get-namelists-merged ${BENELUX_REAL_NAMELISTS} ${GERMAN_REAL_NAMELISTS} ${SCANDINAVIAN_EURO_REAL_NAMELISTS} real/germanic/common)
GERMANIC_EURO_NAMELISTS=$(get-namelists-merged ${GERMANIC_EURO_REAL_NAMELISTS} ${GERMANIC_EURO_MEDIA_NAMELISTS} ${GERMANIC_EURO_GENERATED_NAMELISTS})

GERMANIC_NAMELISTS=$(get-namelists-merged ${GERMANIC_EURO_NAMELISTS} ${SCANDINAVIAN_NAMELISTS})

##############
### HEBREW ###
##############
HEBREW_MEDIA_NAMELISTS="media/civbe/human/semitic/hebrew media/starcraft/human/semitic/hebrew media/stellaris/human/semitic/hebrew"
HEBREW_REAL_NAMELISTS="real/semitic/hebrew real/common real/common/_"
HEBREW_NAMELISTS=$(get-namelists-merged ${HEBREW_REAL_NAMELISTS} ${HEBREW_MEDIA_NAMELISTS})

################
### HELLENIC ###
################
HELLENIC_GENERATED_NAMELISTS="generated/ung/human/greek"
HELLENIC_MEDIA_NAMELISTS="media/alien/human/hellenic/common media/civbe/human/greek media/dune/greek media/foundation/greek media/galactik-football/greek media/galciv/human/greek media/pandora/human/greek media/stellaris/human/hellenic/common media/starcraft/human/greek media/ypp/greek media/other/human/hellenic/common ui/human/hellenic/greek ui/human/hellenic/common"
HELLENIC_REAL_NAMELISTS="real/hellenic/cypriote real/hellenic/greek real/hellenic/common real/common/european real/common real/common/_"
HELLENIC_NAMELISTS=$(get-namelists-merged ${HELLENIC_REAL_NAMELISTS} ${HELLENIC_MEDIA_NAMELISTS} ${HELLENIC_GENERATED_NAMELISTS})

#################
### HUNGARIAN ###
#################
HUNGARIAN_GENERATED_NAMELISTS="generated/fng/human/hungarian generated/ung/human/hungarian"
HUNGARIAN_MEDIA_NAMELISTS="ui/human/hungarian"
HUNGARIAN_REAL_NAMELISTS="real/hungarian real/common real/common/_"
HUNGARIAN_NAMELISTS=$(get-namelists-merged ${HUNGARIAN_REAL_NAMELISTS} ${HUNGARIAN_MEDIA_NAMELISTS} ${HUNGARIAN_GENERATED_NAMELISTS})

##############
### INDIAN ###
##############
INDIAN_COMMON_MEDIA_NAMELISTS="media/civbe/human/indian/common"
INDIAN_COMMON_REAL_NAMELISTS="real/indian/common real/common real/common/_"

BENGAL_MEDIA_NAMELISTS="${INDIAN_COMMON_MEDIA_NAMELISTS}"
BENGAL_REAL_NAMELISTS="real/indian/bengal ${INDIAN_COMMON_REAL_NAMELISTS}"
BENGAL_NAMELISTS=$(get-namelists-merged ${BENGAL_REAL_NAMELISTS} ${BENGAL_MEDIA_NAMELISTS})

HINDI_MEDIA_NAMELISTS="media/civbe/human/indian/hindi media/pandora/human/indian/hindi ui/human/indian/hindi ${INDIAN_COMMON_MEDIA_NAMELISTS}"
HINDI_REAL_NAMELISTS="real/indian/hindi ${INDIAN_COMMON_REAL_NAMELISTS}"
HINDI_NAMELISTS=$(get-namelists-merged ${HINDI_REAL_NAMELISTS} ${HINDI_MEDIA_NAMELISTS})

NEPALI_MEDIA_NAMELISTS="${INDIAN_COMMON_MEDIA_NAMELISTS}"
NEPALI_REAL_NAMELISTS="real/indian/nepali ${INDIAN_COMMON_REAL_NAMELISTS}"
NEPALI_NAMELISTS=$(get-namelists-merged ${HINDI_REAL_NAMELISTS} ${HINDI_MEDIA_NAMELISTS})

SANSKRIT_MEDIA_NAMELISTS="media/civbe/human/indian/sanskrit media/galactik-football/indian/sanskrit media/stellaris/human/indian/sanskrit ${INDIAN_COMMON_MEDIA_NAMELISTS}"
SANSKRIT_REAL_NAMELISTS="real/indian/sanskrit ${INDIAN_COMMON_REAL_NAMELISTS}"
SANSKRIT_NAMELISTS=$(get-namelists-merged ${SANSKRIT_REAL_NAMELISTS} ${SANSKRIT_MEDIA_NAMELISTS})

TAMIL_MEDIA_NAMELISTS="media/civbe/human/indian/tamil ${INDIAN_COMMON_MEDIA_NAMELISTS}"
TAMIL_REAL_NAMELISTS="real/indian/tamil ${INDIAN_COMMON_REAL_NAMELISTS}"
TAMIL_NAMELISTS=$(get-namelists-merged ${TAMIL_REAL_NAMELISTS} ${TAMIL_MEDIA_NAMELISTS})

URDU_MEDIA_NAMELISTS="media/civbe/human/indian/urdu ${INDIAN_COMMON_MEDIA_NAMELISTS}"
URDU_REAL_NAMELISTS="real/indian/urdu ${INDIAN_COMMON_REAL_NAMELISTS}"
URDU_NAMELISTS=$(get-namelists-merged ${URDU_REAL_NAMELISTS} ${URDU_MEDIA_NAMELISTS})

INDIAN_MEDIA_NAMELISTS="${HINDI_MEDIA_NAMELISTS} ${SANSKRIT_MEDIA_NAMELISTS} ${BENGAL_MEDIA_NAMELISTS} ${TAMIL_MEDIA_NAMELISTS} ${URDU_MEDIA_NAMELISTS} ${NEPALI_MEDIA_NAMELISTS} ${INDIAN_COMMON_MEDIA_NAMELISTS}"
INDIAN_REAL_NAMELISTS="${HINDI_REAL_NAMELISTS} ${SANSKRIT_REAL_NAMELISTS} ${BENGAL_REAL_NAMELISTS} ${TAMIL_REAL_NAMELISTS} ${URDU_REAL_NAMELISTS} ${NEPALI_REAL_NAMELISTS} ${INDIAN_COMMON_REAL_NAMELISTS}"
INDIAN_NAMELISTS=$(get-namelists-merged ${INDIAN_REAL_NAMELISTS} ${INDIAN_MEDIA_NAMELISTS})

#######################
### NATIVE AMERICAN ###
#######################
NATIVE_NORTH_AMERICAN_MEDIA_NAMELISTS="media/dishonored/american/native/northern/algonquian media/starcraft/human/american/native/northern/algonquian media/starcraft/human/american/native/northern/washo"
NATIVE_NORTH_AMERICAN_REAL_NAMELISTS="real/american/native/northern/algonquian real/american/native/northern/inuit real/american/native/northern/navajo real/american/native/northern/common"
NATIVE_NORTH_AMERICAN_NAMELISTS=$(get-namelists-merged ${NATIVE_NORTH_AMERICAN_REAL_NAMELISTS} ${NATIVE_NORTH_AMERICAN_MEDIA_NAMELISTS})

NATIVE_SOUTH_AMERICAN_MEDIA_NAMELISTS=""
NATIVE_SOUTH_AMERICAN_REAL_NAMELISTS="real/american/native/southern/mayan real/american/native/southern/nahuatl"
NATIVE_SOUTH_AMERICAN_NAMELISTS=$(get-namelists-merged ${NATIVE_SOUTH_AMERICAN_REAL_NAMELISTS} ${NATIVE_SOUTH_AMERICAN_MEDIA_NAMELISTS})

NATIVE_AMERICAN_MEDIA_NAMELISTS=$(get-namelists-merged ${NATIVE_NORTH_AMERICAN_MEDIA_NAMELISTS} ${NATIVE_SOUTH_AMERICAN_MEDIA_NAMELISTS})
NATIVE_AMERICAN_REAL_NAMELISTS=$(get-namelists-merged ${NATIVE_NORTH_AMERICAN_REAL_NAMELISTS} ${NATIVE_SOUTH_AMERICAN_REAL_NAMELISTS})
NATIVE_AMERICAN_NAMELISTS=$(get-namelists-merged ${NATIVE_AMERICAN_REAL_NAMELISTS} ${NATIVE_AMERICAN_MEDIA_NAMELISTS})

###############
### PERSIAN ###
###############
PERSIAN_MEDIA_NAMELISTS="media/dune/persian media/paxnova/human/persian media/warhammer/40k/human/persian media/ypp/persian"
PERSIAN_REAL_NAMELISTS="real/persian real/common real/common/_"
PERSIAN_NAMELISTS=$(get-namelists-merged ${PERSIAN_REAL_NAMELISTS} ${PERSIAN_MEDIA_NAMELISTS})

###############
### ROMANCE ###
###############
FRENCH_COMMON_GENERATED_NAMELISTS="generated/ung/human/romance/french"
FRENCH_COMMON_MEDIA_NAMELISTS="media/civbe/human/romance/french media/elderscrolls/human/breton/french media/elderscrolls/human/imperial/french media/pandora/human/romance/french media/paxnova/human/romance/french media/runescape/human/kandarin/french media/starcraft/human/romance/french media/stellaris/human/romance/french media/warhammer/fantasy/human/bretonnia media/ypp/romance/french ui/human/romance/french"
IBERIAN_ROMANCE_COMMON_MEDIA_NAMELISTS="media/starcraft/human/romance/iberian/common ui/human/romance/iberian/common"
IBERIAN_ROMANCE_COMMON_REAL_NAMELISTS="real/romance/iberian/common real/common real/common/_"

FRENCH_AFRO_GENERATED_NAMELISTS="${FRENCH_COMMON_GENERATED_NAMELISTS}"
FRENCH_AFRO_MEDIA_NAMELISTS="${FRENCH_COMMON_MEDIA_NAMELISTS}"
FRENCH_AFRO_REAL_NAMELISTS="real/romance/french/ivorian real/common real/common/_"
FRENCH_AFRO_NAMELISTS=$(get-namelists-merged ${FRENCH_AFRO_REAL_NAMELISTS} ${FRENCH_AFRO_MEDIA_NAMELISTS} ${FRENCH_AFRO_GENERATED_NAMELISTS})
FRENCH_EURO_GENERATED_NAMELISTS="${FRENCH_COMMON_GENERATED_NAMELISTS}"
FRENCH_EURO_MEDIA_NAMELISTS="${FRENCH_COMMON_MEDIA_NAMELISTS}"
FRENCH_EURO_REAL_NAMELISTS="real/romance/french/french real/common/european real/common real/common/_"
FRENCH_EURO_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_REAL_NAMELISTS} ${FRENCH_EURO_MEDIA_NAMELISTS} ${FRENCH_EURO_GENERATED_NAMELISTS})
FRENCH_NAMELISTS=$(get-namelists-merged ${FRENCH_AFRO_NAMELISTS} ${FRENCH_EURO_NAMELISTS})

CATALAN_MEDIA_NAMELISTS="media/civbe/human/romance/iberian/catalan ui/human/romance/iberian/catalan ${IBERIAN_ROMANCE_COMMON_MEDIA_NAMELISTS}"
CATALAN_REAL_NAMELISTS="real/romance/iberian/catalan real/common/european ${IBERIAN_ROMANCE_COMMON_REAL_NAMELISTS}"
CATALAN_NAMELISTS=$(get-namelists-merged ${CATALAN_REAL_NAMELISTS} ${CATALAN_MEDIA_NAMELISTS})

ITALIAN_GENERATED_NAMELISTS="generated/ung/human/romance/italian"
ITALIAN_MEDIA_NAMELISTS="media/civbe/human/romance/italian media/dishonored/romance/italian media/galactik-football/romance/italian media/pandora/human/romance/italian media/starcraft/human/romance/italian ui/human/romance/italian"
ITALIAN_REAL_NAMELISTS="real/romance/italian real/common/european real/common real/common/_"
ITALIAN_NAMELISTS=$(get-namelists-merged ${ITALIAN_REAL_NAMELISTS} ${ITALIAN_MEDIA_NAMELISTS} ${ITALIAN_GENERATED_NAMELISTS})

LATIN_GENERATED_NAMELISTS="generated/letsmakeagame/human/romance/latin generated/ung/human/romance/latin"
LATIN_MEDIA_NAMELISTS="media/borderlands/romance/latin media/civbe/human/romance/latin media/foundation/latin media/pandora/human/romance/latin media/sose/human/latin media/starcraft/human/romance/latin media/stellaris/human/romance/latin media/stellaris/human/original/spqr media/ypp/romance/latin ui/human/romance/latin"
LATIN_REAL_NAMELISTS="real/romance/latin real/common/european real/common real/common/_"
LATIN_NAMELISTS=$(get-namelists-merged ${LATIN_REAL_NAMELISTS} ${LATIN_MEDIA_NAMELISTS} ${LATIN_GENERATED_NAMELISTS})

PORTUGUESE_COMMON_GENERATED_NAMELISTS="generated/ung/human/romance/iberian/portuguese"
PORTUGUESE_COMMON_MEDIA_NAMELISTS="media/civbe/human/romance/iberian/portuguese ui/human/romance/iberian/portuguese/common ${IBERIAN_ROMANCE_COMMON_MEDIA_NAMELISTS}"
PORTUGUESE_COMMON_REAL_NAMELISTS="real/romance/iberian/portuguese/common ${IBERIAN_ROMANCE_COMMON_REAL_NAMELISTS}"

PORTUGUESE_AFRICAN_GENERATED_NAMELISTS="${PORTUGUESE_COMMON_GENERATED_NAMELISTS}"
PORTUGUESE_AFRICAN_MEDIA_NAMELISTS="${PORTUGUESE_COMMON_MEDIA_NAMELISTS}"
PORTUGUESE_AFRICAN_REAL_NAMELISTS="real/romance/iberian/portuguese/angolan ${PORTUGUESE_COMMON_REAL_NAMELISTS}"
PORTUGUESE_AFRICAN_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_AFRICAN_REAL_NAMELISTS} ${PORTUGUESE_AFRICAN_MEDIA_NAMELISTS} ${PORTUGUESE_AFRICAN_GENERATED_NAMELISTS})
PORTUGUESE_EURO_GENERATED_NAMELISTS="${PORTUGUESE_COMMON_GENERATED_NAMELISTS}"
PORTUGUESE_EURO_MEDIA_NAMELISTS="${PORTUGUESE_COMMON_MEDIA_NAMELISTS}"
PORTUGUESE_EURO_REAL_NAMELISTS="real/romance/iberian/portuguese/portuguese real/romance/iberian/common real/common/european ${PORTUGUESE_COMMON_REAL_NAMELISTS}"
PORTUGUESE_EURO_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_EURO_REAL_NAMELISTS} ${PORTUGUESE_EURO_MEDIA_NAMELISTS} ${PORTUGUESE_EURO_GENERATED_NAMELISTS})
PORTUGUESE_LATAM_GENERATED_NAMELISTS="${PORTUGUESE_COMMON_GENERATED_NAMELISTS}"
PORTUGUESE_LATAM_MEDIA_NAMELISTS="${PORTUGUESE_COMMON_MEDIA_NAMELISTS}"
PORTUGUESE_LATAM_REAL_NAMELISTS="real/romance/iberian/portuguese/brazilian ${PORTUGUESE_COMMON_REAL_NAMELISTS}"
PORTUGUESE_LATAM_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_LATAM_REAL_NAMELISTS} ${PORTUGUESE_LATAM_MEDIA_NAMELISTS} ${PORTUGUESE_LATAM_GENERATED_NAMELISTS})
PORTUGUESE_NAMELISTS=$(get-namelists-merged ${PORTUGUESE_AFRICAN_NAMELISTS} ${PORTUGUESE_EURO_NAMELISTS} ${PORTUGUESE_LATAM_NAMELISTS})

ROMANIAN_GENERATED_NAMELISTS=""
ROMANIAN_MEDIA_NAMELISTS="media/borderlands/romance/romanian media/stellaris/human/romance/romanian"
ROMANIAN_REAL_NAMELISTS="real/romance/romanian real/common/european real/common real/common/_"
ROMANIAN_NAMELISTS=$(get-namelists-merged ${ROMANIAN_REAL_NAMELISTS} ${ROMANIAN_MEDIA_NAMELISTS})

SPANISH_COMMON_GENERATED_NAMELISTS="generated/ung/human/romance/iberian/spanish"
SPANISH_COMMON_MEDIA_NAMELISTS="media/dishonored/romance/iberian/spanish/common media/galactik-football/romance/iberian/spanish media/starcraft/human/romance/iberian/spanish media/stellaris/human/romance/iberian/spanish/common media/ypp/romance/iberian/spanish media/other/human/romance/iberian/spanish/common ui/human/romance/iberian/spanish/common ${IBERIAN_ROMANCE_COMMON_MEDIA_NAMELISTS}"
SPANISH_COMMON_REAL_NAMELISTS="real/romance/iberian/spanish/common ${IBERIAN_ROMANCE_COMMON_REAL_NAMELISTS}"
SPANISH_EURO_GENERATED_NAMELISTS="${SPANISH_COMMON_GENERATED_NAMELISTS}"
SPANISH_EURO_MEDIA_NAMELISTS="media/alien/human/romance/iberian/spanish media/civbe/human/romance/iberian/spanish ${SPANISH_COMMON_MEDIA_NAMELISTS}"
SPANISH_EURO_REAL_NAMELISTS="real/romance/iberian/spanish/spanish real/romance/iberian/common real/common/european ${SPANISH_COMMON_REAL_NAMELISTS}"
SPANISH_EURO_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_REAL_NAMELISTS} ${SPANISH_EURO_MEDIA_NAMELISTS} ${SPANISH_EURO_GENERATED_NAMELISTS})
SPANISH_LATAM_GENERATED_NAMELISTS="${SPANISH_COMMON_GENERATED_NAMELISTS}"
SPANISH_LATAM_MEDIA_NAMELISTS="media/gta/romance/iberian/spanish/american/mexican media/pandora/human/romance/iberian/spanish/american/venezuelan media/stellaris/human/romance/iberian/spanish/american/mexican ${SPANISH_COMMON_MEDIA_NAMELISTS}"
SPANISH_LATAM_REAL_NAMELISTS="real/romance/iberian/spanish/american/argentinian real/romance/iberian/spanish/american/chilean real/romance/iberian/spanish/american/colombian real/romance/iberian/spanish/american/cuban real/romance/iberian/spanish/american/ecuadorian real/romance/iberian/spanish/american/guatemalan real/romance/iberian/spanish/american/mexican real/romance/iberian/spanish/american/panamanian real/romance/iberian/spanish/american/paraguayan real/romance/iberian/spanish/american/peruvian real/romance/iberian/spanish/american/salvadorian real/romance/iberian/spanish/american/uruguayan real/romance/iberian/spanish/american/venezuelan real/romance/iberian/spanish/american/common ${SPANISH_COMMON_REAL_NAMELISTS}"
SPANISH_LATAM_NAMELISTS=$(get-namelists-merged ${SPANISH_LATAM_REAL_NAMELISTS} ${SPANISH_LATAM_MEDIA_NAMELISTS} ${SPANISH_LATAM_GENERATED_NAMELISTS})
SPANISH_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_NAMELISTS} ${SPANISH_LATAM_NAMELISTS})

IBERIAN_ROMANCE_EURO_GENERATED_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_GENERATED_NAMELISTS} ${PORTUGUESE_EURO_GENERATED_NAMELISTS})
IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_MEDIA_NAMELISTS} ${PORTUGUESE_EURO_MEDIA_NAMELISTS} ${CATALAN_MEDIA_NAMELISTS} ${IBERIAN_ROMANCE_COMMON_MEDIA_NAMELISTS})
IBERIAN_ROMANCE_EURO_REAL_NAMELISTS=$(get-namelists-merged ${SPANISH_EURO_REAL_NAMELISTS} ${PORTUGUESE_EURO_REAL_NAMELISTS} ${CATALAN_REAL_NAMELISTS} real/common/european ${IBERIAN_ROMANCE_COMMON_REAL_NAMELISTS})
IBERIAN_ROMANCE_EURO_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_REAL_NAMELISTS} ${IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS} ${IBERIAN_ROMANCE_EURO_GENERATED_NAMELISTS})
IBERIAN_ROMANCE_NAMELISTS=$(get-namelists-merged ${SPANISH_NAMELISTS} ${PORTUGUESE_NAMELISTS} ${CATALAN_NAMELISTS} ${IBERIAN_ROMANCE_EURO_NAMELISTS})

IBERIAN_EURO_GENERATED_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_GENERATED_NAMELISTS})
IBERIAN_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS} media/civbe/human/basque)
IBERIAN_EURO_REAL_NAMELISTS=$(get-namelists-merged ${IBERIAN_ROMANCE_EURO_REAL_NAMELISTS} real/basque real/romance/iberian/common real/common/european)
IBERIAN_EURO_NAMELISTS=$(get-namelists-merged ${IBERIAN_EURO_REAL_NAMELISTS} ${IBERIAN_EURO_MEDIA_NAMELISTS} ${IBERIAN_EURO_GENERATED_NAMELISTS})
IBERIAN_NAMELISTS=$(get-namelists-merged ${IBERIAN_EURO_NAMELISTS} ${PORTUGUESE_NAMELISTS} ${SPANISH_NAMELISTS})

ROMANCE_EURO_GENERATED_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_GENERATED_NAMELISTS} ${IBERIAN_ROMANCE_EURO_GENERATED_NAMELISTS} ${ITALIAN_GENERATED_NAMELISTS} ${LATIN_GENERATED_NAMELISTS} ${ROMANIAN_GENERATED_NAMELISTS})
ROMANCE_EURO_MEDIA_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_MEDIA_NAMELISTS} ${IBERIAN_ROMANCE_EURO_MEDIA_NAMELISTS} ${ITALIAN_MEDIA_NAMELISTS} ${LATIN_MEDIA_NAMELISTS} ${ROMANIAN_MEDIA_NAMELISTS})
ROMANCE_EURO_REAL_NAMELISTS=$(get-namelists-merged ${FRENCH_EURO_REAL_NAMELISTS} ${IBERIAN_ROMANCE_EURO_REAL_NAMELISTS} ${ITALIAN_REAL_NAMELISTS} ${LATIN_REAL_NAMELISTS} ${ROMANIAN_REAL_NAMELISTS})
ROMANCE_EURO_NAMELISTS=$(get-namelists-merged ${ROMANCE_EURO_REAL_NAMELISTS} ${ROMANCE_EURO_MEDIA_NAMELISTS} ${ROMANCE_EURO_GENERATED_NAMELISTS})
ROMANCE_NAMELISTS=$(get-namelists-merged ${ROMANCE_EURO_NAMELISTS} ${FRENCH_NAMELISTS} ${IBERIAN_ROMANCE_NAMELISTS})

##############
### SLAVIC ###
##############
SLAVIC_COMMON_GENERATED_NAMELISTS="generated/fng/human/slavic/common generated/letsmakeagame/human/slavic/common generated/ung/human/slavic/common"
SLAVIC_COMMON_MEDIA_NAMELISTS="media/alien/human/slavic/common media/civbe/human/slavic/common media/dishonored/slavic/common media/elderscrolls/human/imperial/slavic media/paxnova/human/slavic/common media/starcraft/human/slavic/common media/witcher/human/slavic/common"
SLAVIC_COMMON_REAL_NAMELISTS="real/slavic/common real/common/european real/common real/common/_"

SLAVIC_EASTERN_COMMON_MEDIA_NAMELISTS=$(get-namelists-merged ui/human/slavic/eastern/common ${SLAVIC_COMMON_MEDIA_NAMELISTS})

CZECHOSLOVAKIAN_COMMON_MEDIA_NAMELISTS="media/marvel/human/slavic/western/czechoslovakian/common ui/human/slavic/western/czechoslovakian/common ${SLAVIC_COMMON_MEDIA_NAMELISTS}"

YUGOSLAVIC_COMMON_GENERATED_NAMELISTS="generated/ung/human/slavic/southern/serbocroatian ${SLAVIC_COMMON_GENERATED_NAMELISTS}"
YUGOSLAVIC_COMMON_MEDIA_NAMELISTS="media/witcher/human/slavic/southern/yugoslavic/common ui/human/slavic/southern/yugoslavic/common ${SLAVIC_COMMON_MEDIA_NAMELISTS}"
YUGOSLAVIC_COMMON_REAL_NAMELISTS="real/slavic/southern/yugoslavic/common ${SLAVIC_COMMON_REAL_NAMELISTS}"

BELARUSIAN_MEDIA_NAMELISTS="media/civbe/human/slavic/belarusian ui/human/slavic/eastern/belarusian ${SLAVIC_EASTERN_COMMON_MEDIA_NAMELISTS}"
BELARUSIAN_REAL_NAMELISTS="real/slavic/eastern/belarusian ${SLAVIC_COMMON_REAL_NAMELISTS}"
BELARUSIAN_NAMELISTS=$(get-namelists-merged ${UKRAINIAN_REAL_NAMELISTS} ${UKRAINIAN_MEDIA_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})

BULGARIAN_MEDIA_NAMELISTS="media/paxnova/human/slavic/southern/bulgarian ui/human/slavic/southern/bulgarian ${SLAVIC_COMMON_MEDIA_NAMELISTS}"
BULGARIAN_REAL_NAMELISTS="real/slavic/southern/bulgarian ${SLAVIC_COMMON_REAL_NAMELISTS}"
BULGARIAN_NAMELISTS=$(get-namelists-merged ${CZECHOSLOVAKIAN_REAL_NAMELISTS} ${CZECHOSLOVAKIAN_MEDIA_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})

CZECH_MEDIA_NAMELISTS="media/pandora/human/slavic/western/czechoslovakian/czech media/other/human/slavic/western/czechoslovakian/czech ui/human/slavic/western/czechoslovakian/czech ${CZECHOSLOVAKIAN_COMMON_MEDIA_NAMELISTS}"
CZECH_REAL_NAMELISTS="real/slavic/western/czechoslovakian/czech ${SLAVIC_COMMON_REAL_NAMELISTS}"
CZECH_NAMELISTS=$(get-namelists-merged ${CZECH_REAL_NAMELISTS} ${CZECH_MEDIA_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})

SLOVAK_GENERATED_NAMELISTS="generated/ung/human/slavic/western/czechoslovakian/slovak ${SLAVIC_COMMON_GENERATED_NAMELISTS}"
SLOVAK_MEDIA_NAMELISTS="ui/human/slavic/western/czechoslovakian/slovak ${CZECHOSLOVAKIAN_COMMON_MEDIA_NAMELISTS}"
SLOVAK_REAL_NAMELISTS="real/slavic/western/czechoslovakian/slovakian ${SLAVIC_COMMON_REAL_NAMELISTS}"
SLOVAK_NAMELISTS=$(get-namelists-merged ${SLOVAK_REAL_NAMELISTS} ${SLOVAK_MEDIA_NAMELISTS} ${SLOVAK_GENERATED_NAMELISTS})

CROATIAN_GENERATED_NAMELISTS="${YUGOSLAVIC_COMMON_GENERATED_NAMELISTS}"
CROATIAN_MEDIA_NAMELISTS="media/pandora/human/slavic/southern/yugoslavic/croatian ui/human/slavic/southern/yugoslavic/croatian ${YUGOSLAVIC_COMMON_MEDIA_NAMELISTS}"
CROATIAN_REAL_NAMELISTS="real/slavic/southern/yugoslavic/croatian ${SLAVIC_COMMON_REAL_NAMELISTS}"
CROATIAN_NAMELISTS=$(get-namelists-merged ${SERBIAN_REAL_NAMELISTS} ${SERBIAN_MEDIA_NAMELISTS} ${CROATIAN_GENERATED_NAMELISTS})

CZECHOSLOVAKIAN_GENERATED_NAMELISTS=$(get-namelists-merged ${SLOVAK_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
CZECHOSLOVAKIAN_MEDIA_NAMELISTS=$(get-namelists-merged ${CZECH_MEDIA_NAMELISTS} ${SLOVAK_MEDIA_NAMELISTS} ${CZECHOSLOVAKIAN_COMMON_MEDIA_NAMELISTS})
CZECHOSLOVAKIAN_REAL_NAMELISTS=$(get-namelists-merged ${CZECH_REAL_NAMELISTS} ${SLOVAK_REAL_NAMELISTS} ${SLAVIC_COMMON_REAL_NAMELISTS})
CZECHOSLOVAKIAN_NAMELISTS=$(get-namelists-merged ${CZECHOSLOVAKIAN_REAL_NAMELISTS} ${CZECHOSLOVAKIAN_MEDIA_NAMELISTS} ${CZECHOSLOVAKIAN_GENERATED_NAMELISTS})

POLISH_GENERATED_NAMELISTS="generated/fng/human/slavic/western/polish generated/ung/human/slavic/western/polish ${SLAVIC_COMMON_GENERATED_NAMELISTS}"
POLISH_MEDIA_NAMELISTS="media/stellaris/human/slavic/western/polish ui/human/slavic/western/polish ${SLAVIC_COMMON_MEDIA_NAMELISTS}"
POLISH_REAL_NAMELISTS="real/slavic/western/polish ${SLAVIC_COMMON_REAL_NAMELISTS}"
POLISH_NAMELISTS=$(get-namelists-merged ${POLISH_REAL_NAMELISTS} ${POLISH_MEDIA_NAMELISTS} ${POLISH_GENERATED_NAMELISTS})

RUSSIAN_GENERATED_NAMELISTS="generated/ung/human/slavic/eastern/russian ${SLAVIC_COMMON_GENERATED_NAMELISTS}"
RUSSIAN_MEDIA_NAMELISTS="media/alien/human/slavic/eastern/russian media/civbe/human/slavic/russian media/dishonored/slavic/eastern/russian media/paxnova/human/slavic/eastern/russian media/pandora/human/slavic/eastern/russian media/stellaris/human/slavic/eastern/russian media/other/human/slavic/eastern/russian media/aow/planetfall/dvar ui/human/slavic/eastern/russian ${SLAVIC_EASTERN_COMMON_MEDIA_NAMELISTS}"
RUSSIAN_REAL_NAMELISTS="real/slavic/eastern/russian ${SLAVIC_COMMON_REAL_NAMELISTS}"
RUSSIAN_NAMELISTS=$(get-namelists-merged ${RUSSIAN_REAL_NAMELISTS} ${RUSSIAN_MEDIA_NAMELISTS} ${RUSSIAN_GENERATED_NAMELISTS})

SERBIAN_GENERATED_NAMELISTS="${YUGOSLAVIC_COMMON_GENERATED_NAMELISTS}"
SERBIAN_MEDIA_NAMELISTS="ui/human/slavic/southern/yugoslavic/serbian ${YUGOSLAVIC_COMMON_MEDIA_NAMELISTS}"
SERBIAN_REAL_NAMELISTS="real/slavic/southern/yugoslavic/serbian ${SLAVIC_COMMON_REAL_NAMELISTS}"
SERBIAN_NAMELISTS=$(get-namelists-merged ${SERBIAN_REAL_NAMELISTS} ${SERBIAN_MEDIA_NAMELISTS} ${SERBIAN_GENERATED_NAMELISTS})

UKRAINIAN_MEDIA_NAMELISTS="media/alien/human/slavic/eastern/ukrainian media/paxnova/human/slavic/eastern/ukrainian media/stellaris/human/slavic/eastern/ukrainian ui/human/slavic/eastern/ukrainian ${SLAVIC_EASTERN_COMMON_MEDIA_NAMELISTS}"
UKRAINIAN_REAL_NAMELISTS="real/slavic/eastern/ukrainian ${SLAVIC_COMMON_REAL_NAMELISTS}"
UKRAINIAN_NAMELISTS=$(get-namelists-merged ${UKRAINIAN_REAL_NAMELISTS} ${UKRAINIAN_MEDIA_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})

YUGOSLAVIC_GENERATED_NAMELISTS=$(get-namelists-merged ${CROATIAN_GENERATED_NAMELISTS} ${SERBIAN_GENERATED_NAMELISTS} ${YUGOSLAVIC_COMMON_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
YUGOSLAVIC_MEDIA_NAMELISTS="${CROATIAN_MEDIA_NAMELISTS} ${SERBIAN_MEDIA_NAMELISTS} ${YUGOSLAVIC_COMMON_MEDIA_NAMELISTS}"
YUGOSLAVIC_REAL_NAMELISTS="real/slavic/southern/yugoslavic/bosnian ${CROATIAN_REAL_NAMELISTS} real/slavic/southern/yugoslavic/montenegrin ${SERBIAN_REAL_NAMELISTS} real/slavic/southern/yugoslavic/slovenian ${YUGOSLAVIC_COMMON_REAL_NAMELISTS}"
YUGOSLAVIC_NAMELISTS=$(get-namelists-merged ${YUGOSLAVIC_REAL_NAMELISTS} ${YUGOSLAVIC_MEDIA_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})

SLAVIC_EASTERN_GENERATED_NAMELISTS="${RUSSIAN_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS}"
SLAVIC_EASTERN_MEDIA_NAMELISTS=$(get-namelists-merged ${RUSSIAN_MEDIA_NAMELISTS} ${UKRAINIAN_MEDIA_NAMELISTS} ${BELARUSIAN_MEDIA_NAMELISTS} ${SLAVIC_EASTERN_COMMON_MEDIA_NAMELISTS} ${SLAVIC_COMMON_MEDIA_NAMELISTS})
SLAVIC_EASTERN_REAL_NAMELISTS=$(get-namelists-merged ${RUSSIAN_REAL_NAMELISTS} ${UKRAINIAN_REAL_NAMELISTS} ${BELARUSIAN_REAL_NAMELISTS} ${SLAVIC_COMMON_REAL_NAMELISTS})
SLAVIC_EASTERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_REAL_NAMELISTS} ${SLAVIC_EASTERN_MEDIA_NAMELISTS} ${SLAVIC_EASTERN_GENERATED_NAMELISTS})
SLAVIC_SOUTHERN_GENERATED_NAMELISTS=$(get-namelists-merged ${YUGOSLAVIC_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
SLAVIC_SOUTHERN_MEDIA_NAMELISTS=$(get-namelists-merged ${YUGOSLAVIC_MEDIA_NAMELISTS} ${SLAVIC_COMMON_MEDIA_NAMELISTS})
SLAVIC_SOUTHERN_REAL_NAMELISTS=$(get-namelists-merged ${YUGOSLAVIC_REAL_NAMELISTS} ${BULGARIAN_REAL_NAMELISTS})
SLAVIC_SOUTHERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_SOUTHERN_REAL_NAMELISTS} ${SLAVIC_SOUTHERN_MEDIA_NAMELISTS} ${SLAVIC_SOUTHERN_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
SLAVIC_WESTERN_GENERATED_NAMELISTS=$(get-namelists-merged ${CZECHOSLOVAKIAN_GENERATED_NAMELISTS} ${POLISH_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
SLAVIC_WESTERN_MEDIA_NAMELISTS=$(get-namelists-merged ${CZECHOSLOVAKIAN_MEDIA_NAMELISTS} ${POLISH_MEDIA_NAMELISTS} ${SLAVIC_COMMON_MEDIA_NAMELISTS})
SLAVIC_WESTERN_REAL_NAMELISTS=$(get-namelists-merged ${CZECHOSLOVAKIAN_REAL_NAMELISTS} ${POLISH_REAL_NAMELISTS} ${SLAVIC_COMMON_REAL_NAMELISTS})
SLAVIC_WESTERN_NAMELISTS=$(get-namelists-merged ${SLAVIC_WESTERN_REAL_NAMELISTS} ${SLAVIC_WESTERN_MEDIA_NAMELISTS} ${SLAVIC_WESTERN_GENERATED_NAMELISTS})

SLAVIC_GENERATED_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_GENERATED_NAMELISTS} ${SLAVIC_SOUTHERN_GENERATED_NAMELISTS} ${SLAVIC_WESTERN_GENERATED_NAMELISTS} ${SLAVIC_COMMON_GENERATED_NAMELISTS})
SLAVIC_MEDIA_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_MEDIA_NAMELISTS} ${SLAVIC_SOUTHERN_MEDIA_NAMELISTS} ${SLAVIC_WESTERN_MEDIA_NAMELISTS} media/warhammer/fantasy/human/kislev ${SLAVIC_COMMON_MEDIA_NAMELISTS})
SLAVIC_REAL_NAMELISTS=$(get-namelists-merged ${SLAVIC_EASTERN_REAL_NAMELISTS} ${SLAVIC_SOUTHERN_REAL_NAMELISTS} ${SLAVIC_WESTERN_REAL_NAMELISTS} ${SLAVIC_COMMON_REAL_NAMELISTS})
SLAVIC_NAMELISTS=$(get-namelists-merged ${SLAVIC_REAL_NAMELISTS} ${SLAVIC_MEDIA_NAMELISTS} ${SLAVIC_GENERATED_NAMELISTS})

#################
### STARCRAFT ###
#################
STARCRAFT_PROTOSS_NAMELISTS=$(get-namelists-merged media/starcraft/protoss/daelaam media/starcraft/protoss/nerazim media/starcraft/protoss/purifier media/starcraft/protoss/taldarim media/starcraft/protoss/common)
STARCRAFT_TERRAN_NAMELISTS=$(get-namelists-merged media/starcraft/human/american/native/northern/algonquian media/starcraft/human/american/native/northern/washo media/starcraft/human/english/american/american media/starcraft/human/english/oceanian/australian media/starcraft/human/english/english media/starcraft/human/english/american/american media/starcraft/human/germanic/dutch media/starcraft/human/germanic/german media/starcraft/human/germanic/norse media/starcraft/human/romance/french media/starcraft/human/romance/italian media/starcraft/human/romance/latin media/starcraft/human/romance/iberian/spanish media/starcraft/human/romance/iberian/common media/starcraft/human/semitic/arabic media/starcraft/human/semitic/hebrew media/starcraft/human/slavic/common media/starcraft/human/greek media/starcraft/human/human)

################
### STARWARS ###
################
STARWARS_HUMAN_NAMELISTS="media/starwars/human/alderaanian media/starwars/human/corellian media/starwars/human/coruscanti media/starwars/human/common"

#################
### STELLARIS ###
#################
STELLARIS_HUMAN_NAMELISTS=$(get-namelists-merged media/stellaris/human/original/une media/stellaris/human/original/com media/stellaris/human/common)

##############
### TURKIC ###
##############
TURKISH_GENERATED_NAMELISTS="generated/ung/human/turkic/turkish"
TURKISH_MEDIA_NAMELISTS="media/paxnova/human/turkish ui/human/turkic/turkish"
TURKISH_REAL_NAMELISTS="real/turkic/turkish real/turkic/common real/common real/common/_"
TURKISH_NAMELISTS=$(get-namelists-merged ${TURKISH_REAL_NAMELISTS} ${TURKISH_MEDIA_NAMELISTS} ${TURKISH_GENERATED_NAMELISTS})

TURKIC_GENERATED_NAMELISTS="${TURKISH_GENERATED_NAMELISTS}"
TURKIC_MEDIA_NAMELISTS="${TURKISH_MEDIA_NAMELISTS}"
TURKIC_REAL_NAMELISTS="${TURKISH_REAL_NAMELISTS} real/turkic/turkmen real/turkic/uyghur real/turkic/common real/common real/common/_"
TURKIC_NAMELISTS=$(get-namelists-merged ${TURKIC_MEDIA_NAMELISTS} ${TURKIC_REAL_NAMELISTS} ${TURKIC_GENERATED_NAMELISTS})

#################
### RUNESCAPE ###
#################
RUNESCAPE_HUMAN_NAMELISTS="media/runescape/human/asgarnian media/runescape/human/kandarin/english media/runescape/human/kandarin/french media/runescape/human/kandarin/_ media/runescape/human/kharidian media/runescape/human/menaphite media/runescape/human/misthalinian/english media/runescape/human/misthalinian/_ media/runescape/human/common"

################
### EUROPEAN ###
################
EUROPEAN_GENERATED_NAMELISTS=$(get-namelists-merged ${BALTIC_GENERATED_NAMELISTS} ${CELTIC_GENERATED_NAMELISTS} ${GERMANIC_EURO_GENERATED_NAMELISTS} ${HELLENIC_GENERATED_NAMELISTS} ${HUNGARIAN_GENERATED_NAMELISTS} ${ROMANCE_EURO_GENERATED_NAMELISTS} ${SLAVIC_GENERATED_NAMELISTS})
EUROPEAN_MEDIA_NAMELISTS=$(get-namelists-merged ${BALTIC_MEDIA_NAMELISTS} ${CELTIC_MEDIA_NAMELISTS} ${ENGLISH_EURO_MEDIA_NAMELISTS} ${GERMANIC_EURO_MEDIA_NAMELISTS} ${HELLENIC_MEDIA_NAMELISTS} ${HUNGARIAN_MEDIA_NAMELISTS} ${IBERIAN_EURO_MEDIA_NAMELISTS} ${ROMANCE_EURO_MEDIA_NAMELISTS} ${SLAVIC_MEDIA_NAMELISTS} media/runescape/human/asgarnian media/runescape/human/kandarin/_ media/runescape/human/misthalinian/_ media/runescape/human/common)
EUROPEAN_REAL_NAMELISTS=$(get-namelists-merged ${BALTIC_REAL_NAMELISTS} ${CELTIC_REAL_NAMELISTS} ${ENGLISH_EURO_REAL_NAMELISTS} ${GERMANIC_EURO_REAL_NAMELISTS} ${HELLENIC_REAL_NAMELISTS} ${HUNGARIAN_REAL_NAMELISTS} ${IBERIAN_EURO_REAL_NAMELISTS} ${ROMANCE_EURO_REAL_NAMELISTS} ${SLAVIC_REAL_NAMELISTS} real/common real/common/_)
EUROPEAN_NAMELISTS=$(get-namelists-merged ${EUROPEAN_REAL_NAMELISTS} ${EUROPEAN_MEDIA_NAMELISTS} ${EUROPEAN_GENERATED_NAMELISTS})

build "ui_extra_humans_african"         "Human - African"           "L" ${AFRICAN_NAMELISTS} ${FRENCH_AFRO_NAMELISTS} ${PORTUGUESE_AFRICAN_NAMELISTS} real/tunisian
build "ui_extra_humans_american_north"  "Human - American NA"       "L" ${ENGLISH_NORTHAMERICAN_NAMELISTS}
build "ui_extra_humans_american_usa"    "Human - American USA"      "L" ${ENGLISH_USA_NAMELISTS}
build "ui_extra_humans_arabic"          "Human - Arabic"            "L" ${ARABIC_NAMELISTS}
build "ui_extra_humans_asian"           "Human - Asian"             "L" ${ASIAN_NAMELISTS}
build "ui_extra_humans_austronesian"    "Human - Austronesian"      "L" ${AUSTRONESIAN_NAMELISTS}
build "ui_extra_humans_british"         "Human - British"           "L" ${ENGLISH_EURO_NAMELISTS} ${SCOTTISH_NAMELISTS} ${WELSH_NAMELISTS} ${CORNISH_NAMELISTS} ${ICENIC_REAL_NAMELISTS}
build "ui_extra_humans_celtic"          "Human - Celtic"            "L" ${CELTIC_NAMELISTS}
build "ui_extra_humans_chinese"         "Human - Chinese"           "L" ${CHINESE_NAMELISTS}
build "ui_extra_humans_english"         "Human - English"           "L" ${ENGLISH_NAMELISTS}
build "ui_extra_humans_european"        "Human - European"          "L" ${EUROPEAN_NAMELISTS}
build "ui_extra_humans_franco-iberian"  "Human - Franco-Iberian"    "L" ${FRENCH_EURO_NAMELISTS} ${IBERIAN_EURO_NAMELISTS}
build "ui_extra_humans_french"          "Human - French EU"         "L" ${FRENCH_EURO_NAMELISTS}
build "ui_extra_humans_french_int"      "Human - French INT"        "L" ${FRENCH_NAMELISTS}
build "ui_extra_humans_german"          "Human - German"            "L" ${GERMAN_NAMELISTS}
build "ui_extra_humans_germanic"        "Human - Germanic"          "L" ${GERMANIC_NAMELISTS}
build "ui_extra_humans_hellenic"        "Human - Hellenic"          "L" ${HELLENIC_NAMELISTS}
build "ui_extra_humans_hindi"           "Human - Indian"            "L" ${INDIAN_NAMELISTS}
build "ui_extra_humans_iberian"         "Human - Iberian"           "L" ${IBERIAN_EURO_NAMELISTS}
build "ui_extra_humans_italian"         "Human - Italian"           "L" ${ITALIAN_NAMELISTS}
build "ui_extra_humans_japanese"        "Human - Japanese"          "L" ${JAPANESE_NAMELISTS}
build "ui_extra_humans_latino"          "Human - Latino"            "L" ${SPANISH_LATAM_NAMELISTS} ${PORTUGUESE_LATAM_NAMELISTS} ${NATIVE_SOUTH_AMERICAN_NAMELISTS}
build "ui_extra_humans_norse"           "Human - Norse"             "L" ${SCANDINAVIAN_NAMELISTS}
build "ui_extra_humans_portuguese"      "Human - Portuguese EU"     "L" ${PORTUGUESE_EURO_NAMELISTS}
build "ui_extra_humans_portuguese_int"  "Human - Portuguese INT"    "L" ${PORTUGUESE_NAMELISTS}
build "ui_extra_humans_romanian"        "Human - Romanian"          "L" ${ROMANIAN_NAMELISTS}
build "ui_extra_humans_romance"         "Human - Romance"           "L" ${ROMANCE_NAMELISTS}
build "ui_extra_humans_russian"         "Human - Russian"           "L" ${RUSSIAN_NAMELISTS}
build "ui_extra_humans_slavic"          "Human - Slavic"            "L" ${SLAVIC_NAMELISTS}
build "ui_extra_humans_spqr_extended"   "Human - Latin"             "L" ${LATIN_NAMELISTS}
build "ui_extra_humans_turkic"          "Human - Turkic"            "L" ${TURKIC_NAMELISTS}
build "ui_extra_humans_yugoslavic"      "Human - Yugoslavic"        "L" ${YUGOSLAVIC_NAMELISTS}
build "ui_extra_humans_extended"        "Human - *Extended*"        "L" \
    ${AFRICAN_NAMELISTS} ${ARABIC_NAMELISTS} ${ARABIC_NAMELISTS} ${ASIAN_NAMELISTS} ${AUSTRONESIAN_NAMELISTS} ${ENGLISH_NAMELISTS} ${EUROPEAN_NAMELISTS} \
    ${GERMANIC_NAMELISTS} ${HEBREW_NAMELISTS} ${INDIAN_NAMELISTS} ${NATIVE_AMERICAN_NAMELISTS} ${PERSIAN_NAMELISTS} ${ROMANCE_NAMELISTS} ${TURKIC_NAMELISTS} \
    real/afghan real/iranian real/kazakh real/tajik real/tunisian \
    \
    ${ELDERSCROLLS_HUMAN_NAMELISTS} ${RUNESCAPE_HUMAN_NAMELISTS} ${STARCRAFT_TERRAN_NAMELISTS} ${STARWARS_HUMAN_NAMELISTS} ${STELLARIS_HUMAN_NAMELISTS} \
    media/foundation/human media/galciv/human/human media/warcraft/human media/other/human/_ \
    \
    ui/human_extra ui/human_zextended

build "ui_aow_dvar"  "AoW:P - Dvar"     "L" media/aow/planetfall/dvar
build "ui_aow_kirko" "AoW:P - Kir'Ko"   "L" media/aow/planetfall/kirko

build "ui_dnd_kobold" "D&D - Kobold" "L" media/dnd/kobold

build "ui_elderscrolls_altmer"      "ElderScrolls - Altmer"     "R" media/elderscrolls/altmer
build "ui_elderscrolls_argonian"    "ElderScrolls - Argonian"   "R" media/elderscrolls/argonian
build "ui_elderscrolls_dremora"     "ElderScrolls - Dremora"    "R" media/elderscrolls/dremora
build "ui_elderscrolls_khajiit"     "ElderScrolls - Khajiit"    "R" media/elderscrolls/khajiit
build "ui_elderscrolls_orc"         "ElderScrolls - Orc"        "R" media/elderscrolls/orc
build "ui_elderscrolls_spriggan"    "ElderScrolls - Spriggan"   "R" media/elderscrolls/spriggan

build "ui_fng_lizardfolk" "FNG - Lizardfolk" "R" generated/fng/lizardfolk

build "ui_galciv_yor" "GalCiv - Yor" "R" media/galciv/yor

build "ui_narivia_rodah" "Narivia - Rodah" "R" media/narivia/rodah

build "ui_runescape_human" "RuneScape - Human" "L" ${RUNESCAPE_HUMAN_NAMELISTS}

build "ui_starcraft_human"      "StarCraft - Human"     "L" ${STARCRAFT_TERRAN_NAMELISTS}
build "ui_starcraft_protoss"    "StarCraft - Protoss"   "R" ${STARCRAFT_PROTOSS_NAMELISTS}

build "ui_starwars_human" "StarWars - Human" "L" ${STARWARS_HUMAN_NAMELISTS}

build "ui_catfolk"          "Fantasy - Catfolk" "R" media/aow/fantasy/tigran media/elderscrolls/khajiit
build "ui_demon"            "Fantasy - Demon"   "R" \
    media/aow/fantasy/draconian media/divinity/demon media/elderscrolls/dremora \
    generated/fng/demon
build "ui_dwarven"          "Fantasy - Dwarven" "R" media/aow/fantasy/dwarven media/divinity/dwarven
build "ui_elven"            "Fantasy - Elven"   "R" \
    media/aow/fantasy/elven media/divinity/elven \
    media/elderscrolls/altmer media/elderscrolls/ayleid \
    media/middle-earth/elven \
    generated/fng/elven-dark
build "ui_fantasy_spider"   "Fantasy - Spider"  "R" \
    media/elderscrolls/spider media/middle-earth/spider \
    generated/fng/spiderfolk
build "ui_goblin"           "Fantasy - Goblin"  "R" \
    media/aow/fantasy/goblin media/divinity/goblin media/elderscrolls/goblin media/runescape/goblin \
    generated/fng/goblin
build "ui_lizard"           "Fantasy - Lizard"  "R" \
    media/divinity/lizard media/elderscrolls/argonian \
    generated/fng/lizardfolk
build "ui_orc"              "Fantasy - Orc"     "R" media/aow/fantasy/orc media/divinity/orc media/elderscrolls/orc media/middle-earth/orc

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
