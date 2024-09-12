*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser
Library    ExcelManipulation.py
Library    DiscordAPIRequest.py

*** Keywords ***

Close Updates Notification
    ${update_alerts}  Does Page contain Element  //div[@data-bind-menu="notification|text_editing" and contains(text(),'ALLOW')]
    IF  ${update_alerts}
        run keyword and return status  click element when visible  //div[@data-bind-menu="notification|text_editing" and contains(text(),'ALLOW')]
    END
    Close Live Chat
    Close the Cookies

Close Live Chat
    ${isLiveChat}  Does Page contain Element  //iframe[@data-qa="launcher-message-iframe"]
    IF  ${isLiveChat}
        select frame  //iframe[@data-qa="launcher-message-iframe"]
        run keyword and return status  click element when visible  //div[@aria-label="Close Klarna live chat message"]
        unselect frame
    END

Close the Cookies
    ${isCookiesVisible}  run keyword and return status    wait until page contains element    //button[@id="onetrust-accept-btn-handler"]
    IF  ${isCookiesVisible}
        run keyword and return status    click element when visible     //button[@id="onetrust-accept-btn-handler"]
    END

Get Price With Exception
    [Arguments]  ${xpath}
    ${xpathPrice}  Set Variable  ${EMPTY}
    ${isXpathVisible}  run keyword and ignore error  wait until keyword succeeds  3x  2s  get text  ${xpath}
    IF  "${isXpathVisible}[0]"=="PASS"
        ${xpathPrice}  set variable  ${isXpathVisible}[1]
    END
    [Return]  ${xpathPrice}

Get Products Pricing
    ${priceNav}  run keyword and return status  wait until page contains element  //div[@class="product-add-to-cart__price-container"]//span[@class="price__current"]  40s
    ${price1}  set variable  ${EMPTY}
    ${price2}  set variable  ${EMPTY}0
    IF  ${priceNav}
        ${pricesRange}  Get Element Count  (//p[@class="product-carousel-variant__item-labels"])
        ${pricesRange}  Evaluate  ${pricesRange}/2
        ${pricesRange1}  set variable  1
        ${pricesRange2}  set variable  2
        IF  ${pricesRange}>2
            ${mlList}  Create List
            FOR  ${x}  IN RANGE  1  ${pricesRange}+1
                ${ml}  Get Price With Exception  (//p[@class="product-carousel-variant__item-labels"])[${x}]//span[1]
                ${ml}  Set variable  ${ml[0:-2]}
                IF  '${ml}'!=''
                    Append to List  ${mlList}  ${ml}
                END
            END
            log  ${mlList}
            ${pricesRange1}  ${pricesRange2}  find_min_max_indices  ${mlList}
        END
        ${price1}  Get Price With Exception  (//p[@class="product-carousel-variant__item-labels"])[${pricesRange1}]//span[2]
        ${price2}  Get Price With Exception  (//p[@class="product-carousel-variant__item-labels"])[${pricesRange2}]//span[2]
        ${price1}  extract_float  ${price1}
        ${price2}  extract_float  ${price2}
    END
    [Return]  ${price1}  ${price2}


Next Page Appearance Confirmation
    [Arguments]  ${currPageNo}
    FOR  ${x}  IN RANGE  1   1000
        ${currPageTemp}  Get Text  //a[@class="page disabled current" and @tabindex="-1"]
        ${currPageTemp}  Strip String  ${currPageTemp}
        IF  int(${currPageTemp})==int(${currPageNo})+1
            exit for loop
        ELSE
            sleep  5s
        END
    END