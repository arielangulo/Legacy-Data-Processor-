import http.server
import socketserver
import sys
PORT = int(sys.argv[3]) if len(sys.argv) > 3 else 5000
Handler = http.server.SimpleHTTPRequestHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
	print(f"Serving at port {PORT}")
	httpd.serve_forever()
