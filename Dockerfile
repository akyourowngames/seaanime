FROM node:20 AS webbuilder
WORKDIR /src
COPY . .
RUN cd seanime-web && npm install && npm run build

FROM golang:1.26 AS builder
WORKDIR /app
COPY . .
RUN rm -rf web && mkdir -p web && cp -r /src/seanime-web/out/* web/
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o seanime .

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/seanime /app/seanime
ENV PORT=10000
EXPOSE 10000
CMD ["/bin/sh", "-c", "/app/seanime --host 0.0.0.0 --port ${PORT:-10000}"]
