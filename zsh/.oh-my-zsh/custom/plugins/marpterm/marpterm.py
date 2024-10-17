import os
import argparse
import subprocess
import re
import time
import tempfile
import threading
import uuid
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import yaml

TEMP_FILE = "marpterm-tmp.md"
TEMP_HTML = "marpterm-tmp.html"
TEMP_MMDC = []
TEMP_MMDI = []
TEMP_TYPC = []
TEMP_TYPI = []


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Marp wrapper with HTML/Mermaid support")
    parser.add_argument("filename", help="Input markdown file")
    parser.add_argument(
        "--archive",
        "-a",
        help="Append content of input md to <archived.md>")
    parser.add_argument("--theme", "-t", help="CSS file to use as theme")
    parser.add_argument("--pdf", action="store_true", help="Render to PDF")
    parser.add_argument("--pptx", action="store_true", help="Render to PPTX")
    parser.add_argument(
        "--no-local",
        "-nl",
        action="store_true",
        help="No Use of Local Files")
    return parser.parse_args()


def generate_front_and_layout(content):
    yaml_header_pattern = r'^---\n(.*?)\n---\n'
    match = re.search(yaml_header_pattern, content, re.DOTALL)

    if not match:
        return content
    yaml_content = match.group(1)
    yaml_data = yaml.safe_load(yaml_content)

    title = yaml_data.get("title", "")
    subtitle = yaml_data.get("subtitle", "")
    author = yaml_data.get("author", "")
    authors = yaml_data.get("authors", [])
    affiliations = yaml_data.get("affili", [])

    front_page = "<!-- _class: front-page -->\n"
    if title:
        front_page += f"# {title}\n"
    if subtitle:
        front_page += f"## {subtitle}\n"
    if authors:
        front_page += f"## {', '.join(authors)}\n"
    elif author:
        front_page += f"## {author}\n"
    if affiliations:
        front_page += f"### {', '.join(affiliations)}\n"
    front_page += f"### {time.strftime('%B %d, %Y')}\n"
    front_page += "---\n"

    return match.group(0) + front_page + column_layout(content[match.end():])


def check_and_box(content):
    # find "[x]" and "[ ]" in the content,
    # and replace them into a green check mark and empty box
    # separately.
    content = content.replace('[x]', '✅')
    content = content.replace('[ ]', '☐')
    return content


def process_typst_charts(content):
    pattern = \
        r'```typst\s*\+render\s*(?:\+width:(\d+(?:px|%)))?' +\
        r'\s*(?:\+height:(\d+(?:px|%)))?\s*([\s\S]*?)```'

    temp_counter = 0

    def replace_typst(match):
        global TEMP_TYPC, TEMP_TYPI
        nonlocal temp_counter
        width = match.group(1)
        if width and not (width.endswith('%') or width.endswith('px')):
            print(f"Warning: Width '{width}' should end with '%' or 'px'")
        width = width or '100%'
        height = match.group(2) or 'auto'
        typst_code = match.group(3)
        typi = uuid.uuid4()

        if len(TEMP_TYPC) < temp_counter + 1:
            print("render new typst chart...")
            TEMP_TYPC.append(typst_code)
            TEMP_TYPI.append(typi)
            temp_counter += 1
            return render_typst(typst_code, typi, width, height)
        elif typst_code != TEMP_TYPC[temp_counter]:
            print(f"update {temp_counter}th typst chart...")
            TEMP_TYPC[temp_counter] = typst_code
            last_pic = f"marpterm-typ-{TEMP_TYPI[temp_counter]}.png"
            os.remove(last_pic)
            TEMP_TYPI[temp_counter] = typi
            temp_counter += 1
            return render_typst(typst_code, typi, width, height)
        else:
            temp_counter += 1
            id_name = TEMP_TYPI[temp_counter - 1]
            return f'<img src="marpterm-typ-{id_name}.png"' +\
                f' width="{width}" height="{height}"/>\n'

    def render_typst(typst_code, typi, width, height):
        with tempfile.NamedTemporaryFile(mode='w',
                                         suffix='.typ',
                                         delete=False) as temp_typ:
            temp_typ.write(typst_code)
            temp_typ_path = temp_typ.name

        output_filename = f"marpterm-typ-{typi}.png"
        typst_command = [
            "typst",
            "compile",
            "--format",
            "png",
            "--ppi",
            "400",
            temp_typ_path,
            output_filename
        ]

        try:
            subprocess.run(typst_command, check=True)
            os.remove(temp_typ_path)
            return f'<img src="{output_filename}" width="{width}"/>\n'

        except subprocess.CalledProcessError:
            return f"Error rendering Typst chart: {typst_code}"

    return re.sub(pattern, replace_typst, content)


def process_mermaid_charts(content):
    pattern = \
        r'```mermaid\s*\+render\s*(?:\+width:(\d+(?:px|%)))?' +\
        r'\s*(?:\+height:(\d+(?:px|%)))?\s*([\s\S]*?)```'

    temp_counter = 0

    def replace_mermaid(match):
        global TEMP_MMDC, TEMP_MMDI
        nonlocal temp_counter
        width = match.group(1)
        if width and not (width.endswith('%') or width.endswith('px')):
            print(f"Warning: Width '{width}' should end with '%' or 'px'")
        width = width or '100%'
        height = match.group(2) or 'auto'
        mermaid_code = match.group(3)
        mmdi = uuid.uuid4()

        if len(TEMP_MMDC) < temp_counter + 1:
            print("render new mmd chart...")
            TEMP_MMDC.append(mermaid_code)
            TEMP_MMDI.append(mmdi)
            temp_counter += 1
            return render_mermaid(mermaid_code, mmdi, width, height)
        elif mermaid_code != TEMP_MMDC[temp_counter]:
            print(f"update {temp_counter}th mmd chart...")
            TEMP_MMDC[temp_counter] = mermaid_code
            last_pic = f"marpterm-mmd-{TEMP_MMDI[temp_counter]}.png"
            os.remove(last_pic)
            TEMP_MMDI[temp_counter] = mmdi
            temp_counter += 1
            return render_mermaid(mermaid_code, mmdi, width, height)
        else:
            temp_counter += 1
            id_name = TEMP_MMDI[temp_counter - 1]
            return f'<img src="marpterm-mmd-{id_name}.png"' +\
                f' width="{width}" height="{height}"/>\n'

    def render_mermaid(mermaid_code, mmdi, width, height):
        with tempfile.NamedTemporaryFile(mode='w',
                                         suffix='.mmd',
                                         delete=False) as temp_mmd:
            temp_mmd.write(mermaid_code)
            temp_mmd_path = temp_mmd.name

        output_filename = f"marpterm-mmd-{mmdi}.png"
        mmdc_command = [
            "mmdc",
            "-i", temp_mmd_path,
            "-o", output_filename,
            "-b", "transparent"
        ]

        try:
            subprocess.run(mmdc_command, check=True)
            os.remove(temp_mmd_path)
            return f'<img src="{output_filename}" width="{width}"' +\
                f' height="{height}"/>\n'

        except subprocess.CalledProcessError:
            return f"Error rendering Mermaid chart: {mermaid_code}"

    return re.sub(pattern, replace_mermaid, content)


def process_columns(column_content, current_columns, processed_lines):
    if current_columns and column_content:
        total = sum(current_columns)
        widths = [f"{col/total*100:.2f}%" for col in current_columns]
        column_html = '<div style="display: flex;">'
        for i, width in enumerate(widths):
            if i < len(column_content):
                column_html += f'<div style="width: {width};">\n' +\
                    f'{column_content[i]}</div>\n'
        column_html += '</div>\n'
        processed_lines.append(column_html)
    return [], 0


def column_layout(content):
    columns_pattern = r'<!-- columns:\s*(\[[\d,\s]+\])\s*-->'
    column_pattern = r'<!-- column:\s*(\d+)\s*-->'
    reset_pattern = r'<!-- reset -->'
    slide_separator = '---'

    lines = content.split('\n')
    processed_lines = []
    current_columns = None
    current_column = 0
    column_content = []

    for line in lines:
        columns_match = re.search(columns_pattern, line)
        column_match = re.search(column_pattern, line)
        reset_match = re.search(reset_pattern, line)

        if columns_match:
            column_content, current_column = process_columns(
                column_content, current_columns, processed_lines)
            current_columns = eval(columns_match.group(1))
            column_content = ['\n'] * len(current_columns)
        elif column_match:
            current_column = int(column_match.group(1)) - 1
        elif reset_match:
            column_content, current_column = process_columns(
                column_content, current_columns, processed_lines)
            current_columns = None
        elif line.strip() == slide_separator:
            column_content, current_column = process_columns(
                column_content, current_columns, processed_lines)
            current_columns = None
            processed_lines.append("\n" + line)
        elif current_columns is not None:
            column_content[current_column] += line + '\n'
        else:
            processed_lines.append(line)
    process_columns(column_content, current_columns, processed_lines)

    return '\n'.join(processed_lines)


def generate_temp_markdown(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    processed_content = generate_front_and_layout(content)
    processed_content = check_and_box(processed_content)
    processed_content = process_mermaid_charts(processed_content)
    processed_content = process_typst_charts(processed_content)

    with open(TEMP_FILE, 'w') as f:
        f.write(processed_content)
    f.close()


def run_marp(args):
    marp_command = ["marp", TEMP_FILE, "--html"]

    if args.theme:
        marp_command.extend(["--theme", args.theme])

    if args.pdf:
        marp_command.append("--pdf")
        marp_command.extend(["-o", args.filename.split('.')[0] + "-mpt.pdf"])
    elif args.pptx:
        marp_command.append("--pptx")
        marp_command.extend(["-o", args.filename.split('.')[0] + "-mpt.pptx"])
    else:
        marp_command.append("--watch")
        marp_command.append("--preview")

    if not args.no_local:
        marp_command.append("--allow-local-files")

    subprocess.run(marp_command)


class FileChangeHandler(FileSystemEventHandler):
    def __init__(self, filename):
        self.filename = filename

    def on_modified(self, event):
        if event.src_path.endswith(self.filename):
            print(
                f"File {self.filename} has been modified. Updating...")
            time.sleep(0.1)
            generate_temp_markdown(self.filename)


def watch_file(filename):
    event_handler = FileChangeHandler(filename)
    observer = Observer()
    observer.schedule(
        event_handler,
        path=os.path.abspath(os.path.dirname(filename) or "."),
        recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


def cleanup(args):
    if os.path.exists(TEMP_FILE):
        os.remove(TEMP_FILE)
    if os.path.exists(TEMP_HTML):
        os.remove(TEMP_HTML)
    if os.path.exists(args.theme):
        os.remove(args.theme)
    gen_html = args.filename.split('.')[0] + ".html"
    if os.path.exists(gen_html):
        os.remove(gen_html)
    for file in os.listdir():
        if file.startswith("marpterm-typ-") and file.endswith(".png"):
            os.remove(file)
        if file.startswith("marpterm-mmd-") and file.endswith(".png"):
            os.remove(file)


def main():
    args = parse_arguments()

    generate_temp_markdown(args.filename)

    if args.archive:
        with open(args.archive, 'a') as archive_file:
            with open(args.filename, 'r') as input_file:
                archive_file.write(input_file.read())

    try:
        if not args.pdf and not args.pptx:
            watch_thread = threading.Thread(
                target=watch_file, args=(args.filename,))
            marp_thread = threading.Thread(target=run_marp, args=(args,))

            watch_thread.start()
            marp_thread.start()

            watch_thread.join()
            marp_thread.join()
        else:
            run_marp(args)
            cleanup(args)
    except KeyboardInterrupt:
        cleanup(args)
    finally:
        cleanup(args)


if __name__ == "__main__":
    main()
