package main

import (
	log "github.com/Sirupsen/logrus"
	"github.com/acquia/grid-api/grid-cli/commands"
	"github.com/codegangsta/cli"
	"os"
	"runtime"
	"time"
)

var flagGridManifestFile cli.StringFlag = cli.StringFlag{
	Name:  "file, f",
	Value: "grid.yaml",
	Usage: "Grid manifest file to load",
}

var (
	commandList []cli.Command
)

func init() {
	commandList = []cli.Command{
		{
			Name:   "create",
			Usage:  "Create a new job with the specified manifest",
			Action: createHandler(commands.Create),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
		{
			Name:   "update",
			Usage:  "Update a job with a new manifest",
			Action: createHandler(commands.Update),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
		{
			Name:   "restart",
			Usage:  "Restart a currently running job",
			Action: createHandler(commands.Restart),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
		{
			Name:   "terminate",
			Usage:  "Stop a currently running job",
			Action: createHandler(commands.Terminate),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
		{
			Name:   "validate",
			Usage:  "Validate the provided manifest",
			Action: createHandler(commands.Validate),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
		{
			Name:   "bootstrap",
			Usage:  "Creates a sample grid manifest",
			Action: createHandler(commands.Bootstrap),
			Flags: []cli.Flag{
				flagGridManifestFile,
			},
		},
	}
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	app := cli.NewApp()
	app.Name = "ag-cli"
	app.Usage = "Acquia Grid CLI"
	app.Version = "0.1.0"
	app.Compiled = time.Now().UTC()
	app.Before = initCLI
	app.Commands = commandList
	app.Flags = []cli.Flag{
		cli.BoolFlag{
			Name:   "debug, d",
			Usage:  "Enable debug mode",
			EnvVar: "AG_DEBUG",
		},
		cli.StringFlag{
			Name:   "log-level, l",
			Value:  "info",
			Usage:  "Log level (options: debug, info, warn, error, fatal, panic)",
			EnvVar: "AG_LOGLEVEL",
		},
		cli.StringFlag{
			Name:   "host, h",
			Value:  "127.0.0.1",
			Usage:  "Host address",
			EnvVar: "AG_HOST",
		},
		cli.IntFlag{
			Name:   "port, p",
			Value:  2114,
			Usage:  "Port to bind to",
			EnvVar: "AG_PORT",
		},
	}

	// Remove -h help flag so it can be used for --host flag alias
	cli.HelpFlag = cli.BoolFlag{
		Name:  "help",
		Usage: "Show help",
	}

	app.Run(os.Args)
}

func initCLI(context *cli.Context) error {
	// Setup log level before starting the app based on passed in log level flag
	log.SetOutput(os.Stderr)
	level, err := log.ParseLevel(context.GlobalString("log-level"))
	if err != nil {
		log.Fatal(err)
	}
	log.SetLevel(level)

	// If a log level wasn't specified and we are running in debug mode then enforce log-level=debug.
	if !context.IsSet("log-level") && !context.IsSet("l") && context.GlobalBool("debug") {
		log.SetLevel(log.DebugLevel)
	}

	return nil
}

func createHandler(cmd commands.CLICommands) func(context *cli.Context) {
	return func(context *cli.Context) {
		handler(cmd, context)
	}
}

func handler(cmd commands.CLICommands, context *cli.Context) {
	// Get all flags and merge them into one usable Flags map
	flags := map[string]string{}
	for _, flagName := range append(context.FlagNames(), context.GlobalFlagNames()...) {
		flags[flagName] = context.String(flagName)
	}

	options := commands.Options{
		Args:  context.Args(),
		Flags: flags,
		Debug: context.GlobalBool("debug"),
		Host:  context.GlobalString("host"),
		Port:  context.GlobalInt("port"),
	}

	log.Debugf("Options: %+v", options)

	if err := cmd(options); err != nil {
		log.Fatal(err)
		os.Exit(1)
	}
}
