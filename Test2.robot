*** Settings ***
Documentation    Function search
Library          SeleniumLibrary    
Library    String
Library    Collections

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome
${searchText}    samsung

*** Keywords ***

*** Test Cases ***
Search
    Open Browser                ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element               xpath=//div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]

    #Conver String to Upper Case
    ${searchTextUpp}=    Convert To Title Case    ${searchText}   
   
    #Search for Samsung
    Input Text    xpath=//input[@type='search']    ${searchText}
    Click Element    xpath=//button[@type='submit']/span

    #verify actual and expected text
    Element Should Contain    xpath=//h1/span    ${searchText}

    #loop for verifying that item name contains Samsung
    ${lastPageNumber}=    Get Text    xpath=(//li[@class='page-item']/a[@class='page-link '])[last()]
    ${lastPageNumber-1}=    Evaluate    ${lastPageNumber}-1
    FOR    ${counter}    IN RANGE    0    ${lastPageNumber}    1
        IF    $counter == ${lastPageNumber-1}    BREAK
        ${items}=    Get Webelements    xpath=//h3[@class='item-title']/a
        FOR    ${item}    IN    @{items}
            ${elementTxt}=    Get Text    ${item}
            Log To Console    ${elementTxt}
            Element Should Contain    ${item}    ${searchTextUpp}
        END  
        Click Element    xpath=//a[@class='page-link next-page ']
        Log To Console    ${counter}
    END
    Close Browser