if [[ $1 == "" ]]
then
    VER=$(curl https://api.github.com/repos/grafana/k6/releases/latest | grep "tag_name" | awk '{print $2}' | sed 's|[\"\,]*||g')
else
    VER=v$1
fi

echo $VER

echoerr() { echo "$@" 1>&2; }
if [[ ! ":$PATH:" == *":/usr/local/bin:"* ]]; then
    echoerr "Your path is missing /usr/local/bin, you need to add this to use this installer."
    exit 1
fi
if [ "$(uname)" == "Darwin" ]; then
    OS=macos
    COMP=zip
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    OS=linux
    COMP=tar.gz
else
    echoerr "This installer is only supported on Linux and MacOS"
    exit 1
fi

ARCH="$(uname -m)"
if [ "$ARCH" == "x86_64" ]; then
    ARCH=amd64
elif [[ "$ARCH" == aarch* ]]; then
    ARCH=arm
else
    echoerr "unsupported arch: $ARCH"
    exit 1
fi
BIN=k6-$VER-$OS-$ARCH
echo DETECTED OS $OS
echo DETECTED ARCH $ARCH
echo VERSION $VER
echo COMPRESSION $COMP
echo BINARY NAME: $BIN
DOWNLOAD_URL=https://github.com/grafana/k6/releases/download/$VER/$BIN.$COMP

echo "Installing k6 from $DOWNLOAD_URL"

if [ $(command -v curl) ]; then
curl -sL "$DOWNLOAD_URL" -o bundle.$COMP
else
wget -O- "$DOWNLOAD_URL"
fi

if [ "$(uname)" == "Darwin" ]; then
    unzip -o bundle.$COMP
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    tar -xvf bundle.$COMP
else
    echoerr "This installer is only supported on Linux and MacOS"
    exit 1
fi

chmod +x $BIN/k6

echo Cleaning up any existing installation of k6
rm -f $(command -v k6) || true
rm -f /usr/local/bin/k6

echo Installating k6 in /usr/local/bin
mv $BIN/k6 /usr/local/bin/k6

echo Cleaning up temporary files
rm -rf $BIN
rm -rf bundle.$COMP
