11.11.2014 QML AR hacking session
=================================

1. Get necessary packages:

  ```
  sudo apt-get install cmake build-essential libv4l-dev
  ```

2. Install Qt 5.3.2 (download from [here](http://download.qt-project.org/official_releases/qt/5.3/5.3.2/qt-opensource-linux-x64-5.3.2.run)):

  ```
  ./qt-opensource-linux-x64-5.3.2.run
  ```

  Note your install path, you'll need it later (most likely `~/Qt5.3.2`).

3. Get, build and install OpenCV:

  ```
  git clone git@github.com:Itseez/opencv.git
  cd opencv
  git checkout 3.0.0-alpha
  mkdir build
  cd build
  cmake .. -DWITH_GSTREAMER=NO -DCMAKE_INSTALL_PREFIX=/usr
  make -j 5
  sudo make install
  ```

4. Get, build and install Chilitags:

  ```
  git clone git@github.com:chili-epfl/chilitags.git
  cd chilitags
  mkdir build
  cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=/usr
  make -j 5
  sudo make install
  ```

5. Get Qimchi:

  ```
  git clone --recursive git@github.com:chili-epfl/qimchi.git
  ```

6. Build and install Qt3D 1.0:

  ```
  cd qimchi/modules/qt3d
  mkdir build
  cd build
  <Qt-install-path>/5.3/gcc_64/bin/qmake ..
  make -j 5
  make install
  ```

7. Build and install qml-cvcamera:

  ```
  cd qimchi/modules/cvcamera
  mkdir build
  cd build
  <Qt-install-path>/5.3/gcc_64/bin/qmake ..
  make -j 5
  make install
  ```

8. Build and install qml-chilitags:

  ```
  cd qimchi/modules/chilitags
  mkdir build
  cd build
  <Qt-install-path>/5.3/gcc_64/bin/qmake ..
  make -j 5
  make install
  ```

9. Build and run samples:

  - Alternative 1, using `qmake` only:

    ```
    cd sample
    mkdir build
    cd build
    <Qt-install-path>/5.3/gcc_64/bin/qmake ..
    make -j 5
    ./sample
    ```

  - Alternative 2, using QtCreator:

    ```
    <Qt-install-path/Tools/QtCreator/bin/qtcreator
    ```

    1. Click `Open Project`
    2. Open sample's `.pro` file
    3. Choose `Desktop Qt 5.3 GCC 64bit` only
    4. Click `Configure Project`
    5. Click run button (green arrow) in the bottom left part

