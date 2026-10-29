import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        message = "<h1>Hello World! DevOps Assessment App running on Port 8081</h1>"
        self.wfile.write(message.encode('utf-8'))

if __name__ == '__main__':
    server_address = ('0.0.0.0', 8081)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
    print("Serving HTTP on 0.0.0.0 port 8081...", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.", flush=True)
        sys.exit(0)
