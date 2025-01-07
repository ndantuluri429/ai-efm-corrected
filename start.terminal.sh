#!/bin/bash
echo "docker exec -u mfm:mfm -it "mfm-$USER" /bin/bash"
docker exec -u mfm:1000 -it "mfm-$USER" /bin/bash


