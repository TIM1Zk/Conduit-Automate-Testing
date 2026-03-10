*** Settings ***
Library     Browser
Library     DataDriver    file=../Testdata/testdata_article.xlsx    sheet_name=Sheet1    handle_empty_cells=True
Resource    ../Resource/Keyword.robot
Resource    ../Variable/variable.robot

Suite Setup      Go To Url
Suite Teardown   Close Browser
Test Template    Create New Article From Excel
Test Teardown    Teardown Article Test

*** Test Cases ***
Create New Article Successfully With ${username}

*** Keywords ***
Create New Article From Excel
    [Arguments]    ${username}    ${email}    ${password}    ${title}    ${description}    ${body}    ${tags}
    Set Suite Variable    ${CURRENT_TEST_USER}    ${username}
    Sign Up    ${username}    ${email}    ${password}
    Create Article    ${title}    ${description}    ${body}    ${tags}

Teardown Article Test
    Run Keyword If Test Passed    Log Result To Excel    ${CURRENT_TEST_USER}    PASS    testdata_article.xlsx
    Run Keyword If Test Failed    Log Result To Excel    ${CURRENT_TEST_USER}    FAIL    testdata_article.xlsx
    Logout
