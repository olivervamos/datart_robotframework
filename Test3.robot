*** Settings ***
Documentation    Empty Basket
Library          SeleniumLibrary    
Library    String

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome
${expectedTxt}    Neplatná hodnota položky v košíku, košík byl vymazán    

*** Keywords ***

*** Test Cases ***
Empty Basket
    Open Browser                ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element               xpath=//div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]
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
    Close Browser