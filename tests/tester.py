#!/usr/bin/python3

from test import Test
from tests import jsonErrors, inputErrors, workingTests

# Returns (testName, successNumber, numberOfTests)
def runTests(tests: list) -> tuple:
    amountOfSuccess = 0
    lenTest = len(tests)
    print(f"#################### {tests[0]} ####################")
    for i in range(1, lenTest):
        currState = tests[i].run(i)
        if (currState == True):
            amountOfSuccess += 1
    print(f"#####################{'#' * len(tests[0])}#####################")
    return (tests[0], amountOfSuccess, lenTest - 1)

def main():
    tests = [jsonErrors, inputErrors, workingTests]
    results = []
    for i in range(0, len(tests)):
        results.append(runTests(tests[i]))
        print("")
    for i in range(0, len(results)):
        print(f"{results[i][0]} : {results[i][1]}/{results[i][2]} " + ("✅" if results[i][1] == results[i][2] else "❌"))

if __name__ == "__main__":
    main()
