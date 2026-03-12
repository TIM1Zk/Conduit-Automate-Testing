*** Settings ***
Library     Browser
Resource    ../Resource/Keyword.robot
Resource    ../Variable/variable.robot

Suite Setup      Go To Url
Suite Teardown   Close Browser

*** Test Cases ***
Extract All Articles From Global Feed
    [Documentation]    เข้าหน้า Global Feed วนลูปคลิกทุกบทความในหน้าแรก แล้วเซฟลง Excel
    Go To Global Feed
    
    # Wait for at least one preview to load (non-strict wait)
    Wait For Elements State    css=.article-preview >> nth=0    visible    timeout=10s
    
    # Get total count
    ${count}=    Get Element Count    css=.article-preview
    Log To Console    Found ${count} articles to extract.
    
    FOR    ${i}    IN RANGE    1    ${count} + 1
        # Click "Read more" of the i-th article
        Click    xpath=(//div[@class='article-preview'])[${i}]//span[contains(text(), 'Read more')]
        
        # Wait for article content
        Wait For Elements State    css=.article-content    visible    timeout=10s
        
        # Save data
        Save Article Content To Excel    extracted_articles.xlsx
        Log To Console    Successfully extracted article ${i}/${count}
        
        # Return to main feed
        Go Back
        Wait For Elements State    css=.article-preview >> nth=0    visible    timeout=10s
        # Small sleep to ensure page stability after navigation
        Sleep    1s
    END
    
    Log To Console    All ${count} articles extracted and saved to Testdata/extracted_articles.xlsx
