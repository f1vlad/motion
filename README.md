#### Motion Detect

python3 -m venv motion-env  
source motion-env/bin/activate   #activate virtual environment  
pip install opencv-python; pip install tqdm; pip install rich; pip install ultralytics  
python3 motion.py "2025-07-24 08-32-32.mov" ignore-stationary=false



#### RTSP Dev Server
###### Server
make start-rtsp-server STREAMS=3


###### Player
make play-all-rtsp-streams
make stop-all-rtsp-streams
make list-all-rtsp-streams



#### Storage Server
cd ./storage-server  
docker compose up -d
ssh surveillanceuser@localhost -p 2222
sftp -P 2222 surveillanceuser:surveillanceuser@localhost



#### Capture and chunk
make start-capture  
make stop-capture  
make status-capture  
make clean-pid  
// ps aux | grep ffmpeg | grep -v grep  
// killall ffmpeg  
