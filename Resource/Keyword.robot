*** Settings ***
Resource    ../Variable/variable.robot
Library     Browser
Library    DataDriver    file=${CURDIR}/../Testdata/testdata_signup.xlsx    sheet_name=Sheet1
*** Keywords ***
Go To Url
    New Browser    ${browser}    headless=False
    New Page    ${url}  networkidle
    Set Browser Timeout  10s
    Sleep    5s
Sign Up
    Click    selector=a:has-text("Sign Up")
    Sleep    5s
Read Data From Excel File
    [Arguments]    ${filePath}    
    Open Excel Document    ${filePath}    Sheet1