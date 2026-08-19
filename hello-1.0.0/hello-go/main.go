package main

import (
	"fmt"
	"os"
)

var (
	programName    = "hello_go"
	programVersion = "1.0.0"
)

func printUsage() {
	fmt.Printf("Usage: %s [OPTION]\n", programName)
	fmt.Printf("Print 'Hello, World!' to standard output.\n\n")
	fmt.Printf("  -h, --help         display this help and exit\n")
	fmt.Printf("  -v, -V, --version  output version information and exit\n")
}

func printVersion() {
	fmt.Printf("%s version %s\n", programName, programVersion)
}

func main() {
	for _, arg := range os.Args[1:] {
		switch arg {
		case "-h", "--help":
			printUsage()
			return
		case "-v", "-V", "--version":
			printVersion()
			return
		}
	}

	fmt.Println("Hello, World!")
}
