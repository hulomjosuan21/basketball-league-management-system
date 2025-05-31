from src import FlaskServer
import os
from dotenv import load_dotenv

load_dotenv()

port= int(os.getenv("PORT", 5000))

server_instance = FlaskServer()
server = server_instance.init_server()

if __name__ == "__main__":
    server.run(debug=True,port=port,host="0.0.0.0")