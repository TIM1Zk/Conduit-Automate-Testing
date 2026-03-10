*** Settings ***
Library     Browser
Library     DataDriver    file=${CURDIR}/../Testdata/testdata_signup.xlsx    sheet_name=Sheet1
Resource    ../Resource/Keyword.robot

Suite Setup      Go To Url
Test Teardown    Teardown Actions
Test Template    Sign Up Page Template

*** Variables ***
${username}    default_user
${email}       default@example.com
${password}    default_pass

*** Test Cases ***
Sign Up Test With Excel    ${username}    ${email}    ${password}

*** Keywords ***
Sign Up Page Template
    [Arguments]    ${username}    ${email}    ${password}
    Set Test Variable    ${CURRENT_USER}    ${username}
    Sign Up    ${username}    ${email}    ${password}

Teardown Actions
    Log Result To Excel    ${CURRENT_USER}    ${TEST STATUS}
    Logout
