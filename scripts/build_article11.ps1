# build_article11.ps1 - Emergency Fund Crisis Article DOCX Generator
# Uses pure PowerShell with .NET for DOCX creation (no python-docx available)
# Requires: OpenXML format with wp:anchor images, 3.5x3.5in dimensions, UTF-8 no BOM

param(
    [string]$OutputDir = "C:\Users\Gordon\AppData\Roaming\TRAE SOLO CN\ModularData\ai-agent\work-mode-projects\6a1304760235e7485d4171a1\easy-personal-finance\scripts"
)

$ErrorActionPreference = "Stop"

# Article content - Emergency Fund Crisis
$ArticleTitle = "Why 53% of Americans Cannot Cover a $1,000 Emergency"
$ArticleDesc = "Discover the shocking statistics behind America's emergency savings crisis and learn practical steps to protect yourself from financial disaster."

# Image paths (from Matrix generation)
$Image1Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728783372-99cc50d3.png"
$Image2Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728808689-d5e6034d.png"
$Image3Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728809523-4ca7a806.png"
$Image4Path = "C:\Users\Gordon\.mavis\sessions\mvs_10400b8d094d4b34aae3ca36325033c0\workspace\matrix-media-1779728811691-5410e1c0.png"

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
$TMP = Join-Path $OutputDir "tmp_article11"
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

# Create word/media directory and copy images
New-Item -ItemType Directory -Path (Join-Path $TMP "word\media") -Force | Out-Null
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

# Build document.xml with full article content
$ImgBlocks = ""
for ($i = 0; $i -lt $ImgDims.Count; $i++) {
    $d = $ImgDims[$i]
    $scale = [Math]::Min($IMG_WIDTH_EMU / $d.Width, $IMG_HEIGHT_EMU / $d.Height)
    $w_emu = [long]($d.Width * $scale)
    $h_emu = [long]($d.Height * $scale)
    $ImgBlocks += [string](New-ImageBlock -Id ($i+1) -rid "rId$($i+3)" -Name "Image$($i+1)" -W_emu $w_emu -H_emu $h_emu -Desc "Article image $($i+1)")
}

$DocumentXml = '@<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    <w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>' + $ArticleTitle + '</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>' + $ArticleDesc + '</w:t></w:r></w:p>
    ' + $ImgBlocks[0] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Emergencies do not announce themselves. A transmission fails. A medical bill arrives. A job disappears. These are not edge cases — they are the financial equivalent of gravity for most American households. And the data is not reassuring: according to Bankrate''s 2026 Emergency Savings Report, only 47% of Americans have enough savings to cover a $1,000 emergency expense. That means the majority of working adults in the United States are one unexpected bill away from financial crisis. Understanding why this happens — and what you can do about it — is the first step toward genuine financial security.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The number is jarring in context. The same report found that 24% of Americans have zero emergency savings whatsoever. Another 30% have some savings, but not enough to cover three months of expenses. This places approximately 54% of the adult population in a precarious position: if an emergency of any kind struck tomorrow, they would be unable to handle it without borrowing, selling assets, or missing payments. The math becomes more alarming when you consider that financial advisors universally recommend keeping three to six months of expenses in accessible savings — a threshold that only 46% of Americans currently meet.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The Numbers Behind the Crisis</w:t></w:r></w:p>
    ' + $ImgBlocks[1] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The Federal Reserve''s Survey of Consumer Finances tells a similar story. While household incomes have nominally increased over the past decade, the actual purchasing power of those incomes has been eroded by inflation. Consumer prices are 26% higher than they were in December 2019, according to Bureau of Labor Statistics data. In practical terms, this means that a $1,000 emergency in 2026 costs the same in real terms as an $800 emergency did in 2019. Meanwhile, the share of income that workers can realistically save has compressed for millions of households. Bankrate''s survey found that 54% of Americans are saving less for emergencies due to inflation and rising prices — the single largest barrier to building savings.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The generational picture adds nuance to these aggregate numbers. Gen Z adults (ages 18-26) have the highest rate of zero emergency savings at 34%, followed closely by millennials at 31%. Gen X sits at 27%, while baby boomers are the most likely to have established savings, with only 16% reporting zero emergency funds. The pattern is predictable: younger workers have had less time to accumulate savings and have faced more volatile employment conditions, particularly in the post-2020 economic environment.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Income plays an outsized role in determining who has savings and who does not. Among households earning over $100,000 annually, 27% were able to grow their emergency savings in 2025. For households earning under $50,000, that figure drops to just 11%. The correlation is not incidental — income growth is the single most powerful predictor of savings accumulation. Workers whose earnings have increased have been roughly four times more likely to increase their emergency savings than workers whose earnings have remained flat or declined.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Why This Matters More Than It Appears</w:t></w:r></w:p>
    ' + $ImgBlocks[2] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The emergency savings gap is not simply a matter of financial inconvenience. It has compounding consequences that ripple outward into every other dimension of financial life. When a household lacks emergency savings, any unexpected expense must be covered through debt — typically a credit card, personal loan, or borrowing from family. The interest costs on that debt add an ongoing expense burden that reduces the household''s ability to save going forward. This creates a self-reinforcing cycle: no savings means debt, debt means interest, interest means less income available to save, less savings means more debt when the next emergency strikes.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The psychological toll is equally significant. Bankrate''s survey found that 68% of Americans would be worried — 43% very worried — about covering their living expenses if they lost their primary income source tomorrow. This anxiety is not merely emotional; it affects decision-making. Workers who lack emergency savings are less likely to negotiate for better pay, more likely to stay in unsatisfying jobs due to fear of income interruption, and more likely to make suboptimal financial decisions under pressure.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">When workers do tap their emergency savings — and 37% of Americans did so in the past year — they typically withdraw between $1,000 and $2,500. A quarter of those who withdrew from savings in the past year used the funds for unplanned emergency expenses like medical bills or car repairs. Another 38% used savings to cover regular monthly bills like rent and utilities. Only 19% used emergency savings for non-essential purposes. The data is unambiguous: emergency savings exist primarily to absorb exactly the kind of unexpected costs that erode financial stability when they are not planned for.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The Math of Three Months</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Financial advisors generally recommend keeping three to six months of expenses in emergency savings, with three months as the minimum threshold for financial protection. Bankrate''s data shows that while 85% of Americans believe they would need at least three months of expenses in savings to feel financially comfortable, only 46% actually have that much. The gap between expectation and reality is significant, and it reflects a broader failure of financial literacy around emergency planning.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">Consider what three months of expenses actually means in concrete terms. For a household earning $60,000 per year — the approximate median household income in the United States — three months of expenses amounts to roughly $15,000. That figure includes housing costs, utilities, food, transportation, insurance, and minimum debt payments. Three months of savings is not a luxury; it is a buffer between normal financial operations and the kind of forced borrowing that derails long-term wealth building.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The good news is that three months of emergency savings is an achievable goal for most working households, even those with modest incomes. The barrier is not income level — it is behavior and prioritization. Automatic transfers from checking to a dedicated savings account remove the decision from day-to-day willpower and make savings a fixed expense rather than an afterthought. Even a $200 per month contribution reaches $2,400 in one year and $7,200 in three years — a meaningful threshold for most households.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Building Your Emergency Fund: The Practical Steps</w:t></w:r></w:p>
    ' + $ImgBlocks[3] + '
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The first step is to establish a savings account that is separate from your daily checking and is not connected to a debit card. The physical separation reduces the psychological accessibility of the funds and makes it less likely that small, non-emergency expenses will gradually erode the balance. Online high-yield savings accounts currently offer rates around 4-5% APY — far superior to the 0.01% APY offered by most traditional checking accounts.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The second step is to automate. Set up a recurring transfer from your primary checking account to your emergency fund on the same day your paycheck arrives. This creates what behavioral economists call a "commitment device" — the savings happen before you have the opportunity to spend the money on discretionary items. Start with an amount that is comfortable, even if it is small, and increase it by 10-20% whenever you receive a raise or windfall.</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The third step is to resist the temptation to invest your emergency fund in higher-return assets. The purpose of an emergency fund is liquidity, not growth. A balanced index fund lost 34% of its value during the COVID-19 crash of early 2020. If your emergency fund had been invested and you lost your job in March 2020, you would have been forced to liquidate assets at a significant loss at exactly the moment you needed them most. Cash or high-yield savings is the correct vehicle for emergency reserves.</w:t></w:r></w:p>
    <w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="120"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>The One Thing to Remember</w:t></w:r></w:p>
    <w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r><w:t xml:space="preserve">The $1,000 emergency threshold is not arbitrary. It represents the approximate cost of the most common financial emergencies — car repairs, medical bills, appliance replacements — that strike working households without warning. Only 47% of Americans can currently absorb that threshold without borrowing. That means if you can build and maintain $1,000 in emergency savings, you have already outperformed more than half of your country on this dimension. From there, the goal is to grow that balance to cover three months of your actual expenses.</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="240" w:after="0"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t> An emergency fund is not about fear. It is about freedom.</w:t></w:r></w:p>
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>'

[System.IO.File]::WriteAllText((Join-Path $TMP "word\document.xml"), $DocumentXml, $encNoBom)

# Create ZIP (use .zip extension first, then rename to .docx)
$ZipPath = Join-Path $OutputDir "Article-11-Emergency-Fund-Crisis.zip"
$OutputPath = Join-Path $OutputDir "Article-11-Emergency-Fund-Crisis.docx"
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
Compress-Archive -Path "$TMP\*" -DestinationPath $ZipPath -CompressionLevel Optimal
Move-Item $ZipPath $OutputPath -Force

# Cleanup
Remove-Item $TMP -Recurse -Force

Write-Host "SUCCESS: Created $OutputPath" -ForegroundColor Green
Write-Host "Article: $ArticleTitle"
Write-Host "Images: $($ImageFiles.Count) embedded"