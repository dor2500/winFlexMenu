# ==============================================================================
# WinFlexOS - AI Hub & Quick Bubbles Module
# ==============================================================================

# --- QUICK ACTION BUBBLE BUTTONS (Home Panel) ---
Set-Click "btnBubAI"  { Switch-Panel "pnlAIBots" }
Set-Click "btnBubCTT" { Switch-Panel "pnlEssentials" }
Set-Click "btnBubTV"  { Switch-Panel "pnlIsraelTV" }
Set-Click "btnBubUpd" { Switch-Panel "pnlUpdateMgr"; Refresh-UpdateHistory }
Set-Click "btnBubHw"  { Switch-Panel "pnlSysInfoTools" }
Set-Click "btnBubWin" { Switch-Panel "pnlWindowsTools" }
Set-Click "btnBubTwk" { Switch-Panel "pnlTweaks" }
Set-Click "btnBubCln" { Switch-Panel "pnlMaintenance" }
Set-Click "btnBubSec" { Switch-Panel "pnlSecurity" }
Set-Click "btnBubMus"  { Switch-Panel "pnlMusic" }
Set-Click "btnBubGame" { Switch-Panel "pnlGaming" }
Set-Click "btnBubBst"  { Switch-Panel "pnlBeast" }

Set-Click "btnAIInfo" {
    $info = "WinFlexOS AI Hub:`n`nAccess over 100 top AI models and services directly in your browser, categorized by workflow: LLMs, Coding, Image, Video, Audio, Writing, 3D, and Research."
    [System.Windows.MessageBox]::Show($info, "AI Hub Information", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
}

# --- NANOBANANA PROMPT STUDIO ---
Set-Click "btnNanoBanana" { Switch-Panel "pnlNanoBanana" }
Set-Click "btnBackToAI"   { Switch-Panel "pnlAIBots" }

$script:stylesHebrew = @("$(([char]0x05E8))$(([char]0x05D9))$(([char]0x05D0))$(([char]0x05DC))$(([char]0x05D9))$(([char]0x05E1))$(([char]0x05D8))$(([char]0x05D9))", "$(([char]0x05D0))$(([char]0x05E0))$(([char]0x05D9))$(([char]0x05DE))$(([char]0x05D4))", "$(([char]0x05E1))$(([char]0x05D9))$(([char]0x05D9))$(([char]0x05D1))$(([char]0x05E8))$(([char]0x05E4))$(([char]0x05D0))$(([char]0x05E0))$(([char]0x05E7))", "$(([char]0x05E6))$(([char]0x05D9))$(([char]0x05D5))$(([char]0x05E8)) $(([char]0x05E9))$(([char]0x05DE))$(([char]0x05DF))", "$(([char]0x05E4))$(([char]0x05E0))$(([char]0x05D8))$(([char]0x05D6))$(([char]0x05D9))$(([char]0x05D4))", "$(([char]0x05DE))$(([char]0x05D9))$(([char]0x05E0))$(([char]0x05D9))$(([char]0x05DE))$(([char]0x05DC))$(([char]0x05D9))$(([char]0x05E1))$(([char]0x05D8))$(([char]0x05D9))", "$(([char]0x05E4))$(([char]0x05D9))$(([char]0x05E7))$(([char]0x05E1))$(([char]0x05DC)) $(([char]0x05D0))$(([char]0x05E8))$(([char]0x05D8))", "$(([char]0x05E7))$(([char]0x05D5))$(([char]0x05DE))$(([char]0x05D9))$(([char]0x05E7))$(([char]0x05E1))", "$(([char]0x05E6))$(([char]0x05D1))$(([char]0x05E2))$(([char]0x05D9)) $(([char]0x05DE))$(([char]0x05D9))$(([char]0x05DD))", "$(([char]0x05E4))$(([char]0x05D5))$(([char]0x05E4)) $(([char]0x05D0))$(([char]0x05E8))$(([char]0x05D8))")
$script:stylesEnglish = @("Photorealistic", "Anime", "Cyberpunk", "Oil Painting", "Fantasy Art", "Minimalist", "Pixel Art", "Comic Book", "Watercolor", "Pop Art", "Claymation", "3D Octane Render", "Origami", "Street Graffiti", "Stained Glass")
$script:scenariosHebrew = @("$(([char]0x05E0))$(([char]0x05D5))$(([char]0x05E3)) $(([char]0x05E2))$(([char]0x05EA))$(([char]0x05D9))$(([char]0x05D3))$(([char]0x05E0))$(([char]0x05D9)) $(([char]0x05E9))$(([char]0x05DC)) $(([char]0x05E2))$(([char]0x05D9))$(([char]0x05E8)) $(([char]0x05D1))$(([char]0x05DC))$(([char]0x05D9))$(([char]0x05DC))$(([char]0x05D4))", "$(([char]0x05D0))$(([char]0x05D1))$(([char]0x05D9))$(([char]0x05E8)) $(([char]0x05E2))$(([char]0x05D5))$(([char]0x05DE))$(([char]0x05D3)) $(([char]0x05E2))$(([char]0x05DC)) $(([char]0x05E4))$(([char]0x05E1))$(([char]0x05D2))$(([char]0x05EA)) $(([char]0x05D4))$(([char]0x05E8)) $(([char]0x05DE))$(([char]0x05D5))$(([char]0x05E9))$(([char]0x05DC))$(([char]0x05D2))", "$(([char]0x05D7))$(([char]0x05EA))$(([char]0x05D5))$(([char]0x05DC)) $(([char]0x05D0))$(([char]0x05E1))$(([char]0x05D8))$(([char]0x05E8))$(([char]0x05D5))$(([char]0x05E0))$(([char]0x05D0))$(([char]0x05D5))$(([char]0x05D8)) $(([char]0x05DE))$(([char]0x05E8))$(([char]0x05D7))$(([char]0x05E3)) $(([char]0x05D1))$(([char]0x05D7))$(([char]0x05DC))$(([char]0x05DC))", "$(([char]0x05D9))$(([char]0x05E2))$(([char]0x05E8)) $(([char]0x05E7))$(([char]0x05E1))$(([char]0x05D5))$(([char]0x05DD)) $(([char]0x05E2))$(([char]0x05DD)) $(([char]0x05E4))$(([char]0x05D8))$(([char]0x05E8))$(([char]0x05D9))$(([char]0x05D5))$(([char]0x05EA)) $(([char]0x05D6))$(([char]0x05D5))$(([char]0x05D4))$(([char]0x05E8))$(([char]0x05D5))$(([char]0x05EA))", "$(([char]0x05E8))$(([char]0x05D5))$(([char]0x05D1))$(([char]0x05D5))$(([char]0x05D8)) $(([char]0x05E2))$(([char]0x05EA))$(([char]0x05D9))$(([char]0x05E7)) $(([char]0x05DE))$(([char]0x05D5))$(([char]0x05E7))$(([char]0x05E3)) $(([char]0x05E6))$(([char]0x05DE))$(([char]0x05D7))$(([char]0x05D9))$(([char]0x05D9))$(([char]0x05D4))")
$script:scenariosEnglish = @("Futuristic cyberpunk city at night", "A lone knight on a snowy mountain peak", "An astronaut cat floating in deep space", "A magical bioluminescent forest", "An ancient moss-covered robot", "A cozy robot coffee shop in Tokyo", "A giant sea turtle carrying a floating island", "A samurai facing a giant mechanical dragon")

function Send-To-Gemini ($prompt) {
    if ([string]::IsNullOrWhiteSpace($prompt)) { Show-Toast "Prompt cannot be empty" "warning"; return }
    try { [System.Windows.Forms.Clipboard]::SetText($prompt) } catch {}
    $enc = [System.Net.WebUtility]::UrlEncode($prompt)
    Show-Toast "Prompt copied to clipboard! Opening Gemini..." "info"
    Start-Process "https://gemini.google.com/app?prompt=$enc"
}

function Get-ActiveModifiers ($lang) {
    $m = ""
    $chk4K = Get-GuiElement "chk4K"
    $chkReal = Get-GuiElement "chkReal"
    $chkLight = Get-GuiElement "chkLight"
    $cmbRatio = Get-GuiElement "cmbRatio"

    if ($chk4K -and $chk4K.IsChecked) { $m += ", 8k resolution, ultra detailed" }
    if ($chkReal -and $chkReal.IsChecked) { $m += ", hyperrealistic, octane render" }
    if ($chkLight -and $chkLight.IsChecked) { $m += ", dramatic cinematic lighting" }
    if ($cmbRatio -and $cmbRatio.SelectedItem) {
        $ratio = $cmbRatio.SelectedItem.ToString()
        if ($ratio) { $m += ", aspect ratio $ratio" }
    }
    return $m
}

function Update-StyleList {
    $cmbStyles = Get-GuiElement "cmbStyles"
    if (-not $cmbStyles) { return }
    $cmbStyles.Items.Clear()
    $rbHe = Get-GuiElement "rbHebrew"
    if ($rbHe -and $rbHe.IsChecked) { $script:stylesHebrew | ForEach-Object { [void]$cmbStyles.Items.Add($_) } }
    else { $script:stylesEnglish | ForEach-Object { [void]$cmbStyles.Items.Add($_) } }
    $cmbStyles.SelectedIndex = 0
}
$rbHe = Get-GuiElement "rbHebrew"; if ($rbHe) { $rbHe.Add_Checked({ Update-StyleList }) }
$rbEn = Get-GuiElement "rbEnglish"; if ($rbEn) { $rbEn.Add_Checked({ Update-StyleList }) }
Update-StyleList

$cmbRatio = Get-GuiElement "cmbRatio"
if ($cmbRatio -and $cmbRatio.Items.Count -eq 0) {
    @("16:9", "1:1", "9:16", "4:3", "21:9") | ForEach-Object { [void]$cmbRatio.Items.Add($_) }
    $cmbRatio.SelectedIndex = 0
}

Set-Click "btnSpinRoulette" {
    $cmbStyles = Get-GuiElement "cmbStyles"
    $idx = if ($cmbStyles -and $cmbStyles.SelectedIndex -ge 0) { $cmbStyles.SelectedIndex } else { 0 }
    $rbHe = Get-GuiElement "rbHebrew"
    if ($rbHe -and $rbHe.IsChecked) {
        $sty = $script:stylesHebrew[$idx]
        $scn = $script:scenariosHebrew | Get-Random
        $mods = Get-ActiveModifiers "He"
        Send-To-Gemini "Generate an image of $scn, in $sty style$mods."
    } else {
        $sty = $script:stylesEnglish[$idx]
        $scn = $script:scenariosEnglish | Get-Random
        $mods = Get-ActiveModifiers "En"
        Send-To-Gemini "Generate an image of $scn, in $sty style$mods."
    }
}

Set-Click "btnGenHebrew" {
    $scn = $script:scenariosHebrew | Get-Random
    $sty = $script:stylesHebrew | Get-Random
    $mods = Get-ActiveModifiers "He"
    Send-To-Gemini "Create an image of $scn, in $sty style$mods."
}

Set-Click "btnGenEnglish" {
    $scn = $script:scenariosEnglish | Get-Random
    $sty = $script:stylesEnglish | Get-Random
    $mods = Get-ActiveModifiers "En"
    Send-To-Gemini "Generate an image of $scn, in $sty style$mods."
}

Set-Click "btnSurpriseMe" {
    $scn = $script:scenariosEnglish | Get-Random
    $sty = $script:stylesEnglish | Get-Random
    $mods = Get-ActiveModifiers "En"
    Send-To-Gemini "Generate an image of $scn, in $sty style$mods."
}

Set-Click "btnLaunchCustom" {
    $box = Get-GuiElement "txtCustomInput"
    $txt = if ($box) { $box.Text.Trim() } else { "" }
    if ($txt) {
        $mods = Get-ActiveModifiers "En"
        Send-To-Gemini "$txt$mods"
    } else {
        Show-Toast "Please enter a custom prompt first" "warning"
    }
}

Set-Click "btnCopyPrompt" {
    $box = Get-GuiElement "txtCustomInput"
    $txt = if ($box) { $box.Text.Trim() } else { "" }
    if ($txt) {
        $mods = Get-ActiveModifiers "En"
        try {
            [System.Windows.Forms.Clipboard]::SetText("$txt$mods")
            Show-Toast "Full prompt copied to clipboard!" "success"
        } catch {
            Show-Toast "Failed to copy prompt" "error"
        }
    } else {
        Show-Toast "Please enter a custom prompt first" "warning"
    }
}

# --- AI PLATFORM BUTTON HANDLERS ---
# Leading LLMs (Chat)
Set-Click "btnGPT"          { Start-Process "https://chatgpt.com" }
Set-Click "btnGemini"       { Start-Process "https://gemini.google.com" }
Set-Click "btnCopilot"      { Start-Process "https://copilot.microsoft.com" }
Set-Click "btnClaude"       { Start-Process "https://claude.ai" }
Set-Click "btnGrok"         { Start-Process "https://grok.com" }
Set-Click "btnMistral"      { Start-Process "https://chat.mistral.ai" }
Set-Click "btnLlama"        { Start-Process "https://www.meta.ai" }
Set-Click "btnPoe"          { Start-Process "https://poe.com" }
Set-Click "btnYouChat"      { Start-Process "https://you.com" }
Set-Click "btnCohere"       { Start-Process "https://coral.cohere.com" }
Set-Click "btnPI"           { Start-Process "https://pi.ai" }
Set-Click "btnJasper"       { Start-Process "https://jasper.ai" }
Set-Click "btnCharacter"    { Start-Process "https://character.ai" }
Set-Click "btnReplika"      { Start-Process "https://replika.com" }
Set-Click "btnHuggingChat"  { Start-Process "https://huggingface.co/chat" }
Set-Click "btnGroq"         { Start-Process "https://groq.com" }
Set-Click "btnOpenRouter"   { Start-Process "https://openrouter.ai" }
Set-Click "btnOllama"       { Start-Process "https://ollama.com" }

# Search & Research
Set-Click "btnPerplexity"   { Start-Process "https://perplexity.ai" }
Set-Click "btnPhind"        { Start-Process "https://phind.com" }
Set-Click "btnKagi"         { Start-Process "https://kagi.com" }
Set-Click "btnWolframAlpha" { Start-Process "https://wolframalpha.com" }
Set-Click "btnConsensus"    { Start-Process "https://consensus.app" }
Set-Click "btnElicit"       { Start-Process "https://elicit.com" }
Set-Click "btnScholar"      { Start-Process "https://semanticscholar.org" }
Set-Click "btnSciSpace"     { Start-Process "https://typeset.io" }
Set-Click "btnConnected"    { Start-Process "https://connectedpapers.com" }
Set-Click "btnScite"        { Start-Process "https://scite.ai" }

# Coding & Development
Set-Click "btnGitHubCopilot"{ Start-Process "https://github.com/features/copilot" }
Set-Click "btnCursor"       { Start-Process "https://cursor.com" }
Set-Click "btnReplit"       { Start-Process "https://replit.com" }
Set-Click "btnBlackbox"     { Start-Process "https://blackbox.ai" }
Set-Click "btnDeepSeek"     { Start-Process "https://chat.deepseek.com" }
Set-Click "btnCodeium"      { Start-Process "https://windsurf.com" }
Set-Click "btnTabnine"      { Start-Process "https://tabnine.com" }
Set-Click "btnAmazonQ"      { Start-Process "https://aws.amazon.com/q" }
Set-Click "btnV0"           { Start-Process "https://v0.dev" }
Set-Click "btnBolt"         { Start-Process "https://bolt.new" }
Set-Click "btnLovable"      { Start-Process "https://lovable.dev" }
Set-Click "btnHuggingFace"  { Start-Process "https://huggingface.co" }
Set-Click "btnCodeSandbox"  { Start-Process "https://codesandbox.io" }
Set-Click "btnStackBlitz"   { Start-Process "https://stackblitz.com" }
Set-Click "btnSourceGraph"  { Start-Process "https://sourcegraph.com/cody" }
Set-Click "btnAider"        { Start-Process "https://aider.chat" }

# Image Generation
Set-Click "btnMidjourney"   { Start-Process "https://midjourney.com" }
Set-Click "btnDALLE"        { Start-Process "https://openai.com/dall-e-3" }
Set-Click "btnBingImage"    { Start-Process "https://www.bing.com/images/create" }
Set-Click "btnLeonardo"     { Start-Process "https://leonardo.ai" }
Set-Click "btnIdeogram"     { Start-Process "https://ideogram.ai" }
Set-Click "btnFlux"         { Start-Process "https://blackforestlabs.ai" }
Set-Click "btnStableDiff"   { Start-Process "https://stability.ai" }
Set-Click "btnPlayground"   { Start-Process "https://playgroundai.com" }
Set-Click "btnNightCafe"    { Start-Process "https://nightcafe.studio" }
Set-Click "btnCivitai"      { Start-Process "https://civitai.com" }
Set-Click "btnSeaArt"       { Start-Process "https://seaart.ai" }
Set-Click "btnTensor"       { Start-Process "https://tensor.art" }
Set-Click "btnKrea"         { Start-Process "https://krea.ai" }
Set-Click "btnFirefly"      { Start-Process "https://firefly.adobe.com" }
Set-Click "btnCanvaAI"      { Start-Process "https://canva.com" }
Set-Click "btnRemoveBg"     { Start-Process "https://remove.bg" }
Set-Click "btnClipDrop"     { Start-Process "https://clipdrop.co" }
Set-Click "btnPhotoRoom"    { Start-Process "https://photoroom.com" }
Set-Click "btnMagnific"     { Start-Process "https://magnific.ai" }

# Video Generation
Set-Click "btnSora"         { Start-Process "https://sora.com" }
Set-Click "btnRunway"       { Start-Process "https://runwayml.com" }
Set-Click "btnPika"         { Start-Process "https://pika.art" }
Set-Click "btnLuma"         { Start-Process "https://lumalabs.ai/dream-machine" }
Set-Click "btnKling"        { Start-Process "https://klingai.com" }
Set-Click "btnVeo"          { Start-Process "https://deepmind.google/technologies/veo" }
Set-Click "btnMinimax"      { Start-Process "https://hailuoai.com" }
Set-Click "btnHeyGen"       { Start-Process "https://heygen.com" }
Set-Click "btnSynthesia"    { Start-Process "https://synthesia.io" }
Set-Click "btnDescript"     { Start-Process "https://descript.com" }
Set-Click "btnCapCut"       { Start-Process "https://capcut.com" }
Set-Click "btnPictory"      { Start-Process "https://pictory.ai" }
Set-Click "btnInVideo"      { Start-Process "https://invideo.io" }
Set-Click "btnFliki"        { Start-Process "https://fliki.ai" }
Set-Click "btnD_ID"         { Start-Process "https://d-id.com" }
Set-Click "btnWonder"       { Start-Process "https://wonderdynamics.com" }

# Audio & Music
Set-Click "btnSuno"         { Start-Process "https://suno.com" }
Set-Click "btnUdio"         { Start-Process "https://udio.com" }
Set-Click "btnElevenLabs"   { Start-Process "https://elevenlabs.io" }
Set-Click "btnMubert"       { Start-Process "https://mubert.com" }
Set-Click "btnSoundraw"     { Start-Process "https://soundraw.io" }
Set-Click "btnBoomy"        { Start-Process "https://boomy.com" }
Set-Click "btnAiva"         { Start-Process "https://aiva.ai" }
Set-Click "btnSplice"       { Start-Process "https://splice.com" }
Set-Click "btnLalal"        { Start-Process "https://lalal.ai" }
Set-Click "btnVoiceMod"     { Start-Process "https://voicemod.net" }
Set-Click "btnAdobePodcast" { Start-Process "https://podcast.adobe.com" }
Set-Click "btnSpeechify"    { Start-Process "https://speechify.com" }
Set-Click "btnWellSaid"     { Start-Process "https://wellsaidlabs.com" }
Set-Click "btnResemble"     { Start-Process "https://resemble.ai" }

# Writing & Content
Set-Click "btnGrammarly"    { Start-Process "https://grammarly.com" }
Set-Click "btnCopy_ai"      { Start-Process "https://copy.ai" }
Set-Click "btnWritesonic"   { Start-Process "https://writesonic.com" }
Set-Click "btnRytr"         { Start-Process "https://rytr.me" }
Set-Click "btnSudowrite"    { Start-Process "https://sudowrite.com" }
Set-Click "btnNovelAI"      { Start-Process "https://novelai.net" }
Set-Click "btnWordtune"     { Start-Process "https://wordtune.com" }
Set-Click "btnQuillBot"     { Start-Process "https://quillbot.com" }
Set-Click "btnHyperwrite"   { Start-Process "https://hyperwriteai.com" }
Set-Click "btnTextCortex"   { Start-Process "https://textcortex.com" }
Set-Click "btnINK"          { Start-Process "https://inkforall.com" }
Set-Click "btnFrase"        { Start-Process "https://frase.io" }

# Productivity & Business
Set-Click "btnNotebookLM"   { Start-Process "https://notebooklm.google.com" }
Set-Click "btnGamma"        { Start-Process "https://gamma.app" }
Set-Click "btnBeautiful"    { Start-Process "https://beautiful.ai" }
Set-Click "btnNotion"       { Start-Process "https://notion.so" }
Set-Click "btnClickUp"      { Start-Process "https://clickup.com" }
Set-Click "btnZapier"       { Start-Process "https://zapier.com" }
Set-Click "btnMake"         { Start-Process "https://make.com" }
Set-Click "btnOtter"        { Start-Process "https://otter.ai" }
Set-Click "btnFireflies"    { Start-Process "https://fireflies.ai" }
Set-Click "btnReclaim"      { Start-Process "https://reclaim.ai" }
Set-Click "btnMotion"       { Start-Process "https://usemotion.com" }
Set-Click "btnMem"          { Start-Process "https://mem.ai" }
Set-Click "btnCraft"        { Start-Process "https://craft.do" }
Set-Click "btnCoda"         { Start-Process "https://coda.io" }
Set-Click "btnAirtable"     { Start-Process "https://airtable.com" }

# 3D & Gaming
Set-Click "btnMeshy"        { Start-Process "https://meshy.ai" }
Set-Click "btnTripo"        { Start-Process "https://tripo3d.ai" }
Set-Click "btnLuma3D"       { Start-Process "https://lumalabs.ai/genie" }
Set-Click "btnKaedim"       { Start-Process "https://kaedim3d.com" }
Set-Click "btnSpline"       { Start-Process "https://spline.design" }
Set-Click "btnAlpha3D"      { Start-Process "https://alpha3d.io" }
Set-Click "btnScenario"     { Start-Process "https://scenario.com" }
Set-Click "btnPromethean"   { Start-Process "https://prometheanai.com" }
Set-Click "btnInworld"      { Start-Process "https://inworld.ai" }
Set-Click "btnConvai"       { Start-Process "https://convai.com" }
Set-Click "btnRobloxAI"     { Start-Process "https://create.roblox.com" }
Set-Click "btnPoint_E"      { Start-Process "https://github.com/openai/point-e" }
Set-Click "btnGetFloorplan" { Start-Process "https://getfloorplan.com" }
Set-Click "btnPlanner5D"    { Start-Process "https://planner5d.com" }

# Data & Analytics
Set-Click "btnJulius"       { Start-Process "https://julius.ai" }
Set-Click "btnRowsAI"       { Start-Process "https://rows.com" }
Set-Click "btnChannel"      { Start-Process "https://channel.ai" }
Set-Click "btnOsmo"         { Start-Process "https://osmo.ai" }
Set-Click "btnObviouslyAI"  { Start-Process "https://obviously.ai" }
Set-Click "btnAkkio"        { Start-Process "https://akkio.com" }
Set-Click "btnMindsDB"      { Start-Process "https://mindsdb.com" }
Set-Click "btnDataRobot"    { Start-Process "https://datarobot.com" }
Set-Click "btnH2O"          { Start-Process "https://h2o.ai" }
Set-Click "btnRapidMiner"   { Start-Process "https://rapidminer.com" }

# Education & Learning
Set-Click "btnKhanmigo"     { Start-Process "https://khanacademy.org/khanmigo" }
Set-Click "btnDuolingo"     { Start-Process "https://duolingo.com" }
Set-Click "btnQuizlet"      { Start-Process "https://quizlet.com" }
Set-Click "btnSocratic"     { Start-Process "https://socratic.org" }
Set-Click "btnPhotomath"    { Start-Process "https://photomath.com" }
Set-Click "btnChegg"        { Start-Process "https://chegg.com" }
Set-Click "btnCourseHero"   { Start-Process "https://coursehero.com" }
Set-Click "btnMagicSchool"  { Start-Process "https://magicschool.ai" }
Set-Click "btnQuestionwell" { Start-Process "https://questionwell.org" }

# Science & Research
Set-Click "btnAlphaFold"    { Start-Process "https://alphafold.ebi.ac.uk" }
Set-Click "btnResearchRabbit"{ Start-Process "https://researchrabbit.ai" }
Set-Click "btnIris"         { Start-Process "https://iris.ai" }
Set-Click "btnLitmaps"      { Start-Process "https://litmaps.com" }
Set-Click "btnInciteful"    { Start-Process "https://inciteful.xyz" }
Set-Click "btnOpenRead"     { Start-Process "https://openread.academy" }
Set-Click "btnChatPDF"      { Start-Process "https://chatpdf.com" }
Set-Click "btnPDFAI"        { Start-Process "https://pdf.ai" }
Set-Click "btnExplainpaper" { Start-Process "https://explainpaper.com" }

# Social & Marketing
Set-Click "btnBuffer"       { Start-Process "https://buffer.com" }
Set-Click "btnHootsuite"    { Start-Process "https://hootsuite.com" }
Set-Click "btnLater"        { Start-Process "https://later.com" }
Set-Click "btnOcoya"        { Start-Process "https://ocoya.com" }
Set-Click "btnPredis"       { Start-Process "https://predis.ai" }
Set-Click "btnFlick"        { Start-Process "https://flick.social" }
Set-Click "btnViralPost"    { Start-Process "https://viralpost.ai" }
Set-Click "btnTweetHunter"  { Start-Process "https://tweethunter.io" }
Set-Click "btnHypefury"     { Start-Process "https://hypefury.com" }
Set-Click "btnTypefully"    { Start-Process "https://typefully.com" }
Set-Click "btnTaplio"       { Start-Process "https://taplio.com" }
Set-Click "btnAuthority"    { Start-Process "https://authoredup.com" }
Set-Click "btnPhotofeeler"  { Start-Process "https://photofeeler.com" }
Set-Click "btnBrandMark"    { Start-Process "https://brandmark.io" }
Set-Click "btnLooka"        { Start-Process "https://looka.com" }
Set-Click "btnHatchful"     { Start-Process "https://hatchful.shopify.com" }

# Legal & Finance
Set-Click "btnHarvey"       { Start-Process "https://harvey.ai" }
Set-Click "btnLexMachina"   { Start-Process "https://lexmachina.com" }
Set-Click "btnDocuSign"     { Start-Process "https://docusign.com" }
Set-Click "btnIronclad"     { Start-Process "https://ironcladapp.com" }
Set-Click "btnSpellbook"    { Start-Process "https://spellbook.legal" }
Set-Click "btnKira"         { Start-Process "https://kirasystems.com" }
Set-Click "btnBloomberg"    { Start-Process "https://bloomberg.com/professional" }
Set-Click "btnAlphaSense"   { Start-Process "https://alpha-sense.com" }
Set-Click "btnKensho"       { Start-Process "https://kensho.com" }
Set-Click "btnAyasdi"       { Start-Process "https://ayasdi.com" }
Set-Click "btnZest"         { Start-Process "https://zest.ai" }

# E-commerce & Sales
Set-Click "btnShopify"      { Start-Process "https://shopify.com/magic" }
Set-Click "btnAmazonSeller" { Start-Process "https://sell.amazon.com" }
Set-Click "btnCratejoy"     { Start-Process "https://cratejoy.com" }
Set-Click "btnSalesforce"   { Start-Process "https://salesforce.com/einstein" }
Set-Click "btnGong"         { Start-Process "https://gong.io" }
Set-Click "btnChorus"       { Start-Process "https://chorus.ai" }
Set-Click "btnOutreach"     { Start-Process "https://outreach.io" }
Set-Click "btnApollo"       { Start-Process "https://apollo.io" }
Set-Click "btnSeamless"     { Start-Process "https://seamless.ai" }
Set-Click "btnLusha"        { Start-Process "https://lusha.com" }

# Customer & Support
Set-Click "btnIntercom"     { Start-Process "https://intercom.com" }
Set-Click "btnZendesk"      { Start-Process "https://zendesk.com" }
Set-Click "btnFreshdesk"    { Start-Process "https://freshdesk.com" }
Set-Click "btnDrift"        { Start-Process "https://drift.com" }
Set-Click "btnAda"          { Start-Process "https://ada.cx" }
Set-Click "btnChatbase"     { Start-Process "https://chatbase.co" }
Set-Click "btnBotpress"     { Start-Process "https://botpress.com" }
Set-Click "btnLandbot"      { Start-Process "https://landbot.io" }
Set-Click "btnTidio"        { Start-Process "https://tidio.com" }
Set-Click "btnCrisp"        { Start-Process "https://crisp.chat" }
Set-Click "btnManyChat"     { Start-Process "https://manychat.com" }
Set-Click "btnChatfuel"     { Start-Process "https://chatfuel.com" }

# Developer Tools
Set-Click "btnOpenAIAPI"    { Start-Process "https://platform.openai.com" }
Set-Click "btnAnthropic"    { Start-Process "https://console.anthropic.com" }
Set-Click "btnGoogleAI"     { Start-Process "https://aistudio.google.com" }
Set-Click "btnReplicate"    { Start-Process "https://replicate.com" }
Set-Click "btnModal"        { Start-Process "https://modal.com" }
Set-Click "btnRunpod"       { Start-Process "https://runpod.io" }
Set-Click "btnVastAI"       { Start-Process "https://vast.ai" }
Set-Click "btnLambdaLabs"   { Start-Process "https://lambdalabs.com" }
Set-Click "btnWeights"      { Start-Process "https://wandb.ai" }
Set-Click "btnMLflow"       { Start-Process "https://mlflow.org" }
Set-Click "btnDVC"          { Start-Process "https://dvc.org" }
Set-Click "btnLangChain"    { Start-Process "https://langchain.com" }
Set-Click "btnLlamaIndex"   { Start-Process "https://llamaindex.ai" }
Set-Click "btnPinecone"     { Start-Process "https://pinecone.io" }
Set-Click "btnWeaviate"     { Start-Process "https://weaviate.io" }

# Translation & Language
Set-Click "btnDeepL"          { Start-Process "https://deepl.com" }
Set-Click "btnGoogleTranslate"{ Start-Process "https://translate.google.com" }
Set-Click "btnPapago"         { Start-Process "https://papago.naver.com" }
Set-Click "btnReverso"        { Start-Process "https://reverso.net" }
Set-Click "btnLinguee"        { Start-Process "https://linguee.com" }
Set-Click "btnYandex"         { Start-Process "https://translate.yandex.com" }
Set-Click "btnBaidu"          { Start-Process "https://fanyi.baidu.com" }
Set-Click "btnRask"           { Start-Process "https://rask.ai" }
Set-Click "btnCaption"        { Start-Process "https://captions.ai" }
Set-Click "btnSubtitle"       { Start-Process "https://subtitle.ai" }

# Creative & Fun
Set-Click "btnLensa"          { Start-Process "https://lensa-ai.com" }
Set-Click "btnRemini"         { Start-Process "https://remini.ai" }
Set-Click "btnFaceApp"        { Start-Process "https://faceapp.com" }
Set-Click "btnReface"         { Start-Process "https://reface.ai" }
Set-Click "btnWombo"          { Start-Process "https://wombo.ai" }
Set-Click "btnMyHeritage"     { Start-Process "https://myheritage.com/deep-nostalgia" }
Set-Click "btnArtbreeder"     { Start-Process "https://artbreeder.com" }
Set-Click "btnDeepDream"      { Start-Process "https://deepdreamgenerator.com" }
Set-Click "btnNeuralStyle"    { Start-Process "https://neuralstyle.art" }

# New AI Platforms (V3.2)
$v32AiLinks = @{
    "btnQwen"           = "https://chat.qwen.ai"
    "btnKimi"           = "https://kimi.com"
    "btnLMStudio"       = "https://lmstudio.ai"
    "btnJanAI"          = "https://jan.ai"
    "btnFirebaseStudio" = "https://firebase.studio"
    "btnClaudeCode"     = "https://docs.anthropic.com/en/docs/claude-code"
    "btnDevin"          = "https://devin.ai"
    "btnRecraft"        = "https://recraft.ai"
    "btnN8N"            = "https://n8n.io"
    "btnNapkin"         = "https://napkin.ai"
    "btnFramerAI"       = "https://framer.com"
}
foreach ($kv in $v32AiLinks.GetEnumerator()) {
    $aiUrl = $kv.Value
    Set-Click $kv.Key { Start-Process $aiUrl }.GetNewClosure()
}
