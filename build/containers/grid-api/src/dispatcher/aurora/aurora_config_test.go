package aurora_test

import (
	"encoding/json"
	"github.com/acquia/grid-api/dispatcher/aurora"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var config = []byte(`
[{
  "name": "mesos-master-01",
  "zk": "10.0.1.112,10.0.2.54,10.0.0.133",
  "zk_port": 2181,
  "auth_mechanism": "UNAUTHENTICATED",
  "scheduler_zk_path": "/aurora/scheduler/",
  "slave_run_directory": "latest",
  "slave_root": "/mnt/lib/mesos"
}]
`)

var _ = Describe("Aurora Config", func() {
	Describe("JSON Parser", func() {
		var err error
		var node aurora.ServerInfo

		BeforeEach(func() {
			var clusters []aurora.ServerInfo
			json.Unmarshal(config, &clusters)
			node = clusters[0]
		})

		It("should process the scheduler config with no errors", func() {
			Expect(err).NotTo(HaveOccurred())
		})
		It("should contain the correct cluster name", func() {
			Expect(node.Name).To(Equal("mesos-master-01"))
		})
		It("should contain the correct zookeeper endpoints", func() {
			Expect(node.Zk).To(ContainSubstring("10.0.1.112"))
		})

		It("should contain the correct zookeeper port", func() {
			Expect(node.ZkPort).To(Equal(2181))
		})
	})
})
