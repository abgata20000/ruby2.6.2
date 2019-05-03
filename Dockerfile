FROM ubuntu:16.04

MAINTAINER abgata20000

WORKDIR /tmp

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.6.2"
ENV LANG="ja_JP.UTF-8"
ENV LANGUAGE="ja_JP:ja"
ENV TZ="Asia/Tokyo"

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git curl wget libreadline-dev build-essential libssl-dev mysql-client libmysqlclient-dev imagemagick tzdata

# 日本語設定とタイムゾーン設定
RUN apt-get -y install language-pack-ja-base language-pack-ja ibus-mozc
RUN locale-gen ja_JP.UTF-8
RUN echo export LANG=ja_JP.UTF-8 >> ~/.profile
# RUN timedatectl set-timezone Asia/Tokyo
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# rubyとbundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

ENV PATH="$RBENV_ROOT:/bin:/usr/local/rbenv/versions/${ruby_ver}/bin:$PATH"

# rubyとrailsをインストール
RUN . /etc/profile.d/rbenv.sh;rbenv install ${ruby_ver}; rbenv global ${ruby_ver}; rbenv rehash;
RUN . /etc/profile.d/rbenv.sh;gem update --system; gem install bundler; bundle -v;

# chrome をインストール
RUN apt-get install -y libappindicator3-1 libappindicator1 libnss3 fonts-liberation libasound2 libxss1 lsb-release xdg-utils \
            && curl -L -o google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
            && dpkg -i google-chrome.deb \
            && sed -i 's|HERE/chrome\"|HERE/chrome\" --disable-setuid-sandbox|g' /opt/google/chrome/google-chrome \
            && rm google-chrome.deb

# yarnのインストール
RUN apt-get install -y nodejs npm  \
            && ln -s /usr/bin/nodejs /usr/bin/node \
            && npm cache clean \
            && npm install n -g \
            && n stable \
            && ln -sf /usr/local/bin/node /usr/bin/node \
            && node -v \
            && npm install -g yarn \
            && apt-get purge -y nodejs npm

# entrykitのインストール
ENV ENTRYKIT_VERSION 0.4.0

RUN wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && mv entrykit /bin/entrykit \
    && chmod +x /bin/entrykit \
    && entrykit --symlink
    