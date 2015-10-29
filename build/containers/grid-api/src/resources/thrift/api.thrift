namespace go thrift
namespace java org.acquia.grid.api.thrift
namespace rb acquia.grid.api.thrift

include "manifest.thrift"

const i32 API_VERSION = 1

struct APIVersion {
  1: required i32 major
}

const APIVersion CURRENT_API_VERSION = { 'major': API_VERSION }

struct JobInfo {
  1: manifest.AppID id
  2: i64 time
  3: string message
}

exception SchedulerError {
  1: i32 code,
  2: string message
}

service Scheduler {
  list<JobInfo> create(1: manifest.Manifest m) throws (1:SchedulerError err),
  list<JobInfo> update(1: manifest.Manifest m) throws (1:SchedulerError err),
  list<JobInfo> terminate(1: manifest.Manifest m) throws (1:SchedulerError err),
  list<JobInfo> restart(1: manifest.Manifest m) throws (1:SchedulerError err),
  bool validate(1: manifest.Manifest m) throws (1:SchedulerError err),
  list<JobInfo> state(1: manifest.Manifest m),
  manifest.Manifest configuration(1: manifest.Manifest m),

  void ping(),
}
