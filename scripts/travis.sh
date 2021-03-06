#!/bin/bash
# https://docs.travis-ci.com/user/customizing-the-build/#Implementing-Complex-Build-Steps
set -ev

npm install

if [ "${TRAVIS_MODE}" = "build" ]; then
	npm run lint && npm run build
  # check that hls.js doesn't error if requiring in node
  # see https://github.com/video-dev/hls.js/pull/1642
  node -e 'require("./" + require("./package.json").main)'
elif [ "${TRAVIS_MODE}" = "unitTests" ]; then
	npm run test:unit
elif [ "${TRAVIS_MODE}" = "funcTests" ]; then
	npm run build
	n=0
	maxRetries=1
	until [ $n -ge ${maxRetries} ]
	do
		if [ $n -gt 0 ]; then
			echo "Retrying... Attempt: $((n+1))"
			delay=$((n*60))
			echo "Waiting ${delay} seconds..."
			sleep $delay
		fi
		npm run test:func && break
		n=$[$n+1]
	done
	if [ ${n} = ${maxRetries} ]; then
		exit 1
	fi
else
	echo "Unknown travis mode: ${TRAVIS_MODE}" 1>&2
	exit 1
fi
