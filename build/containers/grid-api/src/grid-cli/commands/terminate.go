package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	api "github.com/acquia/grid-api/client"
)

func Terminate(options Options) error {
	manifestFile := options.Flags["file"]

	manifest, err := LoadManifestFromFile(manifestFile)
	if err != nil {
		log.Errorf("Error loading Manifest from: %s", manifestFile)
		return fmt.Errorf("Error loading Manifest from: %s. %v", manifestFile, err)
	}

	client := api.NewSchedulerClient(options.Host, options.Port)
	jobInfo, err := client.Terminate(manifest)

	if err != nil {
		log.Errorf("Error terminating Manifest from: %s", manifestFile)
		return fmt.Errorf("Error terminating Manifest from: %s. %v", manifestFile, err)
	}

	log.Info("Terminate complete")
	log.Infof("%+v", jobInfo)

	return nil
}
