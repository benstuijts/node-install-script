NODEJS_VER=${1}
NODEJS_VERT=$(echo ${NODEJS_VER} | cut -c 2- | cut -d '.' -f1)

NODEJS_NAME="node"
NODEJS_BASE_URL="https://nodejs.org"

if [ $NODEJS_VERT -ge 1 ] && [ $NODEJS_VERT -lt 4 ]
then
  echo "Selecting io.js instead of node.js for this version (>= 1.0.0 < 4.0.0)"
  NODEJS_BASE_URL="https://iojs.org"
  NODEJS_NAME="iojs"
fi

if [ -n "$(arch | grep aarch64)" ]; then
  ARCH="arm64"
elif [ -n "$(arch | grep 64)" ]; then
  ARCH="x64"
elif [ -n "$(arch | grep armv8l)" ]; then
  ARCH="arm64"
elif [ -n "$(arch | grep armv7l)" ]; then
  ARCH="armv7l"
elif [ -n "$(arch | grep armv6l)" ]; then
  ARCH="armv6l"
else
  ARCH="x86"
fi

NODEJS_REMOTE="${NODEJS_BASE_URL}/dist/${NODEJS_VER}/${NODEJS_NAME}-${NODEJS_VER}-linux-${ARCH}.tar.gz"
NODEJS_LOCAL="/tmp/${NODEJS_NAME}-${NODEJS_VER}-linux-${ARCH}.tar.gz"
NODEJS_UNTAR="/tmp/${NODEJS_NAME}-${NODEJS_VER}-linux-${ARCH}"

if [ -n "${NODEJS_VER}" ]; then
  echo "installing ${NODEJS_NAME} as ${NODEJS_NAME} ${NODEJS_VER}..."

  if [ -n "$(which curl 2>/dev/null)" ]; then
    curl -fsSL ${NODEJS_REMOTE} -o ${NODEJS_LOCAL} || echo 'error downloading ${NODEJS_NAME}'
  elif [ -n "$(which wget 2>/dev/null)" ]; then
    wget --quiet ${NODEJS_REMOTE} -O ${NODEJS_LOCAL} || echo 'error downloading ${NODEJS_NAME}'
  else
    echo "'wget' and 'curl' are missing. Please run the following command and try again"
    echo "\tsudo apt-get install --yes curl wget"
    exit 1
  fi

  mkdir -p ${NODEJS_UNTAR}/
  tar xf ${NODEJS_LOCAL} -C ${NODEJS_UNTAR}/ --strip-components=1
  rm ${NODEJS_UNTAR}/{LICENSE,CHANGELOG.md,README.md}
  sudo rsync -a "${NODEJS_UNTAR}/" /usr/local/


  sudo chown -R $(whoami) /usr/local/lib/node_modules/
  sudo chown $(whoami) /usr/local/bin/
fi
