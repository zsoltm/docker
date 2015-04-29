#!/bin/bash
if [ "$1" = 'ioq3ded' ]; then
    workdir="/home/q3/.q3a"
    if [ ! -d "${workdir}" ]; then
        mkdir -p "${workdir}/baseq3"
        mkdir -p "${workdir}/excessiveplus"
        chown -R q3:q3 "${workdir}"
    fi

    serverCfg="${workdir}/excessiveplus/server.cfg"
    if [ ! -f "${serverCfg}" ]; then
        cat > "${serverCfg}" << EOF
// default FFA server.cfg
seta sv_fps 30
seta sv_minRate "0"
seta g_allowVote "0"
seta g_forcerespawn "5"
seta bot_nochat "1"
seta g_gametype "0"
seta sv_strictauth "1"
set xp_rotation "rotation.txt"
map test_bigbox
EOF
        chown q3:q3 "${serverCfg}"
    fi

    shift
    exec gosu q3 /usr/local/games/quake3/ioq3ded\
      +set vm_game 2\
      +set dedicated ${DEDICATED}\
      +set fs_game ${GAME}\
      +set net_port ${PORT}\
      +set sv_pure ${PURE}\
      +set sv_maxclients ${MAX_CLIENTS}\
      +set sv_hostname "${NAME}"\
      +set rconPassword "${RCON}"\
      +set fs_basepath /usr/local/games/quake3\
      +exec server.cfg $@
fi

exec $@
