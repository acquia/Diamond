package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	api "github.com/acquia/grid-api/client"
)

func Validate(options Options) error {
	manifestFile := options.Flags["file"]

	manifest, err := LoadManifestFromFile(manifestFile)
	if err != nil {
		log.Errorf("Error loading Manifest from: %s", manifestFile)
		return fmt.Errorf("Error loading Manifest from: %s. %v", manifestFile, err)
	}

	client := api.NewSchedulerClient(options.Host, options.Port)
	valid, err := client.Validate(manifest)

	if err != nil {
		log.Errorf("Error validating Manifest from: %s", manifestFile)
		return fmt.Errorf("Error validating Manifest from: %s. %v", manifestFile, err)
	}

	log.Infof("%v", valid)

	return nil
}
