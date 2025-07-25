python3 -m venv motion-env

source motion-env/bin/activate   #activate virtual environment

pip install opencv-python; pip install tqdm; pip install rich; pip install ultralytics

python3 motion_detect_people.py "2025-07-24 08-32-32.mov"
