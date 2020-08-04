/*
This code takes a UDP video stream and checks for motion

Prerequisites:
- OpenCV installed
- $ ffmpeg -list_devices true -f dshow -i dummy
- $ ffmpeg -f dshow -i video="<camera-name>":audio="<microphone-name>" -preset ultrafast -tune zerolatency -vcodec libx264 -r 10 -b:v 2014k -s 640x480 -acodec aac -ac 2 -ab 128k -ar 44100 -f mpegts -flush_packets 0 udp://localhost:5120?pkt_size=1316

How to:
$ mkdir streamopencv
$ cd streamopencv
$ nano CMakeLists.txt
->
cmake_minimum_required(VERSION 3.16)
project( streamer )
find_package( OpenCV REQUIRED )
add_executable( streamer source.cpp )
target_link_libraries( streamer ${OpenCV_LIBS} )

$ cmake . && cmake --build . && ./streamer
*/

// Source: https://funvision.blogspot.com/2019/12/opencv-web-camera-and-video-streams-in.html
#include <opencv2/opencv.hpp>
#include <opencv2/core/ocl.hpp>
#include <unistd.h>

using namespace cv;
using namespace std;

int main(int argc, char **argv) {
    Mat frame, gray, frameDelta, thresh, firstFrame;
    vector<vector<Point> > cnts;

    // Listen to stream
    VideoCapture vcap("udp://localhost:5120");

    // Init video writer
    int frame_width = vcap.get(CAP_PROP_FRAME_WIDTH);
    int frame_height = vcap.get(CAP_PROP_FRAME_HEIGHT);
    VideoWriter video("out.avi", VideoWriter::fourcc('M','J','P','G'), 10, Size(frame_width, frame_height), true);

    if (!vcap.isOpened()) {
        cout << "Error opening video stream or file" << endl;
        return -1;
    }

    sleep(3);
    vcap >> frame;

    // Convert to grayscale and set the first frame
    cvtColor(frame, firstFrame, COLOR_BGR2GRAY);
    GaussianBlur(firstFrame, firstFrame, Size(21, 21), 0);

    while (!frame.empty()) {
        // Convert to grayscale
        cvtColor(frame, gray, COLOR_BGR2GRAY);
        GaussianBlur(gray, gray, Size(21, 21), 0);

        // Compute difference between first frame and current frame
        absdiff(firstFrame, gray, frameDelta);
        threshold(frameDelta, thresh, 25, 255, THRESH_BINARY);

        dilate(thresh, thresh, Mat(), Point(-1, -1), 2);
        findContours(thresh, cnts, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

        for (int i = 0; i < cnts.size(); i++) {
            int ca = contourArea(cnts[i]);

            cout << ca << endl;

            if (ca < 500) {
                continue;
            }

            cout << "Motion Detected!" << endl;
        }

        video.write(frame);

        if (waitKey(1) == 27) {
            // Exit if ESC is pressed
            break;
        }

	    vcap >> frame;
    }

    return 0;
}