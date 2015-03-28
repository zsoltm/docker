# PLEX

    docker build -t plex plex

Run:

    docker run -d --net="host" -v [cfgdir]:/config -v [mediadir]:/media zsoltm/plex

Edit `cfgdir/Library/Application Support/Plex Media Server/Preferences.xml` and set `allowedNetworks` to match local net.

    <?xml version="1.0" encoding="utf-8"?>
    <Preferences ... allowedNetworks="192.168.0.0/24" />

Access server `http://[host-ip]:32400/web/index.html`.

Checking if the server has advertised itself properly: https://plex.tv/pms/resources.xml
