package main_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"testing"
)

func TestGridCli(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "GridCli Suite")
}
