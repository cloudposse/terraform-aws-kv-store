package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	// Generate a random ID to prevent naming conflicts
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"key_prefix": fmt.Sprintf("/%s", randID),
			"set": map[string]interface{}{
				"mykey": map[string]interface{}{
					"value":     "myval",
					"sensitive": false,
				},
				"mytreekey": map[string]interface{}{
					"key_path":  fmt.Sprintf("/%s/well-known/foo/key1", randID),
					"value":     "key1val",
					"sensitive": false,
				},
				"mytreekey2": map[string]interface{}{
					"key_path":  fmt.Sprintf("/%s/well-known/foo/key2", randID),
					"value":     "key2val",
					"sensitive": false,
				},
				"mytreekey3": map[string]interface{}{
					"key_path":  fmt.Sprintf("/%s/well-known/foo/key3", randID),
					"value":     "key3val",
					"sensitive": false,
				},
			},
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)
	terraform.InitAndApply(t, terraformOptions)

	// Now use a different set of options to test that we can get the values written in the previous step
	tempGetTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
	terraformGetOptions := &terraform.Options{
		TerraformDir: tempGetTestFolder,
		Upgrade:      true,
		VarFiles:     varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"key_prefix": fmt.Sprintf("/%s", randID),
			"get": map[string]interface{}{
				"mykey": map[string]interface{}{},
			},
			"get_by_path": map[string]interface{}{
				"mytreekey": map[string]interface{}{
					"key_path": fmt.Sprintf("/%s/well-known/foo", randID),
				},
			},
		},
	}

	defer cleanup(t, terraformGetOptions, tempGetTestFolder)
	terraform.InitAndApply(t, terraformGetOptions)

	// Run `terraform output` to get the value of an output variable
	values := terraform.OutputMapOfObjects(t, terraformGetOptions, "values")

	// Ensure we get the values back from the k/v store
	assert.Equal(t, "myval", values["mykey"])
	assert.Equal(t, "key1val", values["mytreekey"].(map[string]interface{})[fmt.Sprintf("/%s/well-known/foo/key1", randID)])
	assert.Equal(t, "key2val", values["mytreekey"].(map[string]interface{})[fmt.Sprintf("/%s/well-known/foo/key2", randID)])
	assert.Equal(t, "key3val", values["mytreekey"].(map[string]interface{})[fmt.Sprintf("/%s/well-known/foo/key3", randID)])
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "false",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	results := terraform.InitAndApply(t, terraformOptions)

	// Should complete successfully without creating or changing any resources
	assert.Contains(t, results, "Resources: 0 added, 0 changed, 0 destroyed.")
}
