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
seta sv_hostname "Dockerized Q3 ^2/ ^3Excessive ^2/ ^6ARMv7l"
seta sv_minRate "0"
seta sv_maxclients "10"
seta g_allowVote "0"
seta g_forcerespawn "5"
seta bot_nochat "1"
seta g_gametype "0"
seta rconPassword "" // no rcon admin allowed
seta sv_strictauth "1"
set xp_rotation "rotation.txt"
map test_bigbox
EOF
        chown q3:q3 "${serverCfg}"
    fi

    mapRotationCfg="${workdir}/excessiveplus/rotation.txt"
    if [ ! -f "${mapRotationCfg}" ]; then
        cat > "${mapRotationCfg}" << EOF
// maprotation cfg
\$timelimit = 15;
\$fraglimit = 35;
\$g_gametype = GT_FFA;
\$xp_config = "default";

q3dm17
q3dm18
q3dm7
q3dm15
q3dm12
q3dm11
q3dm9
q3dm4
q3dm19
q3dm13
q3dm16
q3dm14
q3dm6
q3dm3
q3dm8
EOF
        chown q3:q3 "${mapRotationCfg}"
    fi

    callVoteCfg="${workdir}/excessiveplus/callvote.txt"
    if [ ! -f "${callVoteCfg}" ]; then
        cat > "${callVoteCfg}" << EOF
restart, map_restart {
  command = "map_restart";
  description = "Restarts the current map.";
}
nextmap, rotate {
  command = "rotate";
  description = "Forces the next map in server rotation to load.";
}
if ( \$g_gametype >= GT_TEAM ) {
  teamBalance {
    1 {
      empty,
      FPH, 1 {
        command = "teamBalance 1";
      }
      
      score, 2 {
        command = "teamBalance 2";
      }
    }
    
    description = "Balance the teams on the fly, without resetting the game score.";
  }
}
EOF
        chown q3:q3 "${callVoteCfg}"
    fi

    shift
    exec gosu q3 /usr/local/games/quake3/ioq3ded\
      +set vm_game 2\
      +set fs_game ${GAME}\
      +set net_port ${PORT}\
      +set fs_basepath /usr/local/games/quake3\
      +exec server.cfg $@
fi

exec $@
