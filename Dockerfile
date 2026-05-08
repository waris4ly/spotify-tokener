FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS build

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o spotify-tokener github.com/topi314/spotify-tokener

FROM ghcr.io/chromedp/headless-shell:stable

WORKDIR /app

COPY --from=build /build/spotify-tokener /bin/spotify-tokener

ENV PORT=8080

EXPOSE 8080

CMD sh -c "/bin/spotify-tokener -addr 0.0.0.0:${PORT}"
