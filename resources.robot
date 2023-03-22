*** Settings ***
Documentation    Recources
Library          SeleniumLibrary  

*** Variables ***
${URL}        https://www.datart.sk/
${BROWSER}    Chrome
${xpathCookies}    //div[contains(@class,'box')]//button[contains(text(),'Súhlasím a pokračovať')]

*** Keywords ***

Open browser maximize accept cookies
    Open Browser                ${URL}    ${BROWSER}    options=add_experimental_option("detach", True)
    Maximize Browser Window
    Click Element               ${xpathCookies}