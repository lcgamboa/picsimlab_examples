#!/usr/bin/env python3

# Tool to load firmware.hex/firmware.bin in PICSimLab using the rcontrol protocol

"""
   ########################################################################

   PICSimLab - Programmable IC Simulator Laboratory

   ########################################################################

   Copyright (c) : 2025-2026  Luis Claudio Gambôa Lopes <lcgamboa@yahoo.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   For e-mail suggestions :  lcgamboa@yahoo.com
   ######################################################################## 
 """ 

import os
import sys

from PICSimLab_rcontrol import PICSimLab_rcontrol

def main():

    if len(sys.argv) != 2:
        print("PICSimLab Tool:")
        print("*************************************************")
        print("* Developed by L.C. Gamboa <lcgamboa@yahoo.com> *")
        print("*************************************************")
        print(f"Use:\n{sys.argv[0]} file.[hex/bin]")
        return -1
    
    print("================== [PICSimLab Tool] ==================")

    _, extension = os.path.splitext(sys.argv[1])
    is_bin = extension.lower() == ".bin"

    try:
        fname = os.path.realpath(sys.argv[1])
    except Exception:
        fname = None

    if fname and os.path.exists(fname):
        print(f"Loading file: {fname}")
    else:
        print(f"File not found: {sys.argv[1]}")
        return -1

    try:
        with PICSimLab_rcontrol(5000) as rc:

            # --------------------------------------------------
            # info
            # --------------------------------------------------
            
            
            if rc.cmd_info():
                print("Conn. error!")
                return -1

            buff = rc.get_cmd_response()
            if buff.startswith("Board"):
                lines = buff.splitlines()

                if len(lines) > 0:
                    print(lines[0])

                if len(lines) > 1:
                    print(lines[1])

            else:
                print("Error: Getting board info!")
                rc.quit()
                return -1

            # --------------------------------------------------
            # loadhex
            # --------------------------------------------------
            if rc.cmd_loadhex(fname):
                print("Error: File not loaded!")
                return -1
            else:
                print("File loaded!")
                if is_bin:
                    return 0

            rc.cmd_quit()

    except ConnectionError as e:
        print(e)
        return -1

    return 0


if __name__ == "__main__":
    sys.exit(main())
