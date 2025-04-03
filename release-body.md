Release v0.1.0
🚀 New Features:

    Initial release of VideoViewer for efficient video playback using FFmpeg and SDL2.

    Supports video formats like MP4, AVI, MKV, and more via FFmpeg.

    Hardware-accelerated rendering through SDL2.

🐛 Bug Fixes:

    Resolved minor video playback issues.

    Fixed initial application crash on startup (Windows).

🔧 Improvements:

    Optimized video decoding performance.

    Simplified installation process with fewer dependencies.

🔨 Build Changes:

    Added support for cross-platform compilation (Linux, Windows).

    Integrated coverage reporting in the build process.

    GitHub Actions CI/CD workflow added for automated builds and tests.

🧪 Testing:

    Full unit and integration tests for core video playback functionality.

    Coverage reports are now generated automatically on master branch commits.

📅 Upcoming Features:

    Cross-platform support (macOS and windows) coming soon...

    More video formats and codecs will be added in future releases.

📦 Installation:

    Download the latest release from Releases.

    Extract the archive and install:

tar -xzvf video_viewer.tar.gz
./video_viewer_pkg/install

Run the application:

video_viewer path/to/video.mp4

