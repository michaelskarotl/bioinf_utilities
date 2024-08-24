#!/usr/bin/env python3

# import the basic libraries
import argparse
import datetime
import json
import re
import logging
import os.path
import sys
from collections import deque, namedtuple
from typing import Generator, List, Optional, Union
import stringcase as sc
import pandas as pd

# create an argument parser
def setup_parser():
    """
    This function is a supplier function to setup the parser for the command line arguments.
    :args: None
    """
    parser = argparse.ArgumentParser()

    util_grp = parser.add_argument_group('Util Parameters')

    util_grp.add_argument(
        '--input',
        default=None,
        help='The path of the .txt file.',
    )

    util_grp.add_argument(
        '--output',
        default=None,
        help='Path of output CSV.',
    )

    return parser

def process_argv(argv):
    """
    Parse CLI arguments and return a named tuple object.

    :args: The command line input.
    :return: A RunInfo namedtuple.
    Raises: None.
    """
    parser = setup_parser() # call the supplier function

    args = parser.parse_args(argv)
    args_dict = vars(args)
    attr_list = sorted(args_dict.keys())
    RunInfo = namedtuple('RunInfo', attr_list)
    
    run_info = RunInfo(**args_dict)
    return run_info

def main(argv=None):
    """Script entrypoint."""
    # call the setup_parser function
    parser = setup_parser()
    args = parser.parse_args(argv)
    # read the input file
    run_info = process_argv(argv)
    
    # pass the arguements to the functions.

    return None
