# FROM : 기본이 되는 이미지를 사용할 때
# RUN : 명령어 실행
# WORKDIR : working 디렉토리 지정
# ADD : 로컬의 파일을 추가할 때 사용
FROM python:3.6.3-stretch

ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y --no-install-recommends \
    sudo \
    libpam-systemd \
    systemd-sysv \
    dbus-x11 \
    systemd \
    libpq-dev \
    postgresql \
    postgresql-contrib \
    nginx \
    curl \
    openssh-server \
    build-essential \
    openssl \
    zlib1g-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    software-properties-common \
    apt-transport-https \
    libjpeg62-turbo-dev

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer --allow-unauthenticated && \
  rm -rf /var/lib/apt/lists

RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/" >> /etc/apt/sources.list.d/cran.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 6212B7B7931C4BB16280BA1306F90DE5381BA480
RUN apt-get update
RUN apt-get install -y r-base r-base-dev --allow-unauthenticated
RUN R -e "install.packages('dplyr', repos='https://ftp.harukasan.org/CRAN/')"
RUN R -e "install.packages('rjson', repos='https://ftp.harukasan.org/CRAN/')"
RUN R -e "install.packages('statmod', repos='https://ftp.harukasan.org/CRAN/')"
RUN R -e "install.packages('RCurl', repos='https://ftp.harukasan.org/CRAN/')"
RUN R -e "install.packages('jsonlite', repos='https://ftp.harukasan.org/CRAN/')"
RUN R -e "install.packages('h2o', type='source', repos='https://h2o-release.s3.amazonaws.com/h2o/rel-turing/8/R')"

RUN mkdir /lh_prediction
WORKDIR /lh_prediction
ADD . /lh_prediction/
ADD requirements.txt /lh_prediction/
RUN pip install -r requirements.txt

RUN ["chmod", "+x", "./config/gunicorn/gunicorn_start.sh"]
ENTRYPOINT ["bash", "./config/gunicorn/gunicorn_start.sh"]


