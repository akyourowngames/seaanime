FROM node:20 AS webbuilder
WORKDIR /src
COPY seanime-web/package*.json ./seanime-web/
RUN cd seanime-web && npm install
COPY . .
RUN cd seanime-web && npm run build

FROM golang:1.26 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN rm -rf web && mkdir -p web && \
  if [ -d /src/seanime-web/dist ]; then cp -r /src/seanime-web/dist/* web/; \
  elif [ -d /src/seanime-web/build ]; then cp -r /src/seanime-web/build/* web/; \
  else echo "No frontend build output found" && exit 1; fi
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o seanime .

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/seanime /app/seanime
ENV PORT=10000
EXPOSE 10000
CMD ["/bin/sh", "-c", "/app/seanime --host 0.0.0.0 --port ${PORT:-10000}"]
