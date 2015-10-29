package main

import (
	log "github.com/Sirupsen/logrus"
	"github.com/acquia/grid-api/server"
	"github.com/codegangsta/cli"
	"os"
	"runtime"
	"time"
)

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	app := cli.NewApp()
	app.Name = "ag"
	app.Usage = "Acquia Grid API"
	app.Version = "0.1.0"
	app.Compiled = time.Now().UTC()
	app.Flags = []cli.Flag{
		cli.BoolFlag{
			Name:   "debug, d",
			Usage:  "Enable debug mode",
			EnvVar: "AG_DEBUG",
		},
		cli.StringFlag{
			Name:  "log-level, l",
			Value: "info",
			Usage: "Log level (options: debug, info, warn, error, fatal, panic)",
		},
		cli.StringFlag{
			Name:  "host, h",
			Value: "0.0.0.0",
			Usage: "Host address",
		},
		cli.IntFlag{
			Name:  "port, p",
			Value: 2114,
			Usage: "Port to bind to",
		},
		cli.StringFlag{
			Name:  "remote-host",
			Value: "127.0.0.1",
			Usage: "Remote scheduler host address",
		},
		cli.IntFlag{
			Name:  "remote-port",
			Value: 8081,
			Usage: "Remote scheduler port",
		},
	}

	app.Action = runServer

	// Setup log level before starting the app based on passed in log level flag
	app.Before = func(c *cli.Context) error {
		log.SetOutput(os.Stderr)
		level, err := log.ParseLevel(c.String("log-level"))
		if err != nil {
			log.Fatal(err)
		}
		log.SetLevel(level)

		// If a log level wasn't specified and we are running in debug mode then enforce log-level=debug.
		if !c.IsSet("log-level") && !c.IsSet("l") && c.Bool("debug") {
			log.SetLevel(log.DebugLevel)
		}

		return nil
	}

	// Remove -h help flag so it can be used for --host flag alias
	cli.HelpFlag = cli.BoolFlag{
		Name:  "help",
		Usage: "Show help",
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

func runServer(c *cli.Context) {
	s := server.NewSchedulerServer(c.String("host"), c.Int("port"), c.String("remote-host"), c.Int("remote-port"))
	s.Run()
}
