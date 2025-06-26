import eventlet
eventlet.monkey_patch()

from src import FlaskServer
import os
from dotenv import load_dotenv
from src.extensions import socketio,scheduler
import socket

load_dotenv()

port= int(os.getenv("PORT", 5000))

def print_access_ips(port):
    localhost_ip = "127.0.0.1"
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        lan_ip = s.getsockname()[0]
        s.close()
    except Exception:
        lan_ip = "Unavailable"

    print(f"🔗 Localhost: http://{localhost_ip}:{port}")
    print(f"🌐 LAN IP:   http://{lan_ip}:{port}")

print_access_ips(port)

server_instance = FlaskServer()
server = server_instance.init_server()

if __name__ == "__main__":
    # scheduler.start()
    try:
        socketio.run(server, debug=True, port=port, host="0.0.0.0")
    finally:
        # scheduler.shutdown()
        ...