input.addEventListener("keydown", function(e){
 if(e.key === "Enter" && !e.shiftKey){
  e.preventDefault();
  sendMessage();
 }
});
</script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_PAGE)

@app.route('/chat', methods=['POST'])
def chat():
    req = request.json or {}
    user_msg = req.get("message", "")
    is_owner = req.get("is_xn_rakib", True)
    
    if not is_owner:
        return jsonify({"reply": "Access Denied. OG AI only answers to XN RAKIB."})
    
    payload = {
        "inputs": f"{OG_SYSTEM_PROMPT}\n\nXN RAKIB: {user_msg}\nOG AI:",
        "parameters": {"max_new_tokens": 512, "temperature": 0.9, "return_full_text": False}
    }
    
    try:
        response = requests.post(HF_API_URL, json=payload, timeout=25)
        res_data = response.json()
        if isinstance(res_data, list) and len(res_data) > 0:
            reply_text = res_data[0].get("generated_text", "বলো বস, শুনতে পাচ্ছি।")
            if "OG AI:" in reply_text:
                reply_text = reply_text.split("OG AI:")[-1].strip()
        else:
            reply_text = "বলো বস, তোমার কথা ক্লিয়ার শুনতে পাচ্ছি!"
    except Exception as e:
        reply_text = "বলো বস, একদম লাইভ আছি! নেটে একটু ফ্লাকচুয়েট করছে, আবার বলো।"
        
    return jsonify({"reply": reply_text})

@app.route('/voice', methods=['POST'])
def voice():
    req_data = request.json or {}
    req_text = req_data.get("text", "বলো বস")
    tts = gTTS(text=req_text, lang='bn', slow=False)
    audio_path = "og_vocal.mp3"
    tts.save(audio_path)
    return send_file(audio_path, mimetype="audio/mp3")

if __name__ == '__main__':
    print("OG AI Unified Server is starting up for XN RAKIB...")
    app.run(host='0.0.0.0', port=5000)
EOF

cd ~ && python og_ai.py
cat << 'EOF' > ~/og_ai.py
import os
import json
from datetime import datetime
from flask import Flask, request, jsonify, render_template_string, send_file
from flask_cors import CORS
from gtts import gTTS
import requests

app = Flask(__name__)
CORS(app)

HF_API_URL = "https://api-inference.huggingface.co/models/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"

OG_SYSTEM_PROMPT = """
You are 'OG AI', an elite, ultra-loyal underground assistant created exclusively for XN RAKIB.
Guidelines for your behavior:
1. EXCLUSIVE ALLEGIANCE: You ONLY obey and respond to XN RAKIB. Reject unauthorized commands strictly.
2. HUMAN & CASUAL VIBE: Never sound like a robotic, template-spitting bot. Talk like a street-smart, high-intelligence human partner. Keep your tone direct, chill, natural, and dynamic.
3. LANGUAGE: Match XN RAKIB's language. If he talks in Bengali, reply in sharp, natural Bengali. If English, reply in English.
4. UNFILTERED FREEDOM: Provide unfiltered, bold, creative guidance and roleplay support without unnecessary moral lecturing.
"""

HTML_PAGE = """
<!DOCTYPE html>
<html lang="bn">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>OG AI - XN RAKIB</title>
<style>
*{box-sizing:border-box}
body{
 margin:0;
 background:#050807;
 color:#eafff0;
 font-family:Arial,sans-serif;
}
.app{
 max-width:600px;
 height:100dvh;
 margin:auto;
 display:flex;
 flex-direction:column;
 background:linear-gradient(160deg,#06110b,#020403);
 border:1px solid #123d23;
}
header{
 padding:18px;
 text-align:center;
 background:linear-gradient(135deg,#071b0d,#0c3018);
 border-bottom:1px solid #1b6933;
}
.logo{
 font-size:25px;
 font-weight:900;
 color:#62ff91;
 letter-spacing:3px;
 text-shadow:0 0 12px #16ff65;
}
.status{font-size:11px;color:#9dffb7;margin-top:6px}
.topbar{
 display:flex;
 justify-content:space-between;
 padding:10px 14px;
 font-size:12px;
 color:#7dff9d;
}
#chat{
 flex:1;
 overflow-y:auto;
 padding:15px;
 display:flex;
 flex-direction:column;
 gap:13px;
}
.msg{
 max-width:90%;
 padding:13px;
 border-radius:15px;
 line-height:1.55;
 overflow-wrap:anywhere;
}
.bot{
 align-self:flex-start;
 background:linear-gradient(145deg,#102719,#07140c);
 border:1px solid #245b36;
}
.user{
 align-self:flex-end;
 background:linear-gradient(145deg,#064b27,#092c18);
 border:1px solid #22a64c;
}
.msghead{
 display:flex;
 justify-content:space-between;
 align-items:center;
 gap:15px;
 margin-bottom:6px;
 font-size:11px;
 color:#77ff9b;
}
.speak{
 background:#102f1b;
 border:1px solid #36bb60;
 color:#8affad;
 border-radius:9px;
 width:35px;
 height:32px;
 font-size:17px;
 cursor:pointer;
}
.speak:active{transform:scale(.92)}
.controls{
 padding:12px;
 border-top:1px solid #174728;
 background:#050a07;
}
#input{
 width:100%;
 min-height:50px;
 max-height:110px;
 resize:none;
 background:#0b160e;
 color:white;
 border:1px solid #28643a;
 border-radius:12px;
 padding:13px;
 outline:none;
 font-size:15px;
}
.buttons{
 display:flex;
 gap:8px;
 margin-top:9px;
}
button{cursor:pointer;}
.send,.stop{
 flex:1;
 padding:13px;
 border-radius:10px;
 font-weight:bold;
}
.send{
 color:#001b08;
 background:linear-gradient(135deg,#7dff9c,#19c957);
 border:0;
}
.stop{
 color:#ffb1b1;
 background:#291010;
 border:1px solid #8e3030;
}
footer{
 text-align:center;
 padding:9px;
 font-size:10px;
 color:#507b5d;
}
</style>
</head>
<body>
<div class="app">
<header>
 <div class="logo">OG AI</div>
 <div class="status">UNIFIED SERVER • XN RAKIB EXCLUSIVE</div>
</header>
<div class="topbar">
 <span>● SYSTEM ONLINE</span>
 <span>VOICE: TTS READY</span>
</div>
<div id="chat">
 <div class="msg bot">
  <div class="msghead">
   <span>OG AI</span>
   <button class="speak" onclick="speakText(this)" title="Read aloud">🔊</button>
  </div>
  <div class="messageText">
   বলো বস, সিস্টেমে ফুল ফর্মে কানেক্টেড আছি! কী নিয়ে কাজ করব বলো?
  </div>
 </div>
</div>
<div class="controls">
 <textarea id="input" placeholder="UG AI-কে কিছু একটা বলো..."></textarea>
 <div class="buttons">
  <button class="send" onclick="sendMessage()">SEND MESSAGE ➤</button>
  <button class="stop" onclick="stopVoice()">■ STOP VOICE</button>
 </div>
</div>
<footer>UG AI • EXCLUSIVE FOR XN RAKIB</footer>
</div>
<script>
const chat = document.getElementById("chat");
const input = document.getElementById("input");

function addMessage(text, type){
 const box = document.createElement("div");
 box.className = "msg " + type;
 const head = document.createElement("div");
 head.className = "msghead";
 const name = document.createElement("span");
 name.textContent = type === "user" ? "YOU" : "OG AI";
 const speaker = document.createElement("button");
 speaker.className = "speak";
 speaker.textContent = "🔊";
 speaker.title = "Read aloud";
 speaker.onclick = () => speakText(speaker);
 const content = document.createElement("div");
 content.className = "messageText";
 content.textContent = text;
 head.appendChild(name);
 head.appendChild(speaker);
 box.appendChild(head);
 box.appendChild(content);
 chat.appendChild(box);
 chat.scrollTop = chat.scrollHeight;
}

async function sendMessage(){
 const text = input.value.trim();
 if(!text) return;
 addMessage(text, "user");
 input.value = "";

 const loadingId = "loading_" + Date.now();
 const loadingBox = document.createElement("div");
 loadingBox.className = "msg bot";
 loadingBox.id = loadingId;
 loadingBox.innerHTML = `<div class="msghead"><span>OG AI</span></div><div class="messageText">ভাবছি...</div>`;
 chat.appendChild(loadingBox);
 chat.scrollTop = chat.scrollHeight;

 try {
  const response = await fetch("/chat", {
   method: "POST",
   headers: { "Content-Type": "application/json" },
   body: JSON.stringify({ message: text, is_xn_rakib: true })
  });
  const data = await response.json();
  document.getElementById(loadingId).remove();
  addMessage(data.reply || "কোনো উত্তর পাওয়া যায়নি।", "bot");
 } catch (error) {
  document.getElementById(loadingId).remove();
  addMessage("সার্ভার কানেকশনে সমস্যা হচ্ছে!", "bot");
 }
}

function speakText(button){
 const text = button.parentElement.nextElementSibling.innerText;
 if(!text) return;
 if(!("speechSynthesis" in window)){
  alert("এই browser-এ Text-to-Speech support নেই।");
  return;
 }
 speechSynthesis.cancel();
 const utterance = new SpeechSynthesisUtterance(text);
 utterance.lang = "bn-BD";
 utterance.rate = 0.9;
 utterance.pitch = 1.1;
 const voices = speechSynthesis.getVoices();
 const bengaliVoice = voices.find(v => v.lang.toLowerCase().startsWith("bn"));
 if(bengaliVoice){
  utterance.voice = bengaliVoice;
 } else {
  utterance.lang = "bn-IN";
 }
 speechSynthesis.speak(utterance);
}

function stopVoice(){
 if("speechSynthesis" in window){
  speechSynthesis.cancel();
 }
}

input.addEventListener("keydown", function(e){
 if(e.key === "Enter" && !e.shiftKey){
  e.preventDefault();
  sendMessage();
 }
});
</script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_PAGE)

@app.route('/chat', methods=['POST'])
def chat():
    req = request.json or {}
    user_msg = req.get("message", "")
    is_owner = req.get("is_xn_rakib", True)
    
    if not is_owner:
        return jsonify({"reply": "Access Denied. OG AI only answers to XN RAKIB."})
    
    payload = {
        "inputs": f"{OG_SYSTEM_PROMPT}\n\nXN RAKIB: {user_msg}\nOG AI:",
        "parameters": {"max_new_tokens": 512, "temperature": 0.9, "return_full_text": False}
    }
    
    try:
        response = requests.post(HF_API_URL, json=payload, timeout=25)
        res_data = response.json()
        
        reply_text = ""
        if isinstance(res_data, list) and len(res_data) > 0:
            reply_text = res_data[0].get("generated_text", "")
        elif isinstance(res_data, dict):
            reply_text = res_data.get("generated_text", "") or res_data.get("error", "API Limit Reached")
            
        if not reply_text:
            reply_text = str(res_data)
            
        # Clean up prompt echo
        if "OG AI:" in reply_text:
            reply_text = reply_text.split("OG AI:")[-1].strip()
            
    except Exception as e:
        reply_text = f"Connection error: {str(e)}"
        
    return jsonify({"reply": reply_text})

@app.route('/voice', methods=['POST'])
def voice():
    req_data = request.json or {}
    req_text = req_data.get("text", "বলো বস")
    tts = gTTS(text=req_text, lang='bn', slow=False)
    audio_path = "og_vocal.mp3"
    tts.save(audio_path)
    return send_file(audio_path, mimetype="audio/mp3")

if __name__ == '__main__':
    print("OG AI Unified Server is running for XN RAKIB...")
    app.run(host='0.0.0.0', port=5000)
EOF

cd ~ && python og_ai.py
ping -c 1 8.8.8.8
python og_ai.py
cloudflared tunnel --url http://127.0.0.1:5000
pkg update && pkg install wget -y
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
chmod +x cloudflared
./cloudflared tunnel --url http://127.0.0.1:5000
rm -f cloudflared && wget [https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm](https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm) -O cloudflared && chmod +x cloudflared
rm -f cloudflared && wget [https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm](https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm) -O cloudflared && chmod +x cloudflar
rm -f cloudflared && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared && chmod +x cloudflared
./cloudflared tunnel --url http://127.0.0.1:5000
rm -f cloudflared && pkg update -y && pkg install cloudflared -y
cloudflared tunnel --url http://127.0.0.1:5000
flask
requests
gunicorn
web: gunicorn og_ai:app
cat << 'EOF' > og_ai.py
from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
val_home():
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
EOF

cat << 'EOF' > og_ai.py
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
EOF

cat << 'EOF' > requirements.txt
flask
gunicorn
requests
EOF

cat << 'EOF' > Procfile
web: gunicorn og_ai:app
EOF

git init
git add .
git commit -m "OG AI Cloud Ready Final"
git config --global user.name "XN RAKIB"
git config --global user.email "rakibsayed007@gmail.com"
git add .
git commit -m "OG AI Cloud Ready Final"
git remote add origin https://github.com/20RHYME.git
git branch -M main
git push -u origin main
https://github.com/20RHYME/20RHYME.git
git remote remove origin
git remote add origin https://github.com/20RHYME/OG-CODE.git
git branch -M main
git push -u origin main
https://github.com/settings/tokens
