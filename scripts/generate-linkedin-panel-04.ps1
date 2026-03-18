Add-Type -AssemblyName System.Drawing

function New-RoundedRectPath {
    param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$Radius
    )

    $diameter = $Radius * 2
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $repoRoot "images\04-create-http-helper-package-linkedin.png"

$width = 1584
$height = 396

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

try {
    $rect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
    $bgTop = [System.Drawing.Color]::FromArgb(255, 10, 28, 55)
    $bgBottom = [System.Drawing.Color]::FromArgb(255, 3, 10, 27)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $bgTop, $bgBottom, 20
    $graphics.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    $accentBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(35, 64, 196, 255))
    $graphics.FillEllipse($accentBrush, -90, -120, 420, 420)
    $graphics.FillEllipse($accentBrush, 1220, 170, 320, 320)
    $accentBrush.Dispose()

    $panelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(210, 14, 22, 41))
    $panelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 130, 190, 255), 1.5)
    $panelPath = New-RoundedRectPath -X 46 -Y 44 -Width 900 -Height 308 -Radius 24
    $graphics.FillPath($panelBrush, $panelPath)
    $graphics.DrawPath($panelPen, $panelPath)
    $panelBrush.Dispose()
    $panelPen.Dispose()
    $panelPath.Dispose()

    $codeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 8, 14, 28))
    $codePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 88, 161, 255), 1.2)
    $codePath = New-RoundedRectPath -X 990 -Y 44 -Width 548 -Height 308 -Radius 24
    $graphics.FillPath($codeBrush, $codePath)
    $graphics.DrawPath($codePen, $codePath)
    $codeBrush.Dispose()
    $codePen.Dispose()
    $codePath.Dispose()

    $titleFont = New-Object System.Drawing.Font("Georgia", 30, [System.Drawing.FontStyle]::Bold)
    $subtitleFont = New-Object System.Drawing.Font("Segoe UI Semibold", 13, [System.Drawing.FontStyle]::Regular)
    $bodyFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
    $chipFont = New-Object System.Drawing.Font("Segoe UI Semibold", 12, [System.Drawing.FontStyle]::Regular)
    $monoFont = New-Object System.Drawing.Font("Consolas", 11.5, [System.Drawing.FontStyle]::Regular)
    $miniFont = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Regular)

    $whiteBrush = [System.Drawing.Brushes]::White
    $mutedBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 199, 212, 232))
    $cyanBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 112, 222, 255))
    $goldBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 198, 92))
    $greenBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 125, 240, 190))

    $graphics.DrawString("Create an HTTP Helper Package", $titleFont, $whiteBrush, 86, 82)
    $graphics.DrawString("for Oracle PL/SQL", $titleFont, $cyanBrush, 86, 122)
    $graphics.DrawString(
        "A reusable UTL_HTTP wrapper for HTTPS calls with wallet, proxy, timeout, retry, and multipart support.",
        $subtitleFont,
        $mutedBrush,
        (New-Object System.Drawing.RectangleF 88, 178, 800, 44)
    )

    $chips = @(
        @{ X = 88;  Y = 248; W = 164; Text = "TEXT -> CLOB"; Brush = [System.Drawing.Color]::FromArgb(255, 47, 102, 186) },
        @{ X = 264; Y = 248; W = 166; Text = "CLOB -> CLOB"; Brush = [System.Drawing.Color]::FromArgb(255, 38, 133, 138) },
        @{ X = 442; Y = 248; W = 160; Text = "BINARY -> BLOB"; Brush = [System.Drawing.Color]::FromArgb(255, 163, 111, 36) },
        @{ X = 614; Y = 248; W = 232; Text = "MULTIPART / FORM-DATA"; Brush = [System.Drawing.Color]::FromArgb(255, 120, 71, 160) }
    )

    foreach ($chip in $chips) {
        $chipBrush = New-Object System.Drawing.SolidBrush $chip.Brush
        $chipPath = New-RoundedRectPath -X $chip.X -Y $chip.Y -Width $chip.W -Height 38 -Radius 16
        $graphics.FillPath($chipBrush, $chipPath)
        $graphics.DrawString($chip.Text, $chipFont, $whiteBrush, $chip.X + 14, $chip.Y + 10)
        $chipBrush.Dispose()
        $chipPath.Dispose()
    }

    $graphics.DrawString("Centralized configuration", $subtitleFont, $goldBrush, 88, 306)
    $graphics.DrawString("Wallet  |  Proxy  |  Headers  |  Retry  |  Timeout  |  Error handling", $bodyFont, $mutedBrush, 88, 330)

    $graphics.FillEllipse($greenBrush, 1024, 74, 12, 12)
    $graphics.FillEllipse($goldBrush, 1044, 74, 12, 12)
    $graphics.FillEllipse($cyanBrush, 1064, 74, 12, 12)

    $codeText = @(
        "PKG_HELPER_REQUEST_HTTP",
        "",
        "FUNC_REQUEST_HTML(...)",
        "FUNC_REQUEST_HTML_CLOB(...)",
        "FUNC_REQUEST_BLOB_RAW(...)",
        "FUNC_REQUEST_MULTIPART(...)",
        "",
        "SET_WALLET();",
        "SET_TRANSFER_TIMEOUT();",
        "SET_PROXY();",
        "BEGIN_REQUEST();",
        "READ_RESPONSE();",
        "RETRY_ON_FAILURE();"
    )

    $lineY = 104
    foreach ($line in $codeText) {
        $brush = $mutedBrush
        if ($line -eq "PKG_HELPER_REQUEST_HTTP") { $brush = $whiteBrush }
        elseif ($line -match "^FUNC_REQUEST") { $brush = $cyanBrush }
        elseif ($line -match "RETRY_ON_FAILURE|SET_WALLET|SET_PROXY|READ_RESPONSE|BEGIN_REQUEST|SET_TRANSFER_TIMEOUT") { $brush = $greenBrush }

        $graphics.DrawString($line, $monoFont, $brush, 1030, $lineY)
        $lineY += 17
    }

    $graphics.DrawString("Oracle RAC 21c Lab  |  HTTP Helper Package", $miniFont, $mutedBrush, 1030, 336)

    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
}
