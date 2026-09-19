import sys
import subprocess
Import("env")

# List your required Python packages here
REQUIRED_PACKAGES = ["PICSimLab_rcontrol"]

for package in REQUIRED_PACKAGES:
    try:
        __import__(package)
    except ImportError:
        print(f"Installing missing Python dependency: {package}")
        # Uses PlatformIO's internal Python executable to install the library
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
