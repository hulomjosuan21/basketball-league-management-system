from src import FlaskServer
import os
from dotenv import load_dotenv
from src.extensions import socketio,scheduler
load_dotenv()

port= int(os.getenv("PORT", 5000))

server_instance = FlaskServer()
server = server_instance.init_server()

if __name__ == "__main__":
    # scheduler.start()
    try:
        socketio.run(server, debug=True, port=port, host="0.0.0.0")
    finally:
        # scheduler.shutdown()
        ...