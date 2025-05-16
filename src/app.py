from flask import Flask, render_template
from waitress import serve
import socket

# Create a Flask application instance
app = Flask(__name__)

# Define a route for the home page
@app.route('/')
def index():
    hostname = socket.gethostname()  # Get the hostname
    return render_template('index.html', hostname=hostname)

# Run the application
if __name__ == '__main__':
    serve(app, host="0.0.0.0", port=8000)
