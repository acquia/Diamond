package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	svc "github.com/acquia/grid-api/client"
)

func Create(options Options) error {
	manifestFile := options.Flags["file"]

	manifest, err := LoadManifestFromFile(manifestFile)
	if err != nil {
		log.Errorf("Error loading Manifest from: %s", manifestFile)
		return fmt.Errorf("Error loading Manifest from: %s. %v", manifestFile, err)
	}

	client := svc.NewSchedulerClient(options.Host, options.Port)
	jobInfo, err := client.Create(manifest)

	if err != nil {
		log.Errorf("Error creating Manifest from: %s", manifestFile)
		return fmt.Errorf("Error creating Manifest from: %s. %v", manifestFile, err)
	}

	log.Info("Create complete")
	log.Infof("%+v", jobInfo)

	return nil
}
