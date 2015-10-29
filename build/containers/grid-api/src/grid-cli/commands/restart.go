package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	api "github.com/acquia/grid-api/client"
)

func Restart(options Options) error {
	manifestFile := options.Flags["file"]

	manifest, err := LoadManifestFromFile(manifestFile)
	if err != nil {
		log.Errorf("Error loading Manifest from: %s", manifestFile)
		return fmt.Errorf("Error loading Manifest from: %s. %v", manifestFile, err)
	}

	client := api.NewSchedulerClient(options.Host, options.Port)
	jobInfo, err := client.Restart(manifest)

	if err != nil {
		log.Errorf("Error restarting jobs from: %s", manifestFile)
		return fmt.Errorf("Error restarting jobs from: %s. %v", manifestFile, err)
	}

	log.Info("Restart complete")
	log.Infof("%+v", jobInfo)

	return nil
}
