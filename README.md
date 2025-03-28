# **Fruit Ripeness Detection Using YOLOv5**

This project uses the YOLOv5 object detection model to detect and classify the ripeness of fruits from uploaded images, videos, or real-time webcam feeds. The application is built using Flask and provides a user-friendly web interface for interacting with the model.

---

## **Table of Contents**
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Project Structure](#project-structure)
5. [Usage](#usage)
6. [API Endpoints](#api-endpoints)
7. [Contributing](#contributing)

---

## **Features**
- **Upload Image**: Detect fruit ripeness from an uploaded image.
- **Upload Video**: Detect fruit ripeness from an uploaded video.
- **Real-Time Webcam**: Use your device's camera for live object detection.
- **YOLOv5 Integration**: Pre-trained YOLOv5 model for accurate object detection.
- **Responsive Web Interface**: A clean and intuitive UI designed using HTML and CSS.

---

## **Prerequisites**
Before running the project, ensure you have the following installed:
- Python 3.8 or higher
- Flask (`pip install flask`)
- PyTorch (`pip install torch torchvision`)
- OpenCV (`pip install opencv-python`)
- Pillow (`pip install pillow`)
- Numpy (`pip install numpy`)

Additionally, download the YOLOv5 repository and pre-trained weights:
```bash
git clone https://github.com/ultralytics/yolov5.git
cd yolov5
pip install -r requirements.txt
```

---

## **Installation**
1. Clone this repository:
   ```bash
   git clone https://github.com/smokinthunder/fruit_detect.git
   cd fruit-ripeness-detection
   ```

2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Place your custom YOLOv5 model weights (`best.pt`) in the root directory of the project.

4. Create the required directories:
   ```bash
   mkdir static/uploads
   mkdir static/results
   ```

5. Run the Flask app:
   ```bash
   python app.py
   ```

6. Open your browser and navigate to `http://127.0.0.1:5000`.

---

## **Project Structure**
```
project/
├── app.py                  # Main Flask application
├── best.pt                 # Custom YOLOv5 model weights
├── static/
│   ├── uploads/            # Uploaded files (images/videos)
│   ├── results/            # Processed results (images/videos)
│   └── style.css           # CSS file for styling
├── templates/
│   ├── index.html          # Home page
│   ├── upload_image.html   # Upload image page
│   ├── upload_video.html   # Upload video page
│   ├── video_feed.html     # Live camera page
│   └── result.html         # Result display page
└── README.md               # This file
```

---

## **Usage**
### **Home Page**
- Access the home page at `http://127.0.0.1:5000`.
- Choose one of the three options:
  - **Upload Image**: Detect fruit ripeness from an image.
  - **Upload Video**: Detect fruit ripeness from a video.
  - **Real-Time Webcam**: Use your webcam for live detection.

### **Upload Image**
1. Navigate to `/upload_image`.
2. Upload an image file (supported formats: `.png`, `.jpg`, `.jpeg`, `.gif`).
3. View the processed image with detections.

### **Upload Video**
1. Navigate to `/upload_video`.
2. Upload a video file (supported format: `.mp4`).
3. View the processed video with detections.

### **Real-Time Webcam**
1. Navigate to `/video_feed`.
2. Allow access to your webcam.
3. View live detections in real-time.

---

## **API Endpoints**
| Endpoint          | Method | Description                                   |
|--------------------|--------|-----------------------------------------------|
| `/`                | GET    | Home page with detection options              |
| `/upload_image`    | POST   | Upload and process an image                   |
| `/upload_video`    | POST   | Upload and process a video                    |
| `/video_feed`      | GET    | Stream live webcam feed with detections       |
| `/uploads/<filename>` | GET | Serve uploaded files (e.g., images/videos)    |

---

## **Contributing**
We welcome contributions to improve this project! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeatureName`).
3. Commit your changes (`git commit -m "Add some feature"`).
4. Push to the branch (`git push origin feature/YourFeatureName`).
5. Open a pull request.

---

## **Acknowledgments**
- Thanks to the [Ultralytics YOLOv5](https://github.com/ultralytics/yolov5) team for their amazing work on the YOLOv5 model.
- Inspired by real-world applications of computer vision in agriculture.

---

## **Contact**
For questions or feedback, feel free to reach out:
- Email: anteshkumarm3@gmail.com
- GitHub: [smokinthunder](https://github.com/smokinthunder/)


