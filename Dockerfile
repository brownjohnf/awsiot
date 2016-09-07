FROM resin/raspberrypi3-node:5.7

RUN apt-get update \
  && apt-get install -y \
    fbi \
    imagemagick \
    vim \
    wget \
  && apt-get clean

WORKDIR /usr/src/app

CMD ./prestart.sh && ./start.sh

RUN mkdir -p images \
  && wget "http://placeholdit.imgix.net/~text?txtsize=48&bg=ff0000&txtclr=ffffff&txt=Intercom&w=300&h=400&fm=png&txttrack=0" -O images/intercom.png \
  && wget "http://placeholdit.imgix.net/~text?txtsize=48&bg=ff6600&txtclr=ffffff&txt=Flowdock&w=300&h=400&fm=png&txttrack=0" -O images/flowdock.png \
  && wget "http://placeholdit.imgix.net/~text?txtsize=48&bg=385E0F&txtclr=ffffff&txt=All+clear&w=300&h=400&fm=png&txttrack=0" -O images/allclear.png

COPY package.json package.json

# This installs npm dependencies on the resin.io build server,
# making sure to clean up the artifacts it creates in order to reduce the image size.
RUN JOBS=MAX npm install --production --unsafe-perm \
  && npm cache clean \
  && rm -rf /tmp/*

COPY . ./

