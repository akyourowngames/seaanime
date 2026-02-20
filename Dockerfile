FROM golang:1.26 AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Fix embed error: main.go uses //go:embed all:web
RUN mkdir -p web && [ -n "$(ls -A web 2>/dev/null)" ] || echo "<!doctype html><html><body>SeaAnime</body></html>" > web/index.html

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o seanime .

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/seanime /app/seanime
ENV PORT=10000
EXPOSE 10000
CMD ["/bin/sh", "-c", "/app/seanime --host 0.0.0.0 --port ${PORT:-10000}"]
