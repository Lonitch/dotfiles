import os
import sys
import subprocess
from datetime import datetime
import yaml


def print_help():
    print("""
Marp Render Script

Usage: python marp.py [options]

Options:
  -i, --input <file>    Input Markdown (default: recent modified .md)
  -o, --output <dir>    Output directory (default: current directory)
  -h, --help            Display this help message

Example:
  python marp.py -i presentation.qmd -o ./output
""")


def find_latest_md_file():
    files = [f for f in os.listdir('.') if f.lower().endswith('.qmd')]
    if not files:
        return ""
    files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
    if "README" in files[0]:
        return files[1] if len(files) > 1 else ""
    return files[0]


def generate_front_page(yaml_data):
    title = yaml_data.get('title', '').strip('"')
    theme = yaml_data.get('theme', '').strip('"')
    marp_theme = yaml_data.get('marp-theme', '').strip('"')
    authors = yaml_data.get('author', [])
    affiliations = yaml_data.get('affiliations', [])
    date = yaml_data.get('date', datetime.now().strftime("%Y-%m-%d"))
    # Process authors
    author_info = []
    for author in authors:
        name = author.get('name', '').strip('"')
        # email = author.get('email', '').strip('"')
        # affil_ids = author.get('affil-id', '')
        author_info.append(f"{name}")

    # Process affiliations
    affiliation_info = []
    for affiliation in affiliations:
        name = affiliation.get('name', '').strip('"')
        # id = affiliation.get('id', '')
        affiliation_info.append(f"{name}")
    theme_str = ""
    if marp_theme:
        theme_str = "theme: "+marp_theme
    elif theme:
        theme_str = "theme: "+marp_theme
    else:
        print("Warning: No theme name found in input file")

    return f"""---
marp: true
paginate: true
{theme_str}
---

<!-- _class: front-page -->
# {title}

## {' '.join(author_info)}
## {', '.join(affiliation_info)}

### {date}

"""


def main():
    try:
        args = sys.argv[1:]

        if "-h" in args or "--help" in args:
            print_help()
            return

        input_file = get_input_file(args)
        output_file = get_output_file(args, input_file)
        ensure_output_directory(output_file)

        content = read_input_file(input_file)
        full_content = process_content(content)

        create_temp_file(full_content)
        process_python_block(full_content)
        process_mermaid_graphs()
        generate_output_file(output_file)

    except Exception as error:
        print("An error occurred:", str(error))
        print_help()


def get_input_file(args):
    input_file = next(
        (args[i + 1] for i, arg in enumerate(args)
         if arg in ["-i", "--input"] and i + 1 < len(args)),
        None)
    if not input_file:
        input_file = find_latest_md_file()
        if not input_file:
            raise ValueError(
                "Please provide an input file with --input or -i argument")
    print(f"Editing {input_file}")
    return input_file


def get_output_file(args, input_file):
    output_file = next(
        (args[i + 1] for i, arg in enumerate(args)
         if arg in ["-o", "--output"] and i + 1 < len(args)),
        None)
    if not output_file:
        output_file = os.path.splitext(input_file)[0] + ".pdf"
    return output_file


def ensure_output_directory(output_file):
    output_dir = os.path.dirname(output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)


def read_input_file(input_file):
    with open(input_file, 'r') as f:
        return f.read()


def process_content(content):
    yaml_match = content.split('---', 2)
    if len(yaml_match) >= 3:
        yaml_data = yaml.safe_load(yaml_match[1])
        front_page = generate_front_page(yaml_data)
        return front_page + yaml_match[2].replace("\n\n## ", "\n\n---\n\n## ")
    return content


def create_temp_file(content):
    temp_md_file = "temp_output.qmd"
    with open(temp_md_file, 'w') as f:
        f.write(content)
    return temp_md_file


def process_python_block(content):
    import re

    print("Render python figures")
    subprocess.run(
        ["quarto", "render", "temp_output.qmd"], check=True
    )
    filename = "temp_output"
    figure_dir = f"_output/{filename}_files/figure-html"

    python_blocks = re.findall(r'```\{python\}(.*?)```', content, re.DOTALL)

    if os.path.exists(figure_dir):
        figures = [f for f in os.listdir(figure_dir) if f.endswith('.png')]

        if len(figures) == len(python_blocks):
            for i, block in enumerate(python_blocks):
                figure_path = f"{figure_dir}/{figures[i]}"
                replacement = f"![Python output]({figure_path})"
                content = content.replace(
                    f"```{{python}}{block}```", replacement, 1)

            with open("temp_output.qmd", 'w') as f:
                f.write(content)
            subprocess.run([
                "mv", "temp_output.qmd", "temp_output.md"
            ])
            print("Python figure replaced.")
        else:
            print("Warning: Not all Python figure are generated")


def process_mermaid_graphs():

    with open("temp_output.md", 'r') as f:
        content = f.read()
    if "```{mermaid}" in content:
        modified_content = content.replace("```{mermaid}", "```mermaid")
        with open("temp_output.md", 'w') as f:
            f.write(modified_content)
        subprocess.run(
            ["mmdc", "-i", "temp_output.md", "-o", "temp_output.md"],
            check=True)
        print("Mermaid graphs generated.")


def generate_output_file(output_file):
    subprocess.run(
        ["mv", "temp_output.md", output_file],
        check=True)


if __name__ == "__main__":
    main()
