package cmd

import (
	"context"
	"encoding/json"
	"log"

	"github.com/hashicorp/terraform-exec/tfexec"
)

func HandleApply(module string) []byte { // All Errors are Fatal
	execPath := "/bin/terraform"
	workingDir := "/workspace"
	tf, err := tfexec.NewTerraform(workingDir, execPath)
	if err != nil {
		log.Fatalf("error running NewTerraform: %s", err)
	}

	runInit(tf, module)
	runRefresh(tf)
	runApply(tf)

	output, err := tf.Output(context.Background())

	if err != nil {
		log.Fatalf("error getting Output: %s", err)
	}

	result, err := json.Marshal(output)

	if err != nil {
		log.Fatalf("error Converting Json: %s", err)
	}

	return result
}

func runInit(tf *tfexec.Terraform, module string) *tfexec.Terraform {
	tfBackend := tfexec.BackendConfig("/credentials/backend.tf")
	tfModule := tfexec.FromModule(module)
	err := tf.Init(context.Background(), tfModule, tfBackend)
	if err != nil {
		log.Fatalf("error running Init: %s", err)
	}
	return tf
}

func runRefresh(tf *tfexec.Terraform) *tfexec.Terraform {
	tfVars := tfexec.VarFile("/credentials/.tfvars")
	err := tf.Refresh(context.Background(), tfVars)
	if err != nil {
		log.Fatalf("error running Refresh: %s", err)
	}
	return tf
}

func runApply(tf *tfexec.Terraform) *tfexec.Terraform {
	tfVars := tfexec.VarFile("/credentials/.tfvars")
	err := tf.Apply(context.Background(), tfVars)
	if err != nil {
		log.Fatalf("error running Apply: %s", err)
	}
	return tf
}
