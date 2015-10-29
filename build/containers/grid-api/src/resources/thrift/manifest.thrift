namespace go thrift.manifest
namespace java com.acquia.grid.api.thrift.manifest
namespace rb acquia.grid.api.thrift.manifest

struct ManifestID {
  1: string name,
  2: string role = "www-data",
  3: string environment = "dev",
}

struct Manifest {
  1: ManifestID id
  2: required list<Application> applications
}

struct Resources {
  1: double cpu
  2: i64 ram
  3: Disk disk
}

struct Disk {
  1: i64 size
}

struct HealthCheck {
  1: double initialIntervalSecs = 15.0
  2: double intervalSecs = 10.0
  3: double timeoutSecs = 1.0
  4: i32 max_consecutiveFailures = 0
  5: string endpoint = "/health"
  6: string expectedResponse = "ok"
  7: i32 expectedResponseCode = 0
}

struct Copies {
  1: i32 max
}

struct ExposedPorts {
 1: map <string, i32> exposedPorts
}

enum AppType {
  TASK = 0,
  SERVICE = 1,
  CRON = 2
}

enum AppSourceType {
  MESOS = 0,
  DOCKER = 1,
  TAR = 2
}

struct AppID {
  1: string name,
  2: string role = "www-data",
  3: string environment = "dev",
}

struct AppConfig {
  1: AppType appType = AppType.SERVICE,
  2: AppSourceType sourceType = AppSourceType.DOCKER,
  3: string source
  4: string command
  5: bool production
  6: optional map<string, string> parameters
  7: optional list<string> env
  8: optional string cronSchedule
}

struct UpdateConfig {
  1: i32 batchSize
  2: i32 failureThreshold
  3: i32 watchSeconds
  4: i32 minWait 
  5: i32 maxWait
  6: bool rollback
  7: bool waitForBatch
}

struct Application {
  1: AppID id,
  2: AppConfig appConfig,
  3: Resources resources,
  4: Copies copies,
  5: optional HealthCheck healthCheck,
  6: optional list<string> exposedPorts,
  7: optional UpdateConfig updateConfig
}
