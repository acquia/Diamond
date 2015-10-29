package aurora

import (
	"encoding/json"
	"errors"
	"fmt"
	log "github.com/Sirupsen/logrus"
	"io/ioutil"
	"os"
	"strings"
)

type ServerInfo struct {
	AuthMechanism     string `json:"auth_mechanism"`
	Name              string `json:"name"`
	SchedulerZkPath   string `json:"scheduler_zk_path"`
	SlaveRoot         string `json:"slave_root"`
	SlaveRunDirectory string `json:"slave_run_directory"`
	Zk                string `json:"zk"`
	ZkPort            int    `json:"zk_port"`
}

func ParseConfig() (data *ServerInfo, err error) {
	auroraConfigFile := "/etc/aurora/clusters.json"
	if _, err = os.Stat(auroraConfigFile); err != nil {
		log.Errorf("Scheduler configuration file %s does not exist", auroraConfigFile)
		return nil, errors.New("Scheduler configuration file does not exist")
	}

	file, err := ioutil.ReadFile(auroraConfigFile)
	if err != nil {
		log.Errorf("Error reading scheduler configuration file: %s", auroraConfigFile)
		return nil, errors.New("Error reading scheduler configuration file")
	}

	var clusters []ServerInfo
	err = json.Unmarshal(file, &clusters)

	if err != nil {
		log.Errorf("Error parsing %s. %+v", auroraConfigFile, err)
		return nil, errors.New("Error parsing scheduler configuration file")
	}

	data = &clusters[0]

	return data, nil
}

func ClusterName() (string, error) {
	scheduler_config, err := ParseConfig()

	if err != nil {
		log.Error(err)
		return "", errors.New("Error looking up cluster name")
	}

	return scheduler_config.Name, nil
}

func ZookeeperServers() (string, error) {
	scheduler_config, err := ParseConfig()

	if err != nil {
		log.Error(err)
		return "", errors.New("Error looking up Zookeeper cluster information")
	}

	zk_port := 2181
	var res []string
	for _, val := range strings.Split(scheduler_config.Zk, ",") {
		server := fmt.Sprintf("%s:%d", val, zk_port)
		res = append(res, server)
	}
	zkSevers := strings.Join(res, ",")

	return zkSevers, nil
}
