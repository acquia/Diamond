package commands

import (
	"fmt"
	log "github.com/Sirupsen/logrus"
	"github.com/acquia/grid-api/thrift/manifest"
	"gopkg.in/yaml.v2"
	"io/ioutil"
)

type Options struct {
	Args  []string
	Flags map[string]string

	Debug bool
	Host  string
	Port  int
}

type CLICommands func(Options) error

func LoadManifestFromFile(manifestFile string) (data *manifest.Manifest, err error) {
	log.Infof("Parsing Manifest from file: %s", manifestFile)

	contents, err := ioutil.ReadFile(manifestFile)
	if err == nil {
		err = yaml.Unmarshal([]byte(contents), &data)
	}

	if err != nil {
		log.Errorf("Error parsing config: %s. %v", manifestFile, err)
		return nil, fmt.Errorf("Error parsing config: %s", manifestFile)
	}

	return data, nil
}
