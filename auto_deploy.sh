#!/bin/bash
## 컨테이너 포트 설정
HOST_PORT="8080"
CONTAINER_PORT="8080"
## app 홈디렉토리(log 및 heapdump 디렉토리 생성 위치):생성되어 있어야 함.
APP_HOME="/home/azureuser/apps"
## 이미지 Tag
VERSION="v1"
# 프로파일 이름(ex:stage,dev,pro)
SPRING_PROFILE="production"

# 배포할 파일 생성 유무 확인
check_app()
{
  if [[ -f ${APP_HOME}/${DEPLOY_FILE} ]];then
    return 0
  else
    echo "Deploy file or directory Dose not exist in $APP_HOME"
    exit 1
  fi
}

# 대문자 파일 이름을 소문자로 변경(docker tag를 실행하려면 파일명이 소문자여야만 한다.)
to_lowercase() {
  local input="$([[ -p /dev/stdin ]] && cat - || echo "$@")"
  [[ -z "$input" ]] && return 1
  echo "$input" | tr '[:upper:]' '[:lower:]'
}

variable_func()
{
# 파일명에서 확장자를 제거한 문자열을 서비스 이름으로 사용.
  SERVICE_NAME=$(echo ${DEPLOY_FILE%.*})
# 도커 이미지 이름
  IMAGE_NAME="${SERVICE_NAME}-${SPRING_PROFILE}"
# 도커 관련 변수
  CONTAINER_ID=$(docker ps -af ancestor=${IMAGE_NAME}:${VERSION} --format "{{.ID}}")
  IMAGE_ID=$(docker images -f=reference=${IMAGE_NAME}':*' --format "{{.ID}}")
}

# 대문자 deploy 파일을 소문자로 변경
lowercase_deploy_file()
{
  DEPLOY_FILE=$(basename $APP_HOME/*.jar)         # app 파일명 추출
  local FILE=$(to_lowercase $DEPLOY_FILE)         # 파일명을 소문자로 변경
  if [[ $FILE != $DEPLOY_FILE ]];then             # 소문자로 변경한 파일과 원래 배포하려는 파일이 동일한지 비교
    mv $DEPLOY_FILE $(to_lowercase $DEPLOY_FILE)  # 파일이 대문자이면 소문자로 변경
    DEPLOY_FILE=$(basename $APP_HOME/*.jar)       # 변경된 파일을 $DEPLOY_FILE 변수에 저장
    variable_func
  else
    variable_func
  fi
}

# old 버전의 deploy 파일이 있으면 삭제
remove_old_file()
{
  OLD_FILE=$(ls -1 ${APP_HOME}/${SERVICE_NAME}*.jar 2> /dev/null | grep -v "$DEPLOY_FILE")            # 디렉토리의 파일 이름 목록을 배열에 저장 (ls -1)
  OLD_FILE_COUNT=$(ls ${APP_HOME}/${SERVICE_NAME}*.jar 2> /dev/null | grep -v "$DEPLOY_FILE" | wc -l) # old 파일 개수 확인
  if [[ -n $OLD_FILE ]] && [[ $OLD_FILE_COUNT -gt 0 ]];then
    echo "OLD_FILE_COUNT=$OLD_FILE_COUNT"
    echo "remove old version"
    for array in "${OLD_FILE[@]}"
    do
      echo "$array"
      rm $array
    done
  fi
}

# 실행 중인 컨테이너를 stop하고 delete한다.
docker_conainer_stop_remove()
{
  if [ $CONTAINER_ID ];then
    docker stop $CONTAINER_ID
    echo "docker rm $CONTAINER_ID"
    docker rm $CONTAINER_ID
  fi
}

# 기존 생성된 이미지 삭제
docker_image_remove()
{
  if [ $IMAGE_ID ];then
    echo "docker rmi -f $IMAGE_ID"
    docker rmi -f $IMAGE_ID
  fi
}

# 도커 이미지 빌드
docker_image_build()
{
  echo "Docker build"
  docker build --build-arg DEPLOY_FILE="${DEPLOY_FILE}" \
    --build-arg DEPLOY_FILE="${DEPLOY_FILE}" \
    --build-arg SPRING_PROFILE=${SPRING_PROFILE}  \
    --tag ${IMAGE_NAME}:${VERSION} ./
}

# 도커 컨테이너 시작
docker_conainer_start()
{
  echo "Run docker container"
  docker run -itd -p $HOST_PORT:$CONTAINER_PORT \
    # --name ${IMAGE_NAME} \
    --name backend \  # nginx의 proxypass 설정과 맞춤.
    -v $APP_HOME/logs:/logs \
    -v $APP_HOME/heapdump:/heapdump:rw \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ=Asia/Seoul ${IMAGE_NAME}:${VERSION}
}

main()
{
    lowercase_deploy_file && check_app || { echo "[Failed check dir and check app]"; exit 1; }
    cd ${APP_HOME} >& /dev/null || { echo "[Cannot cd to ${APP_HOME}]"; exit 1; }
    remove_old_file || { echo "[Cannot remove old file]"; exit 1; }
    docker_conainer_stop_remove && docker_image_remove || { echo "[cannot stop container and remove image ]"; exit 1; }
    docker_image_build && docker_conainer_start || { echo "[cannot build image and start container ]"; exit 1; }
    rm $DEPLOY_FILE Dockerfile && echo "[ Successfully docker build and run ]"
}

main
