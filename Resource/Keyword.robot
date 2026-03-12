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

Login
    [Arguments]    ${email}    ${password}
    Click    selector=a:has-text("Sign in")
    Fill Text    selector=input[placeholder="Email"]    txt=${email}
    Fill Text    selector=input[placeholder="Password"]    txt=${password}
    Click    selector=button:has-text("Sign in")
    # Reduced timeout for faster failure during debug, but added screenshot
    ${status}=    Run Keyword And Return Status    Wait For Elements State    selector=a:has-text("New Article")    state=visible    timeout=10s
    IF    not ${status}
        Take Screenshot    selector=body
        Fail    Login failed or "New Article" link not visible. Check screenshot.
    END

Verify Article Display and Content
    [Arguments]    ${username}    ${email}    ${password}    ${title}    ${description}    ${body}    ${tags}
    
    # 1. เช็กว่าหัวข้อ (H1) ตรงกับใน Excel ไหม
    Wait For Elements State    xpath://h1[text()="${title}"]    visible    timeout=10s
    Log To Console    Verified Title: ${title}

    # 2. เช็กว่าเนื้อหาบทความ (Body) แสดงผลครบถ้วนไหม
    Get Text    css:.article-content    contains    ${body}
    Log To Console    Verified Body: ${body}

    # 3. เช็กว่าชื่อผู้เขียน (Author) เป็นชื่อของเราที่สมัครไปไหม
    # (ในหน้านี้ชื่อคนเขียนมักจะอยู่ในคลาส .author)
    Get Text    xpath:(//a[@class="author"])[1]    ==    ${username}

    # 4. เช็กปุ่ม Edit/Delete (เจ้าของบทความต้องเห็นปุ่มนี้)
    Wait For Elements State    xpath://a[contains(@class, "btn-outline-secondary") and contains(text(), "Edit Article")]    visible
    Wait For Elements State    xpath://button[contains(@class, "btn-outline-danger") and contains(text(), "Delete Article")]    visible

Go To Global Feed
    # Try clicking Global Feed tab if it exists, otherwise assume we are there or it's a link
    ${status}=    Run Keyword And Return Status    Click    text="Global Feed"
    IF    not ${status}
        Log    'Global Feed' text not clickable or not found. Continuing...
    END

Click On First Article
    # Click 'Read more...' in the first article preview as requested
    Click    xpath=(//div[@class='article-preview'])[1]//span[contains(text(), 'Read more')]

Create Article
    [Arguments]    ${title}    ${description}    ${body}    ${tags}
    Click    selector=a:has-text("New Article")
    Fill Text    selector=input[placeholder="Article Title"]    txt=${title}
    Fill Text    selector=input[placeholder="What's this article about?"]    txt=${description}
    
    # Use name selector discovered in research
    # Clear potential default whitespace before typing
    Clear Text    selector=textarea[name="body"]
    Type Text    selector=textarea[name="body"]    txt=${body}    delay=10ms
    
    Fill Text    selector=input[placeholder="Enter tags"]    txt=${tags}
    Click    selector=button:has-text("Publish Article")
    # Verify success: The published article title should be visible as an h1
    ${status}=    Run Keyword And Return Status    Wait For Elements State    selector=h1:has-text("${title}")    state=visible    timeout=10s
    IF    not ${status}
        Take Screenshot    selector=body
        Fail    Article creation failed or title not visible. Check screenshot.
    END

Sign Up
    [Arguments]    ${username}    ${email}    ${password}
    Click    selector=a:has-text("Sign Up")
    Fill Text    selector=input[placeholder="Username"]    txt=${username}
    Fill Text    selector=input[placeholder="Email"]    txt=${email}
    Fill Text    selector=input[placeholder="Password"]    txt=${password}
    
    # Check if button is enabled
    ${state}=    Get Element States    selector=button:has-text("Sign up")
    IF    'enabled' in $state
        Click    selector=button:has-text("Sign up")
        # Wait to see if we logged in or if an error appeared
        ${success}=    Run Keyword And Return Status    Wait For Elements State    selector=a:has-text("Settings")    state=visible    timeout=5s
        IF    not ${success}
            ${error_visible}=    Run Keyword And Return Status    Wait For Elements State    selector=.error-messages    state=visible    timeout=2s
            IF    ${error_visible}
                ${errors}=    Get Text    selector=.error-messages
                Take Screenshot    selector=body
                Fail    Registration failed with error: ${errors}
            ELSE
                Take Screenshot    selector=body
                Fail    Registration failed: Did not redirect to home page and no error message found.
            END
        END
    ELSE
        Take Screenshot    selector=body
        Fail    Registration failed: 'Sign up' button is disabled due to missing or invalid data.
    END

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
    [Arguments]    ${user}    ${status}    ${excel_file}=testdata_signup.xlsx
    ${excel_path}=    Set Variable    ${CURDIR}/../Testdata/${excel_file}
    Log    Logging result for ${user} with status ${status} to ${excel_path}
    
    Open Excel Document    ${excel_path}    signup
    
    # Get headers to find indices (headers are in row 1)
    ${headers}=      Read Excel Row    row_num=1    sheet_name=Sheet1
    
    ${u_col}=    Set Variable    ${1}
    ${res_col}=    Set Variable    ${-1}
    
    # Finding column indices (ExcelLibrary indices for cells are 1-based)
    ${index}=    Set Variable    ${1}
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
    
    # Standardize target user value for comparison
    ${target_user}=    Convert To String    ${user}
    ${target_user}=    Set Variable If    '${target_user}' == 'None'    ${EMPTY}    ${target_user}

    # Update result for all matching rows
    ${row_idx}=    Set Variable    2
    WHILE    ${True}
        ${current_row}=    Read Excel Row    row_num=${row_idx}    sheet_name=Sheet1
        ${row_len}=    Get Length    ${current_row}
        IF    ${row_len} == 0    BREAK
        
        # Stop if the entire row is empty (Nones) to avoid ghost rows
        ${is_empty}=    Evaluate    all(item is None for item in $current_row)
        IF    ${is_empty}    BREAK
        
        ${raw_val}=    Set Variable    ${current_row[${u_col}-1]}
        ${current_val}=    Convert To String    ${raw_val}
        ${current_val}=    Set Variable If    '${current_val}' == 'None'    ${EMPTY}    ${current_val}

        IF    '${current_val.strip()}' == '${target_user.strip()}'
            Write Excel Cell    row_num=${row_idx}    col_num=${res_col}    value=${status}    sheet_name=Sheet1
            # DO NOT BREAK: update all matches (for duplicate usernames)
        END
        ${row_idx}=    Evaluate    ${row_idx} + 1
        IF    $row_idx > 1000    BREAK
    END
    
    Save Excel Document    ${excel_path}
    Close Current Excel Document

Save Article Content To Excel
    [Arguments]    ${filename}=extracted_articles.xlsx
    ${excel_path}=    Set Variable    ${CURDIR}/../Testdata/${filename}
    
    # Extract content from current page
    ${title}=    Get Text    css=h1
    ${body}=     Get Text    css=.article-content
    ${date}=     Get Text    css=.date >> nth=0
    ${author}=   Get Text    css=.author >> nth=0
    
    # Extract tags as a list then join them
    ${tag_elements}=    Get Elements    css=.tag-list li
    ${tags}=    Set Variable    ${EMPTY}
    FOR    ${element}    IN    @{tag_elements}
        ${text}=    Get Text    ${element}
        ${tags}=    Set Variable    ${tags}${text}, 
    END
    
    # Use robust pure robot append keyword
    Append Article To Excel    ${excel_path}    ${title}    ${body}    ${tags}    ${date}    ${author}

Append Article To Excel
    [Arguments]    ${excel_path}    ${title}    ${body}    ${tags}=${EMPTY}    ${date}=${EMPTY}    ${author}=${EMPTY}
    # Try to open existing document
    ${status}    ${error}=    Run Keyword And Ignore Error    Open Excel Document    ${excel_path}    doc_id=append_doc
    
    # If not found, create a new one
    IF    '${status}' == 'FAIL'
        Create Excel Document    doc_id=append_doc
        Write Excel Cell    row_num=1    col_num=1    value=Title     sheet_name=Sheet
        Write Excel Cell    row_num=1    col_num=2    value=Body      sheet_name=Sheet
        Write Excel Cell    row_num=1    col_num=3    value=Tags      sheet_name=Sheet
        Write Excel Cell    row_num=1    col_num=4    value=Date      sheet_name=Sheet
        Write Excel Cell    row_num=1    col_num=5    value=Author    sheet_name=Sheet
        Save Excel Document    ${excel_path}
    END
    
    # Find last row to append
    ${col_data}=    Read Excel Column    col_num=1    sheet_name=Sheet
    ${count}=    Get Length    ${col_data}
    ${next_row}=    Evaluate    ${count} + 1
    
    Write Excel Cell    row_num=${next_row}    col_num=1    value=${title}     sheet_name=Sheet
    Write Excel Cell    row_num=${next_row}    col_num=2    value=${body}      sheet_name=Sheet
    Write Excel Cell    row_num=${next_row}    col_num=3    value=${tags}      sheet_name=Sheet
    Write Excel Cell    row_num=${next_row}    col_num=4    value=${date}      sheet_name=Sheet
    Write Excel Cell    row_num=${next_row}    col_num=5    value=${author}    sheet_name=Sheet
    
    Save Excel Document    ${excel_path}
    Close Current Excel Document

Read Excel With ExcelLibrary
    ${excel_path}=    Set Variable    ${CURDIR}/../Testdata/testdata_signup.xlsx
    Open Excel Document    ${excel_path}    read_data
    ${data}=    Make List From Excel Sheet    Sheet1
    Log Many    @{data}
    Close Current Excel Document
