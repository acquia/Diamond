package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	api "github.com/acquia/grid-api/client"
)

func Update(options Options) error {
	manifestFile := options.Flags["file"]

	manifest, err := LoadManifestFromFile(manifestFile)
	if err != nil {
		log.Errorf("Error loading Manifest from: %s", manifestFile)
		return fmt.Errorf("Error loading Manifest from: %s. %v", manifestFile, err)
	}

	client := api.NewSchedulerClient(options.Host, options.Port)
	jobInfo, err := client.Update(manifest)

	if err != nil {
		log.Errorf("Error updating Manifest from: %s", manifestFile)
		return fmt.Errorf("Error updating Manifest from: %s. %v", manifestFile, err)
	}

	log.Info("Update complete")
	log.Infof("%+v", jobInfo)

	return nil
}
