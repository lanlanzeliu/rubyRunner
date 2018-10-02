FROM alpine:3.8

RUN apk update && apk add --no-cache ruby ruby-json ruby-test-unit && mkdir /usr/app

WORKDIR /usr/app

COPY ./runner.rb ./runner.rb
COPY ./run.sh ./run.sh

CMD JSON_SRC="$JSON_SRC" sh ./run.sh
