
import cv2
import copy

def detect_moving_objects(frame, model, backSub, width, height):
    """
    Detects objects only in the moving parts of a video frame.

    Args:
        frame (np.ndarray): The current video frame.
        model: The YOLO object detection model.
        backSub: The background subtractor object.
        width (int): The width of the video frame.
        height (int): The height of the video frame.

    Returns:
        Tuple[np.ndarray, list]: A tuple containing the annotated frame and a list of detection results.
    """
    annotated_frame = frame.copy()
    frame_results = []

    # Use background subtraction to find moving regions
    fgMask = backSub.apply(frame)
    contours, _ = cv2.findContours(fgMask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    for contour in contours:
        # Lowered threshold to detect smaller movements and added padding for context
        if cv2.contourArea(contour) > 100: 
            x, y, w, h = cv2.boundingRect(contour)
            
            # Add padding to the ROI to give the model more context
            padding = 20
            x1 = max(0, x - padding)
            y1 = max(0, y - padding)
            x2 = min(width, x + w + padding)
            y2 = min(height, y + h + padding)

            # Ensure the ROI has a valid size
            if x2 > x1 and y2 > y1:
                roi = frame[y1:y2, x1:x2]
                
                # Run detection on the padded Region of Interest (ROI)
                roi_results = model(roi, verbose=False)

                # Check if any detections were made
                if len(roi_results) > 0 and len(roi_results[0].boxes) > 0:
                    # Deepcopy the results to make them modifiable
                    cloned_results = copy.deepcopy(roi_results[0])
                    
                    # Adjust bounding box coordinates relative to the full frame
                    cloned_results.boxes.xyxy[:, 0] += x1
                    cloned_results.boxes.xyxy[:, 1] += y1
                    cloned_results.boxes.xyxy[:, 2] += x1
                    cloned_results.boxes.xyxy[:, 3] += y1
                    
                    # Add the corrected results to our list for the frame
                    frame_results.append(cloned_results)
    
    # Plot all the corrected bounding boxes onto the frame
    for res in frame_results:
        annotated_frame = res.plot(img=annotated_frame)
        
    return annotated_frame, frame_results
