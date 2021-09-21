ARG VERSION=v2.1.1

FROM node:14-alpine as builder

ARG VERSION

RUN apk add -U build-base python3 git

WORKDIR /usr/src/app

RUN git clone --branch $VERSION https://github.com/butlerx/wetty.git /usr/src/app

RUN yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

FROM node:14-alpine as final

WORKDIR /usr/src/app

ENV NODE_ENV=production

COPY --from=builder /usr/src/app/build /usr/src/app/build
COPY --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY --from=builder /usr/src/app/package.json /usr/src/app/package.json

RUN apk add -U coreutils openssh-client sshpass \
 && mkdir ~/.ssh

EXPOSE 3000

ENTRYPOINT [ "node" , "." ]