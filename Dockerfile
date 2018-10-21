FROM node:8.12-alpine


COPY index.js /src/index.js

WORKDIR /src

CMD ["node", "index.js", "30"]
