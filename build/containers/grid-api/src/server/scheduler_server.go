package server

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	svc "github.com/acquia/grid-api/thrift"
	"github.com/apache/thrift/lib/go/thrift"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type SchedulerServer struct {
	address          string
	handler          *SchedulerHandler
	processor        *svc.SchedulerProcessor
	transport        *thrift.TServerSocket
	transportFactory thrift.TTransportFactory
	protocolFactory  *thrift.TBinaryProtocolFactory
	server           *thrift.TSimpleServer
}

func NewSchedulerServer(host string, port int, remoteHost string, remotePort int) *SchedulerServer {
	addr := fmt.Sprintf("%s:%d", host, port)

	handler := NewSchedulerHandler(remoteHost, remotePort)
	processor := svc.NewSchedulerProcessor(handler)
	transport, err := thrift.NewTServerSocket(addr)

	if err != nil {
		log.Error(err)
	}

	transportFactory := thrift.NewTFramedTransportFactory(thrift.NewTTransportFactory())
	protocolFactory := thrift.NewTBinaryProtocolFactoryDefault()
	server := thrift.NewTSimpleServer4(processor, transport, transportFactory, protocolFactory)

	return &SchedulerServer{
		address:          addr,
		handler:          handler,
		processor:        processor,
		transport:        transport,
		transportFactory: transportFactory,
		protocolFactory:  protocolFactory,
		server:           server,
	}
}

func (s *SchedulerServer) Stop() {
	log.Info("Thrift server shutting down")
	s.server.Stop()
	log.Info("Thrift server stopped")
}

func (s *SchedulerServer) Run() {
	log.Info("Thrift server starting")

	// Setup a singnal handler for ctrl+c events
	go func() {
		for {
			c := make(chan os.Signal)
			signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
			sig := <-c
			log.Infof("Signal %d received", sig)
			s.Stop()
			time.Sleep(time.Second)
			os.Exit(0)
		}
	}()

	log.Infof("Thrift server started on: %s", s.address)
	s.server.Serve()
}
