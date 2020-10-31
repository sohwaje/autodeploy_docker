# 소스 도커 자동적용 및 자동 컨테이너 시작 스크립트
# ./auto_apply.sh

## 배포할 파일(.jar, .war)
DEPLOY_FILE="simplewebserver.jar"

## SERVICE 명(jar 파일 이름 앞자리와 동일해야함)
SERVICE_NAME="simplewebserver"

SPRING_PROFILE="stage"

## 외부에 제공되는 포트
HOST_PORT=80
CONTAINER_PORT=80

## Tag 버전명
VERSION="lts"
## IMAGE 명
IMAGE_NAME="${SERVICE_NAME}-${SPRING_PROFILE}"

## app 파일 위치 및 app 이름
APP_HOME="/home/azureuser/apps"
APP_NAME="${SERVICE_NAME}.jar"

# old 배포 파일 관련 변수
OLD_FILE=$(ls -1 ${APP_HOME}/${SERVICE_NAME}*.jar 2> /dev/null | grep -v "$DEPLOY_FILE") # 디렉토리의 파일 이름 목록을 배열에 저장 (ls -1)
OLD_FILE_COUNT=$(ls ${APP_HOME}/${SERVICE_NAME}*.jar 2> /dev/null | grep -v "$DEPLOY_FILE" | wc -l)

# 도커 관련 변수
CONTAINER_ID=$(docker ps -af ancestor=${IMAGE_NAME}:${VERSION} --format "{{.ID}}")
IMAGE_ID=$(docker images -f=reference=${IMAGE_NAME}':*' --format "{{.ID}}")

# check_param()
# {
#   # 인자값 개수($#) 1보다 작으면, 스크립트 사용법을 출력하고 종료.
#   if [[ "$#" -lt 1 ]]; then
#     echo "Usage: $0 $DEPLOY_FILE"
#     exit 1
#   fi
# }

check_dir()
{
  if [[ ! -d ${APP_HOME} ]];then
    echo "Does not exist ${APP_HOME} ========> Create ${APP_HOME}"
    mkdir -p ${APP_HOME}
  fi
}

check_app()
{
  # 배포할 파일, 배포할 파일의 디렉토리 생성 유무 확인
  if [[ -f ${APP_HOME}/${APP_NAME} ]];then
    return 0
  else
    echo "$DEPLOY_FILE dose not exist in $APP_HOME"
    exit 1
  fi
}

remove_old_file()
{
  # old 버전의 배포 파일이 있으면 삭제한다.
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

docker_conainer_stop_remove()
{
  # 실행 중인 컨테이너를 stop하고 delete한다.
  if [ $CONTAINER_ID ];then
    echo "CONTAINER_ID=$CONTAINER_ID"
    echo "docker stop $CONTAINER_ID"
    docker stop $CONTAINER_ID
    echo "---------------------"
    echo "Docker container remove"
    echo "docker rm $CONTAINER_ID"
    docker rm $CONTAINER_ID
  else
    echo "CONTAINER is Empty pass..."
  fi
}

docker_image_remove()
{
  # 기존 생성된 이미지 삭제
  if [ $IMAGE_ID ];then
    echo "IMAGE_ID=$IMAGE_ID"
    echo "docker rmi -f $IMAGE_ID"
    docker rmi -f $IMAGE_ID
  else
    echo "IMAGE is Empty pass..."
  fi
}

docker_image_build()
{
  echo "Docker build"
  docker build --build-arg APP_NAME="${APP_NAME}" \
    --build-arg DEPLOY_FILE="${DEPLOY_FILE}" \
    --build-arg SPRING_PROFILE=${SPRING_PROFILE}  \
    --tag ${IMAGE_NAME}:${VERSION} ./
}

docker_conainer_start()
{
  echo "Run docker container"
  docker run -itd -p $HOST_PORT:$CONTAINER_PORT \
    --name ${IMAGE_NAME} \
    -v $APP_HOME/logs:/logs \
    -v $APP_HOME/heapdump:/heapdump:rw \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ=Asia/Seoul ${IMAGE_NAME}:${VERSION}
}

main()
{
  # change dir to APP_HOME으로 이동
  if [[ -x $(basename $0) ]];then
    cd ${APP_HOME} >& /dev/null || { echo "[Cannot cd to ${APP_HOME}]"; exit 1; }
    check_dir && check_app || { echo "[Failed check dir and check app]"; exit 1; }
    remove_old_file
    docker_conainer_stop_remove && docker_image_remove || { echo "[cannot stop container and remove image ]"; exit 1; }
    docker_image_build && docker_conainer_start || { echo "[cannot build image and start container ]"; exit 1; }
    rm $DEPLOY_FILE && echo "[ Successfully docker build and run ]"
  else
    echo "failed"
    exit 1
  fi
}

main
