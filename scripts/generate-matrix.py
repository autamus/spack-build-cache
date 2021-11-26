#!/usr/bin/env python

import random
import requests
import sys
import json

def main(event_type):
    print("Event type: %s" % event_type)
    if event_type == "pull_request":
        matrix = ['zlib']
    else:
        response = requests.get("https://spack.github.io/packages/data/packages.json")
        if response.status_code != 200:
            sys.exit("Failed to get packages")
        packages = response.json()
        matrix = random.sample(packages, 25)
    
    print(matrix)
    print("::set-output name=packages::%s\n" % json.dumps(matrix))

if __name__ == "__main__":
    main(sys.argv[1])
