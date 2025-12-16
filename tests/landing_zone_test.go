package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestLandingZoneDeployment validates the deployed infrastructure
func TestLandingZoneDeployment(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set, skipping integration tests")
	}

	// Test Hub VNet exists
	t.Run("HubVNetExists", func(t *testing.T) {
		resourceGroupName := "rg-hub-lab-wus2"
		vnetName := "vnet-hub-lab-wus2"

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Hub VNet should exist")
	})

	// Test Identity VNet exists
	t.Run("IdentityVNetExists", func(t *testing.T) {
		resourceGroupName := "rg-identity-lab-wus2"
		vnetName := "vnet-identity-lab-wus2"

		exists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID)
		assert.True(t, exists, "Identity VNet should exist")
	})

	// Test VNet Peering
	t.Run("VNetPeeringConfigured", func(t *testing.T) {
		hubRG := "rg-hub-lab-wus2"
		hubVNet := "vnet-hub-lab-wus2"

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

	resourceGroupName := "rg-shared-lab-wus2"
	
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

	// Test management subnet has NSG
	t.Run("ManagementNSGExists", func(t *testing.T) {
		resourceGroupName := "rg-management-lab-wus2"
		nsgName := "nsg-management-lab-wus2"

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

	resourceGroupName := "rg-hub-lab-wus2"

	t.Run("ResourceGroupHasTags", func(t *testing.T) {
		rg := azure.GetResourceGroup(t, resourceGroupName, subscriptionID)
		assert.NotNil(t, rg.Tags, "Resource group should have tags")
		
		// Check for required tags
		_, hasEnv := rg.Tags["environment"]
		assert.True(t, hasEnv, "Resource group should have 'environment' tag")
	})
}
