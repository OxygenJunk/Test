CMD_DIRS=$(find . -name "cmd" -type d)
WD=$(pwd)
while IFS= read -r line; do
  cd $line
  for d in */ ; do
    cd ./$d
    SERVICE_NAME=${d%?}
    BUILD_DIR=$GITHUB_WORKSPACE/build/$SERVICE_NAME/bin
    mkdir -p $BUILD_DIR
    output=$(go build -o $BUILD_DIR -buildvcs=false  . 2>&1) 
    # $? je exit status od zadnje komande sto je go build iznad
    if [[ $? -ne 0 ]]; then # -ne znaci not equal to -- 0 je valjda success za go build uvijek
    #   payload='{"text":"'$SERVICE_NAME' Go build failed with error: '$output'"}'
    #   curl -X POST -H 'Content-type: application/json' --data "$payload" $SLACK_WEBHOOK_URL
      echo "Build failed - ${SERVICE_NAME} - ${output}"
    #   break 2 # ili exit 1
    fi
    echo "Build succeeded - ${SERVICE_NAME}"
    cd ..
  done
  cd $WD
done <<< "$CMD_DIRS"