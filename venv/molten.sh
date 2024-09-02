#!/bin/zsh
# uncomment the following line if you don't have the folder
# mkdir ~/.virtualenvs
sudo apt-get install luajit
sudo apt-get install libmagickwand-dev
sudo apt-get install luarocks
luarocks install magick
python3 -m venv ~/.virtualenvs/molten # create a new venv
source ~/.virtualenvs/molten/bin/activate # activate the venv
pip install pynvim jupyter_client cairosvg plotly kaleido pnglatex pyperclip matplotlib numpy pandas scikit-learn
