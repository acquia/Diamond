package dispatcher_test

import (
	"fmt"
	"github.com/acquia/grid-api/dispatcher"
	scheduler "github.com/acquia/grid-api/dispatcher/scheduler"
	"github.com/acquia/grid-api/thrift"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func matchMockJobInfo(info *thrift.JobInfo) bool {
	match := false
	manifest := dispatcher.NewMockManifest()
	if info.Id.Name == manifest.Applications[0].Id.Name &&
		info.Id.Role == manifest.Applications[0].Id.Role &&
		info.Id.Environment == manifest.Applications[0].Id.Environment &&
		info.Message == "Success" {
		match = true
	}
	return match
}

var _ = Describe("Dispatcher", func() {
	Context("Dispatcher RemoteScheduler functionality", func() {
		config := scheduler.NewSchedulerConfig("http://127.0.0.1", 12345)
		scheduler := scheduler.NewMockRemoteScheduler()
		manifest := dispatcher.NewMockManifest()

		It("should return a JobInfo struct for a create action", func() {
			job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_CREATE, manifest, config, scheduler)
			Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should return a JobInfo struct for a update action", func() {
			job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_UPDATE, manifest, config, scheduler)
			Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should return a JobInfo struct for a kill action", func() {
			job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_KILL, manifest, config, scheduler)
			Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should return a JobInfo struct for a restart action", func() {
			job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_RESTART, manifest, config, scheduler)
			Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should return a JobInfo struct for a validate action", func() {
			// @todo test once the action is completed.
			//job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_VALIDATE, manifest, config, scheduler)
			//Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should return a JobInfo struct for a state action", func() {
			// @todo test once the action is completed.
			//job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_STATE, manifest, config, scheduler)
			//Expect(matchMockJobInfo(job_info[0])).To(BeTrue())
		})
		It("should create an error for an unknown action", func() {
			job_info, _ := dispatcher.ProcessManifest(dispatcher.ACTION_UNKNOWN, manifest, config, scheduler)
			message := fmt.Sprintf("An unknown error occured executing action UNKNOWN")
			Expect(job_info[0].Message).To(Equal(message))
		})
	})
})
