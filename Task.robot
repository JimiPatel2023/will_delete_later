*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser
Library    ExcelManipulation.py
Library    DiscordAPIRequest.py
Resource   HelperKeywords.robot

*** Variables ***
${websiteLink}    https://www.theperfumeshop.com/
${isPageLoaded}  False

*** Keywords ***
Open the Perfume Shop
    FOR  ${attempt}  IN RANGE    0  3
        open browser    about:blank    chrome
        goto    ${websiteLink}
        ${isPageLoaded}  run keyword and return status    wait until page contains element    //a[@aria-label="Women's" and text()="Women's"]  40s
        IF  ${isPageLoaded}
            Execute Javascript    window.open("about:blank")
            ${windows}  Get window Handles
            Switch Window    ${windows}[0]
            Close the Cookies
            ${isPageLoaded}  set variable  True
            Exit for loop
        END
    END
    sleep  2s
    Close Updates Notification
    [Return]  ${isPageLoaded}

Go To Next Page
    ${currPage}  Get Text  //a[@class="page disabled current" and @tabindex="-1"]
    ${currPage}  Strip String  ${currPage}
    Close Updates Notification
    sleep  1s
    ${testNext}  run keyword and return status  wait until keyword succeeds  5x  2s  click element when visible    //div[@class="product-grid__pagination cx-pagination"]//a[@class="next"]
    IF  not ${testNext}
        Close the Cookies
        ${test3}  run keyword and return status  wait until keyword succeeds  10x  2s  click element when visible    //div[@class="product-grid__pagination cx-pagination"]//a[@class="next"]
        ${isContinue}  set variable  ${True}
    ELSE
        sleep  3s
        ${isContinue}  run keyword and return status  click element when visible    //div[@class="product-grid__pagination cx-pagination"]//a[@class="next"]
    END
    Next Page Appearance Confirmation  ${currPage}
    [Return]  ${isContinue}

Get Post Details
    [Arguments]     ${post}
    ${postName1}  set variable  ${EMPTY}
    ${postName2}  set variable  ${EMPTY}
    ${postURL}  set variable  ${EMPTY}
    ${price1}  set variable  ${EMPTY}
    ${price2}  set variable  ${EMPTY}
    ${postURL}  run keyword and ignore error    wait until keyword succeeds   3x   2s   Get Element Attribute  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]//a[@class="product-list-item__link"]  href
    IF  "${postURL}[0]"=="PASS"
        ${postURL}  set variable  ${postURL}[1]
        ${windows}  Get window Handles
        Switch Window    ${windows}[1]
        goto      ${postURL}
        ${price1}  ${price2}  Get Products Pricing
        ${postName1}  run keyword and ignore error    wait until keyword succeeds   3x   2s   Get Text  //a[@class="product-details-brand-link__text-link"]//span
        ${postName2}  run keyword and ignore error    wait until keyword succeeds   3x   2s   Get Text  //span[@class="product-add-to-cart__details-range-name"]
        IF  "${postName1}[0]"=="PASS"
            ${postName1}  set variable  ${postName1}[1]
        END
        IF  "${postName2}[0]"=="PASS"
            ${postName2}  set variable  ${postName2}[1]
        END
        ${windows}  Get window Handles
        Switch Window    ${windows}[0]
    END
    log many    ${price1}  ${price2}    ${postName1}   ${postName2}    ${postURL}
    [Return]    ${price1}  ${price2}    ${postName1}   ${postName2}    ${postURL}

Update Prices for better rates
    ${rowList}  read_excel_rows_as_list
        Open the Perfume Shop
        FOR  ${individualItem}  IN  @{rowList}
            sleep  2s
            goto  ${individualItem}[0]
            wait until page contains element  //div[@class="product-add-to-cart__price-container"]//span[@class="price__current"]  40s
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
            log many    ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            ${priceDrop1}  ${priceDrop2}=  calculate_percentage_drop   ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            IF  ${priceDrop1}>0
                update_prices  ${individualItem}[0]  ${price1}  0
            END
            IF  ${priceDrop2}>0
                update_prices  ${individualItem}[0]  0  ${price2}
            END
        END

*** Tasks ***
This is task to automate ThePerfrumeShop
    ${productsTypes}  Create List  //a[@aria-label="Men's" and text()="Men's"]  //a[@aria-label="Women's" and text()="Women's"]
    tensorflow
    ${rowsLength}  count_rows_in_excel
    IF  ${rowsLength}<10
        ${isPageLoaded}  Open the Perfume Shop
        IF  ${isPageLoaded}
           FOR  ${categroy}  IN  @{productsTypes}
               click element when visible   ${categroy}
                ${isProductLoaded}  run keyword and return status    wait until page contains element    //a[@class="last"]  40s
                IF  ${isProductLoaded}
                    ${pagesCount}  Get Text  //a[@class="last"]
                    ${pagesCount}  Evaluate  int(${pagesCount})
                    FOR  ${page}  IN RANGE  1  100  #${pagesCount}+1
                        log to console    The page number is ${page}
                        wait until page contains element  //div[@class="product-grid__products-list"]//e2-product-tile[1]  30s
                        sleep    4s
                        ${postCount}  Get Element Count  //div[@class="product-grid__products-list"]//e2-product-tile
                        log to console     Element Count ${postCount}
                        FOR  ${post}  IN RANGE  1  ${postCount}+1
                            ${isPostVisible}  Does Page Contain Element  //div[@class="product-grid__products-list"]//e2-product-tile[${post}]
                            IF  ${isPostVisible}
                                ${price1}    ${price2}    ${postName1}    ${postName2}    ${postURL}    Get Post Details  ${post}
                                IF  '${price1}'!='' and '${price2}'!=''
#                                    ${price1}    ${price2}    extract_prices    ${postPrice}
                                    ${postName}  set variable  ${postName1} ${postName2}
                                    append_to_excel    ${postURL}    ${postName}     ${price1}    ${price2}
                                END
                            END
                        END
                        ${isContinue}  Go To Next Page
                        IF  not ${isContinue}
                            exit for loop
                        END
                    END
                END
                remove_duplicates_in_url
           END
        END
        close browser
#        Update Prices for better rates
    ELSE
        ${rowList}  read_excel_rows_as_list
        Open the Perfume Shop
        FOR  ${individualItem}  IN  @{rowList}
            sleep  2s
            goto  ${individualItem}[0]
            wait until page contains element  //div[@class="product-add-to-cart__price-container"]//span[@class="price__current"]  40s
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
            log many    ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            ${priceDrop1}  ${priceDrop2}=  calculate_percentage_drop   ${individualItem}[2]    ${individualItem}[3]   ${price1}    ${price2}
            IF  ${priceDrop1}>0
                update_prices  ${individualItem}[0]  ${price1}  0
            END
            IF  ${priceDrop2}>0
                update_prices  ${individualItem}[0]  0  ${price2}
            END
            IF  ${priceDrop1}>20
                message_discord  Item: ${individualItem}[1] \n ${individualItem}[0] \n Old Price: ${individualItem}[2] \n New Price: ${price1} \n Price Change Notification: Price changed from ${individualItem}[2] to ${price1}. \n The percentage of price drop is ${priceDrop1}.
            END
            IF  ${priceDrop2}>0
                message_discord  Item: ${individualItem}[1] \n ${individualItem}[0] \n Old Price: ${individualItem}[3] \n New Price: ${price2} \n Price Change Notification: Price changed from ${individualItem}[3] to ${price2}. \n The percentage of price drop is ${priceDrop2}.
            END

        END
    END