FROM elixir:1.3.2
MAINTAINER Gregor Tätzner <gregor@freenet.de>

ENV DEBIAN_FRONTEND=noninteractive

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Install NodeJS 6.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs mariadb-client

# Set /app as workdir
WORKDIR /app

# include dep files
COPY package.json ./
COPY brunch-config.js ./
COPY mix.* ./
# install deps
RUN npm install && \
    mix deps.get && \
    mix deps.compile

# include the project
COPY bin ./bin
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY rel ./rel
COPY test ./test
COPY web ./web

CMD ["bin/run.sh"]
