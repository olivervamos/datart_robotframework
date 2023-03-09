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
    ${searchTextTit}=    Convert To Title Case    ${searchText}
    ${searchTextUpp}=    Convert To Upper Case    ${searchText}   
   
    #Search for variable searchText
    Input Text    xpath=//input[@type='search']    ${searchText}
    Click Element    xpath=//button[@type='submit']/span

    #verify actual and expected text
    Element Should Contain    xpath=//h1/span    ${searchText}

    #loop for verifying that item name contains searchText
    ${lastPageNumber}=    Get Text    xpath=(//li[@class='page-item']/a[@class='page-link '])[last()]
    ${lastPageNumber-1}=    Evaluate    ${lastPageNumber}-1
    FOR    ${counter}    IN RANGE    0    ${lastPageNumber}    1
        IF    $counter == ${lastPageNumber-1}    BREAK
        ${items}=    Get Webelements    xpath=//h3[@class='item-title']/a
        FOR    ${item}    IN    @{items}
            ${elementTxt}=    Get Text    ${item}
            Log To Console    ${elementTxt}
            Element Should Contain    ${item}    ${searchText}    Neobsahuje:${searchText}    ignore_case: bool = True                    
        END  
        ${discountPopUp}=  Get Element Count    xpath=//div[contains(@class,'exponea-colose-link')]
        IF    ($discountPopUp == 1)
        Wait Until Page Contains Element    xpath=//div[contains(@class,'exponea-colose-link')]
        Click Element    xpath=//div[contains(@class,'exponea-colose-link')]
        Wait Until Page Contains Element    xpath=//button[@class ='exponea-button-close']
        Click Element    xpath=//button[@class ='exponea-button-close']
        END
        Click Element    xpath=//a[@class='page-link next-page ']
        Log To Console    ${counter}
    END
    Close Browser