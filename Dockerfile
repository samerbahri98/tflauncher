ARG GO_VERSION=1.21
ARG ALPINE_VERSION=3.19
ARG TERRAFORM_VERSION=1.6

FROM hashicorp/terraform:1.6 as terraform
FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} as build

WORKDIR /app

COPY go.* .

RUN go mod download

COPY main.go cmd ./

COPY --from=terraform /bin/terraform /bin/terraform

RUN go build -o tflauncher

FROM alpine:${ALPINE_VERSION}

COPY --from=terraform /bin/terraform /bin/terraform
COPY --from=build /app/tflauncher /bin/tflauncher

ENTRYPOINT [ "/bin/tflauncher" ]

