import subprocess
import re

TURING_EXEC_PATH = "./ft_turing"

def runTuring(machinePath: str, input: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run([TURING_EXEC_PATH, machinePath, input], stdout=subprocess.PIPE)

def getOutputStr(output: subprocess.CompletedProcess[bytes]) -> str:
    ansiEscape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')
    decoded = output.stdout.decode();
    return ansiEscape.sub('', decoded)

def getReturnCode(output: subprocess.CompletedProcess[bytes]) -> int:
    return output.returncode

def getResultTape(output: subprocess.CompletedProcess[bytes]) -> str:
    outputStr = getOutputStr(output)
    splitedOutput = outputStr.split("\n")
    result = splitedOutput[len(splitedOutput) - 4]
    splicedResult = result[1:len(result) - 1]
    return splicedResult
