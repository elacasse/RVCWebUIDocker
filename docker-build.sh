#!/bin/bash

docker buildx build --platform linux/amd64 --push -t "ericlacasse/retrieval-based-voice-conversion-webui:main" --provenance false -f Dockerfile .