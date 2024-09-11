*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser
Library    ExcelManipulation.py
Library    DiscordAPIRequest.py

*** Variables ***
${websiteLink}    https://www.theperfumeshop.com/
${isPageLoaded}  False

*** Keywords ***
Close Updates Notification
    ${update_alerts}  Does Page contain Element  //div[@data-bind-menu="notification|text_editing" and contains(text(),'ALLOW')]
    IF  ${update_alerts}
        run keyword and return status  click element when visible  //div[@data-bind-menu="notification|text_editing" and contains(text(),'ALLOW')]
    END
    Close Live Chat

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
        #press keys   None  TAB
        #press keys   None  TAB
        #press keys   None  ENTER
        #sleep  2s
        #press keys   None  ENTER
    END

Open the Perfume Shop
    FOR  ${attempt}  IN RANGE    0  3
        open browser    about:blank    chrome
        goto    ${websiteLink}
        ${isPageLoaded}  run keyword and return status    wait until page contains element    //a[@aria-label="Women's" and text()="Women's"]  40s
        IF  ${isPageLoaded}
            Close the Cookies
            ${isPageLoaded}  set variable  True
            Exit for loop
        END
    END
    sleep  2s
    Close Updates Notification
    [Return]  ${isPageLoaded}

Go To Next Page
    Close Updates Notification
    sleep  1s
    ${testNext}  run keyword and return status  wait until keyword succeeds  5x  2s  click element when visible    //div[@class="product-grid__pagination cx-pagination"]//a[@class="next"]
    IF  not ${testNext}
        Close the Cookies
        ${test3}  run keyword and return status  wait until keyword succeeds  10x  2s  click element when visible    //div[@class="product-grid__pagination cx-pagination"]//a[@class="next"]
    END

Get Post Details
    [Arguments]     ${post}
    ${postPrice}  set variable  ${EMPTY}
    ${postPriceStatus}  run keyword and return status  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//span[@class="price__current"]
    IF  ${postPriceStatus}
        ${postPrice}  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//span[@class="price__current"]
    END
    IF  '${postPrice}'==''
        ${postPriceStatus}  run keyword and return status  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//span[@class="discounted-price__price-current"]
        IF   ${postPriceStatus}
            ${postPrice}  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//span[@class="discounted-price__price-current"]
        END
    END
    IF  '${postPrice}'==''
        ${postName1}  set variable  ${EMPTY}
        ${postName2}  set variable  ${EMPTY}
        ${postURL}  set variable  ${EMPTY}
    ELSE
        ${postName1}  run keyword and return status  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//p[@class="product-list-item__brand"]
        ${postName2}  run keyword and return status  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//p[@class="product-list-item__range"]
        ${postURL}  run keyword and return status  Get Element Attribute  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//a[@class="product-list-item__link"]  href
        IF  ${postName1} and ${postName2} and ${postURL}
            ${postName1}  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//p[@class="product-list-item__brand"]
            ${postName2}  Get Text  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//p[@class="product-list-item__range"]
            ${postURL}  Get Element Attribute  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//a[@class="product-list-item__link"]  href
        ELSE
            ${postName1}  set variable  ${EMPTY}
            ${postName2}  set variable  ${EMPTY}
            ${postURL}  set variable  ${EMPTY}
        END
    END
    [Return]    ${postPrice}    ${postName1}    ${postName2}    ${postURL}

Get Price With Exception
    [Arguments]  ${xpath}
    ${xpathPrice}  Set Variable  ${EMPTY}
    ${isXpathVisible}  run keyword and ignore error  get text  ${xpath}
    IF  "${isXpathVisible}[0]"=="PASS"
        ${xpathPrice}  set variable  ${isXpathVisible}[1]
    END
    [Return]  ${xpathPrice}


*** Tasks ***
This is task to automate ThePerfrumeShop
    ${productsTypes}  Create List  //a[@aria-label="Men's" and text()="Men's"]  //a[@aria-label="Women's" and text()="Women's"]
    tensorflow
    ${rowsLength}  count_rows_in_excel
    IF  ${rowsLength}<300
        ${isPageLoaded}  Open the Perfume Shop
        IF  ${isPageLoaded}
           FOR  ${categroy}  IN  @{productsTypes}
               click element when visible   ${categroy}
                ${isProductLoaded}  run keyword and return status    wait until page contains element    //a[@class="last"]  40s
                IF  ${isProductLoaded}
                    ${pagesCount}  Get Text  //a[@class="last"]
                    ${pagesCount}  Evaluate  int(${pagesCount})
                    FOR  ${page}  IN RANGE  1  ${pagesCount}+1
                        log to console    The page number is ${page}
                        wait until page contains element  //div[@class="product-grid__products-list"]//e2-product-tile[1]  30s
                        sleep    4s
                        ${postCount}  Get Element Count  //div[@class="product-grid__products-list"]//e2-product-tile
                        log to console     Element Count ${postCount}
                        FOR  ${post}  IN RANGE  1  ${postCount}+1
                            ${isPostVisible}  Does Page Contain Element  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]
                            IF  ${isPostVisible}
                                ${postPrice}    ${postName1}    ${postName2}    ${postURL}    Get Post Details  ${post}
                                IF  '${postPrice}'!=''
                                    ${price1}    ${price2}    extract_prices    ${postPrice}
                                    append_to_excel    ${postURL}    ${postName1} ${postName2}     ${price1}    ${price2}
                                END
                            END
                        END
                        Go To Next Page
                    END
                END
                remove_duplicates_in_url
           END
        END
    ELSE
        ${rowList}  read_excel_rows_as_list
        Open the Perfume Shop
        FOR  ${individualItem}  IN  @{rowList}
            sleep  2s
            goto  ${individualItem}[0]
            wait until page contains element  //div[@class="product-add-to-cart__price-container"]//span[@class="price__current"]  40s
            ${pricesRange}  Get Element Count  (//p[@class="product-carousel-variant__item-labels"])
            ${pricesRange}  Evaluate  ${pricesRange}/2
            ${price1}  Get Price With Exception  (//p[@class="product-carousel-variant__item-labels"])[1]//span[2]
            ${price2}  Get Price With Exception  (//p[@class="product-carousel-variant__item-labels"])[${pricesRange}]//span[2]
            ${price1}  extract_float  ${price1}
            ${price2}  extract_float  ${price2}
            log many    ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            ${priceDrop1}  ${priceDrop2}=  calculate_percentage_drop   ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            IF  ${priceDrop1}>0
                update_prices  ${individualItem}[0]  ${price1}  0
            END
            IF  ${priceDrop2}>0
                update_prices  ${individualItem}[0]  ${price1}  0
            END
            IF  ${priceDrop1}>20
                message_discord  Item: ${individualItem}[1] \n ${individualItem}[0] \n Old Price: ${individualItem}[2] \n New Price: ${price1} \n Price Change Notification: Price changed from ${individualItem}[2] to ${price1}
            END
            IF  ${priceDrop2}>0
                message_discord  Item: ${individualItem}[1] \n ${individualItem}[0] \n Old Price: ${individualItem}[3] \n New Price: ${price2} \n Price Change Notification: Price changed from ${individualItem}[3] to ${price2}
            END
        END
    END