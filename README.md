# VideoViewer]

to release use:

### Build Configuration

VideoViewer uses a Makefile to handle the build process. The Makefile includes various targets for compiling, testing, and installing the project.

#### Key variables:
- **APP_NAME**: The name of the application (video_viewer).
- **PLATFORM**: The platform on which the app is built (Linux or Windows).
- **CC**: The C compiler to use (`gcc`).
- **CFLAGS**: Compiler flags used for warnings, debugging, and include paths.
- **LDFLAGS**: Linker flags for the required libraries.

#### Directories:
- **SRC_DIR**: Directory containing the source files (`src`).
- **BUILD_DIR**: Directory for build artifacts (`build`).
- **BIN_DIR**: Directory for the compiled binaries (`build/bin`).
- **OBJ_DIR**: Directory for object files (`build/obj`).

#### Platforms:
- On **Windows** (MINGW64), the target is compiled as an executable (`.exe`).
- On **Linux** and other Unix-like systems, the target is compiled as a regular binary.

#### Build
make all

#### Release
make version-patch    # For a patch version
make version-minor    # For a minor version
make version-major    # For a major version
make release

#### Local tests
make test

#### Coverage reports
