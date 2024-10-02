import json


def var2json(**kwargs):
    try:
        with open("tmp.json", "r") as file:
            existing_data = json.load(file)
    except FileNotFoundError:
        existing_data = {}

    existing_data.update(kwargs)

    with open("tmp.json", "w") as file:
        json.dump(existing_data, file, indent=4)
