package test

import (
	"os"
	"os/exec"
	"strconv"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

type testEnv struct {
	environment   string
	locationShort string
}

func currentTestEnv() testEnv {
	env := os.Getenv("TEST_ENVIRONMENT")
	if env == "" {
		env = "lab"
	}

	locationShort := os.Getenv("TEST_LOCATION_SHORT")
	if locationShort == "" {
		locationShort = "wus2"
	}

	return testEnv{
		environment:   env,
		locationShort: locationShort,
	}
}

func (e testEnv) resourceGroup(pillar string) string {
	return "rg-" + pillar + "-" + e.environment + "-" + e.locationShort
}

func (e testEnv) vnet(pillar string) string {
	return "vnet-" + pillar + "-" + e.environment + "-" + e.locationShort
}

func (e testEnv) nsg(name string) string {
	return "nsg-" + name + "-" + e.environment + "-" + e.locationShort
}

func azResourceCount(t *testing.T, resourceGroupName string, resourceType string) int {
	t.Helper()

	output, err := exec.Command(
		"az",
		"resource",
		"list",
		"--resource-group", resourceGroupName,
		"--resource-type", resourceType,
		"--query", "length(@)",
		"-o", "tsv",
	).CombinedOutput()
	assert.NoError(t, err, "az resource list failed: %s", string(output))

	count, parseErr := strconv.Atoi(strings.TrimSpace(string(output)))
	assert.NoError(t, parseErr, "az resource list returned a non-numeric count: %s", string(output))
	return count
}

// TestLandingZoneDeployment validates the deployed infrastructure
func TestLandingZoneDeployment(t *testing.T) {
	t.Parallel()
	testNames := currentTestEnv()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	// Test Hub VNet exists
	t.Run("HubVNetExists", func(t *testing.T) {
		resourceGroupName := testNames.resourceGroup("hub")
		vnetName := testNames.vnet("hub")

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Hub VNet should exist")
	})

	// Test Identity VNet exists
	t.Run("IdentityVNetExists", func(t *testing.T) {
		resourceGroupName := testNames.resourceGroup("identity")
		vnetName := testNames.vnet("identity")

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Identity VNet should exist")
	})

	// Test VNet Peering
	t.Run("VNetPeeringConfigured", func(t *testing.T) {
		hubRG := testNames.resourceGroup("hub")
		hubVNet := testNames.vnet("hub")

		vnet, err := azure.GetVirtualNetworkE(hubVNet, hubRG, subscriptionID)
		assert.NoError(t, err)
		assert.NotNil(t, vnet.VirtualNetworkPropertiesFormat, "Hub VNet should include properties")
		assert.NotEmpty(t, vnet.VirtualNetworkPropertiesFormat.VirtualNetworkPeerings, "Hub VNet should have peerings configured")
	})
}

// TestKeyVaultAccessible validates Key Vault is deployed and accessible
func TestKeyVaultAccessible(t *testing.T) {
	t.Parallel()
	testNames := currentTestEnv()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	resourceGroupName := testNames.resourceGroup("shared")

	// Find Key Vault in resource group
	t.Run("KeyVaultExists", func(t *testing.T) {
		keyVaultCount := azResourceCount(t, resourceGroupName, "Microsoft.KeyVault/vaults")
		assert.Greater(t, keyVaultCount, 0, "Key Vault should exist in shared services")
	})
}

// TestNetworkSecurityGroups validates NSGs are properly configured
func TestNetworkSecurityGroups(t *testing.T) {
	t.Parallel()
	testNames := currentTestEnv()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	// Test management subnet has NSG
	t.Run("ManagementNSGExists", func(t *testing.T) {
		resourceGroupName := testNames.resourceGroup("management")
		nsgName := testNames.nsg("jumpbox")

		rules := azure.GetAllNSGRules(t, resourceGroupName, nsgName, subscriptionID)
		assert.NotEmpty(t, rules.SummarizedRules, "Management NSG should exist and return default rules")
	})
}

// TestResourceTags validates all resources have required tags
func TestResourceTags(t *testing.T) {
	t.Parallel()
	testNames := currentTestEnv()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	resourceGroupName := testNames.resourceGroup("hub")

	t.Run("ResourceGroupHasTags", func(t *testing.T) {
		rg := azure.GetAResourceGroup(t, resourceGroupName, subscriptionID)
		assert.NotNil(t, rg.Tags, "Resource group should have tags")

		// Check for required tags
		_, hasEnv := rg.Tags["Environment"]
		assert.True(t, hasEnv, "Resource group should have 'Environment' tag")
	})
}
