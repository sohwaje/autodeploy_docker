FROM openjdk:8-jre-alpine

# ARG APP_NAME
ARG DEPLOY_FILE
ARG SPRING_PROFILE

# ENV APP_NAME=${APP_NAME:-app.jar}
ENV DEPLOY_FILE=${DEPLOY_FILE:-deploy.jar}
ENV SPRING_PROFILE=${SPRING_PROFILE:-dev}

# TimeZone 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 힙덤프 생성 디렉토리
# RUN mkdir -p /heapdump

ADD ${DEPLOY_FILE} /
ENV JAVA_OPTS=""

RUN echo "DEPLOY_FILE = ${DEPLOY_FILE}"

CMD java -jar "${DEPLOY_FILE}" -Duser.timezone=Asia/Seoul --spring.profiles.active="${SPRING_PROFILE}" -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heapdump
