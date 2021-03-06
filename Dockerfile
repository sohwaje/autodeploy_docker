FROM openjdk:8-jre-alpine

ARG DEPLOY_FILE
ARG SPRING_PROFILE

# DEPLOY_FILE이 설정되었다면 사용하고 그렇지 않으면 "deploy.jar"를 사용한다.
ENV DEPLOY_FILE=${DEPLOY_FILE:-deploy.jar}
ENV SPRING_PROFILE=${SPRING_PROFILE:-dev}

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD ${DEPLOY_FILE} /
ENV JAVA_OPTS=""

RUN echo "DEPLOY_FILE = ${DEPLOY_FILE}"

CMD java -jar "${DEPLOY_FILE}" \
  -XX:MaxMetaspaceSize=512m \
  -XX:MetaspaceSize=256m \
  -Xms2048m \
  -Xmx2048m \
  -Duser.timezone=Asia/Seoul \
  --spring.profiles.active="${SPRING_PROFILE}" \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/heapdump
