*** Settings ***
Resource    ../Variable/variable.robot
Library     Browser
Library     ExcelLibrary
Library     Collections

*** Keywords ***
Go To Url
    New Browser    ${browser}    headless=False
    New Page    ${url}  networkidle
    Set Browser Timeout  10s
    Sleep    5s

Sign Up
    [Arguments]    ${username}    ${email}    ${password}
    Click    selector=a:has-text("Sign Up")
    Fill Text    selector=input[placeholder="Username"]    txt=${username}
    Fill Text    selector=input[placeholder="Email"]    txt=${email}
    Fill Text    selector=input[placeholder="Password"]    txt=${password}
    Click    selector=button:has-text("Sign up")
    Sleep    2s

Logout
    # Robust logout: check if page exists first to avoid 'No active page' errors
    ${pages}=    Get Page Ids
    ${count}=    Get Length    ${pages}
    IF    $count == 0
        Log    No active pages found. Re-opening for cleanup...
        Go To    ${url}
    END
    
    # Nuclear option: Clear all storage to ensure logout
    LocalStorage Clear
    SessionStorage Clear
    Sleep    1s
    
    # Try clicking logout if still visible
    ${is_visible}=    Get Element Count    selector=a:has-text("Log out")
    IF    $is_visible > 0
        Click    selector=a:has-text("Log out")
        Sleep    1s
    END
    
    # Return to home to be ready for next iteration
    Go To    ${url}

Log Result To Excel
    [Arguments]    ${user}    ${status}
    ${excel_path}=    Set Variable    ${CURDIR}/../Testdata/testdata_signup.xlsx
    Log    Logging result for ${user} with status ${status} to ${excel_path}
    
    Open Excel Document    ${excel_path}    signup
    
    # Get headers to find indices (headers are in row 1)
    ${headers}=      Read Excel Row    row_num=1    sheet_name=Sheet1
    
    ${u_col}=    Set Variable    1
    ${res_col}=    Set Variable    -1
    
    # Finding column indices (ExcelLibrary indices for cells are 1-based)
    ${index}=    Set Variable    1
    FOR    ${header}    IN    @{headers}
        ${header_str}=    Convert To String    ${header}
        IF    'username' in $header_str.lower()
            ${u_col}=    Set Variable    ${index}
        END
        IF    'Result' == $header_str
            ${res_col}=    Set Variable    ${index}
        END
        ${index}=    Evaluate    ${index} + 1
    END

    # If Result column not found, add it
    IF    $res_col == -1
        ${res_col}=    Set Variable    ${index}
        Write Excel Cell    row_num=1    col_num=${res_col}    value=Result    sheet_name=Sheet1
    END
    
    # Update result for the specific user
    # Search starting from row 2
    ${row_idx}=    Set Variable    2
    WHILE    ${True}
        ${current_row}=    Read Excel Row    row_num=${row_idx}    sheet_name=Sheet1
        ${row_len}=    Get Length    ${current_row}
        IF    ${row_len} == 0    BREAK
        
        ${current_val}=    Convert To String    ${current_row[${u_col}-1]}
        IF    '${current_val.strip()}' == '${user}'
            Write Excel Cell    row_num=${row_idx}    col_num=${res_col}    value=${status}    sheet_name=Sheet1
            BREAK
        END
        ${row_idx}=    Evaluate    ${row_idx} + 1
        IF    $row_idx > 1000    BREAK
    END
    
    Save Excel Document    ${excel_path}
    Close Current Excel Document

Read Excel With ExcelLibrary
    ${excel_path}=    Set Variable    ${CURDIR}/../Testdata/testdata_signup.xlsx
    Open Excel Document    ${excel_path}    read_data
    ${data}=    Make List From Excel Sheet    Sheet1
    Log Many    @{data}
    Close Current Excel Document
