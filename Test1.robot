*** Settings ***
Documentation    Expensive items in basket.
Library          SeleniumLibrary    
Library    String
Library    Collections

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome
@{priceList}
@{itemNameList}
@{itemNameList3}
@{itemBasketList}

*** Keywords ***

*** Test Cases ***
Get Expensive Items
    Open Browser                ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element               xpath=//div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]
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
    
    ${itemElements}=    Get WebElements    xpath=//h3[@class='item-title']/a[contains(@data-lb-name,'Notebook')]
        FOR    ${itemElement}    IN    @{itemElements}
            ${itemName}=    Get Text    ${itemElement}
            ${itemNameRepl}=    Replace String    ${itemName}      Notebook${SPACE}    ${EMPTY}
            Append To List    ${itemNameList}    ${itemNameRepl}
        END
       
        ${itemNameList3}    Get Slice From List    ${itemNameList}    0    3
                         
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
    
    ${basketElements}=    Get WebElements    xpath=//h2[@class='overflow-ellipsis']
    FOR    ${basketElement}    IN    @{basketElements}
           ${basketItemText}=    Get Text    ${basketElement}
        Append To List    ${itemBasketList}    ${basketItemText}
    END

    #Item name in basket control
    Should Be Equal    ${itemNameList3}    ${itemBasketList}

    #remove item from basket
    Wait Until Element Is Visible    xpath=//a[@rel='nofollow']
    ${totalPrice}=    Get Element Attribute    xpath=//div[@class='basket-total-price']    data-basket-price
    
    Click Element    xpath=//a[@rel='nofollow']
    Sleep    2s  
    
    ${totalPriceRemove}=    Get Element Attribute    xpath=//div[@class='basket-total-price']    data-basket-price

    Should Not Be Equal    ${totalPrice}    ${totalPriceRemove}
    Page Should Contain Element    //div[@class='basket-product-wrap']    limit=2  
    Close Browser