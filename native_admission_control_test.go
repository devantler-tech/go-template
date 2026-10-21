package main_test

import "testing"

// TestNativeAdmissionControl exercises ordinary consumer CI during the gate cutover.
// This temporary validation-only pull request is closed without merging.
func TestNativeAdmissionControl(t *testing.T) {
	t.Parallel()
	t.Fatal("intentional native negative control: required Go validation must reject this failure")
}
