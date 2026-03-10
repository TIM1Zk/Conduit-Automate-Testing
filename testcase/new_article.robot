*** Settings ***
Library     Browser
Resource    ../Resource/Keyword.robot
Resource    ../Variable/variable.robot

Suite Setup      Go To Url
Suite Teardown   Close Browser

*** Variables ***
${TEST_EMAIL}          test1@example.com
${TEST_PASSWORD}       password123
${ARTICLE_TITLE}       Automated Article Title
${ARTICLE_DESC}        This is an automated article description.
${ARTICLE_BODY}        # Automated Content\n\nThis is the body of the article created by Robot Framework.
${ARTICLE_TAGS}        robotframework, automation

*** Test Cases ***
Create New Article Successfully
    ${random_str}=    Evaluate    "".join(random.sample(string.ascii_lowercase, 8))    modules=random, string
    ${username}=      Set Variable    user_${random_str}
    ${email}=         Set Variable    ${username}@example.com
    
    Sign Up    ${username}    ${email}    ${TEST_PASSWORD}
    Create Article    ${ARTICLE_TITLE}    ${ARTICLE_DESC}    ${ARTICLE_BODY}    ${ARTICLE_TAGS}
    [Teardown]    Logout
