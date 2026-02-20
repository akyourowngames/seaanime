FROM golang:1.26 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o seanime .

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/seanime /app/seanime
ENV PORT=10000
EXPOSE 10000
CMD ["/app/seanime"]
