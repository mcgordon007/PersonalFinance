# build_article12.ps1 - Credit Card Minimum Payment Trap Article DOCX Generator
# Uses pure PowerShell with .NET for DOCX creation (no python-docx available)
# Requires: OpenXML format with wp:anchor images, 3.5x3.5in dimensions, UTF-8 no BOM

param(
    [string]$OutputDir = "C:\Users\Gordon\AppData\Roaming\TRAE SOLO CN\ModularData\ai-agent\work-mode-projects\6a1304760235e7485d4171a1\easy-personal-finance\scripts"
)

$ErrorActionPreference = "Stop"

# Article content - Credit Card Minimum Payment Trap
$ArticleTitle = "The Credit Card Minimum Payment Trap That Costs $5,000 Extra"
$ArticleDesc = "Understand how minimum credit card payments trap millions of Americans in decades of debt — and learn the strategy that eliminates your balance years faster."

# Image paths (from Matrix generation)
$Image1Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728813461-9c752985.png"
$Image2Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728839411-6036d376.png"
$Image3Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728839591-dc98b51a.png"
$Image4Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728840335-2b0793c3.png"

# EMU constants: 914400 EMU per inch at 96 DPI
$EMU_PER_INCH = 914400
$IMG_WIDTH_EMU = [long](3.5 * $EMU_PER_INCH)  # 3200400
$IMG_HEIGHT_EMU = [long](3.5 * $EMU_PER_INCH) # 3200400

function Get-ImageDimensions {
    param([string]$Path)
    $b = [System.IO.File]::ReadAllBytes($Path)
    $w = 1024; $h = 1024
    # JPEG SOF0 marker: FF C0
    for ($i = 4; $i -lt $b.Length - 9; $i++) {
        if ($b[$i] -eq 0xFF -and $b[$i+1] -eq 0xC0) {
            $h = $b[$i+5] * 256 + $b[$i+6]
            $w = $b[$i+7] * 256 + $b[$i+8]
            break
        }
    }
    return @{Width=$w; Height=$h}
}

function New-ImageBlock {
    param($Id, $rid, $Name, $W_emu, $H_emu, $Desc)
    '<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:after="0"/></w:pPr><w:r><w:drawing>
<wp:anchor xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
           xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
           xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
           xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
           simplePos="0" relativeHeight="251658240" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1">
  <wp:simplePos x="0" y="0"/>
  <wp:positionH relativeFrom="margin"><wp:align>center</wp:align></wp:positionH>
  <wp:positionV relativeFrom="paragraph"><wp:posOffset>0</wp:posOffset></wp:positionV>
  <wp:extent cx="'+$W_emu+'" cy="'+$H_emu+'"/>
  <wp:effectExtent l="0" t="0" r="0" b="0"/>
  <wp:wrapTopAndBottom/>
  <wp:docPr id="'+$Id+'" name="'+$Name+'" descr="'+$Desc+'"/>
  <wp:cNvGraphicFramePr><a:graphicFrameLocks/></wp:cNvGraphicFramePr>
  <a:graphic>
    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
      <pic:pic>
        <pic:nvPicPr><pic:cNvPr id="'+$Id+'" name="'+$Name+'"/><pic:cNvPicPr/></pic:nvPicPr>
        <pic:blipFill><a:blip r:embed="'+$rid+'"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
        <pic:spPr>
          <a:xfrm><a:off x="0" y="0"/><a:ext cx="'+$W_emu+'" cy="'+$H_emu+'"/></a:xfrm>
          <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
        </pic:spPr>
      </pic:pic>
    </a:graphicData>
  </a:graphic>
</wp:anchor></w:drawing></w:r></w:p>'
}

# Create temp directory and all subdirectories
$TMP = Join-Path $OutputDir "tmp_article12"
if (Test-Path $TMP) { Remove-Item $TMP -Recurse -Force }
New-Item -ItemType Directory -Path $TMP -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TMP "_rels") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TMP "word\_rels") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TMP "word\media") -Force | Out-Null

# Copy and prepare images
$ImageFiles = @($Image1Path, $Image2Path, $Image3Path, $Image4Path)
$ImageNames = @("image1.jpeg", "image2.jpeg", "image3.jpeg", "image4.jpeg")
$ImgDims = @()

for ($i = 0; $i -lt $ImageFiles.Count; $i++) {
    if (Test-Path $ImageFiles[$i]) {
        $dims = Get-ImageDimensions -Path $ImageFiles[$i]
        $ImgDims += $dims
        Copy-Item $ImageFiles[$i] (Join-Path $TMP $ImageNames[$i]) -Force
        Write-Host "Processed image $($i+1): $($dims.Width)x$($dims.Height)"
    }
}

# Copy images to word/media
for ($i = 0; $i -lt $ImageFiles.Count; $i++) {
    if (Test-Path $ImageFiles[$i]) {
        Copy-Item $ImageFiles[$i] ((Join-Path $TMP "word\media") + "\$($ImageNames[$i])") -Force
    }
}

# [Content_Types].xml
$ContentTypes = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/media/image1.jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/media/image2.jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/media/image3.jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/media/image4.jpeg" ContentType="image/jpeg"/>
</Types>'
$encNoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $TMP "[Content_Types].xml"), $ContentTypes, $encNoBom)

# _rels/.rels
$Rels = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>'
[System.IO.File]::WriteAllText((Join-Path $TMP "_rels") + "\.rels", $Rels, $encNoBom)

# word/_rels/document.xml.rels
$DocRels = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
'
for ($i = 1; $i -le $ImageFiles.Count; $i++) {
    $DocRels += "  <Relationship Id=""rId$($i+2)"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"" Target=""media/image$($i).jpeg""/>`n"
}
$DocRels += '</Relationships>'
[System.IO.File]::WriteAllText((Join-Path $TMP "word\_rels") + "\document.xml.rels", $DocRels, $encNoBom)

# word/settings.xml
$Settings = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:defaultTabStop w:val="720"/>
</w:settings>'
[System.IO.File]::WriteAllText((Join-Path $TMP "word\settings.xml"), $Settings, $encNoBom)

# word/styles.xml
$Styles = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
  </w:style>
  <w:style w:type="character" w:styleId="DefaultParagraphFont" w:default="1">
    <w:name w:val="Default Paragraph Font"/>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="Heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="Heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="200" w:after="100"/></w:pPr>
  </w:style>
</w:styles>'
[System.IO.File]::WriteAllText((Join-Path $TMP "word\styles.xml"), $Styles, $encNoBom)

# Build image blocks
$ImgBlocks = @()
for ($i = 0; $i -lt $ImgDims.Count; $i++) {
    $d = $ImgDims[$i]
    $scale = [Math]::Min($IMG_WIDTH_EMU / $d.Width, $IMG_HEIGHT_EMU / $d.Height)
    $w_emu = [long]($d.Width * $scale)
    $h_emu = [long]($d.Height * $scale)
    $ImgBlocks += [string](New-ImageBlock -Id ($i+1) -rid "rId$($i+3)" -Name "Image$($i+1)" -W_emu $w_emu -H_emu $h_emu -Desc "Article image $($i+1)")
}

# Build document.xml with full article content
$DocumentXml = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    <w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>' + $ArticleTitle + '</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>' + $ArticleDesc + '</w:t></w:r></w:p>
    ' + $ImgBlocks[0] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Credit cards do not advertise their most expensive feature. Walk into any bank, scroll through any issuer''s website, and you will find splashy rewards, sign-up bonuses, and travel perks. What you will not see prominently displayed is the minimum payment trap — the mechanism by which carrying a balance costs you exponentially more than the sticker price of anything you purchased. Understanding how minimum payments work, why they are designed to keep you in debt, and how to escape them is not optional financial knowledge. It is essential.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The average credit card interest rate in the United States reached 24.37% in January 2025, according to Investopedia''s monthly tracking of over 300 popular card offers. This is not a temporary spike — it reflects a structural feature of the credit card industry. Major credit card companies charged consumers over $105 billion in interest in 2022 alone, according to the Consumer Financial Protection Bureau. That number has grown every year as total credit card debt across the United States surpassed $1.17 trillion as of September 2024. For households carrying balances month to month, the interest is not an incidental cost — it is the product itself.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>How Minimum Payments Keep You Indebted</w:t></w:r></w:p>
    ' + $ImgBlocks[1] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Credit card minimum payments are calculated as a small percentage of your outstanding balance — typically between 1% and 3% of the total, with a floor of $20 to $35 depending on the issuer. The calculation is not designed to pay off your balance. It is designed to keep you paying for as long as possible while the issuer collects the maximum amount of interest.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Here is the math in action. Suppose you carry a $5,000 balance on a card with a 24% annual interest rate and make only the minimum payment of 2% of the balance. Your minimum payment in the first month would be $100 (2% of $5,000). Of that $100, approximately $100 goes to interest — the 2% monthly rate on an annual 24% balance — and $0 goes to reducing the principal. You paid $100 and owe $5,000. You are exactly where you started, except you are now one month closer to the next billing cycle.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">In practice, the minimum payment calculation does reduce the principal slightly, but at a glacially slow pace. A $5,000 balance at 24% APR with a 2% minimum payment takes approximately 15 to 17 years to pay off, according to multiple debt amortization calculators. The total interest paid over that period exceeds $4,000 — meaning you pay nearly as much in interest as the original balance. This is not an edge case or a worst-case scenario. This is what happens when a typical American household makes regular minimum payments on a typical credit card balance.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The CFPB''s analysis found that excess APR margins — the difference between the average credit card APR and the prime rate — have reached all-time highs. In 2023, this excess margin may have cost the average cardholder over $250 in added interest beyond what would have been charged at historical average margins. The system is designed to extract maximum value from the fact that most cardholders will not pay off their balances in full each month.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The Snowball Effect of Carrying Balances</w:t></w:r></w:p>
    ' + $ImgBlocks[2] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">When you carry a credit card balance, interest is calculated daily and capitalized monthly. This means that each month''s interest becomes part of the balance that generates next month''s interest. The effect is compounding — the same mechanism that makes investment returns accelerate over time works in reverse when you are paying interest on borrowed money.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Imagine a household that charges $2,000 in holiday gifts in December on a card with 24% APR and pays only the minimum of 2% each month. By the following December, a full year later, that household will have paid approximately $240 in interest and reduced the principal by only a few hundred dollars. The holiday gifts that seemed like a good value at the time of purchase have effectively cost 20-30% more due to the interest charges accumulating over the year.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The problem compounds when multiple cards carry balances. Households with credit card debt across multiple accounts face multiple compounding interest cycles simultaneously. The combined interest burden accelerates the rate at which disposable income is consumed by debt service, leaving less available for savings, investment, or quality-of-life spending.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The Income-Debt Trap</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The Federal Reserve''s data shows that total U.S. credit card debt grew by over 15% year-over-year as of late 2023 — the largest annual increase in more than two decades. This reflects a structural shift in household spending patterns. As inflation has eroded real purchasing power, more households have turned to credit cards to bridge the gap between income and expenses. The New York Federal Reserve''s Household Credit and Debt Report documented a sharp increase in credit card balances, with researchers noting that "the real test will be whether these borrowers can continue to service their credit card debt."</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The answer for many households is increasingly no. Credit card delinquency rates have risen as balances have grown. More households are making minimum payments not as a deliberate strategy but as a survival mechanism — paying the minimum because there is nothing left after covering basic expenses. When minimum payments become a permanent feature of a household''s financial life rather than a temporary bridge, the trap is fully engaged.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Breaking Free: The Accelerated Payment Strategy</w:t></w:r></w:p>
    ' + $ImgBlocks[3] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The good news is that escaping the minimum payment trap requires only one change in behavior — paying more than the minimum every single month. The impact is nonlinear. Paying double the minimum payment on a $5,000 balance at 24% APR reduces the payoff timeline from approximately 17 years to approximately 3 years. The total interest paid drops from over $4,000 to under $800. The difference is not modest. It is transformative.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The strategy works because every dollar you pay above the minimum goes directly to reducing the principal. Reducing the principal reduces the balance that generates interest. Reducing the interest burden means more of next month''s payment goes to principal. The cycle accelerates in your favor rather than against you.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The practical implementation requires two steps. First, calculate exactly how much you are paying in interest each month by multiplying your current balance by your APR divided by 12. Second, add enough to your monthly payment to cover that interest amount plus a fixed additional principal reduction. If your interest charge this month is $100 and you pay $200, you have reduced your principal by $100. Next month, your interest charge will be calculated on a $100 lower balance, which means your accelerated principal reduction continues to grow.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The Balance Transfer Option</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">For households with strong credit scores, a 0% balance transfer offer can dramatically accelerate debt payoff by pausing interest accumulation. Most balance transfer cards offer 0% APR for 12 to 21 months, with a 3-5% transfer fee. A household that transfers a $5,000 balance to a 0% card and continues paying the same amount they were paying while that balance accrued 24% interest will eliminate the debt in approximately 18 months instead of 17 years — and save thousands in interest.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The discipline required is to avoid adding new charges to the transferred balance during the 0% period. The trap within the balance transfer opportunity is using the cleared credit limit as a invitation to charge more. Successful balance transfer payoff requires treating the cleared credit line as unavailable, not as freed capacity.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The One Thing to Remember</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Minimum credit card payments are not designed to help you. They are designed to keep you in debt for as long as possible so that the issuer collects the maximum amount of interest. A $5,000 balance paid at minimum only takes 17 years to eliminate and costs $4,000 in interest. The same balance paid at double the minimum takes 3 years and costs $800 in interest. The difference between these two outcomes is a single behavioral change: paying more than the minimum, every month, without exception.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The credit card minimum payment trap is not a personal failing. It is a feature of a system that is optimized to extract value from your financial situation. Opting out of that system requires awareness and discipline — but the math is entirely on your side once you commit to accelerating payments.</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="240" w:after="0"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t> Your debt does not define you. Your strategy for eliminating it does.</w:t></w:r></w:p>
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>'

[System.IO.File]::WriteAllText((Join-Path $TMP "word\document.xml"), $DocumentXml, $encNoBom)

# Create ZIP (use .zip extension first, then rename to .docx)
$ZipPath = Join-Path $OutputDir "Article-12-Minimum-Payment-Trap.zip"
$OutputPath = Join-Path $OutputDir "Article-12-Minimum-Payment-Trap.docx"
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
Compress-Archive -Path "$TMP\*" -DestinationPath $ZipPath -CompressionLevel Optimal
Move-Item $ZipPath $OutputPath -Force

# Cleanup
Remove-Item $TMP -Recurse -Force

Write-Host "SUCCESS: Created $OutputPath" -ForegroundColor Green
Write-Host "Article: $ArticleTitle"
Write-Host "Images: $($ImageFiles.Count) embedded"