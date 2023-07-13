*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.Excel.Application
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             DateTime
Library             RPA.Archive


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Log    Starting....Orders robots from RobotSpareBin Industries Inc.
    Logged in into Application
    Download CSV file
    [Teardown]    Create the zip folder


*** Keywords ***
Logged in into Application
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${CSV_dataTable} =    Read table from CSV    ${OUTPUT_DIR}${/}orders.csv
    # ${CSV_dataTable} =    Read Worksheet As Table    ${OUTPUT_DIR}${/}orders.csv
    FOR    ${csv_record}    IN    @{CSV_dataTable}
        Log    ${csv_record}
        Entering details in Application    ${csv_record}
    END

Entering details in Application
    [Arguments]    ${csv_record}
    Wait Until Page Contains Element    CSS:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
    Click Button When Visible    CSS:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
    Select From List By Index    head    ${csv_record}[Head]
    Select Radio Button    body    ${csv_record}[Body]
    # Select From List By Index    xpath://*[@id="1689240503646"]    ${csv_record}[Legs]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${csv_record}[Legs]
    Input Text    id:address    ${csv_record}[Address]
    Click Button    id:preview
    Wait Until Element Is Visible    css:#robot-preview-image > img:nth-child(1)

    ${snap} =    Screenshot    css:#robot-preview-image > img:nth-child(1)    ${OUTPUT_DIR}${/}snap.jpg
    Click Button    id:order
    Getting receipt details    ${snap}

Getting receipt details
    [Arguments]    ${snap}
    Wait Until Page Contains Element    id:receipt
    ${order_id} =    Get Text    //*[@id="receipt"]/p[1]
    ${receipt_details} =    Get Element Attribute    id:receipt    outerHTML

    Html To Pdf    ${receipt_details}    ${OUTPUT_DIR}${/}${order_id}receipt.Pdf
    Log    ${receipt_details}
    Set Local Variable    ${filename}    ${OUTPUT_DIR}${/}${order_id}receipt.Pdf
    ${snap} =    Screenshot    css:#robot-preview-image    ${OUTPUT_DIR}${/}${order_id}snap.jpg
    ${listdata} =    Create List    ${snap}    ${filename}
    Add Files To Pdf    ${listdata}    ${filename}
    Click Button    id:order-another

Create the zip folder
    ${currentdate} =    Get Current Date
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}zipfolder.zip
