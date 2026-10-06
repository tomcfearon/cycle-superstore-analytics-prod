param(
    [string]$FocusKey,
    [int]$FocusDepth = 1
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

$refreshArgs = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', 'data_platform/warehouse_lineage/refresh_lineage.ps1'
)
if (-not [string]::IsNullOrWhiteSpace($FocusKey)) {
    $refreshArgs += '-FocusKey'
    $refreshArgs += $FocusKey
    $refreshArgs += '-FocusDepth'
    $refreshArgs += [string]$FocusDepth
}

& powershell @refreshArgs

$dotCmd = Get-Command dot -ErrorAction SilentlyContinue
if (-not $dotCmd) {
    $dotCandidates = @(
        "C:\Program Files\Graphviz\bin\dot.exe",
        "C:\Program Files (x86)\Graphviz\bin\dot.exe"
    )
    foreach ($candidate in $dotCandidates) {
        if (Test-Path $candidate) {
            $dotCmd = [pscustomobject]@{ Source = $candidate }
            break
        }
    }
}

if (-not $dotCmd) {
    throw "Graphviz 'dot' was not found. Install Graphviz or add dot.exe to PATH."
}

& $dotCmd.Source -Tsvg "data_platform/warehouse_lineage/lineage_diagram.dot" -o "data_platform/warehouse_lineage/lineage_diagram.svg"

& $dotCmd.Source -Tpng "data_platform/warehouse_lineage/lineage_diagram.dot" -o "data_platform/warehouse_lineage/lineage_diagram.png"

if (-not [string]::IsNullOrWhiteSpace($FocusKey) -and (Test-Path "data_platform/warehouse_lineage/lineage_focus.dot")) {
    & $dotCmd.Source -Tsvg "data_platform/warehouse_lineage/lineage_focus.dot" -o "data_platform/warehouse_lineage/lineage_focus.svg"
    & $dotCmd.Source -Tpng "data_platform/warehouse_lineage/lineage_focus.dot" -o "data_platform/warehouse_lineage/lineage_focus.png"
}

$svgPath = Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_diagram.svg"
Write-Host "Rendered $svgPath"

$pngPath = Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_diagram.png"
Write-Host "Rendered $pngPath"

if (-not [string]::IsNullOrWhiteSpace($FocusKey) -and (Test-Path (Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_focus.svg"))) {
    $focusSvgPath = Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_focus.svg"
    Write-Host "Rendered $focusSvgPath"

    $focusPngPath = Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_focus.png"
    Write-Host "Rendered $focusPngPath"
}

$panHtmlPath = Join-Path $repoRoot "data_platform/warehouse_lineage/lineage_diagram_pan.html"

# Embed the SVG markup directly in the HTML (rather than <img>/<object> referencing the
# sibling file) so search can query and highlight node elements via the DOM. Referencing an
# external SVG from a file:// page blocks contentDocument access in Chromium browsers due to
# opaque per-file origins; inline embedding sidesteps that entirely.
$svgRaw = Get-Content -Path "data_platform/warehouse_lineage/lineage_diagram.svg" -Raw -Encoding UTF8
$svgMarkup = [regex]::Replace($svgRaw, '(?s)^.*?(?=<svg)', '')

$panHtmlHead = @'
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Cycle Superstore Data Warehouse Lineage</title>
    <style>
        html, body {
            margin: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: #f3f6f8;
            color: #18222c;
            font-family: Aptos, "Segoe UI Variable", "Segoe UI", sans-serif;
        }
        body {
            display: flex;
            flex-direction: column;
        }
        #toolbar {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            box-sizing: border-box;
            flex: 0 0 auto;
            min-height: 68px;
            padding: 12px 20px;
            background: #ffffff;
            border-bottom: 1px solid #d7e0e6;
            box-shadow: 0 3px 14px rgba(24, 34, 44, 0.08);
        }
        #zoomHint {
            color: #526675;
            font-size: 13px;
            white-space: nowrap;
        }
        #searchRow {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 0 1 520px;
            min-width: 0;
        }
        #searchInput {
            flex: 1 1 auto;
            min-width: 180px;
            height: 38px;
            box-sizing: border-box;
            background: #f8fafb;
            color: #18222c;
            border: 1px solid #c8d3da;
            border-radius: 5px;
            padding: 0 11px;
            font: inherit;
            font-size: 14px;
        }
        #searchInput:focus {
            outline: 2px solid #0f766e;
            outline-offset: 2px;
        }
        #toolbar button {
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            flex: 0 0 auto;
            background: #ffffff;
            color: #294354;
            border: 1px solid #c8d3da;
            border-radius: 5px;
            font: inherit;
            font-size: 17px;
            cursor: pointer;
        }
        #toolbar button:hover {
            background: #edf4f5;
            border-color: #8ba9ab;
        }
        #searchCount {
            min-width: 52px;
            text-align: center;
            color: #526675;
            font-size: 13px;
            font-variant-numeric: tabular-nums;
        }
        #viewport {
            position: relative;
            overflow: hidden;
            width: 100%;
            height: auto;
            min-height: 0;
            flex: 1 1 auto;
            cursor: grab;
            user-select: none;
            touch-action: none;
        }
        #viewport.dragging {
            cursor: grabbing;
        }
        #content {
            position: absolute;
            top: 0;
            left: 0;
            transform-origin: 0 0;
            will-change: transform;
            display: inline-block;
        }
        #content svg {
            display: block;
            pointer-events: none;
        }
        @media (max-width: 700px) {
            #toolbar {
                align-items: stretch;
                flex-direction: column;
                gap: 10px;
                padding: 12px 14px;
            }
            #searchRow {
                flex: 1 1 auto;
                width: 100%;
            }
            #searchInput {
                min-width: 0;
            }
        }
    </style>
</head>
<body>
    <div id="toolbar">
        <span id="zoomHint">Ctrl + scroll: faster zoom</span>
        <div id="searchRow">
            <input id="searchInput" type="text" placeholder="Search warehouse objects" aria-label="Search warehouse objects" autocomplete="off" />
            <button id="searchPrev" title="Previous match" aria-label="Previous match">&#8593;</button>
            <button id="searchNext" title="Next match" aria-label="Next match">&#8595;</button>
            <span id="searchCount">0 / 0</span>
            <button id="searchClear" title="Clear search" aria-label="Clear search">&#215;</button>
        </div>
    </div>
    <div id="viewport">
        <div id="content">
'@

$panHtmlTail = @'
        </div>
    </div>
    <script>
        const viewport = document.getElementById('viewport');
        const content = document.getElementById('content');
        const svgEl = content.querySelector('svg');

        let scale = 1;
        let x = 20;
        let y = 20;
        let dragging = false;
        let startX = 0;
        let startY = 0;

        function applyTransform() {
            content.style.transform = 'translate(' + x + 'px, ' + y + 'px) scale(' + scale + ')';
        }

        function getSourceSize() {
            const viewBox = svgEl.viewBox && svgEl.viewBox.baseVal;
            const widthAttribute = svgEl.getAttribute('width');
            const heightAttribute = svgEl.getAttribute('height');
            const width = parseFloat(widthAttribute);
            const height = parseFloat(heightAttribute);
            const pointToPixel = 96 / 72;
            if (Number.isFinite(width) && Number.isFinite(height)) {
                return {
                    width: width * (/pt\s*$/i.test(widthAttribute) ? pointToPixel : 1),
                    height: height * (/pt\s*$/i.test(heightAttribute) ? pointToPixel : 1)
                };
            }
            if (viewBox && viewBox.width && viewBox.height) {
                return { width: viewBox.width, height: viewBox.height };
            }
            return { width: width || 1600, height: height || 1200 };
        }

        function resetView() {
            const sourceSize = getSourceSize();
            const viewportWidth = viewport.clientWidth || window.innerWidth;
            const horizontalPadding = 140;

            scale = Math.max(0.15, Math.min(0.6, (viewportWidth - horizontalPadding) / sourceSize.width));
            x = Math.round((viewportWidth - (sourceSize.width * scale)) / 2);
            y = 16;
            applyTransform();
        }

        viewport.addEventListener('pointerdown', (e) => {
            if (e.button !== 0) return;
            dragging = true;
            viewport.classList.add('dragging');
            viewport.setPointerCapture(e.pointerId);
            startX = e.clientX - x;
            startY = e.clientY - y;
        });

        viewport.addEventListener('pointermove', (e) => {
            if (!dragging) return;
            x = e.clientX - startX;
            y = e.clientY - startY;
            applyTransform();
        });

        function stopDragging() {
            dragging = false;
            viewport.classList.remove('dragging');
        }

        viewport.addEventListener('pointerup', stopDragging);
        viewport.addEventListener('pointercancel', stopDragging);

        viewport.addEventListener('wheel', (e) => {
            e.preventDefault();
            const rect = viewport.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const mouseY = e.clientY - rect.top;

            const oldScale = scale;
            const deltaMultiplier = e.deltaMode === 1 ? 16 : (e.deltaMode === 2 ? viewport.clientHeight : 1);
            const normalizedDelta = Math.max(-120, Math.min(120, e.deltaY * deltaMultiplier));
            const zoomSensitivity = e.ctrlKey ? 0.003 : 0.0005;
            const zoomFactor = Math.exp(-normalizedDelta * zoomSensitivity);
            scale = Math.max(0.25, Math.min(6, scale * zoomFactor));

            x = mouseX - ((mouseX - x) * (scale / oldScale));
            y = mouseY - ((mouseY - y) * (scale / oldScale));
            applyTransform();
        }, { passive: false });

        viewport.addEventListener('dblclick', resetView);
        window.addEventListener('resize', resetView);

        // --- Search ---
        const searchInput = document.getElementById('searchInput');
        const searchPrevBtn = document.getElementById('searchPrev');
        const searchNextBtn = document.getElementById('searchNext');
        const searchCountEl = document.getElementById('searchCount');
        const searchClearBtn = document.getElementById('searchClear');

        let allNodeEntries = [];
        let currentMatches = [];
        let currentMatchIndex = -1;
        let highlightedShapes = [];

        function getShapeElement(nodeGroup) {
            return nodeGroup.querySelector('polygon') || nodeGroup.querySelector('path') || nodeGroup.querySelector('ellipse');
        }

        function collectNodeEntries() {
            const groups = svgEl.querySelectorAll('g.node');
            const entries = [];
            groups.forEach(function (g) {
                const titleEl = g.querySelector('title');
                const key = titleEl ? titleEl.textContent : '';
                let label = '';
                g.querySelectorAll('text').forEach(function (t) { label += ' ' + t.textContent; });
                entries.push({ el: g, searchText: (key + ' ' + label).toLowerCase() });
            });
            return entries;
        }

        function clearHighlights() {
            highlightedShapes.forEach(function (shape) {
                shape.style.stroke = '';
                shape.style.strokeWidth = '';
                shape.style.filter = '';
            });
            highlightedShapes = [];
        }

        function applyHighlights() {
            clearHighlights();
            currentMatches.forEach(function (entry, idx) {
                const shape = getShapeElement(entry.el);
                if (!shape) return;
                const isActive = idx === currentMatchIndex;
                shape.style.stroke = isActive ? '#ef4444' : '#facc15';
                shape.style.strokeWidth = isActive ? '5' : '3';
                shape.style.filter = 'drop-shadow(0 0 6px ' + (isActive ? 'rgba(239,68,68,0.9)' : 'rgba(250,204,21,0.7)') + ')';
                highlightedShapes.push(shape);
            });
        }

        function updateCount() {
            searchCountEl.textContent = currentMatches.length === 0
                ? '0 / 0'
                : (currentMatchIndex + 1) + ' / ' + currentMatches.length;
        }

        function centerOnMatch() {
            if (currentMatchIndex < 0 || currentMatchIndex >= currentMatches.length) return;
            const el = currentMatches[currentMatchIndex].el;
            const bbox = el.getBBox();
            const ctm = el.getCTM();
            const pt = svgEl.createSVGPoint();
            pt.x = bbox.x + bbox.width / 2;
            pt.y = bbox.y + bbox.height / 2;
            const transformed = pt.matrixTransform(ctm);
            const rect = viewport.getBoundingClientRect();
            scale = Math.max(scale, 1);
            x = (rect.width / 2) - (transformed.x * scale);
            y = (rect.height / 2) - (transformed.y * scale);
            applyTransform();
        }

        function runSearch() {
            const query = searchInput.value.trim().toLowerCase();
            if (!query) {
                currentMatches = [];
                currentMatchIndex = -1;
                clearHighlights();
                updateCount();
                return;
            }
            currentMatches = allNodeEntries.filter(function (entry) {
                return entry.searchText.indexOf(query) !== -1;
            });
            currentMatchIndex = currentMatches.length > 0 ? 0 : -1;
            applyHighlights();
            updateCount();
            centerOnMatch();
        }

        function goToMatch(delta) {
            if (currentMatches.length === 0) return;
            currentMatchIndex = (currentMatchIndex + delta + currentMatches.length) % currentMatches.length;
            applyHighlights();
            updateCount();
            centerOnMatch();
        }

        searchInput.addEventListener('input', runSearch);
        searchInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                goToMatch(e.shiftKey ? -1 : 1);
            } else if (e.key === 'Escape') {
                searchInput.value = '';
                runSearch();
                searchInput.blur();
            }
        });
        searchPrevBtn.addEventListener('click', function () { goToMatch(-1); });
        searchNextBtn.addEventListener('click', function () { goToMatch(1); });
        searchClearBtn.addEventListener('click', function () {
            searchInput.value = '';
            runSearch();
            searchInput.focus();
        });

        allNodeEntries = collectNodeEntries();
        updateCount();
        resetView();
    </script>
</body>
</html>
'@

$panHtml = $panHtmlHead + $svgMarkup + $panHtmlTail
Set-Content -Path $panHtmlPath -Value $panHtml -Encoding utf8
Write-Host "Rendered $panHtmlPath"

# Open drag-enabled web viewer by default.
Start-Process $panHtmlPath
