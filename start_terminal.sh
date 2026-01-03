#!/bin/bash
echo "docker exec -u mfm:mfm -it "mfm-$USER" /bin/bash"
docker exec -u mfm:501 -it "mfm-$USER" /bin/bash # edit UID
