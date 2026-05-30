// Package example is a minimal, replaceable sample package.
//
// It exists so the template ships one real, tested unit out of the box: a
// newcomer can see the house layout (a package under pkg/ with its test
// alongside) and the table-driven test style. Delete this package and its
// test when you add your own first package.
package example

import "fmt"

// Greet returns a friendly greeting for the given name.
//
// It is deliberately trivial placeholder behaviour — replace it with your own
// package's logic.
func Greet(name string) string {
	return fmt.Sprintf("Hello, %s!", name)
}
