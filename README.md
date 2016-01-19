# Audio-Normalize
This script will convert Video files (flv, mov, avi, mp4, wmv)
relative to it as mp4 files and normalize the audio in range of -5.7 to -6.3


###Requirements
---------------

Needs to have ffmpeg installed with the faac libraries

```sh
  brew install ffmpeg --with-fdk-aac --with-ffplay --with-freetype --with-libass --with-libquvi --with-libvorbis --with-libvpx --with-opus --with-x265
```

Change the permission of the normalizer.command

```sh
  chmod a+x normalizr.command
```
