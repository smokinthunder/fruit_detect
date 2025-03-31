import os
from PIL import Image
import cv2
import numpy as np
import torch
from flask import Flask, render_template, request, redirect, Response, send_from_directory
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Load custom YOLOv5 model
try:
    model = torch.hub.load(
        "yolov5", 
        "custom", 
        path="./best.pt", 
        force_reload=True, 
        source="local"
    )
    model.eval()
    model.conf = 0.7  # Lower confidence threshold for more detections
    model.iou = 0.45
except Exception as e:
    print(f"Error loading model: {e}")
    exit(1)

# Create required directories
os.makedirs('static/uploads', exist_ok=True)
os.makedirs('static/results', exist_ok=True)

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'mp4'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def gen_frames(source=0):
    """Video streaming generator function"""
    cap = cv2.VideoCapture(source)
    try:
        while True:
            success, frame = cap.read()
            if not success:
                break
            else:
                # Convert frame to PIL Image for YOLOv5
                img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                results = model(img, size=640)
                
                # Debugging: Print detections
                print(results.pandas().xyxy[0])
                
                # Render detections and convert back to OpenCV format
                rendered_img = np.squeeze(results.render())
                frame = cv2.cvtColor(rendered_img, cv2.COLOR_RGB2BGR)
                
                ret, buffer = cv2.imencode('.jpg', frame)
                frame = buffer.tobytes()
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
    finally:
        cap.release()

@app.route('/')
def index():
    return render_template('index2.html')

@app.route('/camera')
def camera():
    return Response(
        gen_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame'
    )

@app.route('/video_feed')
def video_feed():
    """Real-time webcam streaming"""

    return render_template('video_feed.html' )
    

@app.route('/upload_image', methods=['GET', 'POST'])
def upload_image():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file and allowed_file(file.filename):
            # Save uploaded file securely
            filename = secure_filename(file.filename)
            filepath = os.path.join('static/uploads', filename)
            file.save(filepath)
            
            try:
                # Process image
                img = Image.open(filepath).convert("RGB")  # Ensure RGB format
                results = model(img, size=640)
                
                # Debugging: Print detections
                print(results.pandas().xyxy[0])
                
                # Render detections
                rendered_img = results.render()
                rendered_img = Image.fromarray(np.squeeze(rendered_img))
                result_path = os.path.join('static/results', filename)
                rendered_img.save(result_path)
                
                return render_template('result.html', result_image=result_path)
            except Exception as e:
                return f"Error processing file: {str(e)}"
        else:
            return "Invalid file type.", 400
    return render_template('upload_image.html')

@app.route('/upload_video', methods=['GET', 'POST'])
def upload_video():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file and allowed_file(file.filename):
            # Save uploaded video securely
            filename = secure_filename(file.filename)
            filepath = os.path.join('static/uploads', filename)
            file.save(filepath)
            
            # Video processing generator
            def generate_video_frames():
                cap = cv2.VideoCapture(filepath)
                try:
                    while True:
                        success, frame = cap.read()
                        if not success:
                            break
                        
                        # Process frame
                        img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                        results = model(img, size=640)
                        
                        # Debugging: Print detections
                        print(results.pandas().xyxy[0])
                        
                        # Render detections and convert back to OpenCV format
                        rendered_img = np.squeeze(results.render())
                        frame = cv2.cvtColor(rendered_img, cv2.COLOR_RGB2BGR)
                        
                        ret, buffer = cv2.imencode('.jpg', frame)
                        frame = buffer.tobytes()
                        yield (b'--frame\r\n'
                               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
                finally:
                    cap.release()
    
            

            return Response(
                generate_video_frames(),
                mimetype='multipart/x-mixed-replace; boundary=frame'
            )
        else:
            return "Invalid file type.", 400
    return render_template('upload_video.html')



@app.route('/uploads/<filename>')
def uploaded_file(filename):
    if not allowed_file(filename):
        return "Invalid file type.", 400
    return send_from_directory('static/uploads', filename)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)