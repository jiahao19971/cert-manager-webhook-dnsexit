FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS build
WORKDIR /workspace
ARG TARGETOS
ARG TARGETARCH

COPY go.mod go.sum ./
RUN go mod download

# Stage 2: Compile the webhook
FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags '-w -extldflags "-static"' -o ./dnsexit-webhook .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /workspace/dnsexit-webhook /usr/local/bin/dnsexit-webhook
ENTRYPOINT ["/usr/local/bin/dnsexit-webhook"]

