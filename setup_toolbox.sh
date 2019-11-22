#!/bin/bash

if [ "$1" == "create" ]; then
  docker image rm -f sdtd-toolbox 2>/dev/null
  docker image build -t sdtd-toolbox .

  docker container rm -f sdtd-toolbox-0 2>/dev/null 
  docker container run -d -t --name sdtd-toolbox-0 sdtd-toolbox
fi

docker container exec -i -t sdtd-toolbox-0 bash