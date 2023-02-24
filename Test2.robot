*** Settings ***
Documentation    Function search
Library          SeleniumLibrary    
Library    String
Library    Collections

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome

*** Keywords ***

*** Test Cases ***
Search
    Open Browser                ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element               xpath=//div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]
    Click Element               xpath=//h2[contains(@class, 'footer')]/..//a[contains(@href, 'pc-notebooky')]
    Click Element               xpath=//span[contains(text(),'Macbooky')]
    Click Element               xpath=//a[@data-lb-name='Najdrahší']
    Wait Until Element Is Visible    xpath=//button[@data-lb-action='buy']/span