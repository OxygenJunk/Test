if [[ -n "$GOARCH" && "$GOARCH" != "amd64" ]]; then
  echo "Invalid GOARCH='$GOARCH'." >&2
  exit 1
fi
CMD_DIRS=$(find . -name "cmd" -type d)
WD=$(pwd)
while IFS= read -r line; do
  cd $line
  for d in */ ; do
    cd ./$d
    SERVICE_NAME=${d%?}
    BUILD_DIR=$GITHUB_WORKSPACE/build/$SERVICE_NAME/bin
    mkdir -p $BUILD_DIR
    echo "${GOARCH}"
    go env GOOS GOARCH GOAMD64 CGO_ENABLED
    echo "${GOAMD64}"
    output=$(go build -o $BUILD_DIR -buildvcs=false  . 2>&1) 
    # $? je exit status od zadnje komande sto je go build iznad
    if [[ $? -ne 0 ]]; then # -ne znaci not equal to -- 0 je valjda success za go build uvijek
      payload2='{"text":"'$SERVICE_NAME' Go build failed with error: '$output'"}'
      echo ${payload2}
      # echo ${payload}
      # curl -X POST -H 'Content-type: application/json' --data "$payload" $SLACK_WEBHOOK_URL
      payload=$(
        jq -Rn \
        --arg service "$SERVICE_NAME" \
        --arg output "$output" \
        '{text: ($service + " Go build failed with error: " + $output)} | @json'
      )
      echo ${payload}
      echo "Build failed - ${SERVICE_NAME} - ${output}"
      exit 1
    fi
    echo "Build succeeded - ${SERVICE_NAME}"
    file "$BUILD_DIR"/*
    cd ..
  done
  cd $WD
done <<< "$CMD_DIRS"

# Dynamically find the 'first_puzzle' binary inside the build directory
BINARY_PATH=$(find "$BUILD_DIR" -type f -name "first_puzzle" | head -n 1)

if [ -z "$BINARY_PATH" ]; then
  echo "Error: Could not find first_puzzle binary inside $BUILD_DIR" >&2
  exit 1
fi

echo "=== Found binary at: $BINARY_PATH ==="

# Run the metadata inspection command
go version -m "$BINARY_PATH" | grep -E "GOARCH|GOAMD64|CGO_ENABLED" || echo "Using system defaults"