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

function Draw-StringBlock {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [System.Drawing.Brush]$Brush,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $rect = New-Object System.Drawing.RectangleF($X, $Y, $Width, $Height)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Near
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $Graphics.DrawString($Text, $Font, $Brush, $rect, $format)
    $format.Dispose()
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $repoRoot "images\05-create-telegram-bot-helper-package.jpg"

$width = 1280
$height = 720

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

try {
    $rect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
    $bgTop = [System.Drawing.Color]::FromArgb(255, 9, 22, 34)
    $bgBottom = [System.Drawing.Color]::FromArgb(255, 6, 53, 78)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $bgTop, $bgBottom, 65
    $graphics.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    $glowA = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(42, 64, 214, 255))
    $glowB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 0, 191, 165))
    $graphics.FillEllipse($glowA, -120, -80, 470, 470)
    $graphics.FillEllipse($glowB, 900, 360, 320, 320)
    $graphics.FillEllipse($glowA, 1030, -40, 260, 260)
    $glowA.Dispose()
    $glowB.Dispose()

    $gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(24, 210, 241, 255), 1)
    for ($x = 0; $x -lt $width; $x += 48) {
        $graphics.DrawLine($gridPen, $x, 0, $x, $height)
    }
    for ($y = 0; $y -lt $height; $y += 48) {
        $graphics.DrawLine($gridPen, 0, $y, $width, $y)
    }
    $gridPen.Dispose()

    $heroPanelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(212, 8, 16, 28))
    $heroPanelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(86, 110, 225, 255), 1.6)
    $heroPath = New-RoundedRectPath -X 60 -Y 62 -Width 700 -Height 596 -Radius 30
    $graphics.FillPath($heroPanelBrush, $heroPath)
    $graphics.DrawPath($heroPanelPen, $heroPath)
    $heroPanelBrush.Dispose()
    $heroPanelPen.Dispose()
    $heroPath.Dispose()

    $codePanelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 12, 26, 40))
    $codePanelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(72, 123, 239, 255), 1.2)
    $codePath = New-RoundedRectPath -X 806 -Y 96 -Width 414 -Height 528 -Radius 28
    $graphics.FillPath($codePanelBrush, $codePath)
    $graphics.DrawPath($codePanelPen, $codePath)
    $codePanelBrush.Dispose()
    $codePanelPen.Dispose()
    $codePath.Dispose()

    $titleFont = New-Object System.Drawing.Font("Georgia", 36, [System.Drawing.FontStyle]::Bold)
    $subtitleFont = New-Object System.Drawing.Font("Segoe UI Semibold", 19, [System.Drawing.FontStyle]::Regular)
    $bodyFont = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Regular)
    $chipFont = New-Object System.Drawing.Font("Segoe UI Semibold", 14, [System.Drawing.FontStyle]::Regular)
    $monoFont = New-Object System.Drawing.Font("Consolas", 15, [System.Drawing.FontStyle]::Regular)
    $miniFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)

    $whiteBrush = [System.Drawing.Brushes]::White
    $cyanBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 110, 228, 255))
    $mutedBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 203, 221, 233))
    $greenBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 117, 238, 196))
    $goldBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 207, 110))

    $graphics.DrawString("Create a Telegram Bot", $titleFont, $whiteBrush, 98, 118)
    $graphics.DrawString("Helper Package", $titleFont, $cyanBrush, 98, 165)
    $graphics.DrawString("for Oracle PL/SQL", $titleFont, $whiteBrush, 98, 212)

    Draw-StringBlock -Graphics $graphics `
        -Text "A database-driven Telegram integration layer for token lookup, bot API calls, file sending, join handling, and operational logging." `
        -Font $subtitleFont `
        -Brush $mutedBrush `
        -X 100 -Y 286 -Width 606 -Height 96

    $chips = @(
        @{ X = 100; Y = 404; W = 158; H = 40; Text = "GET UPDATES"; Color = [System.Drawing.Color]::FromArgb(255, 34, 131, 166) },
        @{ X = 272; Y = 404; W = 160; H = 40; Text = "SEND MESSAGE"; Color = [System.Drawing.Color]::FromArgb(255, 28, 112, 202) },
        @{ X = 446; Y = 404; W = 138; H = 40; Text = "SEND FILE"; Color = [System.Drawing.Color]::FromArgb(255, 123, 89, 198) },
        @{ X = 100; Y = 456; W = 198; H = 40; Text = "JOIN REQUESTS"; Color = [System.Drawing.Color]::FromArgb(255, 0, 152, 122) },
        @{ X = 312; Y = 456; W = 162; H = 40; Text = "SYSTEM LOG"; Color = [System.Drawing.Color]::FromArgb(255, 171, 109, 34) }
    )

    foreach ($chip in $chips) {
        $chipBrush = New-Object System.Drawing.SolidBrush $chip.Color
        $chipPath = New-RoundedRectPath -X $chip.X -Y $chip.Y -Width $chip.W -Height $chip.H -Radius 18
        $graphics.FillPath($chipBrush, $chipPath)
        $graphics.DrawString($chip.Text, $chipFont, $whiteBrush, $chip.X + 16, $chip.Y + 10)
        $chipBrush.Dispose()
        $chipPath.Dispose()
    }

    $graphics.DrawString("Telegram Bot API from inside the database", $subtitleFont, $goldBrush, 100, 540)
    $graphics.DrawString("Wallet | Proxy | HTTPS | JSON | Multipart | Logging", $bodyFont, $mutedBrush, 100, 578)

    $circleBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 54, 179, 255))
    $graphics.FillEllipse($circleBrush, 960, 126, 108, 108)
    $circleBrush.Dispose()

    $paperBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $paperPoints = New-Object 'System.Drawing.Point[]' 7
    $paperPoints[0] = New-Object System.Drawing.Point(1004, 150)
    $paperPoints[1] = New-Object System.Drawing.Point(1038, 181)
    $paperPoints[2] = New-Object System.Drawing.Point(1017, 187)
    $paperPoints[3] = New-Object System.Drawing.Point(1019, 204)
    $paperPoints[4] = New-Object System.Drawing.Point(1005, 194)
    $paperPoints[5] = New-Object System.Drawing.Point(985, 208)
    $paperPoints[6] = New-Object System.Drawing.Point(994, 184)
    $graphics.FillPolygon($paperBrush, $paperPoints)
    $paperBrush.Dispose()

    $graphics.FillEllipse($greenBrush, 838, 124, 12, 12)
    $graphics.FillEllipse($goldBrush, 858, 124, 12, 12)
    $graphics.FillEllipse($cyanBrush, 878, 124, 12, 12)

    $codeLines = @(
        "PKG_TLG_BOT",
        "",
        "FUNC_TLG_GETME(...)",
        "FUNC_TLG_GETUPDATES(...)",
        "FUNC_TLG_SENDMESSAGE(...)",
        "FUNC_TLG_SENDDOCUMENT(...)",
        "FUNC_TLG_HANDLE_JOIN(...)",
        "FUNC_TLG_SEND_FILE(...)",
        "",
        "FUNC_TLG_SEND(...)",
        "FUNC_SYSTEM_LOG(...)",
        "",
        "LOG_TLG_SEND",
        "TLG_BOT_TOKEN"
    )

    $lineY = 180
    foreach ($line in $codeLines) {
        $brush = $mutedBrush
        if ($line -eq "PKG_TLG_BOT") { $brush = $whiteBrush }
        elseif ($line -match "^FUNC_") { $brush = $cyanBrush }
        elseif ($line -match "^LOG_|^TLG_") { $brush = $greenBrush }

        $graphics.DrawString($line, $monoFont, $brush, 844, $lineY)
        $lineY += 28
    }

    $graphics.DrawString("Oracle RAC 21c Lab | Telegram Bot Helper Package", $miniFont, $mutedBrush, 842, 586)

    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, 92L)
    $bitmap.Save($outputPath, $codec, $encoderParams)
    $encoderParams.Dispose()
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
}
