from tools import getOutputStr
from tools import getResultTape
from tools import getReturnCode, runTuring
from termcolor import colored

class Test:
    description = ""
    expCode = 0 # Expected code
    expResult = "" # Expected final tape
    errorStringToFind = "" # String to find if the expCode is 1
    machinePath = ""
    inputTape = ""

    def __init__(self, description: str, expCode: int, expResult: str, errorStringToFind: str, machinePath: str, inputTape: str) -> None:
        self.description = description
        self.expCode = expCode
        self.expResult = expResult
        self.errorStringToFind = errorStringToFind
        self.machinePath = machinePath
        self.inputTape = inputTape
        return

    def retCodeCompare(self, programOutput) -> bool:
        return self.expCode == getReturnCode(programOutput)

    def resultCompare(self, programOutput) -> bool:
        return self.expResult == getResultTape(programOutput)

    def isErrorMsgFound(self, programOutput) -> bool:
        outputStr = getOutputStr(programOutput)
        return outputStr.find(self.errorStringToFind) != -1

    def run(self, index: int) -> None:
        programOutput = runTuring(self.machinePath, self.inputTape)
        isSuccess = None
        if (self.expCode == 1):
            isSuccess = (
                self.retCodeCompare(programOutput) and
                self.isErrorMsgFound(programOutput)
            )
        else:
            isSuccess = (
                self.retCodeCompare(programOutput) and
                self.resultCompare(programOutput)
            )
        if (isSuccess == True):
            print(f"Test [{self.description}] {index} : {colored('Success', 'green')}")
        elif (isSuccess == False):
            if (self.expCode == 1):
                print(f"Test [{self.description}] {index} : {colored('Failed', 'red')}")
                print(f"    Current error : [{getOutputStr(programOutput)}]")
                print(f"    Error expected : [{self.errorStringToFind}]")
                print(f"    Current retCode : [{getReturnCode(programOutput)}]")
                print(f"    Expected retCode : [{self.expCode}]")
            else:
                print(f"Test [{self.description}] {index} : {colored('Failed', 'red')}")
                print(f"    Expected tape : [{self.expResult}]")
                print(f"    Current tape  : [{getResultTape(programOutput)}]")
                print(f"    Expected retCode : [{self.expCode}] ; Current tape [{getReturnCode(programOutput)}]")
