#!/bin/bash
if [ "$1" = 'ioq3ded' ]; then
    workdir="/home/q3/.q3a"
    if [ ! -d "${workdir}" ]; then
        mkdir -p "${workdir}/baseq3"
        chown -R q3:q3 "${workdir}"
    fi

    serverCfg="${workdir}/baseq3/server.cfg"
    if [ ! -f "${serverCfg}" ]; then
        cat > "${serverCfg}" << EOF
// default FFA server.cfg
seta sv_fps 30
seta sv_hostname "Dockerized Q3 ^2/ ^3Vanilla ^2/ ^6ARMv7l"
seta sv_minRate "0"
seta sv_maxclients "10"
seta g_allowVote "0"
seta g_forcerespawn "5"
seta bot_nochat "1"
seta g_gametype "0"
seta rconPassword "" // no rcon admin allowed
seta sv_strictauth "1"
EOF
        chown q3:q3 "${serverCfg}"
    fi

    mapRotationCfg="${workdir}/baseq3/map-rotation.cfg"
    if [ ! -f "${mapRotationCfg}" ]; then
        cat > "${mapRotationCfg}" << EOF
// maprotation cfg
set m1 "fraglimit 30; timelimit 0;  map q3dm17; set nextmap vstr m2"
set m2 "fraglimit 30; timelimit 0;  map q3dm18; set nextmap vstr m3"
set m3 "fraglimit 30; timelimit 0;  map q3dm7 ; set nextmap vstr m4"
set m4 "fraglimit 30; timelimit 0;  map q3dm15; set nextmap vstr m5"
set m5 "fraglimit 30; timelimit 0;  map q3dm12; set nextmap vstr m6"
set m6 "fraglimit 30; timelimit 0;  map q3dm11; set nextmap vstr m7"
set m7 "fraglimit 30; timelimit 0;  map q3dm9 ; set nextmap vstr m8"
set m8 "fraglimit 30; timelimit 0;  map q3dm4 ; set nextmap vstr m9"
set m9 "fraglimit 30; timelimit 0;  map q3dm19; set nextmap vstr m10"
set m10 "fraglimit 30; timelimit 0; map q3dm13; set nextmap vstr m11"
set m11 "fraglimit 30; timelimit 0; map q3dm16; set nextmap vstr m12"
set m12 "fraglimit 30; timelimit 0; map q3dm14; set nextmap vstr m13"
set m13 "fraglimit 30; timelimit 0; map q3dm6 ; set nextmap vstr m14"
set m14 "fraglimit 30; timelimit 0; map q3dm3 ; set nextmap vstr m15"
set m15 "fraglimit 30; timelimit 0; map q3dm8 ; set nextmap vstr m1"
vstr m1
EOF
        chown q3:q3 "${mapRotationCfg}"
    fi

    shift
    exec gosu q3 /usr/local/games/quake3/ioq3ded\
      +set vm_game 2\
      +set fs_basepath /usr/local/games/quake3\
      +exec server.cfg\
      +exec map-rotation.cfg $@
fi

exec $@
