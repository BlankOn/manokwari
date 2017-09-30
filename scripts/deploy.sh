#!/bin/bash

#./autogen.sh
#./configure
#docker pull herpiko/uluwatu-dev

Xephyr :2 -resizeable -fullscreen -ac -softCursor -zap&
docker run --rm --env DISPLAY=":2" -v $(pwd):/manokwari -v /tmp:/tmp -ti herpiko/uluwatu-dev /bin/bash -c /manokwari/scripts/compile-run.sh
