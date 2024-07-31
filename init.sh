#!/bin/bash

CONTAINER_ALREADY_STARTED="$HOME/Retrieval-based-Voice-Conversion-WebUI/firstrun"
if [ ! -e "$CONTAINER_ALREADY_STARTED" ]; then
    sudo chown rvc:rvc ~/Retrieval-based-Voice-Conversion-WebUI
    sudo chmod 755 ~/Retrieval-based-Voice-Conversion-WebUI

    git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git

    cd ~/Retrieval-based-Voice-Conversion-WebUI || exit

    python3 -m venv venv

    source ./venv/bin/activate

    pip install torch torchvision torchaudio
    pip install -r requirements.txt
    python tools/download_models.py

    deactivate

    touch "$CONTAINER_ALREADY_STARTED"
fi

cd ~/Retrieval-based-Voice-Conversion-WebUI || exit
source ./venv/bin/activate
python infer-web.py