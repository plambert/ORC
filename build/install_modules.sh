#!/bin/bash

grep -v Test::Continuous Prerequisites | xargs cpanm --notest

