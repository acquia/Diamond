package commands

import (
	"bufio"
	"fmt"
	log "github.com/Sirupsen/logrus"
	"github.com/acquia/grid-api/thrift/manifest"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

func Bootstrap(options Options) error {
	manifestFile := options.Flags["file"]

	if _, err := os.Stat(manifestFile); err == nil {
		consolereader := bufio.NewReader(os.Stdin)
		fmt.Println(fmt.Sprintf("File %s exists. Overwrite? (y/N) ", manifestFile))
		response, err := consolereader.ReadString('\n')

		if err != nil {
			log.Error("Error reading response from user")
			return err
		}

		response = strings.ToLower(strings.TrimSpace(response))

		if !regexp.MustCompile(`^(y|yes)$`).MatchString(response) {
			log.Infof("User canceled bootstrap due to file %s existing", manifestFile)
			return fmt.Errorf("User canceled bootstrap due to file %s existing", manifestFile)
		}
	}

	data := manifest.Manifest{
		Id: &manifest.ManifestID{
			Name:        "example",
			Role:        "www-data",
			Environment: "devel",
		},
		Applications: []*manifest.Application{
			sampleApp("foo", nil),
			sampleApp(
				"bar",
				map[string]string{
					"port": "12345",
				},
			),
		},
	}

	content, err := yaml.Marshal(data)
	if err != nil {
		return err
	}
	log.Debug("Bootstrap manifest: %s", string(content))

	if err := ioutil.WriteFile(manifestFile, content, 0644); err != nil {
		log.Errorf("Error writting manifest to file %s. %+v", manifestFile, err)
		return fmt.Errorf("Error writting manifest to file %s. %+v", manifestFile, err)
	}

	log.Infof("Manifest file created: %s", manifestFile)

	return nil
}

func sampleApp(name string, params map[string]string) *manifest.Application {
	app := &manifest.Application{
		Id: &manifest.AppID{
			Name:        name,
			Role:        "www-data",
			Environment: "dev",
		},
		AppConfig: &manifest.AppConfig{
			AppType:    manifest.AppType_SERVICE,
			SourceType: manifest.AppSourceType_DOCKER,
			Source:     "ubuntu/trusty",
		},
		Resources: &manifest.Resources{
			Cpu: 1.0,
			Ram: 128,
			Disk: &manifest.Disk{
				Size: 10,
			},
		},
		Copies: &manifest.Copies{
			Max: 1,
		},
	}

	if params != nil {
		app.AppConfig.Parameters = params
	}

	return app
}
