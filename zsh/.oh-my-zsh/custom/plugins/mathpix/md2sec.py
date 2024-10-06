# Script: md2sec
# Description: divide a markdown file into sections by markdown title level.
# Divided files are named by following the rule: <md_file>.<section_number>.md
# Section numbers are given by incrementing a counter to give filenames
# Usage: python3 md2sec <md_file> [option]
# Argument:
# <md_file>               Input MD file
# Options:
# -h, --help              Show help msg
# -l, --level             Title level at which the MD is divided(default:1)
# -o, --output [folder]   Output folder for storing divided files(default:cwd)

import os
import argparse


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Divide a markdown file into sections by title level.")
    parser.add_argument("md_file", help="Input MD file")
    parser.add_argument(
        "-l", "--level", type=int, default=1,
        help="Title level at which the markdown is divided (default: 1)")
    parser.add_argument(
        "-o", "--output", default=os.getcwd(),
        help="Output folder for storing divided files (default: cwd)")
    return parser.parse_args()


def divide_markdown(md_file, level, output_folder):
    with open(md_file, 'r') as f:
        content = f.read()

    sections = content.split(f"{'#' * level} ")

    for i, section in enumerate(sections[1:], 1):
        title = section.split('\n', 1)[0].strip()
        title = title.strip().lower()
        sanitized_title = ''.join(c
                                  if c.isalnum() else '_'
                                  for c in title)
        truncated_title = sanitized_title[:50]  # Limit title length
        output_file = os.path.join(
            output_folder,
            f"{os.path.basename(md_file).split('.')[0]}.{i:03d}.{truncated_title}.md")
        with open(output_file, 'w') as f:
            f.write(f"{'#' * level} {section}")


def main():
    args = parse_arguments()
    divide_markdown(args.md_file, args.level, args.output)
    print(f"File divided into sections and saved in '{args.output}'")


if __name__ == "__main__":
    main()
