package client

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	svc "github.com/acquia/grid-api/thrift"
	"github.com/acquia/grid-api/thrift/manifest"
	"github.com/apache/thrift/lib/go/thrift"
)

type SchedulerClient struct {
	Host      string
	Port      int
	Transport thrift.TTransport
	Client    *svc.SchedulerClient
}

func NewSchedulerClient(host string, port int) *SchedulerClient {
	addr := fmt.Sprintf("%s:%d", host, port)
	socket, err := thrift.NewTSocket(addr)
	if err != nil {
		log.Error("Error creating scheduler client", err)
		return nil
	}

	transportFactory := thrift.NewTFramedTransportFactory(thrift.NewTTransportFactory())
	protocolFactory := thrift.NewTBinaryProtocolFactoryDefault()
	transport := transportFactory.GetTransport(socket)
	client := svc.NewSchedulerClientFactory(transport, protocolFactory)

	return &SchedulerClient{
		Host:      host,
		Port:      port,
		Transport: transport,
		Client:    client,
	}
}

func (client *SchedulerClient) Connect() (err error) {
	if err = client.Transport.Open(); err != nil {
		log.Error(err)
		return err
	}

	return nil
}

func (client *SchedulerClient) Close() error {
	if client.Transport != nil {
		client.Transport.Close()
	}
	client.Transport = nil

	return nil
}

func (sc *SchedulerClient) Create(manifest *manifest.Manifest) ([]*svc.JobInfo, error) {
	if err := sc.Connect(); err != nil {
		sc.Close()
		return nil, err
	}
	return sc.Client.Create(manifest)
}

func (sc *SchedulerClient) Update(manifest *manifest.Manifest) ([]*svc.JobInfo, error) {
	if err := sc.Connect(); err != nil {
		sc.Close()
		return nil, err
	}
	return sc.Client.Update(manifest)
}

func (sc *SchedulerClient) Restart(manifest *manifest.Manifest) ([]*svc.JobInfo, error) {
	if err := sc.Connect(); err != nil {
		sc.Close()
		return nil, err
	}
	return sc.Client.Restart(manifest)
}

func (sc *SchedulerClient) Terminate(manifest *manifest.Manifest) ([]*svc.JobInfo, error) {
	if err := sc.Connect(); err != nil {
		sc.Close()
		return nil, err
	}
	return sc.Client.Terminate(manifest)
}

func (sc *SchedulerClient) Validate(manifest *manifest.Manifest) (bool, error) {
	if err := sc.Connect(); err != nil {
		sc.Close()
		return false, err
	}
	return sc.Client.Validate(manifest)
}
