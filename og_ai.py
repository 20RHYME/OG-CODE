from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>OG AI</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { background-color: #0b0b0f; color: #ffffff; font-family: sans-serif; text-align: center; padding-top: 50px; }
            h1 { color: #00ffcc; text-shadow: 0 0 10px rgba(0,255,204,0.5); }
        </style>
    </head>
    <body>
        <h1>OG AI System Online</h1>
        <p>Powered by Cloud & 20RHYME RECORDS</p>
    </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
