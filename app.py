import os
from PIL import Image
import io
import cv2
import numpy as np
import torch
from flask import Flask, render_template, request, redirect, Response, send_from_directory

app = Flask(__name__)

# Load custom YOLOv5 model
model = torch.hub.load(
    "yolov5", 
    "custom", 
    path="./best.pt", 
    force_reload=True, 
    source="local"
)
model.eval()
model.conf = 0.6
model.iou = 0.45

# Create required directories
os.makedirs('static/uploads', exist_ok=True)
os.makedirs('static/results', exist_ok=True)

def gen_frames(source=0):
    """Video streaming generator function"""
    cap = cv2.VideoCapture(source)
    while True:
        success, frame = cap.read()
        if not success:
            break
        else:
            # Convert frame to PIL Image for YOLOv5
            img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            results = model(img, size=640)
            
            # Render detections and convert back to OpenCV format
            rendered_img = np.squeeze(results.render())
            frame = cv2.cvtColor(rendered_img, cv2.COLOR_RGB2BGR)
            
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    """Real-time webcam streaming"""
    return Response(
        gen_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame'
    )

@app.route('/upload_image', methods=['GET', 'POST'])
def upload_image():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file:
            # Save uploaded file
            filename = os.path.join('static/uploads', file.filename)
            file.save(filename)
            
            # Process image
            img = Image.open(filename)
            results = model(img, size=640)
            results.render()
            rendered_img = Image.fromarray(np.squeeze(results.render()))
            result_path = os.path.join('static/results', file.filename)
            rendered_img.save(result_path)
            
            return render_template('result.html', result_image=result_path)
    return render_template('upload_image.html')

@app.route('/upload_video', methods=['GET', 'POST'])
def upload_video():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file:
            # Save uploaded video
            filename = os.path.join('static/uploads', file.filename)
            file.save(filename)
            
            # Video processing generator
            def generate_video_frames():
                cap = cv2.VideoCapture(filename)
                while True:
                    success, frame = cap.read()
                    if not success:
                        break
                    # Process frame (same as webcam)
                    img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                    results = model(img, size=640)
                    rendered_img = np.squeeze(results.render())
                    frame = cv2.cvtColor(rendered_img, cv2.COLOR_RGB2BGR)
                    ret, buffer = cv2.imencode('.jpg', frame)
                    frame = buffer.tobytes()
                    yield (b'--frame\r\n'
                           b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
                cap.release()
            
            return Response(
                generate_video_frames(),
                mimetype='multipart/x-mixed-replace; boundary=frame'
            )
    return render_template('upload_video.html')

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory('static/uploads', filename)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)