#!/bin/sh

yq e '.contexts[].name = "$K3S_CONTEXT"' -i config

