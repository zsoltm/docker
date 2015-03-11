# PLEX

    docker build -t plex plex

Run:

    docker run -d -h [hostname] -v [cfgdir]:/config -v [mediadir]:/media -p 32400:32400 zsoltm/plex

Edit `cfgdir/Library/Application Support/Plex Media Server/Preferences.xml` and set `allowedNetworks` to match local net.

    <?xml version="1.0" encoding="utf-8"?>
    <Preferences ... allowedNetworks="192.168.0.0/24" />

Access server `http://[host-ip]:32400/web/index.html`.
