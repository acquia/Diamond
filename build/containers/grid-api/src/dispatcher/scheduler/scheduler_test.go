package scheduler_test

import (
	"github.com/acquia/grid-api/dispatcher"
	scheduler "github.com/acquia/grid-api/dispatcher/scheduler"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"reflect"
)

var _ = Describe("Scheduler", func() {
	Context("Scheduler types", func() {
		It("should have a complete MockRemoteScheduler", func() {
			mock := scheduler.NewMockRemoteScheduler()
			remote_scheduler_type := reflect.TypeOf((*scheduler.RemoteScheduler)(nil)).Elem()
			mock_type := reflect.TypeOf((*scheduler.MockRemoteScheduler)(nil))
			// Ensure that the mock implements the RemoteScheduler interface.
			Expect(mock_type.Implements(remote_scheduler_type)).Should(BeTrue())

			// Test all of the interface methods.
			mock_manifest := dispatcher.NewMockManifest()
			create_result, _ := mock.Create(mock_manifest.Applications[0])
			Expect(create_result.ExitCode).Should(Equal(0))
			update_result, _ := mock.Update(mock_manifest.Applications[0])
			Expect(update_result.ExitCode).Should(Equal(0))
			kill_result, _ := mock.Kill(mock_manifest.Applications[0].Id)
			Expect(kill_result.ExitCode).Should(Equal(0))
			restart_result, _ := mock.Restart(mock_manifest.Applications[0].Id)
			Expect(restart_result.ExitCode).Should(Equal(0))
			validate_result, _ := mock.Validate(mock_manifest)
			Expect(validate_result).Should(BeTrue())
			state_result, _ := mock.State(mock_manifest.Applications[0].Id)
			Expect(state_result.ExitCode).Should(Equal(0))

		})
		It("should have a complete SchedulerConfig", func() {
			config := scheduler.NewSchedulerConfig("test", 123)
			Expect(reflect.TypeOf(config).String()).Should(Equal("*scheduler.SchedulerConfig"))
			Expect(config.RemoteHost).Should(Equal("test"))
			Expect(config.RemotePort).Should(Equal(123))
		})
		It("should have a complete SchedulerResult", func() {
			result := scheduler.NewSchedulerResult()
			Expect(reflect.TypeOf(result).String()).Should(Equal("*scheduler.SchedulerResult"))
		})
	})
})
