package main

import (
	"time"

	"github.com/go-vgo/robotgo"
)

func main() {
	for {
		x, y := robotgo.Location()

		robotgo.Move(x+10, y+10)
		time.Sleep(500 * time.Millisecond)
		robotgo.Move(x, y)

		time.Sleep(30 * time.Second)
	}
}
