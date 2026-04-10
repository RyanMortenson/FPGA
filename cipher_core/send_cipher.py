#!/usr/bin/env python3
import serial
import argparse
import sys
import time


def hex_string_to_byte_array(hex_string):
    """
    Convert a hex string into a byte array.

    Args:
        hex_string (str): A string representing hex values (e.g., "a13a3ab3071897088f3233a58d6238bb").

    Returns:
        bytearray: A bytearray corresponding to the hex string.
    """
    # Remove any spaces from the string, if present.
    hex_string = hex_string.replace(" ", "")

    # Ensure the hex string has an even number of characters.
    if len(hex_string) % 2 != 0:
        raise ValueError("Hex string must have an even number of characters.")

    # Convert the hex string to a byte array.
    return bytearray.fromhex(hex_string)


def send_byte_array_over_serial_port(serial_port, byte_array):
    """
    Send a byte array over a serial port.

    Args:
        byte_array (bytearray): A byte array to send over the serial port.
        port (str): The serial port to use (e.g., "/dev/ttyUSB0").
        baud (int): The baud rate to use (default: 19200).
    """
    # Set a delay between each byte (in seconds).
    delay = 0.001
    try:
        for b in byte_array:
            # Send one byte at a time.
            bytes_written = serial_port.write(bytes([b]))
            if bytes_written != 1:
                print(
                    f"Warning: Expected to send 1 byte, but sent {bytes_written} bytes."
                )
            # print(f"Sent byte: {b:02X}")
            # input("Press Enter to send the next byte.")
            time.sleep(delay)
    except serial.SerialException as e:
        print(f"Error writing to the serial port: {e}")
        sys.exit(1)


def main():

    # Define a 16-byte sequence (bytes may not be ASCII).
    ciphertext_strings = [
        "7d1fd1e0e0b4eeeba6d6d91e2c05d5cb",
        "a13a3ab3071897088f3233a58d6238bb",
        "b8935bbf5f819bcfec46da11d5393d4f",
        "396d6e70500754ff726bd5fb963998ce",
        # "189f2800aac06ce4a74292bffe33fd2c",
        "19b39b044dc39c4e98f9dfb44a0b7c11",
        "136e39184268b877f74536ad779756dc",  # Invalid message
    ]

    ciphertext_bytes = [hex_string_to_byte_array(s) for s in ciphertext_strings]

    # Set up command line argument parsing.
    parser = argparse.ArgumentParser(
        description="Send a 16-byte sequence over a serial port."
    )
    parser.add_argument(
        "--port", required=True, help="Serial port (e.g., /dev/ttyUSB0)"
    )
    parser.add_argument(
        "--baud", type=int, default=19200, help="Baud rate (default: 19200)"
    )
    parser.add_argument(
        "--cipher", type=int, help=f"Ciphertext to send (0-{len(ciphertext_bytes) - 1})"
    )
    args = parser.parse_args()

    # Open the serial port with the specified baud rate, odd parity, and one stop bit.
    serial_port = None
    try:
        serial_port = serial.Serial(
            args.port,
            baudrate=args.baud,
            parity=serial.PARITY_ODD,  # Set odd parity.
            stopbits=serial.STOPBITS_ONE,  # Set one stop bit.
            timeout=1,
        )
    except serial.SerialException as e:
        print(f"Error opening or using the serial port: {e}")
        sys.exit(1)

    if args.cipher is not None:
        index = args.cipher
        if index < 0 or index >= len(ciphertext_bytes):
            print(f"Invalid index: {index}")
            sys.exit(1)
        send_byte_array_over_serial_port(serial_port, ciphertext_bytes[index])
    else:
        continue_input = True
        while continue_input:
            index = input(
                f"Which ciphertext do you want to send? (0-{len(ciphertext_bytes) - 1}, q to exit): "
            )
            if index == "q":
                continue_input = False
                continue
            if not index.isdigit():
                print("Invalid input: Please enter a number.")
                continue
            index = int(index)
            if index < 0 or index >= len(ciphertext_bytes):
                print(f"Invalid index: {index}")
                continue
            print(f" Sending ciphertext {ciphertext_strings[index]}.")
            send_byte_array_over_serial_port(serial_port, ciphertext_bytes[index])


if __name__ == "__main__":
    main()
