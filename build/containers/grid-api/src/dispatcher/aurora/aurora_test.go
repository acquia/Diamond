package aurora_test

import (
	"fmt"
	"github.com/acquia/grid-api/dispatcher"
	"github.com/acquia/grid-api/dispatcher/aurora"
	"github.com/acquia/grid-api/dispatcher/scheduler"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"reflect"
)

var _ = Describe("Aurora", func() {
	Context("Job processing", func() {
		mock_manifest := dispatcher.NewMockManifest()
		config := scheduler.NewSchedulerConfig("http://localhost", 12345)
		aurora_scheduler := aurora.NewAuroraRemoteScheduler(config)
		It("should provide helpers for commonly used structure", func() {
			job_key := aurora_scheduler.GetJobKey(mock_manifest.Applications[0].Id)
			owner := aurora_scheduler.GetOwner(mock_manifest.Applications[0].Id)
			lock_key := aurora_scheduler.GetLockKey(job_key)
			session_key := aurora_scheduler.GetSessionKey()
			Expect(reflect.TypeOf(job_key).String()).Should(Equal("*api.JobKey"))
			Expect(reflect.TypeOf(lock_key).String()).Should(Equal("*api.LockKey"))
			Expect(reflect.TypeOf(session_key).String()).Should(Equal("*api.SessionKey"))
			Expect(reflect.TypeOf(owner).String()).Should(Equal("*api.Identity"))
			host := "http://localhost"
			port := 12345
			uri := aurora_scheduler.AuroraUri(host, port)
			Expect(uri).Should(Equal(fmt.Sprintf("http://%s:%d/api", host, port)))
		})
		It("should convert a manifest application into a task config.", func() {
			task_config := aurora_scheduler.CreateTaskConfigFromApplication(mock_manifest.Applications[0])
			app := mock_manifest.Applications[0]
			// @todo test all value mappings.
			Expect(task_config.Job.Name).To(Equal(app.Id.Name))
			Expect(task_config.Job.Role).To(Equal(app.Id.Role))
			Expect(task_config.Job.Environment).To(Equal(app.Id.Environment))
			Expect(task_config.Container.Docker.Image).To(Equal(app.AppConfig.Source))
		})
	})
})
