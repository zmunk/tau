FROM node:24-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates git ripgrep neovim \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent hunkdiff@0.20.1 \
    && chmod +x /usr/local/lib/node_modules/hunkdiff/node_modules/hunkdiff-linux-x64/bin/hunk

ENV EDITOR=nvim

WORKDIR /workspace
ENTRYPOINT ["pi"]
