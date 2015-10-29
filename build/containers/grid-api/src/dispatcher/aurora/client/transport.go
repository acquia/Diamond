package client

import (
	"bytes"
	"fmt"
	log "github.com/Sirupsen/logrus"
	"github.com/apache/thrift/lib/go/thrift"
	"github.com/jmcvetta/napping"
	"io"
	"net/http"
	"os"
	"strconv"
)

type TRequestsTransport struct {
	Url            string
	ResponseBuffer *bytes.Buffer
	RequestBuffer  *bytes.Buffer
	Session        napping.Session
}

func NewTRequestsTransport(url string) *TRequestsTransport {
	return &TRequestsTransport{
		Url:            url,
		ResponseBuffer: nil,
		RequestBuffer:  nil,
		Session:        napping.Session{},
	}
}

func (trans *TRequestsTransport) Close() error {
	if trans.RequestBuffer != nil {
		trans.RequestBuffer.Reset()
	}

	trans.RequestBuffer = nil
	trans.Session = napping.Session{}
	return nil
}

func (trans *TRequestsTransport) Flush() error {
	trans.Session.Header.Set("Content-Type", "application/x-thrift")
	trans.Session.Header.Set("Content-Length", strconv.Itoa(trans.RequestBuffer.Len()))
	log.Debug(fmt.Sprintf("%T", trans.RequestBuffer))

	e := struct {
		Message string
		Errors  []struct {
			Resource string
			Field    string
			Code     string
		}
	}{}
	request := &napping.Request{
		Url:                 trans.Url,
		Method:              "POST",
		Payload:             trans.RequestBuffer,
		RawPayload:          true,
		CaptureResponseBody: true,
		Error:               e,
	}
	resp, err := napping.Send(request)
	log.Debug("RESPONSEBODY %+v", request.ResponseBody)
	log.Debug("RESPONSEBODYERR %+v", err)

	if err != nil {
		return thrift.NewTTransportExceptionFromError(err)
	} else if resp.Status() != http.StatusOK {
		return thrift.NewTTransportException(thrift.UNKNOWN_TRANSPORT_EXCEPTION, "HTTP Response code: "+strconv.Itoa(resp.Status()))
	}
	// @todo error handling
	trans.ResponseBuffer = bytes.NewBuffer(resp.ResponseBody.Bytes())

	return nil
}

func (trans *TRequestsTransport) IsOpen() bool {
	return trans.Session != napping.Session{}
}

func (trans *TRequestsTransport) Open() error {
	trans.Session = napping.Session{
		Header: &http.Header{},
	}

	hostname, _ := os.Hostname()
	trans.Session.Header.Set("Host", hostname)
	trans.Session.Header.Set("User-Agent", "Aurora V2")

	return nil
}

func (trans *TRequestsTransport) Read(buf []byte) (int, error) {
	if trans.ResponseBuffer == nil {
		return 0, thrift.NewTTransportException(thrift.NOT_OPEN, "Response buffer is empty, no request.")
	}

	n, err := trans.ResponseBuffer.Read(buf)
	if n > 0 && (err == nil || err == io.EOF) {
		return n, nil
	}
	return n, thrift.NewTTransportExceptionFromError(err)
}

func (trans *TRequestsTransport) RemainingBytes() uint64 {
	return uint64(trans.ResponseBuffer.Len())
}

func (trans *TRequestsTransport) Write(buf []byte) (int, error) {
	if trans.RequestBuffer == nil {
		trans.RequestBuffer = new(bytes.Buffer)
	}
	log.Debug("tbuf %+v", string(buf))
	log.Debug("wbuf %+v", trans.RequestBuffer)
	n, err := trans.RequestBuffer.Write(buf)
	return n, err
}
