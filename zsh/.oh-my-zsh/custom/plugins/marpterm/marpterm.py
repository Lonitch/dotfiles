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

TEMP_FILE = "marpterm-tmp.md"
TEMP_HTML = "marpterm-tmp.html"


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


def process_mermaid_charts(content):

    pattern = \
        r'```mermaid\s*\+render\s*(?:\+width:(\d+(?:px|%)))?' +\
        r'\s*(?:\+height:(\d+(?:px|%)))?\s*([\s\S]*?)```'

    def replace_mermaid(match):
        width = match.group(1)
        if width and not (width.endswith('%') or width.endswith('px')):
            print(f"Warning: Width '{width}' should end with '%' or 'px'")
        width = width or '100%'
        height = match.group(2) or 'auto'
        mermaid_code = match.group(3)
        return render_mermaid(mermaid_code, width, height)

    def render_mermaid(mermaid_code, width, height):
        with tempfile.NamedTemporaryFile(mode='w',
                                         suffix='.mmd',
                                         delete=False) as temp_mmd:
            temp_mmd.write(mermaid_code)
            temp_mmd_path = temp_mmd.name

        output_filename = f"marpterm-mmd-{uuid.uuid4()}.png"
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


def generate_temp_markdown(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    processed_content = process_mermaid_charts(content)

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
    for file in os.listdir():
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
    except KeyboardInterrupt:
        cleanup(args)
    finally:
        cleanup(args)


if __name__ == "__main__":
    main()
