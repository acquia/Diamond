# Architecture Overview

The grid-cli, grid-api and the remote scheduler (Aurora) communicate using Thrift. All cli commands call Thrift endpoints in the api, which in turn call Thrift endpoints in the remote scheduler. The cli and api communicate using a manifest which describes the job you wish the scheduler to run. This is the "Acquia language" so to speak. When the manifest is received by the api, it is translated into scheduler actions which are then sent to the remote scheduler.

## Thrift

There are three IDLs that you need to be aware of:
1. The api (resources/thrift/api.thrift)
  - describes the api endpoints
2. The manifest (resources/thrift/manifest.thrift)
  - describes the job manifest options
3. The Aurora api (resources/aurora/thrift/api.thrift)
  - describes the aurora scheduler options

Since the Aurora project uses a custom Thrift transport server (Finagle), we needed to implement a corresponding client. The Finagle server simply accepts standard HTTP requests and routes them to the appropriate endpoints. Thus, the Thrift JSON protocol is still valid, but we need to send the entire string in a post body. The thrift implementation is in dispatcher/aurora/transport.go. For session handling with the custom transport, we chose the [napping library](https://github.com/jmcvetta/napping) because it is simple and it works.

The Aurora Thrift IDL requires a few modifications for golang compatibility. There are issues with Thrift union types and golang structs. Golang does not allow nils for non-pointer values, so the client will include "empty" values and confuse the server. For example, a union should only send one value, so the JSON protocol will expect the message to end, but receive a "," instead of a "}". We also needed to make several values optional, namely for the TaskQuery type. For similar reasons, golang will include "empty" values, but the values are meaningful to the Aurora QueryBuilder api. Before updating the aurora api IDL, please compare with the version we maintain (resources/aurora/thrift/api.thrift).

There is one field that is very complicated to construct. In a TaskConfig object it accepts an ExecutorConfig which contains a Name and a Data value. After watching how the python client behaves we realized that it was serializing a python object and using those contents in the Data property. The behavior is undocumented, so we had to reverse engineer the data by using the python client in verbose mode. See /dispatcher/aurora/aurora_mesos_job.go for the MesosJob struct which we marshal as the value. There is also an example of the data sent from the python client as a comment.
