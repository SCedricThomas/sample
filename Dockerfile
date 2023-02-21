FROM golang:1.19

RUN go install github.com/cespare/reflex@latest
ADD . /go/src/github.com/Scalingo/sample-go-gin
WORKDIR /go/src/github.com/Scalingo/sample-go-gin
EXPOSE 3000
RUN go install
CMD /go/bin/sample-go-gin

