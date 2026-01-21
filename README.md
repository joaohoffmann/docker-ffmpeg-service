# ffmpeg web service API

An web service for converting audio/video files using Nodejs, Express and FFMPEG

## Endpoints

> POST /mp3 - Convert audio file in request body to mp3

> POST /mp4 - Convert video file in request body to mp4

> POST /jpg - Convert image file to jpg

> GET /health - Health check endpoint (returns 'online' status)

> GET /, /readme - Web Service Readme

### /mp3, /m4a

Curl Ex:

> curl -F "file=@input.wav" 127.0.0.1:3000/mp3  > output.mp3

> curl -F "file=@input.m4a" 127.0.0.1:3000/mp3  > output.mp3

> curl -F "file=@input.mov" 127.0.0.1:3000/mp4  > output.mp4

> curl -F "file=@input.mp4" 127.0.0.1:3000/mp4  > output.mp4

> curl -F "file=@input.tiff" 127.0.0.1:3000/jpg  > output.jpg

> curl -F "file=@input.png" 127.0.0.1:3000/jpg  > output.jpg

## Configuration and New Endpoints
You can change the ffmpeg conversion settings or add new endpoints by editing 
the /app/endpoints.js file

## Installation

Requires local Node and FFMPEG installation.

1) Install FFMPEG https://ffmpeg.org/download.html

2) Install node https://nodejs.org/en/download/
Using homebrew:
> $ brew install node

## Dev - Running Local Node.js Web Service

Navigate to project directory and:

Install dependencies:
> $ npm install

Start app:
> $ node app.js

Check for errors with ESLint:
> $ ./node_modules/.bin/eslint .

## Docker Image

The Docker image is built from **Ubuntu 22.04 LTS** as the base image and includes the following components:

### System Libraries and Tools
- **FFmpeg** - Media conversion tool (installed from Ubuntu repositories)
- **Node.js 16.x** - JavaScript runtime (installed via NodeSource)
- **Build tools** - build-essential, python3 (for compiling native npm packages)
- **Utilities** - curl, ca-certificates, gnupg, git

### Node.js Packages
- **fluent-ffmpeg** - Installed globally for FFmpeg integration
- Application dependencies from `package.json` (installed with `--production` flag)

### Security Features
- Runs as non-root user (`appuser`) for improved security
- Health check endpoint configured for container monitoring

The image exposes port 3000 and includes a health check that verifies the `/health` endpoint every 30 seconds.

## Running Local Docker Container

Build Docker Image from Dockerfile with a set image tag. ex: docker-ffmpeg
> $ docker build -t docker-ffmpeg .

Launch Docker Container from Docker Image, exposing port 3000 on localhost only
(Note: The container runs the app on port 3000 internally. You can map it to any available host port.)

> docker run -d \
    --name ffmpeg-service \
    --restart=always \
    -v /storage/tmpfs:/usr/src/app/uploads \
    -p 127.0.0.1:3000:3000 \
    docker-ffmpeg

Launch Docker Container from Docker Image, exposing port 3000 on all IPs
> docker run -p 3000:3000 -d docker-ffmpeg
