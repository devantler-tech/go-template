package example_test

import (
	"testing"

	"github.com/devantler-tech/go-template/pkg/example"
)

func TestGreet(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name  string
		input string
		want  string
	}{
		{name: "named", input: "World", want: "Hello, World!"},
		{name: "empty", input: "", want: "Hello, !"},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			t.Parallel()

			got := example.Greet(testCase.input)
			if got != testCase.want {
				t.Errorf("Greet(%q) = %q, want %q", testCase.input, got, testCase.want)
			}
		})
	}
}
