from mitmproxy import http

import json
import os
import subprocess
import signal

# Enables or disables the mocking feature as a whole
isMockEnabled = True

# Setup onExit handler
def handler(signum, frame):
    print("shutting down")
    subprocess.Popen("sh proxy_off.sh".split(), stdout=subprocess.PIPE)

signal.signal(signal.SIGINT, handler)
signal.signal(signal.SIGTERM, handler)

# Setup onStart handler
def load(l):
    print("setting up network proxy")
    subprocess.Popen("sh proxy_on.sh".split(), stdout=subprocess.PIPE)

# Setup onRequest handler
def request(flow: http.HTTPFlow) -> None:

    if isMockEnabled:
        directory_path = os.path.dirname(os.path.abspath(__file__))

        if "http://com.rlmg.mitmproxy.server.com/todos" == flow.request.pretty_url:
            flow.response = http.HTTPResponse.make(
                200,
                open(directory_path + "/jsons/todos.json", "r").read(),
                {"Content-Type": "application/json"}
            )
            return