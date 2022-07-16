#!/usr/bin/env python3

# Start a server on `localhost:8080` that runs a command on every request and serves
# its output, or displays a more detailed 500 error message if the command fails.
# Essentially this is a lightweight version of CGI, I think.

import sys, subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer

cmd = sys.argv[1:]
if not cmd:
    print("please provide a command to run", file=sys.stderr)
    sys.exit(1)

def indent(bs):
    parts = []
    for line in bs.split(b"\n"):
        if line.strip() == b"":
            parts.append(line)
        else:
            parts.append(b"    " + line)
    return b"\n".join(parts)

class Server(BaseHTTPRequestHandler):
    def respond_with_command(self):
        cmd_result = subprocess.run(cmd, capture_output=True)
        if cmd_result.returncode == 0:
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(cmd_result.stdout)
        else:
            parts = []
            parts.append(b"Generator command failed with exit code ")
            parts.append(str(cmd_result.returncode).encode())
            parts.append(b".")
            for name, content in [(b"Stderr", cmd_result.stderr), (b"Stdout", cmd_result.stdout)]:
                parts.append(b"\n\n")
                parts.append(name)
                parts.append(b":\n\n")
                parts.append(indent(content))
            self.send_response(500)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"".join(parts))

    def do_GET(self):
        if self.path == "/":
            self.respond_with_command()
        else:
            self.send_response(404)
            self.wfile.write(b"404 - not found")

port = 8080
print("starting server on port {}...".format(port))
httpd = HTTPServer(("0.0.0.0", port), Server)
print("running server...")
httpd.serve_forever()
