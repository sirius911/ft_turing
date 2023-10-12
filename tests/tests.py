from test import Test

jsonErrors = [
    "Machine json errors tests",
    Test(
        description= "Empty json",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Blank input data",
        machinePath="./tests/wrongJsons/empty.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "Not well formated",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Error parsing JSON: Line 2, bytes 3-4:",
        machinePath="./tests/wrongJsons/notWellFormated.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "String in transitions",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Invalid format for transitions field in JSON",
        machinePath="./tests/wrongJsons/stringInTransitions.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "expect to read a char not in an alphabet",
        expCode= 1,
        expResult= "",
        errorStringToFind= "'T' not in alphabet",
        machinePath="./tests/wrongJsons/expectToReadNonAlphabet.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "Empty finals array",
        expCode= 1,
        expResult= "",
        errorStringToFind= "finals is empty",
        machinePath="./tests/wrongJsons/emptyFinals.json",
        inputTape="this_is_an_error"
    ),
    Test(
        description= "Got a finals but not present in states array",
        expCode= 1,
        expResult= "",
        errorStringToFind= "Finals states are not a subset of States list",
        machinePath="./tests/wrongJsons/finalsNotInStates.json",
        inputTape="this_is_an_error"
    ),
]

inputErrors = [
    "Errors in input tests",
    Test(
        description= "Unknown char in input",
        expCode= 1,
        expResult= "",
        errorStringToFind= "an input character is not present in Alphabet",
        machinePath="./machines/yes.json",
        inputTape="ynynynTnnynyyy"
    ),
    Test(
        description= "Empty input",
        expCode= 1,
        expResult= "",
        errorStringToFind= "empty input",
        machinePath="./machines/yes.json",
        inputTape=""
    ),
]

workingTests = [
    "Tests of working machine",
    Test(
        description= "Simpliest functional test",
        expCode= 13,
        expResult= "yyyyyyyyyyyy.........",
        errorStringToFind= "", # Empty because we do not expect this test to fail
        machinePath="./machines/yes.json",
        inputTape="ynynynnynyny"
    ),
]
