*** Settings ***
Documentation   Certifaction II.
Library           RPA.Browser
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Tables
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault


*** Keywords ***
Collect order location
    Add heading       Select order.csv file location
    Add text          Only for Dialog demo.     size=Small
    Add text          Please Input https://robotsparebinindustries.com/orders.csv    size=Small
    Add text input   Inputlink
    ${result}=    Run dialog        title=Order.csv file location    height=400    width=480
    [Return]    ${result.Inputlink}

*** Keywords ***
Open the intranet website
   Log     Opening the robot ordering website
   ${secrt}=    RPA.Robocorp.Vault.Get Secret    site
   Log     ${secrt}[url_location]
   Open Available Browser  ${secrt}[url_location]

*** Keywords ***
Give consent.
     Click Button    OK

*** Keywords ***
Download The CSV File
    [Arguments]     ${order_path}
    Convert To String    ${order_path}
    Download   ${order_path}  overwrite=True


*** Keywords ***
Fill and submit form for one person
    [Arguments]     ${order}
    Select From List By Value    head   ${order}[Head]
    Select Radio Button  body  ${order}[Body]
    Input Text    class:form-control   ${order}[Legs]
    Input Text    address    ${order}[Address]

*** Keywords ***
Clicking the order button
    Click Button    order
    Wait Until Element Is Visible    receipt

*** Keywords ***
Take screenshot
    [Arguments]     ${order}
    Wait Until Element Is Visible    preview    
    Click Button    preview
    Wait Until Element Is Visible    id:robot-preview-image
    Sleep    3
    Screenshot    filename=Preview.png   locator=robot-preview-image  

*** Keywords ***
Save reciept
    [Arguments]     ${order}
    #Set Local Variable    ${OrderNumber}    ${order}[Order number]
    ${receipt_html}=   Get Element Attribute    receipt    outerHTML
    #Set Local Variable    ${path_receipt}       ${CURDIR}${/}receipts${/}OrderNumber_${OrderNumber}.pdf
    Html To Pdf    ${receipt_html}    ${CURDIR}${/}receipts${/}OrderNumber_${order}[Order number].pdf
    Add screenshot to pdf   ${order}

*** Keywords ***
Fill the form using the data from the CSV file
    ${orders}=  Read table from CSV   orders.csv   header=True
    FOR    ${order}    IN    @{orders}
        Fill and submit form for one person  ${order}
        Take screenshot    ${order}
        Wait Until Keyword Succeeds    10x    2s     Clicking the order button
        Save reciept    ${order}
        Wait Until Element Is Visible  id:order-another
        Click Button  id:order-another
        Give consent.
    END


*** Keywords ***
Add screenshot to pdf
        [Arguments]     ${order}
        Open Pdf   ${CURDIR}${/}receipts${/}OrderNumber_${order}[Order number].pdf
        Add Watermark Image To Pdf    Preview.png    ${CURDIR}${/}receipts${/}OrderNumber_${order}[Order number].pdf
        Close Pdf   ${CURDIR}${/}receipts${/}OrderNumber_${order}[Order number].pdf


*** Keywords ***
Creating Zip Archive
    Archive Folder With Zip    ${CURDIR}${/}receipts    ${CURDIR}${/}output${/}receipts.zip

*** Tasks ***
Robort for ordering a robort
    Open the intranet website
    ${order_path} =  Collect order location
    Download The CSV File  ${order_path}
    Give consent.
    Fill the form using the data from the CSV file
    Creating Zip Archive


