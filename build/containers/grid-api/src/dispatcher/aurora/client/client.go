package client

import (
	log "github.com/Sirupsen/logrus"
	"github.com/apache/aurora/api"
	"github.com/apache/thrift/lib/go/thrift"
)

type AuroraClient struct {
	Url       string
	Transport thrift.TTransport
	Client    *api.AuroraAdminClient
}

func NewAuroraClient(url string) *AuroraClient {
	transport := NewTRequestsTransport(url)
	protocolFactory := thrift.NewTJSONProtocolFactory()
	client := api.NewAuroraAdminClientFactory(transport, protocolFactory)

	return &AuroraClient{
		Url:       url,
		Transport: transport,
		Client:    client,
	}
}

func (ac *AuroraClient) Connect() (err error) {
	if err = ac.Transport.Open(); err != nil {
		log.Error(err)
		return err
	}

	return nil
}

func (ac *AuroraClient) Close() error {
	if ac.Transport != nil {
		ac.Transport.Close()
	}
	ac.Transport = nil

	return nil
}
