#### Motion Detect

python3 -m venv motion-env  
source motion-env/bin/activate   #activate virtual environment  
pip install opencv-python; pip install tqdm; pip install rich; pip install ultralytics  
python3 motion.py "2025-07-24 08-32-32.mov" ignore-stationary=false


------------



#### RTSP Dev Server
###### Server
docker run -it --rm -p 8554:8554 -v $(pwd)/rtsp-dev-server/mediamtx.yml:/mediamtx.yml bluenviron/mediamtx:latest-ffmpeg

###### Player
ffplay -rtsp_transport tcp rtsp://localhost:8554/stream