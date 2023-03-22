*** Settings ***
Documentation    Expensive items in basket.
Library          SeleniumLibrary    
Library    String
Library    Collections
Resources    res.robot

Suite Setup    Log    suite setup
Test Setup     Open Browser And Maximize
Test Teardown    Close Browser
Suite Teardown    Log    suite teardown

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome
@{priceList}
@{itemNameList}
@{itemNameList2}
@{itemBasketList}
${searchText}    samsung
${boxed-content}    //div[@class='boxed-content']

*** Keywords ***
### StaleElementReferenceException: Message: stale element reference: element is not attached to the page document
## SETUP / TEARDOWN
# setup -> vykona vzdy na zaciatku
# teardown -> vzdy na konci
Open Browser And Maximize
    Open Browser                ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element               xpath=//div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]

Check if items are sorted
    [Arguments]    ${param1}    ${param2}
    ${ListCount-1}=    Evaluate    ${ListCount}-1
       FOR    ${counter}    IN RANGE    0    ${ListCount}    1
           ${counter+1}=    Evaluate    ${counter}+1
           IF    $counter == ${ListCount-1}    BREAK
           ${ListItem1}=    Get From List    ${priceList}    ${counter}
           ${ListItem2}=    Get From List    ${priceList}    ${counter+1}
           Should Be True    ${ListItem1}>=${ListItem2}
           Log To Console    ${ListItem1}' and '${ListItem2}
       END  
    [Return]    ${ListItem1}

*** Test Cases ***
Dummy one
    ${res}    Check if items are sorted    item1    @{items}


Get Expensive Items
    [Tags]    test1    work-in-progress
    Click Element               xpath=//h2[contains(@class, 'footer')]/..//a[contains(@href, 'pc-notebooky')]
    Click Element               xpath=//span[contains(text(),'Macbooky')]
    Click Element               xpath=//a[@data-lb-name='Najdrahší']
    Wait Until Element Is Visible    xpath=//button[@data-lb-action='buy']/span
    
    #Create List of prices
    ${ListCount}=    Get Element Count    xpath=//div[@class='item-price'] 
    ${prices}=    Get WebElements    xpath=//div[@class='item-price']
       FOR    ${price}    IN    @{prices}
           ${priceVal}=    Get Element Attribute    ${price}    data-product-price
           ${priceInt}=    Convert To Integer    ${priceVal}
           Append To List    ${priceList}    ${priceInt}
       END

    #Price sorting control
    ${ListCount-1}=    Evaluate    ${ListCount}-1
       FOR    ${counter}    IN RANGE    0    ${ListCount}    1
           ${counter+1}=    Evaluate    ${counter}+1
           IF    $counter == ${ListCount-1}    BREAK
           ${ListItem1}=    Get From List    ${priceList}    ${counter}
           ${ListItem2}=    Get From List    ${priceList}    ${counter+1}
           Should Be True    ${ListItem1}>=${ListItem2}
           Log To Console    ${ListItem1}' and '${ListItem2}
       END  
    
    #Create list of names of 3 most expensive items 
    ${itemElements}=    Get WebElements    xpath=//h3[@class='item-title']/a[contains(@data-lb-name,'Notebook')]
        FOR    ${itemElement}    IN    @{itemElements}
            ${itemName}=    Get Text    ${itemElement}
            ${itemNameRepl}=    Replace String    ${itemName}      Notebook${SPACE}    ${EMPTY}
            Append To List    ${itemNameList}    ${itemNameRepl}
        END
       
        ${itemNameList2}    Get Slice From List    ${itemNameList}    0    3
    
    #Add 3 most expensive items to basket                      
    ${buyButtons}=    Get WebElements    xpath=//button[@data-lb-action='buy']/span
    FOR    ${buyButton}    IN    @{buyButtons}
        Wait Until Element Is Visible    xpath=//button[@data-lb-action='buy']/span
        Click Element    ${buyBUtton}
        Sleep    2s

        ${discountPopUp}=  Get Element Count    xpath=//div[@class='boxed-content']
        IF    ($discountPopUp == 1)
        Click Element    xpath=//span[@class='close-cross']
        END

        Wait Until Element Is Visible    xpath=//button[@aria-label='Close']
        Click Element    xpath=//button[@aria-label='Close']
        Wait Until Element Is Visible    xpath=//span[@class='badge pcs-total']
        ${iteminBasket}=    Get Text    xpath=//span[@class='badge pcs-total']
        IF    $iteminBasket == '3'    BREAK
    END

    #navigate to basket
    Wait Until Element Is Visible    xpath=//img[@class='svg-cart-full']/../span
    Click Element    xpath=//img[@class='svg-cart-full']/../span
    
    #Create list of names of 3 items in basket
    ${basketElements}=    Get WebElements    xpath=//h2[@class='overflow-ellipsis']
    FOR    ${basketElement}    IN    @{basketElements}
           ${basketItemText}=    Get Text    ${basketElement}
        Append To List    ${itemBasketList}    ${basketItemText}
    END

    #Item name in basket control
    Should Be Equal    ${itemNameList2}    ${itemBasketList}

    #remove item from basket
    Wait Until Element Is Visible    xpath=//a[@rel='nofollow']
    ${totalPrice}=    Get Element Attribute    xpath=//div[@class='basket-total-price']    data-basket-price
    
    Click Element    xpath=//a[@rel='nofollow']
    Sleep    2s  
    
    ${totalPriceRemove}=    Get Element Attribute    xpath=//div[@class='basket-total-price']    data-basket-price

    Should Not Be Equal    ${totalPrice}    ${totalPriceRemove}
    Page Should Contain Element    //div[@class='basket-product-wrap']    limit=2  

Search
    [Tags]    test2     regression
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

Empty Basket
    [Tags]    test3    regression
    Click Element               xpath=//h2[contains(@class, 'footer')]/..//a[contains(@href, 'pc-notebooky')]
    Click Element               xpath=//span[contains(text(),'Macbooky')]
    Wait Until Element Is Visible    xpath=//button[@data-lb-action='buy']/span
    #add item to basket
    Click Element    xpath=//button[@data-lb-action='buy']/span
    #close popup
    Wait Until Element Is Visible    xpath=//button[@aria-label='Close']
    Click Element    xpath=//button[@aria-label='Close']
    
    ${discountPopUp}=  Get Element Count    xpath=//div[@class='boxed-content']
        IF    ($discountPopUp == 1)
        Click Element    xpath=//span[@class='close-cross']
        END

    #navigate to basket 
    Wait Until Element Is Visible    xpath=//img[@class='svg-cart-full']
    Click Element    xpath=//img[@class='svg-cart-full']
    #remove item from basket
    Click Element    xpath=//img[contains(@src,'remove')]
    #click on continue button
    Click Element    xpath=//a[contains(@class,'continue')]
    #verify if basket is empty
    ${actualTxt}=    Get Text    xpath=//div[@class='modal-body']
    Should Be Equal    ${actualTxt}    ${expectedTxt}