#!/bin/bash

# curl --insecure -s https://raw.github.com/pypa/virtualenv/master/virtualenv.py | python - /tmp/sagaenv
# . /tmp/sagaenv/bin/activate

# pip install PIL
. $HOME/sagaenv/bin/activate
python mandelbrot.py $@