import glob
import json
from pathlib import Path
import hashlib
import os

def sha256sum(filename):
    with open(filename, 'rb', buffering=0) as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()

checksum_files = glob.glob("vendor/*/.cargo-checksum.json")

for checksum_file in checksum_files:
    crate_directory = Path(checksum_file).resolve().parent
    print(crate_directory)

    with open(checksum_file, "r") as f:
        data = json.load(f)['files']

    new_hashes={}

    for filename in data.keys():
        path = str(crate_directory) + "/" + filename
        if os.path.isfile(path):
            new_hash = sha256sum(path)
            new_hashes[filename] = new_hash

    with open(checksum_file, "w") as f:
        json.dump({'files' : {}}, f)

