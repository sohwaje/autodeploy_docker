FROM openjdk:8-jre-alpine

ARG DEPLOY_FILE
ARG SPRING_PROFILE

# variable이 만일 정의가 안되어 있으면 word 부분의 값이 사용된다.
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
