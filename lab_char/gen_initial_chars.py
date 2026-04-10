#!/usr/bin/python3

"""
This script is used to generate background memory files based on a text file for use
within the VGA character generator. The script reads an ASCII file to determine the
memory contents.
"""

# Manages file paths
import pathlib
# Command line argunent parser
import argparse
import re
import os

# Script defaults
script_path = pathlib.Path(__file__).absolute().parent.resolve()
cwd_path =  pathlib.Path(os.getcwd())

def generate_mem_file(output_filename, char_array, input_filename = None):
    ''' Generates the output file for the memory ''' 
    newLines = []

    # Total number of displayable rows
    totalRows = 32
    visibleRows = 29
    totalColumns = 128
    borderEndColumn = 76
    # Character to use if no character is defined
    default_char = ' '

    # Create a header
    newLines.append("////////////////////////////////////////////////////////////////////////")
    newLines.append("//")
    newLines.append(f"// {output_filename}: Character background memory file: ")
    if input_filename is not None:
        newLines.append(f"//   Generated from file {input_filename} ")
    newLines.append("//")
    newLines.append("// Locations tagged with '*' are not visible ")
    newLines.append("//")
    newLines.append("////////////////////////////////////////////////////////////////////////")
    newLines.append("")
    newLines.append("")

    # iterate over all rows that should be in the final memory (both displayable and non-displayable)
    for idx in range(totalRows):
        # Row comment
        if idx < visibleRows:
            newLines.append(f"// Row {idx}")
        else:
            newLines.append(f"// Row {idx} - Not visible")
        # Create an empty column list for each of the characters
        column_vals = []
        # If the current row exists in the character array, process the characters in the array
        if idx < len(char_array):
            row = char_array[idx]
            for jdx in range(totalColumns):
                if jdx < len(row):
                    # Character defined in input file
                    char_val = row[jdx]
                else:
                    # Not defined in input file
                    char_val = (ord(default_char))
                column_vals.append(char_val)
        # The current row does not exist in the character array. Provide default values.
        else:
            # Row not defined in input file
            for jdx in range(totalColumns):
                column_vals.append(ord(default_char))

        # Done processing the row. Generate the memory values
        for jdx, char_mem in enumerate(column_vals):
            # Print value
            newStr = f"{char_mem:02x}  // \'{chr(char_mem & 0x7f)}\' ({jdx:03d},{idx:02d}) addr:0x{jdx+idx*128:03x} ({jdx+idx*128})"
            if jdx >= borderEndColumn or idx >= visibleRows:
                newStr = newStr + " *"
            newLines.append(newStr)
    return newLines

def create_2d_char_array(lines):
    ''' Parses an array of ascii lines and generates an array of lists where each list is
    a list of the ASCII values within the line. '''
    char_array = []
    for line in lines:
        line_array = []
        for c in line:
            if c=='\n':
                # Skip end of line characters
                continue
            line_array.append(ord(c))
        char_array.append(line_array)
    return char_array

def extract_character_lines(input_filename,
                            comment_character = "#",
                            line_start_annotation = None,
                            line_end_annotation = None):
    ''' Parse an ASCII file to identify the lines in the file that correspond to
    ASCII characters. Extract \n from the lines.

    input_filename: refers to the filename that contains the ASCII characters
    command_character: the character that indicates a comment line to ignore
    line_start_annotation: the string that indicates the start of the character lines.
       If this is None, no start annotation will be used. All lines will be considered.
    line_end_annotation: the string that indicates the end of the character lines
       If this is None, no end annotation will be used. All lines after the start will be considered.
    '''
    # Load all lines into a list
    with open(input_filename) as file:
        lines = [line for line in file]
    # Strip all comment lines
    character_lines = []
    start_annotation = False # Flag to indicate we have started keeping character lines
    # If we don't have a start_annotation, just start keeping lines
    if line_start_annotation is None:
        keep_lines = True
    for line in lines:
        # Skip comment lines
        if line.startswith(comment_character):
            continue
        # If we have a start annotation, check if we have started keeping lines
        if line_start_annotation is not None and not start_annotation:
            if line.startswith(line_start_annotation):
                start_annotation = True
            continue
        # If we have a line end annotation and the current line specifies it, return the character lines
        if line_end_annotation is not None and line.startswith(line_end_annotation):
            break
        # Skip if we haven't reached the start annotation
        if line_start_annotation is not None and not start_annotation:
            continue
        # Append a valid line
        character_lines.append(line)
    # Remove the newline character from the end of each line
    character_lines = [line.rstrip('\n') for line in character_lines]

    # Return the character_lines
    return character_lines


def main():

    parser = argparse.ArgumentParser(description='Create background memory files')
    parser.add_argument('input_file',  type=str, help='Filename of the input template file')
    parser.add_argument('output_file',  type=str, help='Filename of the output memory file')

    # Parse the command line given using the above arg definitions
    args = parser.parse_args()

    char_lines = extract_character_lines(args.input_file)
    char_array = create_2d_char_array(char_lines)
    new_lines = generate_mem_file(args.output_file, char_array, args.input_file)

    # Spit out the new file based on the proocessed lines of code
    outputFilePath = cwd_path / args.output_file
    with open(outputFilePath, 'w') as f:
        for line in new_lines:
            f.write('%s\n' % line)

if __name__ == "__main__":
    main()