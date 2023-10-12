#!/usr/bin/python3

from test import Test

tests = [
    Test(
        description= "Simpliest functional test",
        expCode= 13,
        expResult= "yyyyyyyyyyyy.........",
        errorStringToFind= "", # Empty because we do not expect this test to fail
        machinePath="./machines/yes.json",
        inputTape="ynynynnynyny"
    ),
    Test(
        description= "Empty json",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Blank input data", # Empty because we do not expect this test to fail
        machinePath="./tests/wrongJsons/empty.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "Not well formated",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Error parsing JSON: Line 2, bytes 3-4:", # Empty because we do not expect this test to fail
        machinePath="./tests/wrongJsons/notWellFormated.json",
        inputTape="this_is_an_error"
    ),
]

def main():
    print("---------------------------------------------")
    for i in range(0, len(tests)):
        tests[i].run(i)
        print("---------------------------------------------")

if __name__ == "__main__":
    main()
