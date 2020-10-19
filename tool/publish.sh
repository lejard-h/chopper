#!/usr/bin/env bash

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

echo -e "\033[1mPKG: ${PKG}\033[22m"
pushd "${PKG}"

mkdir -p .pub-cache

cat <<EOF > ~/.pub-cache/credentials.json
{
  "accessToken":"$accessToken",
  "refreshToken":"$refreshToken",
  "tokenEndpoint":"$tokenEndpoint",
  "scopes": ["https://www.googleapis.com/auth/userinfo.email","openid"],
  "expiration":$expiration
}
EOF

dart pub publish -f