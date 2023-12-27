package cmd

import "os"

func Run() {
	module := os.Getenv("MODULE")
	output := HandleApply(module)
	HandleSecretUpdate(output)
}
