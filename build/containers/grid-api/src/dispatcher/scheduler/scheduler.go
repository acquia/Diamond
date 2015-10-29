package scheduler

import (
	"github.com/acquia/grid-api/thrift/manifest"
)

// RemoteScheduler defines the interface for all scheduler actions that the
// api is aware of.
type RemoteScheduler interface {
	Create(app *manifest.Application) (*SchedulerResult, error)
	Update(app *manifest.Application) (*SchedulerResult, error)
	Kill(id *manifest.AppID) (*SchedulerResult, error)
	Restart(id *manifest.AppID) (*SchedulerResult, error)
	Validate(jobManifest *manifest.Manifest) (bool, error)
	State(id *manifest.AppID) (*SchedulerResult, error)
}

type MockRemoteScheduler struct{}

func NewMockRemoteScheduler() *MockRemoteScheduler {
	return &MockRemoteScheduler{}
}

func (mrs *MockRemoteScheduler) getMockResult() *SchedulerResult {
	mock_result := NewSchedulerResult()
	mock_result.ExitCode = 0
	mock_result.Output = "Success"
	return mock_result
}

func (mrs *MockRemoteScheduler) Create(app *manifest.Application) (*SchedulerResult, error) {
	return mrs.getMockResult(), nil
}

func (mrs *MockRemoteScheduler) Update(app *manifest.Application) (*SchedulerResult, error) {
	return mrs.getMockResult(), nil
}

func (mrs *MockRemoteScheduler) Kill(id *manifest.AppID) (*SchedulerResult, error) {
	return mrs.getMockResult(), nil
}

func (mrs *MockRemoteScheduler) Restart(id *manifest.AppID) (*SchedulerResult, error) {
	return mrs.getMockResult(), nil
}

func (mrs *MockRemoteScheduler) Validate(jobManifest *manifest.Manifest) (bool, error) {
	return true, nil
}

func (mrs *MockRemoteScheduler) State(id *manifest.AppID) (*SchedulerResult, error) {
	return mrs.getMockResult(), nil
}

// SchedulerConfig is meant to be a generic configuration that can be used to
// configure remote schedulers.
type SchedulerConfig struct {
	RemoteHost string
	RemotePort int
}

// NewSchedulerConfig creates a new SchedulerConfig struct.
func NewSchedulerConfig(remoteHost string, remotePort int) *SchedulerConfig {
	config := SchedulerConfig{
		RemoteHost: remoteHost,
		RemotePort: remotePort,
	}
	return &config
}

// @todo we need meaningful exit codes.
type SchedulerResult struct {
	ExitCode int
	Output   string
}

// NewSchedulerResult creates a new SchedulerResult
func NewSchedulerResult() *SchedulerResult {
	return &SchedulerResult{}
}
