package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func main() {
	file, err := os.Open("data.txt")
	if err != nil {
		fmt.Println(err)
	}

	scanner := bufio.NewScanner(file)
	firstCol := []int{}
	secondCol := []int{}
	for scanner.Scan() {
		line := scanner.Text()
		nums := strings.Fields(line)
		firstNum, _ := strconv.Atoi(nums[0])
		secondNum, _ := strconv.Atoi(nums[1])
		firstCol = append(firstCol, firstNum)
		secondCol = append(secondCol, secondNum)
	}

	slices.Sort(firstCol)
	slices.Sort(secondCol)

	var res int

	for i := 0; i < len(firstCol); i++ {
		x := firstCol[i]
		y := secondCol[i]
		if x > y {
			res += x - y
		} else {
			res += y - x
		}
	}

	fmt.Println(res)

	var res2 int
	for _, x := range firstCol {
		counter := 0
		for _, y := range secondCol {
			if y == x {
				counter++
			}
		}
		res2 += counter * x
	}

	fmt.Println(res2)
}
