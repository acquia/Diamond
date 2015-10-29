package server

import (
	log "github.com/Sirupsen/logrus"
	"github.com/acquia/grid-api/dispatcher"
	"github.com/acquia/grid-api/dispatcher/aurora"
	scheduler "github.com/acquia/grid-api/dispatcher/scheduler"
	"github.com/acquia/grid-api/thrift"
	"github.com/acquia/grid-api/thrift/manifest"
)

type SchedulerHandler struct {
	RemoteScheduler *scheduler.RemoteScheduler
	Config          *scheduler.SchedulerConfig
}

func NewSchedulerHandler(remoteHost string, remotePort int) *SchedulerHandler {
	config := scheduler.NewSchedulerConfig(remoteHost, remotePort)
	return &SchedulerHandler{
		Config: config,
	}
}

func (sh *SchedulerHandler) Create(manifest *manifest.Manifest) ([]*thrift.JobInfo, error) {
	rs := aurora.NewAuroraRemoteScheduler(sh.Config)
	result, err := dispatcher.ProcessManifest(dispatcher.ACTION_CREATE, manifest, sh.Config, rs)
	return result, err
}

func (sh *SchedulerHandler) Update(manifest *manifest.Manifest) ([]*thrift.JobInfo, error) {
	rs := aurora.NewAuroraRemoteScheduler(sh.Config)
	result, err := dispatcher.ProcessManifest(dispatcher.ACTION_UPDATE, manifest, sh.Config, rs)
	return result, err
}

func (sh *SchedulerHandler) Terminate(manifest *manifest.Manifest) ([]*thrift.JobInfo, error) {
	rs := aurora.NewAuroraRemoteScheduler(sh.Config)
	result, err := dispatcher.ProcessManifest(dispatcher.ACTION_KILL, manifest, sh.Config, rs)
	return result, err
}

func (sh *SchedulerHandler) Restart(manifest *manifest.Manifest) ([]*thrift.JobInfo, error) {
	rs := aurora.NewAuroraRemoteScheduler(sh.Config)
	result, err := dispatcher.ProcessManifest(dispatcher.ACTION_RESTART, manifest, sh.Config, rs)
	return result, err
}

func (sh *SchedulerHandler) Validate(manifest *manifest.Manifest) (bool, error) {
	// @todo
	return true, nil
}

func (sh *SchedulerHandler) State(manifest *manifest.Manifest) ([]*thrift.JobInfo, error) {
	rs := aurora.NewAuroraRemoteScheduler(sh.Config)
	result, err := dispatcher.ProcessManifest(dispatcher.ACTION_STATE, manifest, sh.Config, rs)
	return result, err
}

func (sh *SchedulerHandler) Configuration(manifest *manifest.Manifest) (*manifest.Manifest, error) {
	// @todo
	return nil, nil
}

func (sh *SchedulerHandler) Ping() (err error) {
	log.Info("ping")
	return nil
}
