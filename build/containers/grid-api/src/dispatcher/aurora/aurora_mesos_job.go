package aurora

import (
	"github.com/acquia/grid-api/thrift/manifest"
)

/*
  ### EXAMPLE from the python client:
  {
    "environment": "devel",
    "health_check_config": {
      "initial_interval_secs": 15.0,
      "endpoint": "/health",
      "expected_response_code": 0,
      "expected_response": "ok",
      "max_consecutive_failures": 0,
      "timeout_secs": 1.0,
      "interval_secs": 10.0
    },
    "container": {
      "docker": {
        "parameters": [{"name": "env", "value": "TEST=something"}],
        "networking_mode": "HOST",
        "image": "protochron/hi_aurora",
        "force_pull_image": true,
        "port_mappings": [],
        "privileged": false
      }
    },
    "name": "kevin",
    "service": true,
    "max_task_failures": 1,
    "cron_collision_policy": "KILL_EXISTING",
    "enable_hooks": false,
    "cluster": "dnorris-mesos",
    "task": {
      "processes": [{"daemon": false, "name": "kevin", "ephemeral": false, "max_failures": 1, "min_duration": 5, "cmdline": "redis-server --port {{thermos.ports[http]}}", "final": false}],
      "name": "kevin",
      "finalization_wait": 30,
      "max_failures": 1,
      "max_concurrency": 0,
      "resources": {"disk": 10485760, "ram": 268435456, "cpu": 0.25},
      "constraints": []
    },
    "production": false,
    "role": "www-data",
    "announce": {
      "primary_port": "http",
      "portmap": {"aurora": "http"}
    },
    "lifecycle": {"http": {"graceful_shutdown_endpoint": "/quitquitquit", "port": "health", "shutdown_endpoint": "/abortabortabort"}},
    "priority": 0
  }

*/

type MesosContainer struct {
	Docker MesosDockerContainer `json:"docker"`
}

type MesosDockerContainer struct {
	Parameters     []*MesosDockerParameter `json:"parameters"`
	NetworkingMode string                  `json:"networking_mode"`
	Image          string                  `json:"image"`
	ForcePullImage bool                    `json:"force_pull_image"`
	PortMappings   []int                   `json:"port_mappings"`
	Privileged     bool                    `json:"privileged"`
}

type MesosDockerParameter struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

type MesosProcess struct {
	Cmdline     string `json:"cmdline"`
	Name        string `json:"name"`
	MaxFailures int    `json:"max_failures"`
	Daemon      bool   `json:"daemon"`
	Ephemeral   bool   `json:"ephemeral"`
	MinDuration int    `json:"min_duration"`
	Final       bool   `json:"final"`
}

type MesosResources struct {
	Disk int64   `json:"disk"`
	Ram  int64   `json:"ram"`
	Cpu  float64 `json:"cpu"`
}

type MesosTask struct {
	Name             string          `json:"name"`
	Processes        []*MesosProcess `json:"processes"`
	Constraints      []*string       `json:"constraints"`
	Resources        *MesosResources `json:"resources"`
	MaxFailures      int             `json:"max_failures"`
	MaxConcurrency   int             `json:"max_concurrency"`
	FinalizationWait int             `json:"finalization_wait"`
	//User             string `json:"user"`
}

type MesosAnnounce struct {
	PrimaryPort string            `json:"primary_port"`
	Portmap     map[string]string `json:"portmap"`
}

type MesosJob struct {
	Name string `json:"name"`
	Role string `json:"role"` // REQD
	//Contact     string    `json:"contact"`
	//Cluster     string `json:"cluster"`     // REQD
	Environment string `json:"environment"` // REQD
	//Instances   int       `json:"instances"`
	Task     *MesosTask     `json:"task"`     // REQD
	Announce *MesosAnnounce `json:"announce"` // @todo make an announcer?
	//Tier                string `json:"tier"`
	//CronSchedule        string `json:"cron_schedule"`
	CronCollisionPolicy string `json:"cron_collision_policy"`
	//UpdateConfig        UpdateConfig `json:"update_config"` // @todo make an updateconfig?
	Service         bool                  `json:"service"`
	MaxTaskFailures int                   `json:"max_task_failures"`
	Production      *bool                 `json:"production"`
	Priority        int                   `json:"priority"`
	HealthCheck     *manifest.HealthCheck `json:"health_check_config"`
	//Lifecycle           LifeCycleConfig `json:"lifecycle"` // @todo make a lifecycleconfig
	//TaskLinks   map[string]string `json:"task_links"`
	EnableHooks bool            `json:"enable_hooks"`
	Container   *MesosContainer `json:"container"` // @todo connect to thrift?
}
