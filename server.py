#!/usr/bin/env python3
"""
Simple HTTP server for the Compiler Optimization Viewer.
Run: python server.py
Then open: http://localhost:8080
"""
import http.server
import socketserver
import os

PORT = 3333
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        super().end_headers()

    def log_message(self, format, *args):
        print(f"  {self.address_string()} - {format % args}")

if __name__ == "__main__":
    os.chdir(BASE_DIR)
    with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
        print(f"\n{'='*55}")
        print(f"  Compiler Optimization Viewer")
        print(f"  http://localhost:{PORT}")
        print(f"{'='*55}\n")
        print("Press Ctrl+C to stop.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
