#!/bin/zsh
# mkdir ~/.virtualenvs
python3 -m venv ~/.virtualenvs/molten # create a new venv
source ~/.virtualenvs/molten/bin/activate # activate the venv
pip install pynvim jupyter_client cairosvg plotly kaleido pnglatex pyperclip matplotlib numpy pandas scikit-learn
