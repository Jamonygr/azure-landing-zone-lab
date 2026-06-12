package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func testEnv(name, fallback string) string {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}
	return value
}

func testNames() (string, string) {
	return testEnv("TEST_ENVIRONMENT", "lab"), testEnv("TEST_LOCATION_SHORT", "wus2")
}

// TestLandingZoneDeployment validates the deployed infrastructure
func TestLandingZoneDeployment(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	environment, locationShort := testNames()

	// Test Hub VNet exists
	t.Run("HubVNetExists", func(t *testing.T) {
		resourceGroupName := "rg-hub-" + environment + "-" + locationShort
		vnetName := "vnet-hub-" + environment + "-" + locationShort

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Hub VNet should exist")
	})

	// Test Identity VNet exists
	t.Run("IdentityVNetExists", func(t *testing.T) {
		resourceGroupName := "rg-identity-" + environment + "-" + locationShort
		vnetName := "vnet-identity-" + environment + "-" + locationShort

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Identity VNet should exist")
	})

	// Test VNet Peering
	t.Run("VNetPeeringConfigured", func(t *testing.T) {
		hubRG := "rg-hub-" + environment + "-" + locationShort
		hubVNet := "vnet-hub-" + environment + "-" + locationShort

		// Check peering exists
		peerings := azure.GetVirtualNetworkPeerings(t, hubVNet, hubRG, subscriptionID)
		assert.NotEmpty(t, peerings, "Hub VNet should have peerings configured")
	})
}

// TestKeyVaultAccessible validates Key Vault is deployed and accessible
func TestKeyVaultAccessible(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	environment, locationShort := testNames()
	resourceGroupName := "rg-shared-" + environment + "-" + locationShort

	// Find Key Vault in resource group
	t.Run("KeyVaultExists", func(t *testing.T) {
		keyVaults := azure.ListKeyVaultsByResourceGroup(t, subscriptionID, resourceGroupName)
		assert.NotEmpty(t, keyVaults, "Key Vault should exist in shared services")
	})
}

// TestNetworkSecurityGroups validates NSGs are properly configured
func TestNetworkSecurityGroups(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	environment, locationShort := testNames()

	// Test management subnet has NSG
	t.Run("ManagementNSGExists", func(t *testing.T) {
		resourceGroupName := "rg-management-" + environment + "-" + locationShort
		nsgName := "nsg-jumpbox-" + environment + "-" + locationShort

		exists := azure.NetworkSecurityGroupExists(t, nsgName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Management NSG should exist")
	})
}

// TestResourceTags validates all resources have required tags
func TestResourceTags(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	environment, locationShort := testNames()
	resourceGroupName := "rg-hub-" + environment + "-" + locationShort

	t.Run("ResourceGroupHasTags", func(t *testing.T) {
		rg := azure.GetResourceGroup(t, resourceGroupName, subscriptionID)
		assert.NotNil(t, rg.Tags, "Resource group should have tags")

		// Check for required tags
		_, hasEnv := rg.Tags["Environment"]
		assert.True(t, hasEnv, "Resource group should have 'Environment' tag")
	})
}
