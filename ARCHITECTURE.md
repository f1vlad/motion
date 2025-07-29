### High-Level Strategy

The most reliable approach is to decouple the video recording from the file uploading. This creates a more resilient system. If your internet connection or SFTP server goes down, you don't lose recordings; they simply queue up on your local disk and the uploader can catch up later.

1.  **Recorder Process:** A continuous process that connects to the RTSP stream and saves it into video files of a fixed duration (e.g., 1-hour chunks).
2.  **Uploader Process:** A separate process that monitors a directory for new video files. When a new file appears, it uploads it to the SFTP server and, upon success, moves or deletes the local copy.

---

### Component 1: The Recorder (Using `ffmpeg`)

`ffmpeg` is the perfect tool for this. It's highly efficient and can run continuously. The key is to use its `segment` feature to automatically split the stream into manageable file chunks.

**Action:**

You would run a command like this as a background service:

```bash
# First, create a directory to store the recordings
mkdir -p capture

# Run ffmpeg to capture the stream
ffmpeg \
    -rtsp_transport tcp \
    -i "rtsp://your_camera_ip:554/stream" \
    -c copy \
    -f segment \
    -segment_time 3600 \
    -strftime 1 \
    "capture/recording-%Y%m%d-%H%M%S.mp4"
```

**Explanation:**

*   `-rtsp_transport tcp`: Forces `ffmpeg` to use TCP for the RTSP stream, which is generally more reliable over unstable networks than the default UDP.
*   `-i "rtsp://..."`: Your camera's RTSP stream URL.
*   `-c copy`: **This is critical for efficiency.** It tells `ffmpeg` to copy the video and audio streams directly without re-encoding them. This uses almost no CPU, which is ideal for a low-power device.
*   `-f segment`: Enables the segmenter, which splits the output into multiple files.
*   `-segment_time 3600`: Creates a new file every 3600 seconds (1 hour). You can adjust this.
*   `-strftime 1`: This enables timestamping for the filenames, making them unique and easy to sort (e.g., `recording-20250729-143000.mp4`).
*   `"capture/..."`: The output directory and filename pattern.

---

### Component 2: The Uploader (Python Script)

A Python script is ideal for the uploader because it can handle logic, error checking, and retries gracefully. You would need a library for SFTP, like `paramiko` or `pysftp`.

**Proposed Logic for `uploader.py`:**

1.  **Watch a Directory:** Continuously scan the `capture/` directory for `.mp4` files.
2.  **Pick a File:** Select the oldest file that is no longer being written to. (You can check this by seeing if the file's modification time has not changed for a few seconds).
3.  **Connect to SFTP:** Establish a connection to your SFTP server.
4.  **Upload:** Transfer the file.
5.  **Verify & Delete:** After a successful upload, delete the local file to free up space. If the upload fails, log the error and retry later.
6.  **Loop:** Repeat the process.

---

### Component 3: Orchestration

You need to run both the `ffmpeg` command and the `uploader.py` script as persistent background services.

*   **On Linux:** `systemd` is the standard. You would create two service files, one for the recorder and one for the uploader, that automatically start on boot and restart on failure.
*   **On macOS:** `launchd` is the equivalent.
*   **Simple Alternative:** You could use a process manager like `supervisor` which is easy to configure and works on both Linux and macOS.

### Summary: Why this approach is robust

*   **Decoupled:** The recorder and uploader don't directly depend on each other. The local `capture/` directory acts as a buffer.
*   **Resilient:** Network or SFTP server outages won't stop the recording process (as long as you have local disk space).
*   **Efficient:** Using `-c copy` in `ffmpeg` requires minimal CPU resources.
*   **Manageable:** Splitting video into hourly chunks is much easier to handle than a single, massive file.

```